
import 'package:flutter/material.dart';

class CreateTicket extends StatefulWidget {
  final dynamic props;
  const CreateTicket({Key? key, @required this.props}) : super(key: key);

  @override
  State<CreateTicket> createState() => _CreateTicketState();
}

class _CreateTicketState extends State<CreateTicket> {
  double? _price;
  int? _quantity;
  double? _comission;

  coverPreviewContainer() {
    return Column(
      children: [
        Text(
          "Preview",
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 10),
        Container(
          width: 250,
          height: 250,
          child: Container(
            height: 120,
            width: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.memory(
                widget.props["coverImageAsBytes"],
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
        Container(
          width: 250,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Title: ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    child: Text(
                      widget.props["title"],
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Start: ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    widget.props["startDate"].toString().split(" ")[0] +
                        " - " +
                        RegExp(r'\d{2}:\d{2}')
                            .stringMatch(widget.props['startTime'].toString())
                            .toString(),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "End: ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    widget.props["endDate"].toString().split(" ")[0] +
                        " - " +
                        RegExp(r'\d{2}:\d{2}')
                            .stringMatch(widget.props['endTime'].toString())
                            .toString(),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Category: ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    widget.props["category"],
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  priceContainer() {
    return Container(
      padding: EdgeInsets.all(8),
      height: 90,
      width: 140,
      decoration: BoxDecoration(
        border:
            Border.all(color: _price != null ? Colors.deepPurple : Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Price",
            style: TextStyle(
                color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(
                "ETH  ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: TextFormField(
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: null,
                  ),
                  // The validator receives the text that the user has entered.
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '';
                    } else {
                      setState(() {
                        _price = double.parse(value);
                      });
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  quantityContainer() {
    return Container(
      padding: EdgeInsets.all(8),
      height: 90,
      width: 140,
      decoration: BoxDecoration(
        border:
            Border.all(color: _price != null ? Colors.deepPurple : Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quantity",
            style: TextStyle(
                color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: null,
                  ),
                  // The validator receives the text that the user has entered.
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '';
                    } else {
                      setState(() {
                        _quantity = int.parse(value);
                      });
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  resaleComissionContainer() {
    return Container(
      padding: EdgeInsets.all(8),
      height: 90,
      decoration: BoxDecoration(
        border:
            Border.all(color: _price != null ? Colors.deepPurple : Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Resale Comission",
            style: TextStyle(
                color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(
                "%  ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: TextFormField(
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: null,
                  ),
                  // The validator receives the text that the user has entered.
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '';
                    } else {
                      setState(() {
                        _comission = double.parse(value);
                      });
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  confirmButton() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 70,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff050a31), // Background color
                elevation: 0,
                side: BorderSide(color: Colors.deepPurple),
              ),
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_price != null && _quantity != null && _comission != null) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                }
              },
              child: const Text(
                'Confirm',
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
    // print(widget.props);

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
          "Create Ticket",
          style: TextStyle(
            color: Color(0xff050a31),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                coverPreviewContainer(),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    priceContainer(),
                    quantityContainer(),
                  ],
                ),
                SizedBox(height: 20),
                resaleComissionContainer(),
                SizedBox(height: 20),
                confirmButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
