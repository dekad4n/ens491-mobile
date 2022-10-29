import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tickrypt/providers/metamask.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return (ChangeNotifierProvider(
      create: (context) => MetamaskProvider()..init(),
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            children: [
              Center(
                child: Consumer<MetamaskProvider>(
                    builder: (context, provider, child) {
                  late final String text;
                  if (provider.isConnected) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () =>
                                  context.read<MetamaskProvider>().logout(),
                              child: const Text('Disconnect'))
                        ],
                      ),
                    );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: ElevatedButton(
                              onPressed: () => context
                                  .read<MetamaskProvider>()
                                  .loginUsingMetamask(),
                              child: const Text('Connect')),
                        )
                      ],
                    );
                  }
                }),
              )
            ],
          ),
        );
      },
    ));
  }
}
