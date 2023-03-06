import 'dart:io';

import 'package:flutter/material.dart';

CircleAvatar profileAvatarFromFile(var url, context) {
  return CircleAvatar(
    radius: MediaQuery.of(context).size.width * 53 / 375,
    backgroundImage: FileImage(File(url)),
  );
}
