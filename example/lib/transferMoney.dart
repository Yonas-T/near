import 'package:flutter/material.dart';
import 'package:near_flutter/near_flutter.dart';

class TransferMoney extends StatefulWidget {
  const TransferMoney({Key? key}) : super(key: key);

  @override
  _TransferMoneyState createState() => _TransferMoneyState();
}

class _TransferMoneyState extends State<TransferMoney> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();

  showAlertDialog(BuildContext context, List data) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () async {
        var endUrl = await RestApiProvider().transferRestApiProvider('yonasnear.testnet', 'nearyonas.testnet', _amountController.text);
        String urlToLaunch = endUrl.toString();
        if (urlToLaunch.contains('https')) {
          Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => NearUrlLauncher(initialUrl: urlToLaunch)));
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('${data[0]} ${data[1]}'),
      content: ListView(
        children:  [
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              hintText: 'Enter Amount',
            ),
          ),
          TextField(
            controller: _accountController,
            decoration: const InputDecoration(
              labelText: 'To',
              hintText: 'Enter Receiver',
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
        return alert;
      },
    );
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
                'Transfer Money',
                style: TextStyle(fontSize: 28),
              )),
        ),
      ),
    );
  }
}
