// lib/widgets/num_pad.dart
import 'package:flutter/material.dart';

class NumPad extends StatelessWidget {
  final Function(String) onKeyPress;
  final VoidCallback onDelete;

  const NumPad({super.key, required this.onKeyPress, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 20),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 20),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 20),
        _buildRow(['', '0', 'delete']),
      ],
    );
  }

  Widget _buildRow(List<String> values) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: values.map((val) {
        if (val == '') return const SizedBox(width: 80);
        if (val == 'delete') {
          return _NumberButton(
            icon: Icons.backspace_outlined,
            onPressed: onDelete,
          );
        }
        return _NumberButton(text: val, onPressed: () => onKeyPress(val));
      }).toList(),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;

  const _NumberButton({this.text, this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, size: 28)
              : Text(
                  text!,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
