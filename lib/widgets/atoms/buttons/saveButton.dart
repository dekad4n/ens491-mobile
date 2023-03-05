import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';

TextButton saveButton(context) {
  var userProvider = Provider.of<UserProvider>(context);
  var metamaskProvider = Provider.of<MetamaskProvider>(context);
  return TextButton(
    onPressed: () {
      metamaskProvider.logout();
      userProvider.token = "";
      userProvider.user = null;
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
