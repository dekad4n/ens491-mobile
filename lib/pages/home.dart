import 'package:flutter/material.dart';
import 'package:tickrypt/widgets/navbars.dart';
import 'package:tickrypt/widgets/atoms/sliders/horizontal_slider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            carouselSlider([
              {
                "url":
                    "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg"
              },
              {
                "url":
                    "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg"
              }
            ])
          ]),
    ));
  }
}
