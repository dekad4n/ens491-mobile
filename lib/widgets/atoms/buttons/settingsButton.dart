import 'package:flutter/material.dart';
import 'package:tickrypt/pages/profile.dart';
import 'package:tickrypt/pages/profile_settings.dart';
import 'package:provider/provider.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';
import 'package:tickrypt/services/user.dart';

MaterialButton settingsButton(context) {
  var userProvider = Provider.of<UserProvider>(context);
  var metamaskProvider = Provider.of<MetamaskProvider>(context);
  return MaterialButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfileSettings(user: userProvider.user)),
      );
    },
    color: Color(0xFF050A31),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(5),
      ),
    ),
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 27),
      child: Text(
        "Settings",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ),
  );
}
