import 'package:flutter/material.dart';

dynamic primaryElevatedButton(String text, var onPressed) {
  return Row(
    children: [
      Expanded(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: ElevatedButton(
          child: Text(text),
          onPressed: onPressed,
        ),
      )),
    ],
  );
}
