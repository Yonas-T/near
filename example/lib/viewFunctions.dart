import 'package:flutter/material.dart';
import 'package:near_flutter/near_flutter.dart';

class ViewFunctions extends StatefulWidget {
  const ViewFunctions({Key? key}) : super(key: key);

  @override
  _ViewFunctionsState createState() => _ViewFunctionsState();
}

class _ViewFunctionsState extends State<ViewFunctions> {
  WalletAccount walletAccount = WalletAccount('nearyonas.testnet');
  Near? near;

  @override
  void initState() {
    // walletAccount = setupWallet();
    super.initState();
  }

  setupWallet() {
    var keyStore = InMemoryKeyStore();
    var config = NearConfig(
        networkId: "default",
        nodeUrl: "https://rpc.testnet.near.org",
        masterAccount: '',
        helperUrl: '',
        initialBalance: null,
        keyStore: keyStore,
        walletUrl: "https://wallet.testnet.near.org/",
        signer: InMemorySigner(keyStore),
        headers: {});
    near = Near(config);
    return WalletAccount('nearyonas.testnet');
  }

  showAlertDialog(BuildContext context, List data) {

  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () { },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("View Data"),
    content: ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Text(data[index]));
      },
      itemCount: data.length,),
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
    var contractId = 'nearyonas.testnet';
    return Scaffold(
        appBar: AppBar(
          title: const Text('View Functions'),
        ),
        body: GridView.count(
          crossAxisCount: 2,
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(8.0),
              color: Colors.grey[300],
              child: Center(
                  child: TextButton(
                    child: const Text('View Account', style: TextStyle(fontSize: 20)),
                    onPressed: () async {
                      var account = await walletAccount
                          .viewMethod(contractId, 'query', {
                               "request_type": "view_account",
                               "finality": "final",
                               "account_id": 'nearyonas.testnet'
                             
                          });
                      print(account.result.toString().split(','));
                      var valToPass = account.result.toString().split(',');
                      showAlertDialog(context, valToPass);
                    },
                  ),
                
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              color: Colors.grey[300],
              child: Center(
                  child: TextButton(
                    child: const Text('Contract Code', style: TextStyle(fontSize: 20)),
                    onPressed: () async {
                      
                      var account = await walletAccount
                          .viewMethod(contractId, 'query', {
                               "request_type": "view_code",
                              "finality": "final",
                              "account_id": "guest-book.testnet"
                          });
                      print(account.result.toString().split(','));
                      var valToPass = account.result.toString().split(',');
                      showAlertDialog(context, valToPass);
                    },
                  ),
                
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              color: Colors.grey[300],
              child: Center(
                  child: TextButton(
                    child: const Text('Block Details', style: TextStyle(fontSize: 20)),
                    onPressed: () async {
                      
                      var account = await walletAccount
                          .viewMethod(contractId, 'block', {
                               "finality": "final"
                          });
                      print(account.result.toString().split(','));
                      var valToPass = account.result.toString().split(',');
                      showAlertDialog(context, valToPass);
                    },
                  ),
                
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              color: Colors.grey[300],
              child: Center(
                  child: TextButton(
                    child: const Text('Block Details', style: TextStyle(fontSize: 20)),
                    onPressed: () async {
                      
                      var account = await walletAccount
                          .viewMethod(contractId, 'block', {
                               "finality": "final"
                          });
                      print(account.result.toString().split(','));
                      var valToPass = account.result.toString().split(',');
                      showAlertDialog(context, valToPass);
                    },
                  ),
                
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              color: Colors.grey[300],
              
              child: Center(
                  child: TextButton(
                    child: const Text('Chunk Details', style: TextStyle(fontSize: 20)),
                    onPressed: () async {
                      
                      var account = await walletAccount
                          .viewMethod(contractId, 'chunk', {
                               "chunk_id": "FkmUZKPH1npXQgZoiWReDQfQ7TAKiRsdbTyzBxZ9EqKX"
                          });
                      print(account.result.toString().split(','));
                      var valToPass = account.result.toString().split(',');
                      showAlertDialog(context, valToPass);
                    },
                  ),
                
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              color: Colors.grey[300],
               child: Center(
                  child: TextButton(
                    child: const Text('Genesis Config', style: TextStyle(fontSize: 20)),
                    onPressed: () async {
                      
                      var account = await walletAccount
                          .viewMethod(contractId, 'EXPERIMENTAL_genesis_config', null
                          );
                      print(account.result.toString().split(','));
                      var valToPass = account.result.toString().split(',');
                      showAlertDialog(context, valToPass);
                    },
                  ),
                
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              color: Colors.grey[300],
              child: Center(
                  child: TextButton(
                    child: const Text('Protocol Config', style: TextStyle(fontSize: 20)),
                    onPressed: () async {
                      
                      var account = await walletAccount
                          .viewMethod(contractId, 'EXPERIMENTAL_protocol_config', {
                            "finality": "final"
                          }
                          );
                      print(account.result.toString().split(','));
                      var valToPass = account.result.toString().split(',');
                      showAlertDialog(context, valToPass);
                    },
                  ),
                
              ),
            ),
           
          ],
        ));
  }
}
