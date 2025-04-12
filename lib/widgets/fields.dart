import 'package:flutter/material.dart';

class NosTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool multiline;
  final void Function(String)? onChanged;

  const NosTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.multiline = false, this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      cursorColor: Colors.white,
      controller: controller,
      maxLines: multiline ? null : 1,
      style: TextStyle(color: Colors.white), // Text color
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)), // Placeholder text color
        filled: true,
        fillColor: Colors.black,
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
