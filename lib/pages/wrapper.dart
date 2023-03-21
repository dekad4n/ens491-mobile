import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tickrypt/pages/home.dart';
import 'package:tickrypt/pages/profile.dart';
import 'package:tickrypt/pages/search.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';
import 'package:tickrypt/services/auth.dart';
import 'package:tickrypt/services/user.dart';
import 'package:tickrypt/widgets/navbars.dart';

class MetamaskWrapper extends StatefulWidget {
  const MetamaskWrapper({Key? key}) : super(key: key);

  @override
  State<MetamaskWrapper> createState() => _MetamaskWrapperState();
}

class _MetamaskWrapperState extends State<MetamaskWrapper> {
  AuthService authService = AuthService();
  UserService userService = UserService();
  @override
  Widget build(BuildContext context) {
    return (ChangeNotifierProvider(
      create: (context) => MetamaskProvider()..init(),
      builder: (BuildContext context, child) {
        return Consumer<MetamaskProvider>(builder: (context, provider, child) {
          if (context.read<MetamaskProvider>().isConnected) {
            return LoggedIn(metamaskProvider: provider);
          } else {
            return LoggedIn(metamaskProvider: provider);
          }
        });
      },
    ));
  }
}

class LoggedIn extends StatefulWidget {
  final MetamaskProvider metamaskProvider;
  const LoggedIn({Key? key, required this.metamaskProvider}) : super(key: key);

  @override
  State<LoggedIn> createState() => _LoggedInState();
}

class _LoggedInState extends State<LoggedIn> {
  var pageIdx = 0;
  dynamic current = Home();
  void changeMainPage(changeTo) {
    setState(() {
      pageIdx = changeTo;
    });
    if (pageIdx == 0) {
      current = Home();
    } else if (pageIdx == 1) {
      current = Search();
    } else if (pageIdx == 4) {
      current = Profile();
    }
  }

  Widget build(BuildContext context) {
    var metamaskProvider = Provider.of<MetamaskProvider>(context);

    return (ChangeNotifierProvider(
        create: (context) => UserProvider()..init(),
        builder: (context, child) {
          return Consumer<UserProvider>(
            builder: (context, provider, child) {
              if (metamaskProvider.isConnected) {
                provider.handleLogin(metamaskProvider);
              }
              return Scaffold(
                body: Center(child: current),
                bottomNavigationBar:
                    bottomNavBar(context, changeMainPage, pageIdx),
              );
            },
          );
        }));
  }
}
