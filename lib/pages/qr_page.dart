import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'dart:ui' as ui;

class QRPage extends StatefulWidget {
  Event event;
  UserProvider userProvider;
  MetamaskProvider metamaskProvider;
  Map<dynamic, dynamic> item;

  QRPage({
    super.key,
    required this.event,
    required this.userProvider,
    required this.metamaskProvider,
    required this.item,
  });

  @override
  State<QRPage> createState() => QRPageState();
}

class QRPageState extends State<QRPage> {
  late String message;
  @override
  void initState() {
    message = widget.item.toString();
    print(message);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shadowColor: null,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          iconSize: 30,
          color: Color(0xff050a31),
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Viewing Ticket QR",
          style: TextStyle(
            color: Color(0xff050a31),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: QrImage(
              data: message,
              version: QrVersions.auto,
              size: 300.0,
            ),
          ),
        ),
      ),
    );
  }
}
