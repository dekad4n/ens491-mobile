import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';
import 'package:tickrypt/services/user.dart';
import 'package:tickrypt/widgets/organisms/headers/settingsHeader.dart';

class ProfileSettings extends StatefulWidget {
  final dynamic user;
  const ProfileSettings({Key? key, this.user}) : super(key: key);

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [settingsHeader(context, widget.user)],
            // Get Minted Tickets
          ),
        ),
      ),
    );
  }
}
