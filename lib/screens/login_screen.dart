// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/pin_vault.dart';
import '../widgets/num_pad.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _vault = PinVault();
  String _inputPin = "";
  bool _isVerifying = false;

  void _onKeyPress(String value) {
    if (_inputPin.length < 4) {
      setState(() {
        _inputPin += value;
      });
    }

    // Auto-verify when 4 digits are reached
    if (_inputPin.length == 4) {
      _verifyPin();
    }
  }

  void _onDelete() {
    if (_inputPin.isNotEmpty) {
      setState(() {
        _inputPin = _inputPin.substring(0, _inputPin.length - 1);
      });
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isVerifying = true);

    // Slight delay to allow the user to see the 4th dot fill up
    await Future.delayed(const Duration(milliseconds: 200));

    final savedPin = await _vault.getPin();

    if (_inputPin == savedPin) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Provide haptic-like feedback via SnackBar
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incorrect PIN. Please try again."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _inputPin = "";
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // App Branding/Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_person_rounded,
                size: 60,
                color: Colors.indigo,
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "Welcome Back",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Enter your security PIN to continue",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),

            const SizedBox(height: 40),

            // PIN Indicators (The Dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                bool isFilled = index < _inputPin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? Colors.indigo : Colors.grey[300],
                    border: Border.all(
                      color: isFilled ? Colors.indigo : Colors.transparent,
                      width: 2,
                    ),
                  ),
                );
              }),
            ),

            const Spacer(flex: 2),

            // Custom Number Pad
            if (!_isVerifying)
              NumPad(onKeyPress: _onKeyPress, onDelete: _onDelete)
            else
              const CircularProgressIndicator(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
