import 'package:flutter/material.dart';
import 'package:near_flutter/near_flutter.dart';

class CallFunction extends StatefulWidget {
  const CallFunction({Key? key}) : super(key: key);

  @override
  _CallFunctionState createState() => _CallFunctionState();
}

class _CallFunctionState extends State<CallFunction> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool messageSuccess = false;

  showAlertDialog(BuildContext context, List data) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () async {
        if (!messageSuccess) {
          var resp = await RestApiProvider().callRestApiProvider(
              'privateKey',
              'yonasnear.testnet',
              'guest-book.testnet',
              _messageController.text,
              _amountController.text);
          print(resp);
          if (resp != null) {
            print('not null');
            setState(() {
              messageSuccess = true;
            });
          }
        } else {
          Navigator.pop(context);
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('${data[0]} ${data[1]}'),
      content: messageSuccess
          ? const Center(
              child: Text('Message sent successfully'),
            )
          : ListView(
              children: [
                TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: 'Enter Amount',
                  ),
                ),
                TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    hintText: 'Enter Message',
                  ),
                ),
              ],
            ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return alert;
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () {
            showAlertDialog(context, ["Hello", "World"]);
          },
          child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width * 0.8,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueGrey[100],
              ),
              child: const Text(
                'Add Message',
                style: TextStyle(fontSize: 28),
              )),
        ),
      ),
    );
  }
}
