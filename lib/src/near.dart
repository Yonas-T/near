import 'package:flutter/foundation.dart';

import './account.dart';
import './account_creator.dart';
import './connection.dart';
import './contract.dart';
import './key_stores/key_store.dart';
import './signer.dart';
import './utils/key_pair.dart';

class NearConfig {
    /// Holds {@link KeyPair | KeyPairs} for signing transactions */
    KeyStore? keyStore;

    /// @hidden */
    Signer? signer;

    /// @deprecated use {@link NearConfig.keyStore} */
    // deps?: { keyStore: KeyStore };

    /// {@link https://github.com/near/near-contract-helper | NEAR Contract Helper} url used to create accounts if no master account is provided
    /// @see {@link UrlAccountCreator}
    String? helperUrl;

    /// The balance transferred from the {@link NearConfig.masterAccount | masterAccount} to a created account
    /// @see {@link LocalAccountCreator}
    String? initialBalance;

    /// The account to use when creating  accounts
    /// @see {@link LocalAccountCreator}
    String? masterAccount;

    /// {@link KeyPair | KeyPairs} are stored in a {@link KeyStore} under the `networkId` namespace.
    String networkId;

    /// NEAR RPC API url. used to make JSON RPC calls to interact with NEAR.
    /// @see {@link JsonRpcProvider.JsonRpcProvider | JsonRpcProvider}
    String nodeUrl;

    /// NEAR RPC API headers. Can be used to pass API KEY and other parameters.
    /// @see {@link JsonRpcProvider.JsonRpcProvider | JsonRpcProvider}
    Map<String, dynamic> headers;

    /// NEAR wallet url used to redirect users to their wallet in browser applications.
    /// @see {@link https://docs.near.org/docs/tools/near-wallet}
    String? walletUrl;
  NearConfig({
    this.keyStore,
    this.signer,
    this.helperUrl,
    this.initialBalance,
    this.masterAccount,
    required this.networkId,
    required this.nodeUrl,
    required this.headers,
    this.walletUrl,
  });
}

/// This is the main class developers should use to interact with NEAR.
/// @example
/// ```js
/// const near =  Near(config);
/// ```
class Near {
    
    // NearConfig config;
    Connection? connection;
    AccountCreator? accountCreator;
    Near(NearConfig config) {
      
      Connection con = Connection(config.networkId,
            { 'type': 'JsonRpcProvider', 'args': { 'url': config.nodeUrl, 'headers': config.headers } },
            config.signer
        );
      connection = Connection(config.networkId,
            { 'type': 'JsonRpcProvider', 'args': { 'url': config.nodeUrl, 'headers': config.headers } },
            config.signer).fromConfig(con);      
      // accountCreator = accountCreator!;
        if (config.masterAccount!.isNotEmpty) {
            // TODO: figure out better way of specifiying initial balance.
            // Hardcoded number below must be enough to pay the gas cost to dev-deploy with near-shell for multiple times
            var initialBalance = config.initialBalance!.isNotEmpty ?  BigInt.tryParse(config.initialBalance!) :  BigInt.from(5000000000000000000) ;
            accountCreator =  LocalAccountCreator(Account(connection!, config.masterAccount!), initialBalance!);
        } else if (config.helperUrl!.isNotEmpty) {
            accountCreator =  UrlAccountCreator(connection!, config.helperUrl!);
        } else {
            accountCreator = null;
        }
    }
  

    /// accountId near accountId used to interact with the network.
    Future<Account> account(String accountId) async {
        var account =  Account(connection!, accountId);
        return account;
    }

    /// Create an account using the {@link AccountCreator}. Either:
    /// * using a masterAccount with {@link LocalAccountCreator}
    /// * using the helperUrl with {@link UrlAccountCreator}
    /// @see {@link NearConfig.masterAccount} and {@link NearConfig.helperUrl}-
    /// 
    /// accountId
    /// publicKey
    Future<Account> createAccount(String accountId, PublicKey publicKey) async {
        if (accountCreator == null) {
            throw  Error();
        }
        await accountCreator!.createAccount(accountId, publicKey);
        return  Account(connection!, accountId);
    }

    /// @deprecated Use {@link Contract} instead.
    /// contractId
    /// options
    Future<Contract> loadContract(String contractId, dynamic options) async {
        var account =  Account(connection!, options.sender);
        return Contract(account: account, contractId: contractId, options: options);
    }

    /// @deprecated Use {@link Account.sendMoney} instead.
    /// amount
    /// originator
    /// receiver
    
    Future<String> sendTokens(BigInt amount, String originator, String receiver) async {
        
        var account =  Account(connection!, originator);
        var result = await account.sendMoney(receiver, amount);
        return result!.transaction_outcome.id;
    }
}
