import 'package:flutter/material.dart';
import 'package:tickrypt/widgets/molecules/appbars/profile_appbar.dart';
import 'package:tickrypt/widgets/atoms/imageWrappers/avatar.dart';
import 'package:tickrypt/models/user_model.dart';
import 'package:tickrypt/widgets/molecules/button_groups/profile_header_group.dart';

dynamic profileHeader(BuildContext context, User? currentUser, setState) {
  var username = currentUser?.username ?? "";
  username = username.length > 16 ? username.substring(0, 16) + '..' : username;
  return Column(children: [
    profileAppbar(context),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: profileAvatar(currentUser?.avatar, context),
    ),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        username ?? "",
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 30,
          fontFamily: 'Avenir',
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 50),
      child: profileHeaderGroup(context, setState),
    )
  ]);
}
