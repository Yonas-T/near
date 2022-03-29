import '../utils/key_pair.dart';
import 'key_store.dart';


 /// Simple in-memory keystore for mainly for testing purposes.

 /// const privateKey = '.......';
 /// const keyPair = utils.KeyPair.fromString(privateKey);
 /// 
 /// const keyStore = new keyStores.InMemoryKeyStore();
 /// keyStore.setKey('testnet', 'example-account.testnet', keyPair);
 /// 
 /// const config = { 
 ///   keyStore, // instance of InMemoryKeyStore
 ///   networkId: 'testnet',
 ///   nodeUrl: 'https://rpc.testnet.near.org',
 ///   walletUrl: 'https://wallet.testnet.near.org',
 ///   helperUrl: 'https://helper.testnet.near.org',
 ///   explorerUrl: 'https://explorer.testnet.near.org'
 /// };
 /// 
 /// // inside an async function
 /// const near = await connect(config)
 

 class InMemoryKeyStore extends KeyStore {

    dynamic keys;


    /// Stores a {@KeyPair} in in-memory storage item
    /// networkId The targeted network. (ex. default, betanet, etc…)
    /// accountId The NEAR account tied to the key pair
    /// keyPair The key pair to store in local storage    
    @override
  Future<void> setKey(String networkId, String accountId, KeyPair keyPair) async {
        keys['$accountId:$networkId'] = keyPair.toString();
    }

    /// Gets a {@link KeyPair} from in-memory storage
    /// networkId The targeted network. (ex. default, betanet, etc…)
    /// accountId The NEAR account tied to the key pair
    /// @returns {Promise<KeyPair>}
    @override
  Future<KeyPair?> getKey(String networkId, String accountId) async {
        var value = keys['$accountId:$networkId'];
        if (!value) {
            return null;
        }
        return KeyPair(
          publicKey: '',
          secretKey: ''
        ).fromString(value);
    }

    /// Removes a {@link KeyPair} from in-memory storage
    /// networkId The targeted network. (ex. default, betanet, etc…)
    /// accountId The NEAR account tied to the key pair
    @override
  Future<void> removeKey(String networkId, String accountId) async {
      Map<String, dynamic> keyPairMap = keys;
      keyPairMap.remove('$accountId:$networkId');
    }

    /// Removes all {@link KeyPairs} from in-memory storage
    @override
  Future<void> clear() async {
        keys = {};
    }

    /// Get the network(s) from in-memory storage
    /// @returns {Promise<string[]>}
    @override
  Future<List<String>> getNetworks() async {
        List<String> result = [];
        keys.forEach((key, value) {
            result.add(key.split(':')[1]);
        });
      
        return result;
    }

    /// Gets the account(s) from in-memory storage
    /// networkId The targeted network. (ex. default, betanet, etc…)
    /// @returns{Promise<string[]>}
    @override
  Future<List<String>> getAccounts(String networkId) async {
        List<String> result = [];
        keys.forEach((key, value) {
          var parts = key.split(':');
            if (parts[parts.length - 1] == networkId) {
                result.add(parts.slice(0, parts.length - 1).join(':'));
            }
        });

        return result;
    }

    @override
  String toString() {
        return 'InMemoryKeyStore';
    }
}