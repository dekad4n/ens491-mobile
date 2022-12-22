import 'package:flutter/material.dart';
import 'package:tickrypt/services/auth.dart';
import 'package:tickrypt/services/user.dart';
import 'package:tickrypt/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  String? token = "";
  User? user;
  UserService userService = UserService();
  AuthService authService = AuthService();
  bool hasToken() {
    if (token == null) {
      return false;
    }
    return token != "";
  }

  void handleLogin(metamaskProvider) async {
    if (hasToken()) {
      return;
    }
    try {
      String publicAddress = metamaskProvider.currentAddress;
      user = await userService.getNonce(publicAddress);
      String signature = await metamaskProvider.sign(user!.nonce);
      dynamic result = await authService.login(user!.nonce, signature);
      token = result["token"];
    } catch (e) {}
  }

  init() {}
}
