// import 'package:flutter/material.dart';
// import 'package:tickrypt/providers/metamask.dart';
// import 'package:tickrypt/providers/user_provider.dart';
// import 'package:tickrypt/services/ticket.dart';
// import 'package:tickrypt/widgets/navbars.dart';
// import 'package:provider/provider.dart';
// import 'package:alchemy_web3/alchemy_web3.dart';
// import 'package:walletconnect_dart/walletconnect_dart.dart';
// import 'package:url_launcher/url_launcher_string.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:web3dart/web3dart.dart';

// class Home extends StatefulWidget {
//   const Home({Key? key}) : super(key: key);

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   TicketService ticketService = TicketService();
//   var asd;
//   final alchemy = Alchemy();
//   @override
//   Widget build(BuildContext context) {
//     var userProvider = Provider.of<UserProvider>(context);
//     var metamaskProvider = Provider.of<MetamaskProvider>(context);
//     void call(Future function) async {
//       print("requestion");
//       dynamic result;

//       try {
//         result = await function;
//       } catch (e) {
//         print('Exception: $e}');
//         rethrow;
//       }

//       result.either(
//         (error) {
//           final text = error is String ? error : error.toJson().toString();
//           print(text);
//         },
//         (response) {
//           final text =
//               response is String ? response : response.toJson().toString();
//           print(text);
//         },
//       );

//       setState(() {});
//     }

//     print(metamaskProvider.connector.signingMethods);
//     print("token");
//     print(userProvider.token);
//     print(asd);
//     return (Scaffold(
//       body: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             ElevatedButton(
//                 onPressed: () async {
//                   asd = await ticketService.mint(userProvider.token);
//                   print(asd);
//                 },
//                 child: Text("premint")),
//             Center(
//               child: ElevatedButton(
//                 child: Text("trymint"),
//                 onPressed: () async {
//                   // obtain yours at https://alchemy.com
//                   alchemy.init(
//                     httpRpcUrl:
//                         "https://polygon-mumbai.g.alchemy.com/v2/jq6Um8Vdb_j-F0vwzpqBjvjHiz3-v5wy",
//                     wsRpcUrl:
//                         "wss://polygon-mumbai.g.alchemy.com/v2/jq6Um8Vdb_j-F0vwzpqBjvjHiz3-v5wy",
//                     verbose: true,
//                   );

//                   List<dynamic> params = [
//                     {
//                       "from": asd["from"],
//                       "to": asd["to"],
//                       "data": asd["data"],
//                     }
//                   ];
//                   String method = "eth_sendTransaction";

//                   await launchUrl(
//                       Uri.parse(metamaskProvider.connector.session.toUri()),
//                       mode: LaunchMode.externalApplication);
//                   final signature =
//                       await metamaskProvider.connector.sendCustomRequest(
//                     method: method,
//                     params: params,
//                   );
//                   print(signature);

//                   try {
//                     print("burda");
//                   } catch (e) {
//                     print(e);
//                   }
//                 },
//               ),
//             ),
//             ElevatedButton(
//                 onPressed: () => {metamaskProvider.loginUsingMetamask()},
//                 child: Text("connect"))
//           ]),
//       bottomNavigationBar: bottomNavBar(context),
//     ));
//   }
// }
