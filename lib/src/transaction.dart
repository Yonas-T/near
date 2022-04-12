import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../near_flutter.dart';
import './signer.dart';
import './utils/key_pair.dart';

import 'package:tweetnacl/tweetnacl.dart' as tweetNacl;
// import { serialize, deserialize } from 'borsh';

class FunctionCallPermission {
  BigInt allowance;
  String receiverId;
  List<String> methodNames;
  FunctionCallPermission({
    required this.allowance,
    required this.receiverId,
    required this.methodNames,
  });
}

class FullAccessPermission {}

class AccessKeyPermission {
  FunctionCallPermission? functionCall;
  FullAccessPermission? fullAccess;
  AccessKeyPermission({
    this.functionCall,
    this.fullAccess,
  });
}

class AccessKey {
  int nonce;
  AccessKeyPermission permission;
  AccessKey({
    required this.nonce,
    required this.permission,
  });
}

AccessKey fullAccessKey() {
  return AccessKey(
      nonce: 0,
      permission: AccessKeyPermission(fullAccess: FullAccessPermission()));
}

AccessKey functionCallAccessKey(
    String receiverId, List<String> methodNames, BigInt allowance) {
  return AccessKey(
      nonce: 0,
      permission: AccessKeyPermission(
          functionCall: FunctionCallPermission(
              receiverId: receiverId,
              allowance: allowance,
              methodNames: methodNames)));
}

class IActn {}

class CreateAccount extends IActn {}

class DeployContract extends IActn {
  dynamic code;
  DeployContract({
    required this.code,
  });
}

class FunctionCall extends IActn {
  String? methodName;
  dynamic args;
  BigInt? gas;
  BigInt? deposit;
  FunctionCall({
    this.methodName,
    this.args,
    this.gas,
    this.deposit,
  });
}

class Transfer extends IActn {
  dynamic deposit;
  Transfer({
    this.deposit,
  });
  factory Transfer.fromJson(Map<String, dynamic> json) => Transfer(
        deposit: json['deposit'] == null ? null : BigInt.parse(json['deposit']),
      );

  toJson() => {
        'deposit': deposit == null ? null : deposit.toString(),
      };
}

class Stake extends IActn {
  BigInt? stake;
  PublicKey? publicKey;
  Stake({
    this.stake,
    this.publicKey,
  });
}

class AddKey extends IActn {
  PublicKey? publicKey;
  AccessKey? accessKey;
  AddKey({
    this.publicKey,
    this.accessKey,
  });
}

class DeleteKey extends IActn {
  PublicKey? publicKey;
  DeleteKey({
    this.publicKey,
  });
}

class DeleteAccount extends IActn {
  String? beneficiaryId;
  DeleteAccount({
    this.beneficiaryId,
  });
}

// Actn createAccount() {
//   return Actn(createAccount: CreateAccount());
// }

// Actn deployContract(dynamic code) {
//   return Actn(deployContract: DeployContract(code: code));
// }

stringifyJsonOrBytes(dynamic args) {
  var isUint8Array = args.byteLength != null && args.byteLength == args.length;
  final re = Uint8List(args)..buffer.asByteData().setUint64(0, 64);
  var cList = re.reversed.toList();
  var serializedArgs = isUint8Array ? args : cList;
  return serializedArgs;
}

/// Constructs {@link Actn} instance representing contract method call.
///
/// methodName the name of the method to call
/// args arguments to pass to method. Can be either plain JS object which gets serialized as JSON automatically
///  or `Uint8Array` instance which represents bytes passed as is.
/// gas max amount of gas that method call can use
/// deposit amount of NEAR (in yoctoNEAR) to send together with the call
/// stringify Convert input arguments into bytes array.
// Actn functionCall(String methodName, dynamic args, BigInt gas, BigInt deposit,
//     Function stringify) {
//   return Actn(
//       functionCall: FunctionCall(
//           methodName: methodName,
//           args: stringify(args),
//           gas: gas,
//           deposit: deposit));
// }

Actn transfer(deposit) {
  return Actn(transfer: Transfer(deposit: deposit));
}

// Actn stake(BigInt stake, PublicKey publicKey) {
//   return Actn(stake: Stake(stake: stake, publicKey: publicKey));
// }

// Actn addKey(PublicKey publicKey, AccessKey accessKey) {
//   return Actn(addKey: AddKey(publicKey: publicKey, accessKey: accessKey));
// }

// Actn deleteKey(PublicKey publicKey) {
//   return Actn(deleteKey: DeleteKey(publicKey: publicKey));
// }

// Actn deleteAccount(String beneficiaryId) {
//   return Actn(deleteAccount: DeleteAccount(beneficiaryId: beneficiaryId));
// }

class _Signature {
  dynamic keyType; //TODO: make type KeyType
  dynamic data;
  _Signature({
    required this.keyType,
    required this.data,
  });

  factory _Signature.fromJson(Map<String, dynamic> json) =>
      _Signature(keyType: json["keyType"], data: json["data"]);

  toJson() {
    return {
      "keyType": keyType,
      "data": data,
    };
  }
}

class Transaction {
  String? signerId;
  dynamic publicKey;
  dynamic nonce;
  String? receiverId;
  List actions;
  dynamic blockHash;
  Transaction({
    this.signerId,
    this.publicKey,
    this.nonce,
    this.receiverId,
    required this.actions,
    this.blockHash,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      signerId: json['signerId'] as String,
      publicKey: json.containsKey('publicKey')
          ? PublicKey.fromJson(json['publicKey'])
          : null,
      nonce: json.containsKey('nonce') ? json['nonce'] : null,
      receiverId:
          json.containsKey('receiverId') ? json['receiverId'] as String : null,
      actions: (json['actions'] as List<dynamic>)
          .map((actn) => Actn.fromJson(Actn as Map<String, dynamic>))
          .toList(),
      blockHash: json['blockHash'],
    );
  }

  toJson() {
    return {
      'signerId': signerId,
      'publicKey': publicKey,
      'nonce': nonce,
      'receiverId': receiverId,
      'actions': actions.map((actn) => actn.toJson()).toList(),
      'blockHash': blockHash,
    };
  }
}

class SignedTransaction {
  Transaction transaction;
  dynamic signature;
  SignedTransaction({
    required this.transaction,
    required this.signature,
  });

  factory SignedTransaction.fromJson(Map<String, dynamic> json) {
    return SignedTransaction(
      transaction:
          Transaction.fromJson(json['transaction'] as Map<String, dynamic>),
      signature: _Signature.fromJson(json['signature'] as Map<String, dynamic>),
    );
  }

  toJson() {
    return {
      'transaction': transaction.toJson(),
      'signature': signature,
    };
  }
}

/// Contains a list of the valid Transaction actions available with this API
/// @see {@link https://nomicon.io/RuntimeSpec/actions.html | actions Spec}
class Actn {
  // CreateAccount? createAccount;
  // DeployContract? deployContract;
  // FunctionCall? functionCall;
  Transfer? transfer;
  // Stake? stake;
  // AddKey? addKey;
  // DeleteKey? deleteKey;
  // DeleteAccount? deleteAccount;
  Actn({
    // this.createAccount,
    // this.deployContract,
    // this.functionCall,
    this.transfer,
    // this.stake,
    // this.addKey,
    // this.deleteKey,
    // this.deleteAccount,
  });

  factory Actn.fromJson(Map<String, dynamic> json) {
    return Actn(
      // createAccount: json['createAccount'],
      // deployContract: json['deployContract'],
      // functionCall: json['functionCall'],
      transfer: json['transfer'],
      // stake: json['stake'],
      // addKey: json['addKey'],
      // deleteKey: json['deleteKey'],
      // deleteAccount: json['deleteAccount'],
    );
  }

  toJson() {
    return {
      // 'createAccount': createAccount,
      // 'deployContract': deployContract,
      // 'functionCall': functionCall,
      'transfer': transfer!.toJson(),
      // 'stake': stake,
      // 'addKey': addKey,
      // 'deleteKey': deleteKey,
      // 'deleteAccount': deleteAccount,
    };
  }
}

Transaction createTransaction(String signerId, dynamic publicKey,
    String receiverId, dynamic nonce, List actions, dynamic blockHash) {
  return Transaction(
      signerId: signerId,
      publicKey: PublicKey('ed25519', publicKey).toJson(),
      nonce: nonce,
      receiverId: receiverId,
      actions: actions,
      blockHash: blockHash);
}

///Signs a given Transaction from an account with given keys, applied to the given network
/// Transaction The Transaction object to sign
/// signer The {Signer} object that assists with signing keys
/// accountId The human-readable NEAR account name
/// networkId The targeted network. (ex. default, betanet, etc…)

Future signTransactionObject(Transaction transaction, Signer signer,
    String? accountId, String? networkId) async {
  // var message = serialize(SCHEMA, Transaction);
  var a = tweetNacl.Box.keyPair();
  log('______--------------________' + a.publicKey.toString());
  var pubk = {'keyType': 0, 'data': a.publicKey};
  var transactionJson = {
    'signerId': transaction.signerId,
    'publicKey': pubk,
    'nonce': transaction.nonce,
    'receiverId': transaction.receiverId,
    'actions': [transaction.actions[0].toJson()],
    'blockHash': transaction.blockHash
  };
  print('transaction OBJECT: ' + transactionJson.toString());
  var message = jsonEncode(transactionJson);
  // List<int> list = message.codeUnits;
  // Uint8List hash = Uint8List.fromList(list);

  final bytes = utf8.encode(message);
  final base64Str = base64.encode(bytes);
  // const base64Str =
  //     'e3NpZ25lcklkOiBuZWFyeW9uYXMudGVzdG5ldCwgcHVibGljS2V5OiBlZDI1NTE5OmVkMjU1MTk6RUo4cDdXTVJKU2NjUGd6TlZNSnBweWtIak1EbWVkcVQzbmVKYmVGZks2UXQsIG5vbmNlOiA4MDgwMDE4NTAwMDAwMiwgcmVjZWl2ZXJJZDogdGVzdC50ZXN0bmV0LCBhY3RuczogW3t0cmFuc2Zlcjoge2RlcG9zaXQ6IDEwMDAwMDAwMDAwMDA1fX1dLCBibG9ja0hhc2g6IE5uVlRZVVZ3VTNwVVJqWjJaMmhWVjNORVpUaHpORUkwVFVaVFZWazRPVmhaZGxoNVVEaFNjVWRVZEUwPX0=';

  var _signature = await signer.signMessage(base64Str, accountId, networkId);
  log('Sgnn: ' + _signature.toString());
  var signedTx = SignedTransaction(
    transaction: transaction,
    signature: _signature,
  );
  return [base64Str, signedTx];
}

Future signTransaction(
    Transaction transaction,
    List actions,
    Signer signer,
    String accountId,
    String? networkId,
    String receiverId,
    dynamic nonce,
    dynamic blockHash) async {
  if (transaction is Transaction) {
    return signTransactionObject(transaction, signer, accountId, networkId);
  } else {
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
    // var publicKey = await signer.
    // getPublicKey(accountId, networkId);
    var transaction = createTransaction(
        accountId, publicKey, receiverId, nonce, actions, blockHash);
    return signTransactionObject(transaction, signer, accountId, networkId);
  }
}
