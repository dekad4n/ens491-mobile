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
      print("here2");
      return;
    }
    print("buraa");
    try {
      String publicAddress = metamaskProvider.currentAddress;
      print(publicAddress);
      user = await userService.getNonce(publicAddress);
      print(user);
      String signature = await metamaskProvider.sign(user!.nonce);
      print(signature);
      dynamic result = await authService.login(user!.nonce, signature);
      token = result["token"];
      notifyListeners();
    } catch (e) {}
  }

  init() {}
}
