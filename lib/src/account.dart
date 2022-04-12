import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import '../near_flutter.dart';
import './connection.dart';
import './transaction.dart' as transact;
import './providers/provider.dart';

import 'dart:typed_data';

import 'package:bs58/bs58.dart';

import './transaction.dart';
import './utils/key_pair.dart';

import './utils/exponential_backoff.dart';
import 'package:tweetnacl/tweetnacl.dart' as tweetNacl;

var DEFAULT__CALL_GAS = BigInt.from(30000000000000);

// Default number of retries with different nonce before giving up on a transaction.
const TX_NONCE_RETRY_NUMBER = 12;

// Default wait until next retry in millis.
const TX_NONCE_RETRY_WAIT = 500;

// Exponential back off for waiting to retry.
const TX_NONCE_RETRY_WAIT_BACKOFF = 1.5;

class AccountBalance {
  String total;
  String stateStaked;
  String staked;
  String available;
  AccountBalance({
    required this.total,
    required this.stateStaked,
    required this.staked,
    required this.available,
  });
}

class AccountAuthorizedApp {
  String contractId;
  String amount;
  String publicKey;
  AccountAuthorizedApp({
    required this.contractId,
    required this.amount,
    required this.publicKey,
  });
}

/// Options used to initiate sining and sending transactions
class SignAndSendTransactionOptions {
  String receiverId;
  List actions;

  /// Metadata to send the NEAR Wallet if using it to sign transactions.
  /// @see {@link RequestSignTransactionsOptions}
  String? walletMeta;

  /// Callback url to send the NEAR Wallet if using it to sign transactions.
  /// @see {@link RequestSignTransactionsOptions}
  String? walletCallbackUrl;
  bool? returnError;
  SignAndSendTransactionOptions({
    required this.receiverId,
    required this.actions,
    this.walletMeta,
    this.walletCallbackUrl,
    this.returnError,
  });
}

/// Options used to initiate a  call (especially a change  call)
/// @see {@link view} to initiate a view  call
class CallOptions {
  /// The NEAR account id where the contract is deployed */
  String contractId;

  /// The name of the method to invoke */
  String methodName;

  /// named arguments to pass the method `{ messageText: 'my message' }`
  dynamic args;

  /// max amount of gas that method call can use */
  BigInt? gas;

  /// amount of NEAR (in yoctoNEAR) to send together with the call */
  BigInt? attachedDeposit;

  /// Metadata to send the NEAR Wallet if using it to sign transactions.
  /// @see {@link RequestSignTransactionsOptions}
  String? walletMeta;

  /// Callback url to send the NEAR Wallet if using it to sign transactions.
  /// @see {@link RequestSignTransactionsOptions}
  String? walletCallbackUrl;
  CallOptions({
    required this.contractId,
    required this.methodName,
    required this.args,
    this.gas,
    this.attachedDeposit,
    this.walletMeta,
    this.walletCallbackUrl,
  });

  /// Convert input arguments into bytes array.
  stringify(dynamic input) {
    List<int> list = input.toString().codeUnits;
    Uint8List byteD = Uint8List.fromList(list);
    return byteD;
  }
}

class ReceiptLogWithFailure {
  List<String> receiptIds;
  List<String> logs;
  dynamic failure; //Server Error
  ReceiptLogWithFailure({
    required this.receiptIds,
    required this.logs,
    required this.failure,
  });
}

parseJsonFromRawResponse(response) {
  var str = const Utf8Decoder().convert(response);

  return jsonDecode(str);
}

bytesJsonStringify(input) {
  var list = const Utf8Encoder().convert(input);
  var data = list is Uint8List ? list.buffer : Uint8List.fromList(list).buffer;
  return data;
}

/// This class provides common account related RPC calls including signing transactions with a {@link KeyPair}.
///
/// @example {@link https://docs.near.org/docs/develop/front-end/naj-quick-reference#account}
/// @hint Use {@link WalletConnection} in the browser to redirect to {@link https://docs.near.org/docs/tools/near-wallet | NEAR Wallet} for Account/key management using the {@link BrowserLocalStorageKeyStore}.
/// @see {@link https://nomicon.io/DataStructures/Account.html | Account Spec}
class Account {
  Connection connection;
  String accountId;

  Account(this.connection, this.accountId);

  /// @hidden */
  // Future<void> get ready() async{
  //     const deprecate = depd('Account.ready()');
  //     deprecate('not needed anymore, always ready');
  //     return Future.resolve();
  // }

  Future<void> fetchState() async {
    // const deprecate = depd('Account.fetchState()');
    // deprecate('use `Account.state()` instead');
  }

  /// Returns basic NEAR account information via the `view_account` RPC query method
  /// @see {@link https://docs.near.org/docs/develop/front-end/rpc#view-account}
  Future<AccountView?> state() async {
    print('========================');
    var b = await connection.provider.query({
      'request_type': 'view_account',
      'account_id': accountId,
      'finality': 'optimistic'
    });
    AccountView accountView = AccountView.fromJson(b);
    print('bbbbbb: ' + b.toString());
    return accountView;
  }

  /// Create a signed transaction which can be broadcast to the network
  /// receiverId NEAR account receiving the transaction
  /// actions list of actions to perform as part of the transaction
  /// @see {@link JsonRpcProvider.sendTransaction}
  Future signTransact(String receiverId, List actions) async {
    // var accessKeyInfo = await findAccessKey(receiverId, actions);

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

    print('vvv' + x.toString());
    var accessKey = x[0]['access_key'];
    // if (!accessKeyInfo) {
    //   throw Exception(
    //       'Can not sign transactions for account $accountId on network ${connection.networkId}, no matching key pair found in ${connection.signer}.'
    //       'KeyNotFound');
    // }
    // var accessKey = accessKeyInfo['accessKey'];

    var block = await connection.provider.block({'finality': 'final'});

    var blockHash = base58.decode(block['header']['hash']);
    var transaction;
    log('BLOCK h: ' + block['header']['hash'].toString());

    print('BLOCK HASH: ' + blockHash.toString());
    var nonce = ++accessKey['nonce'];

    // final bytes = utf8.encode(blockHash);
    // final base64Str = base64.encode(bytes);
    return await signTransaction(
      transaction,
      actions,
      connection.signer!,
      accountId,
      connection.networkId,
      receiverId,
      nonce,
      blockHash,
    );
  }

  /// Sign a transaction to preform a list of actions and broadcast it using the RPC API.
  /// @see {@link JsonRpcProvider.sendTransaction}
  ///
  /// receiverId NEAR account receiving the transaction
  /// actions list of actions to perform as part of the transaction
  Future<FinalExecutionOutcome?> signAndSendTransaction(
      receiverId, List actions) async {
    return receiverId is String
        ? signAndSendTransactionV1(receiverId, actions)
        : signAndSendTransactionV2(receiverId);
  }

  Future<FinalExecutionOutcome> signAndSendTransactionV1(
      dynamic receiverId, List actions) async {
    var c =
        SignAndSendTransactionOptions(receiverId: receiverId, actions: actions);
    return signAndSendTransactionV2(c);
  }

  Future<FinalExecutionOutcome> signAndSendTransactionV2(
      SignAndSendTransactionOptions a) async {
    dynamic txHash;
    SignedTransaction signedTx;
    var result = await exponentialBackoff(
        TX_NONCE_RETRY_WAIT, TX_NONCE_RETRY_NUMBER, TX_NONCE_RETRY_WAIT_BACKOFF,
        () async {
      var sign = await signTransact(a.receiverId, a.actions);
      txHash = sign[0];
      signedTx = sign[1];
      var ab = tweetNacl.Box.keyPair();
      log('______--------------________' + sign.toString());
      var pubk = {'keyType': 0, 'data': ab.publicKey};
      transact.Transaction tr = transact.Transaction(
        signerId: signedTx.transaction.signerId,
        publicKey: pubk,
        nonce: signedTx.transaction.nonce,
        receiverId: signedTx.transaction.receiverId,
        actions: signedTx.transaction.actions,
        blockHash: signedTx.transaction.blockHash,
      );
      SignedTransaction tran = SignedTransaction(
        signature: {
          'signature': sign[1].signature['signature'],
          'publicKey': ab.publicKey,
        },
        transaction: tr,
      );

      print('SIGNED TX: ' + signedTx.transaction.toJson().toString());
      print('SIGNED sign: ' + signedTx.signature.toString());

      var publicKey = signedTx.transaction.publicKey;

      try {
        return await connection.provider.sendTransaction(tran);
      } catch (error) {
        var errStr = error.toString();
        if (errStr.contains('InvalidNonce')) {
          accessKeyByPublicKeyCache.remove(publicKey.toString());
          return null;
        }
        if (errStr.contains('Expired')) {
          return null;
        }

        rethrow;
      }
    });
    if (result == null) {
      throw Exception(
          'nonce retries exceeded for transaction. This usually means there are too many parallel requests with the same access key.'
          'RetriesExceeded');
    }

    var flatLogs = [result.transaction_outcome, ...result.receipts_outcome]
        .reduce((acc, it) => {
              // if (it.outcome.logs.length ||
              //     (it.outcome.status is Object && it.outcome.status.Failure is Object)) {
              //     return acc.concat({
              //         'receiptIds': it.outcome.receipt_ids,
              //         'logs': it.outcome.logs,
              //         'failure': it.outcome.status.Failure != null ? parseRpcError(it.outcome.status.Failure) : null
              //     });
              // } else
              acc
            });

    if (result.status is Object && result.status.Failure is Object) {
      // if error data has error_message and error_type properties, we consider that node returned an error in the old format
      if (result.status.Failure.error_message &&
          result.status.Failure.error_type) {
        throw Exception(
            'Transaction ${result.transaction_outcome.id} failed. ${result.status.Failure.error_message}'
            '${result.status.Failure.error_type}');
      } else {
        throw Exception(result);
      }
    }
    // TODO: if Tx is Unknown or Started.
    return result;
  }

  Map<String, AccessKeyView> accessKeyByPublicKeyCache = {};

  /// Finds the {@link AccessKeyView} associated with the accounts {@link PublicKey} stored in the {@link KeyStore}.
  ///
  /// receiverId currently unused (see todo)
  /// actions currently unused (see todo)
  /// @returns `{ publicKey PublicKey; accessKey: AccessKeyView }`
  Future findAccessKey(String receiverId, List actions) async {
    // var publicKey =
    //     await connection.signer!.getPublicKey(accountId, connection.networkId);
    var s = await WalletAccount('nearyonas.testnet').getStoredKey();
    var publicKey = Uint8List.fromList(s!.codeUnits);
    log(publicKey.toString());
    var cachedAccessKey = accessKeyByPublicKeyCache[publicKey.toString()];
    if (cachedAccessKey != null) {
      return {'publicKey': publicKey, 'accessKey': cachedAccessKey};
    }

    try {
      var accessKey = await connection.provider.query<AccessKeyView>({
        'request_type': 'view_access_key',
        'account_id': accountId,
        'public_key': publicKey.toString(),
        'finality': 'optimistic'
      });

      // this  can be called multiple times and retrieve the same access key
      // this checks to see if the access key was already retrieved and cached while
      // the above network call was in flight. To keep nonce values in line, we return
      // the cached access key.
      if (accessKeyByPublicKeyCache[publicKey.toString()] != null) {
        return {
          'publicKey': publicKey,
          'accessKey': accessKeyByPublicKeyCache[publicKey.toString()]
        };
      }

      accessKeyByPublicKeyCache[publicKey.toString()] = accessKey;
      return {'publicKey': publicKey, 'accessKey': accessKey};
    } catch (e) {
      if (e.toString().contains('AccessKeyDoesNotExist')) {
        return null;
      }
      rethrow;
    }
  }

  /// Create a new account and deploy a contract to it
  ///
  /// contractId NEAR account where the contract is deployed
  /// publicKey The public key to add to the created contract account
  /// data The compiled contract code
  /// amount of NEAR to transfer to the created contract account. Transfer enough to pay for storage https://docs.near.org/docs/concepts/storage-staking

  Future<Account> createAndDeployContract(
      String contractId, dynamic publicKey, dynamic data, BigInt amount) async {
    var accessKey = fullAccessKey();
    await signAndSendTransaction(contractId, [
      createAccount(contractId, publicKey, amount),
      transfer(amount),
      addKey(PublicKey.from(publicKey), '', accessKey, BigInt.one),
      deployContract(data)
    ]);
    var contractAccount = Account(connection, contractId);
    return contractAccount;
  }

  /// receiverId NEAR account receiving
  /// amount Amount to send in yocto
  Future<FinalExecutionOutcome?> sendMoney(
      String receiverId, dynamic amount) async {
    return signAndSendTransaction(receiverId, [transfer(amount)]);
  }

  /// newAccountId NEAR account name to be created
  /// publicKey A public key created from the masterAccount
  Future<FinalExecutionOutcome?> createAccount(
      String newAccountId, dynamic publicKey, BigInt amount) async {
    var accessKey = fullAccessKey();
    return signAndSendTransaction(newAccountId, [
      createAccount(newAccountId, publicKey, amount),
      transfer(amount),
      addKey(PublicKey.from(publicKey), '', accessKey, BigInt.one)
    ]);
  }

  /// beneficiaryId The NEAR account that will receive the remaining Ⓝ balance from the account being deleted
  deleteAccount(String beneficiaryId) async {
    return signAndSendTransaction(accountId, [deleteAccount(beneficiaryId)]);
  }

  /// data The compiled contract code
  Future<FinalExecutionOutcome?> deployContract(data) async {
    return signAndSendTransaction(accountId, [deployContract(data)]);
  }

  /// contractId NEAR account where the contract is deployed
  /// methodName The method name on the contract as it is written in the contract code
  /// args arguments to pass to method. Can be either plain JS object which gets serialized as JSON automatically
  ///  or `Uint8Array` instance which represents bytes passed as is.
  /// gas max amount of gas that method call can use
  /// amount amount of NEAR (in yoctoNEAR) to send together with the call
  /// @returns {Future<FinalExecutionOutcome>}

  Future<FinalExecutionOutcome?> call(List args) async {
    if (args[0] is String) {
      return callV1(args[0], args[1], args[2], args[3], args[4]);
    } else {
      return callV2(args[0]);
    }
  }

  Future<FinalExecutionOutcome?> callV1(String contractId, String methodName,
      dynamic args, BigInt? gas, BigInt? amount) async {
    args = args ?? {};
    validateArgs(args);
    return signAndSendTransaction(contractId, [
      call([methodName, args, gas ?? DEFAULT__CALL_GAS, amount])
    ]);
  }

  Future<FinalExecutionOutcome?> callV2(CallOptions co) async {
    validateArgs(co.args);
    var stringifyArg = co.stringify;
    return signAndSendTransaction(
      co.contractId,
      [
        call([co.methodName, co.args, co.gas, co.attachedDeposit, stringifyArg])
      ],
      // co.walletMeta,
      // co.walletCallbackUrl
    );
  }

  /// @see {@link https://docs.near.org/docs/concepts/account#access-keys}
  /// @todo expand this API to support more options.
  /// publicKey A public key to be associated with the contract
  /// contractId NEAR account where the contract is deployed
  /// methodNames The method names on the contract that should be allowed to be called. Pass null for no method names and '' or [] for any method names.
  /// amount Payment in yoctoⓃ that is sent to the contract during this  call
  Future<FinalExecutionOutcome?> addKey(dynamic publicKey, String? contractId,
      dynamic methodNames, BigInt? amount) async {
    if (!methodNames) {
      methodNames = [];
    }
    if (methodNames is List) {
      methodNames = [methodNames];
    }
    var accessKey;
    if (contractId != null) {
      accessKey = fullAccessKey();
    } else {
      accessKey = functionCallAccessKey(contractId!, methodNames, amount!);
    }
    return signAndSendTransaction(accountId,
        [addKey(PublicKey.from(publicKey), '', accessKey, BigInt.one)]);
  }

  /// publicKey The public key to be deleted
  /// @returns {Promise<FinalExecutionOutcome>}
  Future<FinalExecutionOutcome?> deleteKey(dynamic publicKey) {
    return signAndSendTransaction(
        accountId, [deleteKey(PublicKey.from(publicKey))]);
  }

  /// @see {@link https://docs.near.org/docs/validator/staking-overview}
  ///
  /// publicKey The public key for the account that's staking
  /// amount The account to stake in yoctoⓃ
  Future<FinalExecutionOutcome?> stake(dynamic publicKey, BigInt amount) async {
    return signAndSendTransaction(
        accountId, [stake(amount, PublicKey.from(publicKey))]);
  }

  /// @hidden */
  validateArgs(dynamic args) {
    var argByte = const Utf8Encoder().convert(jsonEncode(args));

    var isUint8Array = argByte.isNotEmpty && argByte.length == args.length;
    if (isUint8Array) {
      return;
    }

    if (args is List || args is! Object) {
      throw Error();
    }
  }

  /// Invoke a contract view  using the RPC API.
  /// @see {@link https://docs.near.org/docs/develop/front-end/rpc#call-a-contract-}
  ///
  /// contractId NEAR account where the contract is deployed
  /// methodName The view-only method (no state mutations) name on the contract as it is written in the contract code
  /// args Any arguments to the view contract method, wrapped in JSON
  /// options.parse Parse the result of the call. Receives a Buffer (bytes array) and converts it to any object. By default result will be treated as json.
  /// options.stringify Convert input arguments into a bytes array. By default the input is treated as a JSON.
  Future<dynamic> view(
    String contractId,
    String methodName,
    args,
    // {parse = parseJsonFromRawResponse,
    // stringify = bytesJsonStringify}
  ) async {
    validateArgs(args);
    var serializedArgs = base64.encode(utf8.encode(jsonEncode(args)));

    var result = await connection.provider.query({
      'request_type': 'call_function',
      'account_id': contractId,
      'method_name': methodName,
      'args_base64': serializedArgs,
      'finality': 'optimistic'
    });

    return result;
    //  &&
    //     result['result'].length > 0 &&
    //     jsonDecode(base64.encode(utf8.encode(result.result)));
  }

  /// Returns the state (key value pairs) of this account's contract based on the key prefix.
  /// Pass an empty string for prefix if you would like to return the entire state.
  /// @see {@link https://docs.near.org/docs/develop/front-end/rpc#view-contract-state}
  ///
  /// prefix allows to filter which keys should be returned. Empty prefix means all keys. String prefix is utf-8 encoded.
  /// blockQuery specifies which block to query state at. By default returns last "optimistic" block (i.e. not necessarily finalized).
  // Future<List<Map<dynamic, dynamic>>> viewState(prefix, blockQuery) async {
  //   var values = await connection.provider.query<ViewStateResult>({
  //     'request_type': 'view_state',
  //     ...blockQuery,
  //     'account_id': accountId,
  //     'prefix_base64': base64.decode(prefix)
  //   });
  //   return values.map(({key, value}) => ({
  //         key: base64.encode(utf8.encode(key)),
  //         value: base64.encode(utf8.encode(value))
  //       }));
  // }

  /// Get all access keys for the account
  /// @see {@link https://docs.near.org/docs/develop/front-end/rpc#view-access-key-list}
  Future<dynamic> getAccessKeys() async {
    var response = await connection.provider.query<dynamic>({
      'request_type': 'view_access_key_list',
      'account_id': accountId,
      'finality': 'optimistic'
    });
    // A breaking API change introduced extra information into the
    // response, so it now returns an object with a `keys` field instead
    // of an array: https://github.com/nearprotocol/nearcore/pull/1789
    if (response is List<AccessKeyInfoView>) {
      return response;
    }
    return response['keys'];
  }

  /// Returns a list of authorized apps
  /// @todo update the response value to return all the different keys, not just app keys.
  Future getAccountDetails() async {
    // Also if we need this , or getAccessKeys is good enough.
    var accessKeys = await getAccessKeys();
    var authorizedApps = accessKeys
        .where((item) => item.access_key.permission != 'FullAccess')
        .map((item) {
      var perm = item.access_key.permission as FunctionCallPermissionView;
      return {
        'contractId': perm.receiver_id,
        'amount': perm.allowance,
        'publicKey': item.public_key,
      };
    });
    return {authorizedApps};
  }

  /// Returns calculated account balance
  Future<AccountBalance> getAccountBalance() async {
    var protocolConfig = await connection.provider
        .experimental_protocolConfig({'finality': 'final'});
    var state = await this.state();
    var costPerByte = BigInt.from(
        num.parse(protocolConfig.runtime_config['storage_amount_per_byte']));
    var stateStaked = BigInt.from(state!.storage_usage) * costPerByte;
    var staked = BigInt.tryParse(state.locked);
    print('-----------------------');

    var totalBalance = BigInt.tryParse(state.amount)! + staked!;
    var availableBalance = staked > stateStaked
        ? totalBalance - staked
        : totalBalance - stateStaked;
    AccountBalance accBalance = AccountBalance(
        total: totalBalance.toString(),
        stateStaked: stateStaked.toString(),
        staked: staked.toString(),
        available: availableBalance.toString());
    print('++++++++++++');
    // print(accBalance);
    return accBalance;
  }
}
