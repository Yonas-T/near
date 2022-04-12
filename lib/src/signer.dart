import 'dart:convert';
import 'dart:typed_data';

import 'package:near_flutter/src/wallet_account.dart';

import '../src/utils/key_pair.dart';
import '../src/key_stores/in_memory_key_store.dart';
// import ''; //import keystore

abstract class Signer {
  /// Creates new key and returns public key.

  Future<PublicKey> createKey(String? accountId, String? networkId);

  /// Returns public key for given account / network.
  /// accountId accountId to retrieve from.
  /// networkId The targeted network. (ex. default, betanet, etc…)

  Future<PublicKey> getPublicKey(String? accountId, String? networkId);

  /// Signs given message, by first hashing with sha256.
  /// message message to sign.
  /// accountId accountId to use for signing.
  /// networkId The targeted network. (ex. default, betanet, etc…)

  Future signMessage(dynamic message, String? accountId, String? networkId);
}

class InMemorySigner extends Signer {
  // KeyStore keyStore;
  InMemoryKeyStore keyStore;

  InMemorySigner(this.keyStore);

  /// Creates a single account Signer instance with account, network and keyPair provided.
  ///
  /// Intended to be useful for temporary keys (e.g. claiming a Linkdrop).
  ///
  /// networkId The targeted network. (ex. default, betanet, etc…)
  /// accountId The NEAR account to assign the key pair to
  /// keyPair The keyPair to use for signing

  Future<Signer> fromKeyPair(
      String networkId, String accountId, KeyPair keyPair) async {
    var keyStore = InMemoryKeyStore();
    await keyStore.setKey(networkId, accountId, keyPair);
    return InMemorySigner(keyStore);
  }

  /// Creates a public key for the account given
  /// accountId The NEAR account to assign a public key to
  /// networkId The targeted network. (ex. default, betanet, etc…)
  /// @returns {Future<PublicKey>}
  ///
  @override
  Future<PublicKey> createKey(String? accountId, String? networkId) async {
    KeyPair? keyPair;
    // KeyPair().fromRandom('ed25519');
    await keyStore.setKey(networkId!, accountId!, keyPair!);
    return keyPair.getPublicKey();
  }

  /// Gets the existing public key for a given account
  /// accountId The NEAR account to assign a public key to
  /// networkId The targeted network. (ex. default, betanet, etc…)
  /// @returns {Future<PublicKey>} Returns the public key or null if not found
  @override
  Future<PublicKey> getPublicKey(String? accountId, String? networkId) async {
    KeyPair? keyPair = await keyStore.getKey(networkId!, accountId!);

    return keyPair!.getPublicKey();
  }

  /// message A message to be signed, typically a serialized transaction
  /// accountId the NEAR account signing the message
  /// networkId The targeted network. (ex. default, betanet, etc…)
  /// @returns {Future<Signature>}
  @override
  // Future<Signature> signMessage(dynamic message, String? accountId, String? networkId)async {
  //       var hash = Uint8Array(sha256.sha256.array(message));
  //       if (accountId == null) {
  //           throw  Error();
  //       }
  //       var keyPair = await keyStore.getKey(networkId, accountId);
  //       if (keyPair == null) {
  //           throw Error();
  //       }
  //       return keyPair.sign(hash);
  //   }

  toString() {
    return 'InMemorySigner($keyStore)';
  }

  @override
  Future<dynamic> signMessage(
    message,
    String? accountId,
    String? networkId,
  ) async {
    final bytes = utf8.encode(message);
    final base64Str = base64.encode(bytes);
    if (accountId == null) {
      throw Exception('InMemorySigner requires provided account id');
    }

    KeyPair? keyPair = await keyStore.getKey(networkId!, accountId);
    if (keyPair == null) {
      throw Exception('Key for $accountId not found in $networkId');
    }
    return keyPair.sign(base64Str);
  }
}
