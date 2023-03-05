import 'package:flutter/material.dart';

CircleAvatar profileAvatar(url, context) {
  return CircleAvatar(
    radius: MediaQuery.of(context).size.width * 53 / 375,
    backgroundImage: NetworkImage(url ??
        "https://static.vecteezy.com/system/resources/previews/007/126/739/original/question-mark-icon-free-vector.jpg"),
  );
}
