import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

Padding backButton(context) {
  var width = MediaQuery.of(context).size.width;
  var height = MediaQuery.of(context).size.height;
  return Padding(
    padding: EdgeInsets.fromLTRB(width * 0.05, 75, width * 0.05, 0),
    child: IconButton(
      icon: const Icon(CupertinoIcons.arrow_left),
      onPressed: () {},
    ),
  );
}
