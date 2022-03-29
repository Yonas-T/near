import   '../utils/key_pair.dart';

/// KeyStores are passed to {@link Near} via {@link NearConfig}
/// and are used by the {@link InMemorySigner} to sign transactions.
/// 
/// @example {@link connect}
 abstract class KeyStore {
    Future<void> setKey(String networkId, String accountId, KeyPair keyPair);
    Future<KeyPair?> getKey(String networkId, String accountId);
    Future<void> removeKey(String networkId, String accountId);
    Future<void> clear();
    Future<List<String>> getNetworks();
    Future<List<String>> getAccounts(String networkId);
}