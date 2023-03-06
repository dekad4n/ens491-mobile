import 'package:flutter/material.dart';

TextButton changeAvatar(var avatar, var _pickImage) {
  return TextButton(
      onPressed: () {
        _pickImage();
      },
      child: const Text(
        "Change Profile Picture",
        style: TextStyle(
            color: Color(0xFF0057FF),
            fontSize: 18,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w500),
      ));
}
