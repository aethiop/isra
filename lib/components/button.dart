import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const/colors.dart';

class ButtonWidget extends ConsumerWidget {
  const ButtonWidget(
      {super.key, this.text, this.icon, required this.onPressed});

  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (icon != null) {
      //Button Widget with icon for Undo and Restart Game button.
      return Container(
        decoration: BoxDecoration(
            color: buttonColor, borderRadius: BorderRadius.circular(14.0)),
        child: IconButton(
            color: textColor,
            onPressed: onPressed,
            icon: Icon(
              icon,
              size: 24.0,
            )),
      );
    }
    //Button Widget with text for New Game and Try Again button.
    return ElevatedButton(
        style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.all(16.0)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)))),
        onPressed: onPressed,
        child: Text(
          text!,
          style: const TextStyle(fontSize: 18.0),
        ));
  }
}
