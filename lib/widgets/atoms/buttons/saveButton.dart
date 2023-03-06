import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';
import 'package:tickrypt/services/user.dart';

TextButton saveButton(
    dynamic user, var token, var changedFile, var changedName, var context) {
  return TextButton(
    onPressed: () async {
      Map<String, dynamic> props = {"avatar": "", "username": ""};
      if (changedFile != null) props["avatar"] = base64Encode(changedFile);
      if (changedName != null) props["username"] = changedName;
      await UserService().updateUser(props, token);
      Navigator.pop(context, true);
    },
    child: Text(
      "Save",
      style: TextStyle(
        color: Color(0xFFE18B8B),
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
