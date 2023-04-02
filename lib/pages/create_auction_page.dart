import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';

class CreateAuctionPage extends StatefulWidget {
  final Map<dynamic, dynamic>? item;
  final Event? event;
  final UserProvider? userProvider;
  final MetamaskProvider? metamaskProvider;

  const CreateAuctionPage({
    super.key,
    this.item,
    this.event,
    this.userProvider,
    this.metamaskProvider,
  });

  @override
  State<CreateAuctionPage> createState() => _CreateAuctionPageState();
}

class _CreateAuctionPageState extends State<CreateAuctionPage> {
  List<dynamic> auctions = [];
  bool _isLoading = true;

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
          "Create Auction",
          style: TextStyle(
            color: Color(0xff050a31),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("create auction page"),
          ],
        ),
      ),
    );
  }
}
