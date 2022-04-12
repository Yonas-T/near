import 'dart:convert';
import 'dart:io';

import '../account.dart';
import '../models/account.dart';
import '../utils/key_pair.dart';
import 'key_store.dart';

Future loadJsonFile(String filename) async {
  String content = File(filename).readAsStringSync();
  return jsonDecode(content.toString());
}

Future<void> ensureDir(String dir) async {
  try {
    await Directory(dir).create(recursive: true);
  } catch (err) {
    if (err != 'EEXIST') {
      throw Error();
    }
  }
}

Future readKeyFile(String filename) async {
  var accountInfo = await loadJsonFile(filename);
  // The private key might be in private_key or secret_key field.
  var privateKey = accountInfo.private_key;
  if (!privateKey && accountInfo.secret_key) {
    privateKey = accountInfo.secret_key;
  }
  return [
    accountInfo.account_id,
    KeyPair(publicKey: '', secretKey: '').fromString(privateKey)
  ];
}

/// This module contains the {@link UnencryptedFileSystemKeyStore} class which is used to store keys on the file system.
///
/// @example {@link https://docs.near.org/docs/develop/front-end/naj-quick-reference#key-store}
/// @example
/// ```js
/// const { homedir } = require('os');
/// const { connect, keyStores } = require('near-api-js');
///
/// const keyStore = new keyStores.UnencryptedFileSystemKeyStore(`${homedir()}/.near-credentials`);
/// const config = {
///   keyStore, // instance of UnencryptedFileSystemKeyStore
///   networkId: 'testnet',
///   nodeUrl: 'https://rpc.testnet.near.org',
///   walletUrl: 'https://wallet.testnet.near.org',
///   helperUrl: 'https://helper.testnet.near.org',
///   explorerUrl: 'https://explorer.testnet.near.org'
/// };
///
/// // inside an async function
/// const near = await connect(config)

class UnencryptedFileSystemKeyStore extends KeyStore {
  String keyDir;
  UnencryptedFileSystemKeyStore({
    required this.keyDir,
  });

  /// Store a {@link KeyPair} in an unencrypted file
  /// networkId The targeted network. (ex. default, betanet, etc…)
  /// accountId The NEAR account tied to the key pair
  /// keyPair The key pair to store in local storage
  @override
  Future setKey(String networkId, String accountId, KeyPair keyPair) async {
    await ensureDir('$keyDir/$networkId');
    AccountInfo account = AccountInfo(
        accountId: accountId,
        publicKey: KeyPairEd25519(
                // keyPair.toString()
                )
            .getPublicKey()
            .toString(),
        privateKey: keyPair.toString());
    final File file = File(getKeyFilePath(networkId, accountId));
    file.writeAsStringSync(account.toJson());
  }

  /// Gets a {@link KeyPair} from an unencrypted file
  /// networkId The targeted network. (ex. default, betanet, etc…)
  /// accountId The NEAR account tied to the key pair
  /// @returns {Future<KeyPair>}
  @override
  Future<KeyPair?> getKey(String networkId, String accountId) async {
    if (!await getKeyFilePath(networkId, accountId).exists()) {
      return null;
    }
    var accountKeyPair =
        await readKeyFile(getKeyFilePath(networkId, accountId));
    return accountKeyPair[1];
  }

  /// Deletes an unencrypted file holding a {@link KeyPair}
  /// networkId The targeted network. (ex. default, betanet, etc…)
  /// accountId The NEAR account tied to the key pair
  ///
  @override
  Future<void> removeKey(String networkId, String accountId) async {
    if (await getKeyFilePath(networkId, accountId).exists()) {
      File(getKeyFilePath(networkId, accountId)).delete();
    }
  }

  /// Deletes all unencrypted files from the `keyDir` path.
  @override
  Future<void> clear() async {
    for (var network in await getNetworks()) {
      for (var account in await getAccounts(network)) {
        await removeKey(network, account);
      }
    }
  }

  /// @hidden */
  getKeyFilePath(String networkId, String accountId) {
    return '$keyDir/$networkId/$accountId.json';
  }

  /// Get the network(s) from files in `keyDir`
  /// @returns {Future<List<string>>}
  @override
  Future<List<String>> getNetworks() async {
    var config = File(keyDir);
    List<String> files = config.readAsLinesSync();

    List<String> result = [];
    files.forEach((item) {
      result.add(item);
    });
    return result;
  }

  /// Gets the account(s) files in `keyDir/networkId`
  /// networkId The targeted network. (ex. default, betanet, etc…)
  /// @returns{Future<List<String>>}
  ///
  @override
  Future<List<String>> getAccounts(String networkId) async {
    if (!await Directory('$keyDir/$networkId').exists()) {
      return [];
    }
    final dir = Directory('$keyDir/$networkId');
    final List<FileSystemEntity> entities = await dir.list().toList();
    List<String> files = [];

    entities.forEach((element) {
      files.add(element.path);
    });
    List filesWithJson = files.where((f) => f.endsWith('.json')).toList();
    List<String> resultAccount = [];
    filesWithJson.forEach((element) {
      var pos = element.lastIndexOf('.');
      String result = (pos != -1) ? element.substring(0, pos) : element;
      resultAccount.add(result);
    });

    return resultAccount;
  }

  // String toString() {
  //     return UnencryptedFileSystemKeyStore(keyDir: keyDir);
  // }
}
