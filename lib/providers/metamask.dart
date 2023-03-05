import 'package:flutter/material.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';

class MetamaskProvider extends ChangeNotifier {
  // Variables
  var _uri = '';
  var _session;
  var currentAddress = '';
  var chainId = 80001;

  // Connector
  var connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta:
          const PeerMeta(name: 'Cryptick', url: 'https://cryptick.com', icons: [
        // our logo
        'https://files.gitbook.com/v0/b/gitbook-legacy-files/o/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
      ]));

  bool get isConnected => connector.connected && currentAddress.isNotEmpty;

  Future<void> loginUsingMetamask() async {
    if (!connector.connected) {
      try {
        var session = await connector.createSession(
            chainId: 280,
            onDisplayUri: (uri) async {
              _uri = uri;
              await launchUrlString(uri, mode: LaunchMode.externalApplication);
            });
        chainId = session.chainId;
        currentAddress = session.accounts[0];
        _session = session;
        notifyListeners();
      } catch (exp) {
        print(exp);
      }
    }
  }

  Future<String> sign(nonce) async {
    List<String?> params = [currentAddress.toLowerCase(), nonce];
    String method = "personal_sign";
    await launchUrl(Uri.parse(connector.session.toUri()),
        mode: LaunchMode.externalApplication);
    final signature = await connector.sendCustomRequest(
      method: method,
      params: params,
    );

    return signature;
  }

  Future<void> logout() async {
    if (connector.connected) {
      try {
        connector.killSession();
        currentAddress = '';
        connector = WalletConnect(
            bridge: 'https://bridge.walletconnect.org',
            clientMeta: const PeerMeta(
                name: 'Cryptick',
                url: 'https://cryptick.com',
                icons: [
                  // our logo
                  'https://files.gitbook.com/v0/b/gitbook-legacy-files/o/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
                ]));
        notifyListeners();
      } catch (exp) {
        print("Couldnt kill sry");
      }
    }
  }

  clear() {
    _uri = '';
    currentAddress = '';
    notifyListeners();
  }

  init() {
    connector.on('SessionUpdate', (event) {
      clear();
    });
    connector.on('Disconnect', (event) {
      clear();
    });
  }
}
