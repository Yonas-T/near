import './account.dart';
import './providers/provider.dart';

// Makes `function.name` return given name
// // function nameFunction(String name, body: (args?: any[]) => {}) {
//     return {
//         [name](...args: any[]) {
//             return body(...args);
//         }
//     }[name];
// }

isUint8Array(x) => x && x.byteLength != null && x.byteLength == x.length;

//  isObject (x) =>
//     Object.prototype.toString.call(x) == '[object Object]';

abstract class ChangeMethodOptions {
  dynamic args;
  String methodName;
  BigInt? gas;
  BigInt? amount;
  String? meta;
  String? callbackUrl;
  ChangeMethodOptions({
    required this.args,
    required this.methodName,
    this.gas,
    this.amount,
    this.meta,
    this.callbackUrl,
  });
}

abstract class ContractMethods {
  /// Methods that change state. These methods cost gas and require a signed transaction.
  ///
  /// @see {@link Account.functionCall}
  List<String> changeMethods;

  /// View methods do not require a signed transaction.
  ///
  /// @@see {@link Account.viewFunction}
  List<String> viewMethods;
  ContractMethods({
    required this.changeMethods,
    required this.viewMethods,
  });
}

/// Defines a smart contract on NEAR including the change (mutable) and view (non-mutable) methods
///
/// @example {@link https://docs.near.org/docs/develop/front-end/naj-quick-reference#contract}
/// @example
/// ```js
/// import { Contract } from 'near-api-js';
///
/// async function contractExample() {
///   const methodOptions = {
///     viewMethods: ['getMessageByAccountId'],
///     changeMethods: ['addMessage']
///   };
///   const contract = new Contract(
///     wallet.account(),
///     'contract-id.testnet',
///     methodOptions
///   );
///
///   // use a contract view method
///   const messages = await contract.getMessages({
///     accountId: 'example-account.testnet'
///   });
///
///   // use a contract change method
///   await contract.addMessage({
///      meta: 'some info',
///      callbackUrl: 'https://example.com/callback',
///      args: { text: 'my message' },
///      amount: 1
///   })
/// }
/// ```
class Contract {
  Account account;
  String contractId;
  ContractMethods? options;
  Contract({
    required this.account,
    required this.contractId,
    this.options
  });

  /// account NEAR account to sign change method transactions
  /// contractId NEAR account id where the contract is deployed
  /// options NEAR smart contract methods that your application will use. These will be available as `contract.methodName`

  _changeMethod(args, methodName, gas, amount, meta, callbackUrl) async {
    validateBNLike({'gas': gas, 'amount': amount});

    var rawResult = await account.call([
      {
        'contractId': contractId,
        'methodName': methodName,
        'args': args,
        'gas': gas,
        'attachedDeposit': amount,
        'walletMeta': meta,
        'walletCallbackUrl': callbackUrl
      }
    ]);

    return getTransactionLastResult(rawResult!);
  }
}

/// Validation on arguments being a big number from bn.js
/// Throws if an argument is not in BN format or otherwise invalid
/// argMap
validateBNLike(Map<String, dynamic> argMap) {
  const bnLike = 'number, decimal string or BN';
  for (var argName in argMap.keys.toList()) {
    var argValue = argMap[argName];
    if (argValue && argValue.isValidInt && argValue.isNaN) {
      throw Exception([argName, bnLike, argValue]);
    }
  }
}
