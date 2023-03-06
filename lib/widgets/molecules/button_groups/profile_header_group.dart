import 'package:flutter/material.dart';
import 'package:tickrypt/widgets/atoms/buttons/settingsButton.dart';
import 'package:tickrypt/widgets/atoms/buttons/shareButton.dart';

Row profileHeaderGroup(context, setState) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [shareButton(context), settingsButton(context, setState)],
  );
}
