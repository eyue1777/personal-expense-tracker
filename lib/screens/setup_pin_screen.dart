import 'package:flutter/material.dart';
import '../services/pin_vault.dart';
import 'home_screen.dart';

class SetupPinScreen extends StatefulWidget {
  final bool isFirstTime; // Added this flag

  const SetupPinScreen({super.key, this.isFirstTime = true});

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final TextEditingController _pinController = TextEditingController();

  void _saveAndProceed() async {
    if (_pinController.text.length == 4) {
      await PinVault().savePin(_pinController.text);

      if (!mounted) return;

      if (widget.isFirstTime) {
        // Go to Home if it's the first initialization
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Just go back to Settings if they were just changing the PIN
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PIN updated successfully!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dynamic Icon
              Icon(
                widget.isFirstTime
                    ? Icons.auto_awesome_rounded
                    : Icons.lock_reset_rounded,
                size: 80,
                color: Colors.indigo,
              ),
              const SizedBox(height: 20),

              // Dynamic Title
              Text(
                widget.isFirstTime ? "Welcome to MyMoney" : "Update Security",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Dynamic Subtitle
              Text(
                widget.isFirstTime
                    ? "Let's get started! Set a 4-digit PIN to secure your new financial vault."
                    : "Enter a new 4-digit PIN to update your app security.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),

              const SizedBox(height: 40),

              // The Rounded Input
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  letterSpacing: 25,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: "0000",
                  counterText: "",
                  filled: true,
                  fillColor: Colors.grey[100],
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Colors.indigo,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveAndProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    widget.isFirstTime ? "Create My Vault" : "Update PIN",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
