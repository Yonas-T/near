import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:near_flutter/src/models/signInModel.dart';
import 'package:near_flutter/src/signer.dart';
import 'package:near_flutter/src/utils/key_pair.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../near_flutter.dart';
import './account.dart';
import './connection.dart';
import './constants/constants.dart';
import './key_stores/key_store.dart';
import './near.dart';
import './providers/provider.dart';
import './signer.dart';
import './transaction.dart';
import './utils/key_pair.dart';
import 'near_url_launcher.dart';
import 'near_url_launcher.dart';
import 'providers/json_rpc.dart';

var loginWalletUrlSuffix = "/login/";

var localStorageKeySuffix = "_wallet_auth_key";

/// storage key for a pending access key (i.e. key has been generated but we are not sure it was added yet)
var pendingAccessKeySuffix = "pending_key";

///Sign in a Near account
///It returns a NearIdentity object

class WalletAccount {
  String? accountId;
  String walletBaseUrl = walletUrl;

  WalletAccount(
    this.accountId,
  );

  ///check if the account is already signed in
  ///returns true if the account is authorized with the wallet
  isSignedIn() {
    return accountId != null;
  }

  ///returns an authorized account id
  getAccountId() {
    return accountId ?? "";
  }

  ///sign in an account
  ///Redirects to wallet authentication page
  ///Parameters:
  ///    - [contractId] the contract id
  ///    - [accountId] the account id
  ///    - successUrl: successUrl to redirect on success
  ///    - failureUrl: failureUrl to redirect on failure

  Future requestSignIn(context, String? contractId, String? title,
      String? successUrl, String? failureUrl) async {
    var url = "$walletUrl";
    return Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => NearUrlLauncher(initialUrl: url)));
    // return NearUrlLauncher(initialUrl: url);
  }

  Future<String?> getStoredKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? key = prefs.getString('stored_key');
    return key;
  }

  // Future _requestSignIn(
  //     dynamic contractIdOrOptions,
  //     String title,
  //     String successUrl,
  //     String failureUrl,
  //     WebViewController webViewController) async {
  //   dynamic options;
  //   // var _keyStore = (near.connection.signer as InMemorySigner).keyStore;
  //   // var _networkId = near.config.networkId;
  //   // var _walletBaseUrl = near.config.walletUrl;
  //   var _walletBaseUrl = walletUrl;
  //   if (contractIdOrOptions is String) {
  //     // const deprecate = depd('requestSignIn(contractId, title)');
  //     // deprecate('`title` ignored; use `requestSignIn({ contractId, methodNames, successUrl, failureUrl })` instead');
  //     // options = { ...successUrl, failureUrl, 'contractId': contractIdOrOptions };
  //   } else {
  //     options = contractIdOrOptions;
  //   }

  //   const currentUrl = ''; // get from web view
  //   var newUrl = Uri.parse('$_walletBaseUrl + $loginWalletUrlSuffix');
  //   webViewController.loadUrl('${newUrl.toString()}', headers: {
  //     'success_url': options.successUrl ? options.successUrl : currentUrl
  //   });
  //   webViewController.loadUrl(newUrl.toString(), headers: {
  //     'failure_url': options.failureUrl ? options.failureUrl : currentUrl
  //   });

  //   // newUrl.searchParams.set('success_url', options.successUrl || currentUrl.href);
  //   // newUrl.searchParams.set('failure_url', options.failureUrl || currentUrl.href);
  //   if (options.contractId) {
  //     /* Throws exception if contract account does not exist */
  //     // var contractAccount = await _near.account(options.contractId);
  //     // await contractAccount.state();

  //     // newUrl.searchParams.set('contract_id', options.contractId);
  //     var accessKey = KeyPair().fromRandom('ed25519');

  //     webViewController.loadUrl(newUrl.toString(),
  //         headers: {'public_key': accessKey.getPublicKey().toString()});
  //     // newUrl.searchParams.set('public_key', accessKey.getPublicKey().toString());
  //     // await _keyStore.setKey(_networkId,
  //     //     pendingAccessKeySuffix + accessKey.getPublicKey(), accessKey);
  //   }

  //   if (options.methodNames) {
  //     options.methodNames.forEach((methodName) {
  //       // newUrl.searchParams.append('methodNames', methodName);
  //     });
  //   }
  //   webViewController.loadUrl(newUrl.toString());
  //   // window.location.assign(newUrl.toString()); // redirect to the app
  // }

  requestSignTransactions(List args, context) async {
    if (args[0] is List) {
      return _requestSignTransactions(
          {'transactions': args[0], 'callbackUrl': args[1], 'meta': args[2]},
          context);
    }

    return _requestSignTransactions(args[0], context);
  }

  Future _requestSignTransactions(
      Map<String, dynamic> requestTransactionOption, context) async {
    var currentUrl = walletUrl;
    // var newUrl =  URL('sign', _walletBaseUrl);

    // newUrl.searchParams.set('transactions', requestTransactionOption['transactions']
    //     .map((transaction) => jsonEncode(transaction.toJson()))
    //     .map((serialized) => base64.encode(serialized))
    //     .join(','));
    // newUrl.searchParams.set('callbackUrl', requestTransactionOption['callbackUrl'] ?? currentUrl.href);
    // if(requestTransactionOption['meta']) newUrl.searchParams.set('meta', requestTransactionOption['meta']);

    // window.location.assign(newUrl.toString());

    return Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => NearUrlLauncher(
            initialUrl: currentUrl,
            requestTransactionOption: requestTransactionOption,
            walletBaseUrl: walletUrl)));
  }

  ///view access key
  ///Returns information about a single access key for given account.
  ///parameters: accountId, publicKey

  Future<RPCResponse> viewAccessKey(String accountId) async {
    return JsonRPC('https://rpc.testnet.near.org').call('query', {
      "request_type": "view_access_key",
      "finality": "final",
      "account_id": "$accountId.testnet",
      "public_key": "ed25519:EJ8p7WMRJSccPgzNVMJppykHjMDmedqT3neJbeFfK6Qt"
    });
  }

  ///view access key list
  ///Returns all access keys for a given account.
  ///parameters: accountId

  Future viewAccessKeyList(String accountId) async {
    return JsonRPC('https://rpc.testnet.near.org').call('query', {
      "request_type": "view_access_key_list",
      "finality": "final",
      "account_id": "$accountId.testnet"
    });
  }

  ///Returns individual access key changes in a specific block.
  ///You can query multiple keys by passing an array of objects containing the account_id and public_key.
  ///parameters: accountId, public key
  ///example" walletAccount.viewAccessKeyChanges([
  ///                     {
  ///                       "account_id": "example-acct1.testnet",
  ///                       "public_key": "ed25519:25KEc7t7MQohAJ4EDThd2vkksKkwangnuJFzcoiXj9oM"
  ///                     },
  ///                     {
  ///                       "account_id": "example-acct2.testnet",
  ///                       "public_key": "ed25519:B4KGhtohjQohAJ4EDThd2vkksKkwangnuJBgrehD4tqd"
  ///                     },
  ///                   ])

  Future viewAccessKeyChanges(List<Map<String, dynamic>> listOfQuery) async {
    return JsonRPC('https://rpc.testnet.near.org')
        .call('EXPERIMENTAL_changes', {
      "changes_type": "single_access_key_changes",
      "keys": listOfQuery,
      "finality": "final"
    });
  }

  Future viewMethod(
      String contractId, String method, Map<String, dynamic>? params) async {
    return JsonRPC('https://rpc.testnet.near.org').call(method, params);
  }
}

class Signature {
  dynamic keyType;
  dynamic data;
}

class ConnectedWalletAccount extends Account {
  WalletAccount walletConnection;

  ConnectedWalletAccount({
    required this.walletConnection,
  }) : super(Connection('', '', null), '');

  // Overriding Account methods

  /// Sign a transaction by redirecting to the NEAR Wallet
  /// @see {@link WalletConnection.requestSignTransactions}
  @override
  Future<FinalExecutionOutcome?> signAndSendTransaction(args, context) async {
    if (args[0] is String) {
      return _signAndSendTransaction(context, args[0], args[1], null);
    }

    return _signAndSendTransaction(context, args[0]['receiverId'],
        args[0]['actions'], args[0]['walletMeta']);
  }

  Future<FinalExecutionOutcome?> _signAndSendTransaction(
      context, receiverId, actions, walletMeta) async {
    var walletCallbackUrl = walletUrl;
    var localKey =
        await connection.signer!.getPublicKey(accountId, connection.networkId);
    // var accessKey =
    //     await accessKeyForTransaction(receiverId, actions, localKey);
    // if (!accessKey) {
    //   throw Error();
    // }

    // if (localKey != null && localKey.toString() == accessKey.public_key) {
    //   try {
    //     return await signAndSendTransaction([receiverId, actions], context);
    //   } catch (e) {
    //     if (e.toString().contains('NotEnoughAllowance')) {
    //       accessKey = await accessKeyForTransaction(receiverId, actions, null);
    //     } else {
    //       rethrow;
    //     }
    //   }
    // }

    var block = await connection.provider.block({'finality': 'final'});

    // var blockHash = baseDecode(block.header.hash);
    var temp = Uint8List(block.header.hash);
    var list = List.from(temp);
    String s = list.toString();
    var blockHash = jsonDecode(s);
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
    Near near = Near(config);
    Account jst = await near.account('nearyonas.testnet');
    var x = await jst.getAccessKeys();

    var publicKey = x[0]['public_key'];
    // var publicKey = PublicKey.from(accessKey.public_key);
    var nonce = x[0]['public_key']['nonce'] + 1;
    var transaction = createTransaction(
        accountId, publicKey, receiverId, nonce, actions, blockHash);
    await walletConnection.requestSignTransactions([
      {
        'transactions': [transaction],
        'meta': walletMeta,
        'callbackUrl': walletCallbackUrl
      }
    ], context);

    return null;
  }

  /// Check if given access key allows the function call or method attempted in transaction
  /// accessKey Array of {access_key: AccessKey, public_key: PublicKey} items
  /// receiverId The NEAR account attempting to have access
  /// actions The action(s) needed to be checked for access
  // Future<bool> accessKeyMatchesTransaction(
  //     accessKey, String receiverId, List<Actn> actions) async {
  //   var permission = accessKey['permission'];
  //   if (permission == 'FullAccess') {
  //     return true;
  //   }

  //   if (permission.FunctionCall) {
  //     var allowedReceiverId = permission.FunctionCall['receiver_ids'];
  //     var allowedMethods = permission.FunctionCall['method_names'];
  //     //Accept multisig access keys and let wallets attempt to signAndSendTransaction
  //     //If an access key has itself as receiverId and method permission add_request_and_confirm, then it is being used in a wallet with multisig contract: https://github.com/near/core-contracts/blob/671c05f09abecabe7a7e58efe942550a35fc3292/multisig/src/lib.rs#L149-L153

  //     if (allowedReceiverId == accountId &&
  //         allowedMethods.contains('MULTISIG_HAS_METHOD')) {
  //       return true;
  //     }
  //     if (allowedReceiverId == receiverId) {
  //       if (actions.length != 1) {
  //         return false;
  //       }
  //       var functionCall = actions[0].functionCall;
  //       return functionCall != null &&
  //           (functionCall.deposit != null ||
  //               functionCall.deposit.toString() == '0') &&
  //           (allowedMethods.length == 0 ||
  //               allowedMethods.includes(functionCall.methodName));
  //     }
  //   }

  //   return false;
  // }

  /// Helper function returning the access key (if it exists) to the receiver that grants the designated permission
  /// receiverId The NEAR account seeking the access key for a transaction
  /// actions The action(s) sought to gain access to
  /// localKey A local public key provided to check for access
  /// @returns Future<any>
  // Future<dynamic> accessKeyForTransaction(
  //     String receiverId, List<Actn> actions, PublicKey? localKey) async {
  //   var accessKeys = await getAccessKeys();

  //   if (localKey != null) {
  //     var accessKey = accessKeys
  //         .where((key) => key.public_key.toString() == localKey.toString());
  //     if (accessKey != null &&
  //         await accessKeyMatchesTransaction(accessKey, receiverId, actions)) {
  //       return accessKey;
  //     }
  //   }

  //   WalletAccount walletAccount = WalletAccount('nearyonas.testnet');

  //   var walletKeys = await walletAccount.getStoredKey();
  //   for (var accessKey in accessKeys) {
  //     if (walletKeys!.contains(accessKey.public_key) &&
  //         await accessKeyMatchesTransaction(accessKey, receiverId, actions)) {
  //       return accessKey;
  //     }
  //   }

  //   return null;
  // }
}
