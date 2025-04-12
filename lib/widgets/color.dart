import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

Future<Color?> showColorPickerDialog(BuildContext context) async {
  Color selectedColor = Colors.blue; // Default color

  return showDialog<Color>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              "Pick a Color",
              textStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              speed: Duration(milliseconds: 100),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        content: SizedBox(
          height: 470,
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              selectedColor = color;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, selectedColor),
            child: Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: Colors.white),
        ),
      );
    },
  );
}
