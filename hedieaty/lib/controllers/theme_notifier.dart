import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;
  String? _userId;

  bool get isDarkMode => _isDarkMode;

  Future<void> loadUserPreferences(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = userId;

    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult[0] == ConnectivityResult.none) {
        _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      } else {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (userDoc.exists && userDoc.data() != null) {
          var data = userDoc.data() as Map<String, dynamic>;
          _isDarkMode = data['preferences']?.contains('darkMode=true') ?? false;
          await prefs.setBool('isDarkMode', _isDarkMode);
        } else {
          _isDarkMode = prefs.getBool('isDarkMode') ?? false;
        }
      }
    } catch (e) {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    }

    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _saveThemePreference();
  }

  Future<void> _saveThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);

    if (_userId != null) {
      try {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult[0] != ConnectivityResult.none) {
          await FirebaseFirestore.instance.collection('users').doc(_userId).update({
            'preferences': _isDarkMode ? 'darkMode=true' : 'darkMode=false',
          });
        }
      } catch (e) {
        print('Failed to save preferences to Firestore: $e');
      }
    }
  }
}

class ThemeSwitch extends StatefulWidget {
  const ThemeSwitch({super.key});

  @override
  _ThemeSwitchState createState() => _ThemeSwitchState();
}

class _ThemeSwitchState extends State<ThemeSwitch> {
  @override
  void initState() {
    super.initState();
    _loadInitialThemePreference();
  }

  void _loadInitialThemePreference() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    setState(() {
      _isDarkMode = themeNotifier.isDarkMode;
    });
  }
  // Leave it Unused
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Switch(
      value: themeNotifier.isDarkMode,
      onChanged: (value) {
        setState(() {
          _isDarkMode = value;
        });
        themeNotifier.toggleTheme();
      },
    );
  }
}
