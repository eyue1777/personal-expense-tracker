import 'package:flutter/material.dart';
import 'services/pin_vault.dart';
import 'services/prefs_service.dart';
import 'screens/login_screen.dart';
import 'screens/setup_pin_screen.dart';

void main() async {
  // Required for initializing plugins before runApp
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyMoneyApp());
}

class MyMoneyApp extends StatefulWidget {
  const MyMoneyApp({super.key});

  @override
  MyMoneyAppState createState() => MyMoneyAppState();
}

class MyMoneyAppState extends State<MyMoneyApp> {
  bool _isDark = false;
  final _prefs = PrefsService();

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // R3: Load the theme preference immediately
  void _loadTheme() async {
    final dark = await _prefs.getTheme();
    setState(() => _isDark = dark);
  }

  // Public method so SettingsScreen can trigger a theme change
  void updateTheme(bool dark) {
    setState(() => _isDark = dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyMoney',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: _isDark ? Brightness.dark : Brightness.light,
      ),
      // R1: Dynamic routing based on whether a PIN exists
      home: FutureBuilder<bool>(
        future: PinVault().hasPin(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // If true: Go to Login. If false: Go to Welcome/Setup.
          return snapshot.data!
              ? const LoginScreen()
              : const SetupPinScreen(isFirstTime: true);
        },
      ),
    );
  }
}
