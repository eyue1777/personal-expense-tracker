import 'package:flutter/material.dart';
import '../services/prefs_service.dart';
import '../services/pin_vault.dart';
import '../services/expenses_db.dart';
import '../main.dart';
import 'setup_pin_screen.dart';
import 'login_screen.dart'; // Import added for logout navigation

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _prefs = PrefsService();
  bool _isDark = false;
  String _currency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() async {
    final d = await _prefs.getTheme();
    final c = await _prefs.getCurrency();
    setState(() {
      _isDark = d;
      _currency = c;
    });
  }

  // NEW LOGIC: Logout (Return to Login Screen and clear stack)
  void _handleLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false, // This clears the navigation history for security
    );
  }

  void _handleChangePin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SetupPinScreen(isFirstTime: false),
      ),
    );
  }

  void _handleFactoryReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Factory Reset?",
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          "This will permanently delete all your expenses and your security PIN. The app will restart.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await PinVault().clearPin();
              await ExpensesDb.instance.wipeDatabase();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const SetupPinScreen(isFirstTime: true),
                ),
                (route) => false,
              );
            },
            child: const Text("Delete Everything"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          _buildSectionTitle("Appearance"),
          SwitchListTile(
            title: const Text("Dark Mode"),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: _isDark,
            onChanged: (val) async {
              await _prefs.setTheme(val);
              setState(() => _isDark = val);
              if (mounted) {
                context.findAncestorStateOfType<MyMoneyAppState>()?.updateTheme(
                  val,
                );
              }
            },
          ),
          ListTile(
            title: const Text("Currency"),
            leading: const Icon(Icons.payments_outlined),
            trailing: DropdownButton<String>(
              value: _currency,
              underline: const SizedBox(),
              onChanged: (val) async {
                if (val != null) {
                  await _prefs.setCurrency(val);
                  setState(() => _currency = val);
                }
              },
              items: [
                'USD',
                'EUR',
                'ETB',
                'GBP',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            ),
          ),

          const Divider(height: 40),
          _buildSectionTitle("Security"),
          ListTile(
            title: const Text("Change App PIN"),
            leading: const Icon(Icons.lock_person_outlined),
            trailing: const Icon(Icons.chevron_right),
            onTap: _handleChangePin,
          ),

          // ADDED LOGOUT TILE
          ListTile(
            title: const Text("Logout"),
            subtitle: const Text("Lock application access"),
            leading: const Icon(Icons.logout_rounded, color: Colors.orange),
            trailing: const Icon(Icons.chevron_right),
            onTap: _handleLogout,
          ),

          const SizedBox(height: 40),
          _buildSectionTitle("Danger Zone"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: _handleFactoryReset,
              icon: const Icon(Icons.delete_forever_rounded),
              label: const Text("Reset App & Wipe Data"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.indigo.withOpacity(0.6),
        ),
      ),
    );
  }
}
