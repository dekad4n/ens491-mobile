import 'package:flutter/material.dart';
import 'package:tickrypt/widgets/molecules/appbars/settings_appbar.dart';
import 'package:tickrypt/widgets/atoms/imageWrappers/avatar.dart';
import 'package:tickrypt/models/user_model.dart';
import 'package:tickrypt/widgets/molecules/button_groups/profile_header_group.dart';

dynamic settingsHeader(BuildContext context, User? currentUser) {
  var username = currentUser?.username ?? "";
  username = username.length > 16 ? username.substring(0, 16) + '..' : username;
  return Column(children: [
    settingsAppbar(context),
  ]);
}
