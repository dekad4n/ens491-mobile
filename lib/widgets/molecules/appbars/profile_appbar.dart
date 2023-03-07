import 'package:flutter/material.dart';
import 'package:tickrypt/widgets/atoms/buttons/backButton.dart';
import 'package:tickrypt/widgets/atoms/buttons/logoutButton.dart';

dynamic profileAppbar(context) {
  var width = MediaQuery.of(context).size.width;
  var height = MediaQuery.of(context).size.height;
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const Spacer(),
      Padding(
        padding: EdgeInsets.fromLTRB(width * 0.05, 75, width * 0.05, 0),
        child: logoutButton(context),
      )
    ],
  );
}
