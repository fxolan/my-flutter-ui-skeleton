import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  String bgImage = '';

  Color primaryColor = Colors.blue;
  Color accentColor = Colors.purple;
  Color backgroundColor = Colors.black;
  double _fontSize = 32;
  late AnimationController _controller;
  bool _isRGBEnabled = false;
  bool _autoSave = false;
  bool useImageBG = false;
  //bool _isFabVisible = true;
  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('rgb', _isRGBEnabled);
    prefs.setBool('autoSave', _autoSave);
    prefs.setDouble('fontSize', _fontSize);
    prefs.setInt('primaryColor', primaryColor.value);
    prefs.setInt('accentColor', accentColor.value);
    prefs.setInt('backgroundColor', backgroundColor.value);
    prefs.setString('bgImage', bgImage);
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isRGBEnabled = prefs.getBool('rgb') ?? _isRGBEnabled;
      _autoSave = prefs.getBool('autoSave') ?? _autoSave;
      _fontSize = prefs.getDouble('fontSize') ?? _fontSize;
      primaryColor = Color(prefs.getInt('primaryColor') ?? primaryColor.value);
      accentColor = Color(prefs.getInt('primaryColor') ?? accentColor.value);
      backgroundColor =
          Color(prefs.getInt('primaryColor') ?? backgroundColor.value);
      bgImage = prefs.getString('bgImage') ?? bgImage;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    if (_isRGBEnabled) _controller.repeat();
  }

  @override
  void dispose() {
    if (_autoSave) _saveSettings();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UI',
      theme: ThemeData(
          scaffoldBackgroundColor: backgroundColor,
          listTileTheme: ListTileThemeData(
              textColor: primaryColor,
              titleTextStyle: TextStyle(color: primaryColor)),
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: primaryColor,
                displayColor: primaryColor,
              ),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: getMaterialColor(primaryColor),
            accentColor: accentColor,
          )),
      home: Scaffold(
          /*key: _scaffoldKey,
          floatingActionButton: _isFabVisible
              ? FloatingActionButton(
                  foregroundColor: primaryColor,
                  backgroundColor: Colors.transparent,
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 2, color: primaryColor),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(Icons.settings),
                )
              : null,*/
          appBar: AppBar(),
          drawer: Drawer(
              backgroundColor: Colors.transparent.withOpacity(0.4),
              child: ListView(children: [
                getDrawerOption('UI Settings', () {
                  uiSettingsDialog();
                }),
                getDrawerOption(
                    'Toggle Auto Save (currently ' + _autoSave.toString() + ')',
                    () {
                  setState(() {
                    _autoSave = !_autoSave;
                  });
                }),
                getDrawerOption('Save Settings', () {
                  _saveSettings();
                }),
              ])),
          body: Stack(children: [
            if (useImageBG)
              Image.file(
                File(bgImage),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _isRGBEnabled
                      ? getRGBtext('RGB Text')
                      : Text(
                          'Normal Text',
                          style: TextStyle(fontSize: _fontSize),
                        ),
                ],
              ),
            ),
          ])),
    );
  }

  void uiSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('UI Settings'),
          backgroundColor: Colors.transparent.withOpacity(0.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _buildToggleSwitch(
                'RGB Effect',
                _isRGBEnabled,
                () => setState(() {
                  _isRGBEnabled = !_isRGBEnabled;
                }),
              ),
              _buildToggleSwitch(
                'Auto Save',
                _autoSave,
                () => setState(() {
                  _autoSave = !_autoSave;
                }),
              ),
              _buildToggleSwitch(
                'Use Image Background',
                useImageBG,
                () => setState(() {
                  useImageBG = !useImageBG;
                }),
              ),
              ListTile(
                title: Text(
                  'Font Size',
                                    style: TextStyle(color: primaryColor),

                ),
                trailing: TextButton(
                  onPressed: _adjustFontSize,
                  child: Text(_fontSize.toString()),
                ),
              ),
              ListTile(
                title: Text(
                  'Primary Color',
                  style: TextStyle(color: primaryColor),
                ),
                trailing: TextButton(
                  onPressed: () {
                    _openColorPicker(primaryColor, (Color newColor) {
                      setState(() {
                        primaryColor = newColor;
                      });
                    });
                  },
                  child: const Text('Select'),
                ),
              ),
              ListTile(
                title: Text(
                  useImageBG ? 'Background Image' : 'Background Color',
                  style: TextStyle(color: primaryColor),
                ),
                trailing: TextButton(
                  onPressed: useImageBG
                      ? _pickBackgroundImage
                      : () {
                          _openColorPicker(backgroundColor, (Color newColor) {
                            setState(() {
                              backgroundColor = newColor;
                            });
                          });
                        },
                  child: const Text('Select'),
                ),
              ),
              ListTile(
                title: Text(
                  'Accent Color',
                  style: TextStyle(color: primaryColor),
                ),
                trailing: TextButton(
                  onPressed: () {
                    _openColorPicker(accentColor, (Color newColor) {
                      setState(() {
                        accentColor = newColor;
                      });
                    });
                  },
                  child: const Text('Select'),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildToggleSwitch(String label, bool value, Function() onTap) {
    return StatefulBuilder(builder: (context, setState) {
      return ListTile(
        title: Text(
          label,
          style: TextStyle(color: primaryColor),
        ),
        trailing: Switch(
          value: value,
          onChanged: (bool newValue) {
            onTap();
            setState(() {
              value = newValue;
            });
          },
        ),
      );
    });
  }

  AnimatedBuilder getRGBtext(String text) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Text(text,
            style: TextStyle(color: getRGB(), fontSize: _fontSize));
      },
    );
  }

  MaterialColor getMaterialColor(Color color) {
    final int red = color.red;
    final int green = color.green;
    final int blue = color.blue;
    final int alpha = color.alpha;

    final Map<int, Color> shades = {
      50: Color.fromARGB(alpha, red, green, blue),
      100: Color.fromARGB(alpha, red, green, blue),
      200: Color.fromARGB(alpha, red, green, blue),
      300: Color.fromARGB(alpha, red, green, blue),
      400: Color.fromARGB(alpha, red, green, blue),
      500: Color.fromARGB(alpha, red, green, blue),
      600: Color.fromARGB(alpha, red, green, blue),
      700: Color.fromARGB(alpha, red, green, blue),
      800: Color.fromARGB(alpha, red, green, blue),
      900: Color.fromARGB(alpha, red, green, blue),
    };

    return MaterialColor(color.value, shades);
  }

  void _openColorPicker(Color toSet, void Function(Color) setColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color selectedColor = toSet;
        return AlertDialog(
          title: const Text('Pick Custom Color'),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setColor(selectedColor);
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _adjustFontSize() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double oldFontSize = _fontSize;
        double selectedFontSize = _fontSize;
        double maxSliderValue = 512;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Adjust Font Size',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Current Font Size: $selectedFontSize',
                      style: TextStyle(
                        color: primaryColor,
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        inactiveTrackColor: Colors.grey,
                        trackShape: const RectangularSliderTrackShape(),
                        trackHeight: 4.0,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 12.0,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 28.0,
                        ),
                      ),
                      child: Slider.adaptive(
                        value: _fontSize,
                        min: 10,
                        max: maxSliderValue,
                        onChanged: (double value) {
                          setState(() {
                            _fontSize = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        _fontSize = oldFontSize;
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {});
    });
  }

  ListTile getDrawerOption(String text, VoidCallback toDoOnTap) {
    return ListTile(
      title: Text(
        text,
      ),
      onTap: () {
        toDoOnTap();
      },
    );
  }

  void _pickBackgroundImage() async {
    Navigator.pop(context);
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          bgImage = pickedImage.path;
        });
      }
    } catch (e) {}
  }

  Color getRGB() {
    int r = (sin(_controller.value * 2 * pi) * 127.5 + 127.5).toInt();
    int g =
        (sin(_controller.value * 2 * pi + 2 / 3 * pi) * 127.5 + 127.5).toInt();
    int b =
        (sin(_controller.value * 2 * pi + 4 / 3 * pi) * 127.5 + 127.5).toInt();
    return Color.fromARGB(255, r, g, b);
  }
}
