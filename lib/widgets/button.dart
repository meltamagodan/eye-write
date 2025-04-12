import 'package:eyewrite/widgets/text_color_changer.dart';
import 'package:flutter/material.dart';

class NosButton extends StatelessWidget {
  final String text;
  final Color? color;
  final VoidCallback onPressed;

  const NosButton({
    super.key,
    required this.text,
    required this.onPressed, this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(color ?? Colors.black),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: BorderSide(color: color==null ? Colors.white : getTextColorBasedOnBackground(color!)),
          ),
        ),
        padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 12, horizontal: 20)),
        overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.2)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(color: color==null ? Colors.white : getTextColorBasedOnBackground(color!), fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
