import 'dart:convert';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';

import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tickrypt/services/ticket.dart';

class ScanPage extends StatefulWidget {
  final Event? event;
  final UserProvider? userProvider;
  final MetamaskProvider? metamaskProvider;
  final List<dynamic>? marketItemsAll;

  const ScanPage(
      {super.key,
      this.event,
      this.userProvider,
      this.metamaskProvider,
      this.marketItemsAll});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  List<int> _checkedIds = [];

  bool checkTicket(int tokenId) {
    _checkedIds.add(tokenId);
    return true;
  }

  int isTicketUsed(int tokenId) {
    for (dynamic item in widget.marketItemsAll!) {
      if (item["tokenId"] == tokenId) {
        if (item["used"])
          // Meaning this token is already used before
          return 1;
        else
          // Meaning this token is not used
          return 0;
      }
    }
    // Meaning this token doesn't belong to this event
    return -1;
  }

  @override
  void initState() {
    // buildTokenIDtoUsedInfoMap();
  }

  finishButton(token) {
    return GestureDetector(
        child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.green[700],
            ),
            child: Text("Finish Control",
                style: TextStyle(color: Colors.white, fontSize: 18))),
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ticketService.changeTicketUsedState(_checkedIds, token);
        });
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: (QRViewController controller) {
        _onQRViewCreated(controller, context);
      },
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  TicketService ticketService = TicketService();
  // SCAN RESULT IS HERE
  void _onQRViewCreated(QRViewController controller, context) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      // Scanning will verify that shown ticket has not been used.
      // Otherwise show error message
      controller.pauseCamera();
      var decodedQR = jsonDecode(scanData.code!);
      ticketService
          .getTicketCheckedInfo(
              decodedQR["tokenId"].toString(),
              decodedQR["nonce"],
              decodedQR["signature"],
              widget.userProvider!.token)
          .then((res) {
        if (res["value"]) {
          ElegantNotification.error(
            title: Text("Ticket"),
            description: Text("Ticket is used!"),
            onProgressFinished: () {
              controller.resumeCamera();
            },
          ).show(context);
        } else {
          ElegantNotification.success(
              title: Text("Ticket"),
              description: Text("Ticket is not used!"),
              onProgressFinished: () {
                _checkedIds.add(decodedQR["tokenId"]);
                controller.resumeCamera();
              }).show(context);
        }
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else {
      controller!.resumeCamera();
    }
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
          "Scan QR Code",
          style: TextStyle(
            color: Color(0xff050a31),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              if (result != null)
                Text(
                    'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
              else
                const Text('Scan a code'),
              finishButton(widget.userProvider!.token!),
            ],
          )
        ],
      )),
    );
  }
}
