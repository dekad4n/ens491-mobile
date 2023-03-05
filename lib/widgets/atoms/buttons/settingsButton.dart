import 'package:flutter/material.dart';

MaterialButton settingsButton(context) {
  return MaterialButton(
    onPressed: () {},
    color: Color(0xFF050A31),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(5),
      ),
    ),
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 27),
      child: Text(
        "Settings",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ),
  );
}
