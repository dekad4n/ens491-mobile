import 'package:flutter/material.dart';
import 'package:tickrypt/widgets/navbars.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      body: Column(children: [
        Center(
          child: Text("Sadi"),
        ),
      ]),
      bottomNavigationBar: bottomNavBar(context),
    ));
  }
}
