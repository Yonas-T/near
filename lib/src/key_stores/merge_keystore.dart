import '../utils/key_pair.dart';
import 'key_store.dart';

/// Keystore which can be used to merge multiple key stores into one virtual key store.
///
/// @example
/// ```js
/// const { homedir } = require('os');
/// import { connect, keyStores, utils } from 'near-api-js';
///
/// const privateKey = '.......';
/// const keyPair = utils.KeyPair.fromString(privateKey);
///
/// const inMemoryKeyStore = new keyStores.InMemoryKeyStore();
/// inMemoryKeyStore.setKey('testnet', 'example-account.testnet', keyPair);
///
/// const fileSystemKeyStore = new keyStores.UnencryptedFileSystemKeyStore(`${homedir()}/.near-credentials`);
///
/// const keyStore = new MergeKeyStore([
///   inMemoryKeyStore,
///   fileSystemKeyStore
/// ]);
/// const config = {
///   keyStore, // instance of MergeKeyStore
///   networkId: 'testnet',
///   nodeUrl: 'https://rpc.testnet.near.org',
///   walletUrl: 'https://wallet.testnet.near.org',
///   helperUrl: 'https://helper.testnet.near.org',
///   explorerUrl: 'https://explorer.testnet.near.org'
/// };
///
/// // inside an async function
/// const near = await connect(config)
/// ```

class MergeKeyStoreOptions {
  int writeKeyStoreIndex;
  MergeKeyStoreOptions({
    required this.writeKeyStoreIndex,
  });
}

class MergeKeyStore extends KeyStore {
  late MergeKeyStoreOptions options;
  var keyStores;

  /// Store a {@link KeyPain} to the first index of a key store array
  /// networkId The targeted network. (ex. default, betanet, etc…)
  /// accountId The NEAR account tied to the key pair
  /// keyPair The key pair to store in local storage
  @override
  Future<void> setKey(
      String networkId, String accountId, KeyPair keyPair) async {
    await keyStores[options.writeKeyStoreIndex]
        .setKey(networkId, accountId, keyPair);
  }

  /// Gets a {@link KeyPair} from the array of key stores
  /// networkId The targeted network. (ex. default, betanet, etc…)
  /// accountId The NEAR account tied to the key pair
  /// @returns {Future<KeyPair>}
  @override
  Future<KeyPair?> getKey(String networkId, String accountId) async {
    for (var keyStore in keyStores) {
      var keyPair = await keyStore.getKey(networkId, accountId);
      if (keyPair) {
        return keyPair;
      }
    }
    return null;
  }

  /// Removes a {@link KeyPair} from the array of key stores
  /// networkId The targeted network. (ex. default, betanet, etc…)
  /// accountId The NEAR account tied to the key pair
  @override
  Future<void> removeKey(String networkId, String accountId) async {
    for (var keyStore in keyStores) {
      await keyStore.removeKey(networkId, accountId);
    }
  }

  /// Removes all items from each key store
  @override
  Future<void> clear() async {
    for (const keyStore in keyStores) {
      await keyStore.clear();
    }
  }

  /// Get the network(s) from the array of key stores
  /// @returns {Future<string[]>}
  @override
  Future<List<String>> getNetworks() async {
    List<String> result = [];
    for (var keyStore in keyStores) {
      for (var network in await keyStore.getNetworks()) {
        result.add(network);
      }
    }
    return result;
  }

  /// Gets the account(s) from the array of key stores
  /// networkId The targeted network. (ex. default, betanet, etc…)
  /// @returns{Future<string[]>}
  @override
  Future<List<String>> getAccounts(String networkId) async {
    List<String> result = [];
    for (var keyStore in keyStores) {
      for (const account in await keyStore.getAccounts(networkId)) {
        result.add(account);
      }
    }
    return result;
  }

  @override
  String toString() {
    return 'MergeKeyStore(${keyStores.join(', ')})';
  }
}
