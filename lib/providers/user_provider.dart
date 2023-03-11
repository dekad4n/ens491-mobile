import 'package:flutter/material.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/services/auth.dart';
import 'package:tickrypt/services/user.dart';
import 'package:tickrypt/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  String? token = "";
  User? user;
  bool? isWhitelisted;

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
      isWhitelisted = result["isWhitelisted"];

      notifyListeners();
    } catch (e) {}
  }

  Future<void> handleUpdate(metamaskProvider) async {
    user = await userService.getNonce(metamaskProvider.currentAddress);
    notifyListeners();
  }

  init() {}
}
