import 'package:flutter/material.dart';

ElevatedButton shareButton(context) {
  return ElevatedButton(
    onPressed: () {},
    child: Image.asset('lib/assets/shareButton.png'),
    style: ElevatedButton.styleFrom(
        shape: CircleBorder(), elevation: 5, backgroundColor: Colors.white),
  );
}
