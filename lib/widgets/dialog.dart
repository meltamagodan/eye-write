import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

void showNosDialog(BuildContext context, String title, Widget content, List<Widget> actions) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        insetPadding: EdgeInsets.all(18.0),
        backgroundColor: Colors.black,

        title: Center(
          child: AnimatedTextKit(
            totalRepeatCount: 1,
            animatedTexts: [
              TypewriterAnimatedText(
                title,
                textStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                speed: Duration(milliseconds: 100),
              ),
            ],
          ),
        ),
        content: SizedBox(width: MediaQuery.of(context).size.width,child: content,),
        actions: actions,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: Colors.white),
        ), // Optional: Rounded corners
      );
    },
  );
}
