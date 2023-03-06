import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tickrypt/widgets/atoms/buttons/changeAvatar.dart';
import 'package:tickrypt/widgets/atoms/imageWrappers/avatarFromFile.dart';
import 'package:tickrypt/widgets/molecules/appbars/settings_appbar.dart';
import 'package:tickrypt/widgets/atoms/imageWrappers/avatar.dart';
import 'package:tickrypt/models/user_model.dart';
import 'package:tickrypt/widgets/molecules/button_groups/profile_header_group.dart';
import 'package:tickrypt/widgets/atoms/imageWrappers/avatar.dart';

dynamic settingsHeader(BuildContext context, User? currentUser, var token,
    bool changed, var changedAvatar, var changedFile, var changedName) {
  var username = currentUser?.username ?? "";
  username = username.length > 16 ? username.substring(0, 16) + '..' : username;
  var avatar = currentUser!.avatar;
  return Column(children: [
    settingsAppbar(context, token, changedFile, changedName),
    if (!changed)
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: profileAvatar(currentUser.avatar, context),
      ),
    if (changed)
      Container(
        child: profileAvatarFromFile(changedAvatar, context),
      )
  ]);
}
