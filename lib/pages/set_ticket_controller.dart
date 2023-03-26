import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/services/event.dart';
import 'package:tickrypt/widgets/atoms/buttons/backButton.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:elegant_notification/elegant_notification.dart';
import '../providers/user_provider.dart';

class SetTicketControllerPage extends StatefulWidget {
  final dynamic event;
  final UserProvider? userProvider;
  final MetamaskProvider? metamaskProvider;
  const SetTicketControllerPage(
      {super.key, this.event, this.userProvider, this.metamaskProvider});

  @override
  State<SetTicketControllerPage> createState() =>
      _SetTicketControllerPageState();
}

class _SetTicketControllerPageState extends State<SetTicketControllerPage> {
  String? _address;
  final _formKey = GlobalKey<FormState>();
  EventService eventService = EventService();
  TextEditingController? _textFormFieldController = TextEditingController();
  formField() {
    return TextFormField(
      style: TextStyle(fontSize: 18),
      // The validator receives the text that the user has entered.
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: TextStyle(color: Colors.grey),
        labelText: 'Public Address',
      ),
      cursorColor: Colors.deepPurple,
      controller: _textFormFieldController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        } else {
          setState(() {
            _address = value;
          });
        }
        return null;
      },
    );
  }

  confirmButton(userProvider, metamaskProvider, context) {
    // bool isEnabled = _address != null;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 70,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    true ? Color(0xff050a31) : Colors.grey, // Background color
                elevation: 0,
              ),
              onPressed: true
                  ? () async {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState != null &&
                          _formKey.currentState!.validate() &&
                          _address != null) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Adding new event controller...')),
                        );

                        // 1- Send request to backend to create Event in mongoDB

                        var controllerResult =
                            await eventService.setTicketController(_address,
                                widget.event.integerId, userProvider.token);

                        List<dynamic> params = [
                          {
                            "from": controllerResult["from"],
                            "to": controllerResult["to"],
                            "data": controllerResult["data"],
                          }
                        ];

                        String method = "eth_sendTransaction";

                        await launchUrl(
                            Uri.parse(
                                metamaskProvider.connector.session.toUri()),
                            mode: LaunchMode.externalApplication);

                        final signature =
                            await metamaskProvider.connector.sendCustomRequest(
                          method: method,
                          params: params,
                          topic: "Set Controller",
                        );

                        if (signature != null) {
                          _textFormFieldController!.clear();
                          ElegantNotification.success(
                                  animation: AnimationType.fromBottom,
                                  notificationPosition:
                                      NotificationPosition.bottomCenter,
                                  title: Text("Ticket controller added"),
                                  description:
                                      Text("With wallet Id: ${_address}"),
                                  onProgressFinished: () {})
                              .show(context);
                        }
                      }
                    }
                  : null,
              child: const Text(
                'Add Ticket Controller',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              backButton(context),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 75.0, 0, 0),
                child: Text(
                  "Add Event Controller",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  formField(),
                  SizedBox(height: 30),
                  confirmButton(
                      widget.userProvider, widget.metamaskProvider, context),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
