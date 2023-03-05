import 'package:flutter/material.dart';
import 'package:tickrypt/pages/home.dart';
import 'package:tickrypt/pages/profile_settings.dart';
import 'package:tickrypt/pages/search.dart';
import 'utils/routes.dart';
import 'pages/wrapper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: "lib/.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Avenir',
      ),
      routes: {
        MainRoutes.wrapper: (context) => const MetamaskWrapper(),
        MainRoutes.home: (context) => const Home(),
        MainRoutes.search: (context) => const Search(),
        MainRoutes.profileSettings: (context) => const ProfileSettings(),
      },
      home: const MetamaskWrapper(),
    );
  }
}
