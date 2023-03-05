import 'package:flutter/material.dart';

FittedBox verticalEventImageWrapper(BuildContext context, String? url) {
  return FittedBox(
    fit: BoxFit.cover,
    child: ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      child: (Image.network(
        url ?? "",
        fit: BoxFit.cover,
        width: (MediaQuery.of(context).size.width - 39) / 2,
        height: (MediaQuery.of(context).size.width - 39) * 113 / 330,
      )),
    ),
  );
}
