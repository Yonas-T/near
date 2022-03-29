import 'package:flutter/material.dart';
import 'package:near_flutter/near_flutter.dart';
import 'package:near_flutter/near_flutter.dart';

class ConnectWallet extends StatefulWidget {
  const ConnectWallet({Key? key}) : super(key: key);

  @override
  _ConnectWalletState createState() => _ConnectWalletState();
}

class _ConnectWalletState extends State<ConnectWallet> {
  WalletAccount? walletAccount;
  Near? near;

  @override
  void initState() {
    walletAccount = setupWallet();
    super.initState();
  }

  setupWallet() {
    var keyStore = InMemoryKeyStore();
    var config = NearConfig(
        networkId: "testnet",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            Account jst = await near!.account('nearyonas.testnet');
            var sent = await jst.sendMoney('metry.testnet', '100000000000000000000000');
            // String sentTokens = await near!.sendTokens(
            // BigInt.from(1000000000), 'nearyonas.testnet', 'test.testnet');
            // WalletAccount wall = WalletAccount('nearyonas.testnet');
            var x = await jst.getAccessKeys();
            // var key = await wall.getStoredKey();
            // AccountBalance accBal = await jst.getAccountBalance();
            // print('TOTAL BALANCE: ' + accBal.total);
            // print('AVAILABLE: ' + accBal.available);
            // print('STAKED: ' + accBal.staked);
            // print('STATESTAKED: ' + accBal.stateStaked);
            // var x = jst.state();
            // var publicKey = KeyPair().fromRandom('M-511');

            print(x);
            // jst.createAccount(
            //     'someAccIdFor', key, BigInt.from(3000000000000000000));
            // setupWallet();
          },
          child: const Text('Connect Wallet'),
        ),
      ),
    );
  }
}
