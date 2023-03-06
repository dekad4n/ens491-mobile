import 'package:flutter/material.dart';
import 'package:tickrypt/widgets/atoms/buttons/backButton.dart';
import 'package:tickrypt/widgets/atoms/buttons/saveButton.dart';

dynamic settingsAppbar(context, var token, var changedFile, var changedName) {
  var width = MediaQuery.of(context).size.width;
  var height = MediaQuery.of(context).size.height;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      backButton(context),
      const Spacer(),
      Padding(
        padding: EdgeInsets.fromLTRB(width * 0.05, 75, 0, 0),
        child: Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
      ),
      const Spacer(),
      Padding(
        padding: EdgeInsets.fromLTRB(width * 0.05, 75, width * 0.05, 0),
        child: saveButton(context, token, changedFile, changedName, context),
      )
    ],
  );
}
