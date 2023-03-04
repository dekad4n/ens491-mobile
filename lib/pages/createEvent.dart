import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

import 'package:tickrypt/pages/createTicket.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({super.key});

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  final _formKey = GlobalKey<FormState>();

  final ImagePicker _imagePicker = ImagePicker();

  XFile? _coverImage;
  var _coverImageAsBytes;
  String? _title;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _category;
  String? _description;

  void _showDatePickerStart() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(2030),
    )
        .then((value) => {setState(() => _startDate = value!)})
        .onError((error, stackTrace) => {});
  }

  void _showDatePickerEnd() {
    showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2030),
    )
        .then((value) => {setState(() => _endDate = value!)})
        .onError((error, stackTrace) => {});
  }

  void _showTimePicker(String which) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((value) {
      setState(() {
        if (which == "start") {
          setState(() {
            _startTime = value!;
          });
        } else {
          setState(() {
            _endTime = value!;
          });
        }

        // DateTime outgoingData = DateTime(_startDate!.year, _startDate!.month,
        //     _startDate!.day, _startTime!.hour, _startTime!.minute);
      });
    }).onError((error, stackTrace) => null);
  }

  void _pickImageFromGallery() async {
    XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _coverImage = pickedFile;
      });
      var imageBytes = await pickedFile.readAsBytes();

      // String encodedImage = base64Encode(imageBytes);

      setState(() {
        _coverImageAsBytes = imageBytes;
        // imageBase64Encoded = encodedImage;
      });
    }
  }

  uploadCoverContainer() {
    return Container(
      child: Row(
        children: [
          //Photo Cover
          Flexible(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Container(
                  height: 120,
                  width: 120,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: _coverImageAsBytes != null
                          ? Image.memory(
                              _coverImageAsBytes,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            )
                          : Image.network(
                              "https://i.ibb.co/kDMbLZR/eventcoverplaceholder.jpg")),
                ),
              )),
          SizedBox(
            width: 20,
          ),
          Flexible(
            flex: 3,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Select",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Colors.grey[700]),
                  ),
                  Text(
                    "Event Cover",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Background color
                      ),
                      onPressed: () => {_pickImageFromGallery()},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.file_upload_rounded,
                            color: Colors.blue,
                          ),
                          Text("Upload", style: TextStyle(color: Colors.blue))
                        ],
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  titleTextFormField() {
    return TextFormField(
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      // The validator receives the text that the user has entered.
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelText: 'Title',
      ),

      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        } else {
          setState(() {
            _title = value;
          });
        }
        return null;
      },
    );
  }

  pickDatesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          flex: 1,
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Background color
              ),
              onPressed: _showDatePickerStart,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(_startDate?.toString().split(" ")[0] ?? "Start Date",
                      style: TextStyle(color: Colors.grey[700], fontSize: 18)),
                  Icon(
                    Icons.calendar_today,
                    color: Colors.grey[700],
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Flexible(
          flex: 1,
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Background color
              ),
              onPressed: _showDatePickerEnd,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(_endDate?.toString().split(" ")[0] ?? "End Date",
                      style: TextStyle(color: Colors.grey[700], fontSize: 18)),
                  Icon(
                    Icons.calendar_today,
                    color: Colors.grey[700],
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  pickTimesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          flex: 1,
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Background color
              ),
              onPressed: () => {_showTimePicker("start")},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                      _startTime != null
                          ? _startTime.toString().substring(
                              _startTime.toString().indexOf("(") + 1,
                              _startTime.toString().indexOf(")"))
                          : "Start Time",
                      style: TextStyle(color: Colors.grey[700], fontSize: 18)),
                  Icon(
                    Icons.access_time,
                    color: Colors.grey[700],
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Flexible(
          flex: 1,
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Background color
              ),
              onPressed: () => {_showTimePicker("end")},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                      _endTime != null
                          ? _endTime.toString().substring(
                              _endTime.toString().indexOf("(") + 1,
                              _endTime.toString().indexOf(")"))
                          : "End Time",
                      style: TextStyle(color: Colors.grey[700], fontSize: 18)),
                  Icon(
                    Icons.access_time,
                    color: Colors.grey[700],
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  categoryDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border:
            Border.all(color: Colors.grey, style: BorderStyle.solid, width: 1),
      ),
      child: DropdownButton<String>(
          value: _category,
          hint: Text(
            "Select Event Category",
            style: TextStyle(fontSize: 20),
          ),
          icon: const Icon(
            Icons.arrow_drop_down_rounded,
            size: 40,
          ),
          elevation: 16,
          style: const TextStyle(color: Colors.black),
          underline: Container(
            height: 0,
          ),
          onChanged: (String? value) {
            // This is called when the user selects an item.
            setState(() {
              _category = value!;
            });
          },
          items: [
            DropdownMenuItem<String>(
              value: "Category 1",
              child: Text(
                "Category 1",
                style: TextStyle(fontSize: 18),
              ),
            ),
            DropdownMenuItem<String>(
              value: "Category 2",
              child: Text(
                "Category 2",
                style: TextStyle(fontSize: 18),
              ),
            ),
            DropdownMenuItem<String>(
              value: "Category 3",
              child: Text(
                "Category 3",
                style: TextStyle(fontSize: 18),
              ),
            ),
            DropdownMenuItem<String>(
              value: "Category 4",
              child: Text(
                "Category 4",
                style: TextStyle(fontSize: 18),
              ),
            )
          ]),
    );
  }

  descriptionTextFormField() {
    return TextFormField(
      style: TextStyle(fontSize: 18),
      // The validator receives the text that the user has entered.
      decoration: InputDecoration(
          labelText: 'Description',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      keyboardType: TextInputType.multiline,
      minLines: 1, //Normal textInputField will be displayed
      maxLines: 6,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        } else {
          setState(() {
            _description = value;
          });
        }
        return null;
      },
    );
  }

  nextButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate() &&
                  _coverImage != null &&
                  _startDate != null &&
                  _endDate != null &&
                  _startTime != null &&
                  _endTime != null &&
                  _category != null) {
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateTicket(
                      props: {
                        "coverImageAsBytes": _coverImageAsBytes,
                        "title": _title,
                        "startDate": _startDate,
                        "endDate": _endDate,
                        "startTime": _startTime,
                        "endTime": _endTime,
                        "category": _category,
                        "description": _description,
                      },
                    ),
                  ),
                );
              }
            },
            child: const Text(
              'Next: Mint Ticket',
              style: TextStyle(
                fontSize: 18,
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              uploadCoverContainer(),
              SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleTextFormField(),
                    SizedBox(height: 30),
                    pickDatesRow(),
                    SizedBox(height: 10),
                    pickTimesRow(),
                    SizedBox(height: 30),
                    categoryDropdown(),
                    SizedBox(height: 30),
                    descriptionTextFormField(),
                    SizedBox(height: 30),
                    nextButton(),
                  ],
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}
