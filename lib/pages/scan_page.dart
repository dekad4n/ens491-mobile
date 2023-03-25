import 'dart:convert';

import 'package:alchemy_web3/alchemy_web3.dart';
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
import 'package:url_launcher/url_launcher.dart';

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

  final alchemy = Alchemy();

  List<int> _checkedIds = [];

  finishButton(userProvider) {
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
      onTap: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Processing Data')),
        );

        dynamic transactionParameters = ticketService.changeTicketUsedState(
            userProvider!.token, widget.event!.integerId);

        print("transcationParameters:" + transactionParameters.toString());

        alchemy.init(
          httpRpcUrl:
              "https://polygon-mumbai.g.alchemy.com/v2/jq6Um8Vdb_j-F0vwzpqBjvjHiz3-v5wy",
          wsRpcUrl:
              "wss://polygon-mumbai.g.alchemy.com/v2/jq6Um8Vdb_j-F0vwzpqBjvjHiz3-v5wy",
          verbose: true,
        );

        List<dynamic> params = [
          {
            "from": transactionParameters["from"],
            "to": transactionParameters["to"],
            "data": transactionParameters["data"],
          }
        ];

        String method = "eth_sendTransaction";

        await launchUrl(
            Uri.parse(widget.metamaskProvider!.connector.session.toUri()),
            mode: LaunchMode.externalApplication);

        final signature =
            await widget.metamaskProvider!.connector.sendCustomRequest(
          method: method,
          params: params,
        );

        print("signature:" + signature);
      },
    );
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
        bool alreadyChecked = res["value"];

        if (alreadyChecked) {
          ElegantNotification.error(
            title: Text("Ticket is used before!"),
            description: Text("Therefore, you cannot use this ticket anymore."),
            onProgressFinished: () {
              controller.resumeCamera();
            },
          ).show(context);
        } else {
          ElegantNotification.success(
              title: Text("Ticket is usable."),
              description: Text("Ticket id: ${decodedQR}"),
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
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                if (result != null)
                  Text(
                      'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                else
                  const Text('Scan a code'),
                finishButton(widget.userProvider),
              ],
            ),
          )
        ],
      )),
    );
  }
}
