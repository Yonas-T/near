import 'package:example/callFunction.dart';
import 'package:example/mintNft.dart';
import 'package:example/viewFunctions.dart';
import 'package:flutter/material.dart';
import 'package:near_flutter/near_flutter.dart';

import './viewAccessKey.dart';
import './viewAccessKeyChanges.dart';
import './viewAccessKeyList.dart';
import 'connectWallet.dart';
import 'transferMoney.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ConnectWallet(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Near? near;
  WalletAccount walletAccount = WalletAccount('nearyonas.testnet');
  Map<String, dynamic> accessKeyData = {};
  String viewTrigger = '';
  String keyStored = '';

  @override
  void initState() {
    walletAccount.getStoredKey().then((value) {
      if (value != null) {
        setState(() {
          keyStored = value;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TransferMoney()),
                  );
                },
                child: Container(
                    height: 50,
                    color: Colors.blueGrey[100],
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Send Tokens',
                      style: TextStyle(fontSize: 20),
                    )),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: (() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CallFunction()),
                  );
                }),
                child: Container(
                    height: 50,
                    color: Colors.blueGrey[100],
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Add Message',
                      style: TextStyle(fontSize: 20),
                    )),
              )
            ],
          ),
        ));
  }
}
