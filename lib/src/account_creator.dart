import 'dart:convert';

import 'package:near_flutter/src/utils/web.dart';

import './account.dart';
import './connection.dart';
//  import { fetchJson } from './utils/web';
import './utils/key_pair.dart';

/// Account creator provides an interface for implementations to actually create accounts
abstract class AccountCreator {
  Future<void> createAccount(String newAccountId, PublicKey publicKey);
}

class LocalAccountCreator extends AccountCreator {
  Account masterAccount;
  BigInt initialBalance;

  LocalAccountCreator(
    this.masterAccount,
    this.initialBalance,
  );

  /// Creates an account using a masterAccount, meaning the new account is created from an existing account
  /// newAccountId The name of the NEAR account to be created
  /// publicKey The public key from the masterAccount used to create this account
  /// @returns {Future<void>}
  Future<void> createAccount(String newAccountId, PublicKey publicKey) async {
    await masterAccount.createAccount(newAccountId, publicKey, initialBalance);
  }
}

class UrlAccountCreator extends AccountCreator {
  Connection connection;
  String helperUrl;

  UrlAccountCreator(
    this.connection,
    this.helperUrl,
  );

  /// Creates an account using a helperUrl
  /// This is [hosted here](https://helper.nearprotocol.com) or set up locally with the [near-contract-helper](https://github.com/nearprotocol/near-contract-helper) repository
  /// newAccountId The name of the NEAR account to be created
  /// publicKey The public key from the masterAccount used to create this account
  /// @returns {Future<void>}
  @override
  Future<void> createAccount(String newAccountId, PublicKey publicKey) async {
    await fetchJson(
        '$helperUrl/account',
        jsonEncode(
            {'newAccountId': newAccountId, 'publicKey': publicKey.toString()}));
  }
}
