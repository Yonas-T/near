import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';

import 'package:tweetnacl/tweetnacl.dart';

keyTypeToStr(keyType) {
  switch (keyType) {
    case 'ed25519':
      return 'ed25519';
    default:
      throw Error();
  }
}

strToKeyType(String keyType) {
  switch (keyType.toLowerCase()) {
    case 'ed25519':
      return 0;
    default:
      throw Error();
  }
}

///PublicKey representation that has type and bytes of the key.

class PublicKey {
  dynamic keyType;
  dynamic data;

  PublicKey(
    this.keyType,
    this.data,
  );

  factory PublicKey.fromJson(Map<String, dynamic> json) {
    return PublicKey(
      json['keyType'],
      json['data'],
    );
  }

  toJson() {
    return {
      'keyType': keyType,
      'data': data,
    };
  }

  static from(value) {
    if (value is String) {
      return PublicKey.fromString(value);
    }
    return value;
  }

  static fromString(encodedKey) {
    var parts = encodedKey.split(':');
    final List<int> codeUnits0 = encodedKey[0].codeUnits;
    final List<int> codeUnits1 = encodedKey[1].codeUnits;

    final Uint8List unit8List0 = Uint8List.fromList(codeUnits0);
    final Uint8List unit8List1 = Uint8List.fromList(codeUnits1);

    if (parts.length == 1) {
      return PublicKey(0, unit8List0);
    } else if (parts.length == 2) {
      return PublicKey(strToKeyType(parts[0]), unit8List1);
    } else {
      throw Error();
    }
  }

  // toString() {
  //   String str = String.fromCharCodes(data);
  //   // var outputAsUint8List = Uint8List.fromList(str.codeUnits);

  //   return '${keyTypeToStr(keyType)}:$str';
  // }

  // verify(message, signature) {
  //   switch (keyType) {
  //     case 0:
  //       return nacl.sign.detached.verify(message, signature, data);
  //     default:
  //       throw Error();
  //   }
  // }
}

class KeyPair {
  var secretKey;
  var publicKey;
  KeyPair({
    required this.secretKey,
    required this.publicKey,
  });
  

  /// curve Name of elliptical curve, case-insensitive
  /// @returns Random KeyPair based on the curve

  getPublicKey() {
    KeyPairEd25519().getPublicKey();
  }

  fromRandom(String curve) {
    // var k = RSAKeyGenerator();

    // var keyPair = k.generateKeyPair();
    // var privateKey = keyPair.privateKey.toString();
    // String str = String.fromCharCodes(privateKey.codeUnits);

    // switch (curve.toUpperCase()) {
    //   case 'ED25519':
    //     return KeyPairEd25519(str).frmRandom();
    //   default:
    //     throw Error();
    // }
  }

  fromString(String encodedKey) {
    // var parts = encodedKey.split(':');
    // print(parts);
    // if (parts.length == 1) {
    //   return KeyPairEd25519(parts[0]);
    // } else if (parts.length == 2) {
    //   switch (parts[0].toUpperCase()) {
    //     case 'ED25519':
    //       return KeyPairEd25519(parts[1]).fromString(encodedKey);
    //     default:
    //       throw Error();
    //   }
    // } else {
    //   throw Error();
    // }
  }

  sign(message) {
    // const signature = nacl.sign.detached(message, base_decode(this.secretKey));
    
    Uint8List bytes = Uint8List.fromList(message.codeUnits);
    var secretKey = 'ed25519:2Wjwq5xTaRii9mGaUZSZJcKBZhsa4HadLfUjuaZwnPtDgn57a46JT3JwSudxavAtSowqk41SWRsLa3g4LwJSUumL';
    Uint8List secretKeyBytes = Uint8List.fromList(secretKey.codeUnits);
    Signature s1 = Signature(null, secretKeyBytes);
    Uint8List signature = s1.detached(bytes);
    print("signature: \"${TweetNaclFast.hexEncodeToString(signature)}\"");

    return {'signature': TweetNaclFast.hexEncodeToString(signature), 'publicKey': 'ed25519:GWK3q7JG37ji9RupLurUT9hEa5S6pqUeiq4JxNktZtN6'};
  }
}

///This class provides key pair functionality for Ed25519 curve:
///generating key pairs, encoding key pairs, signing and verifying.

class KeyPairEd25519 extends KeyPair {
  KeyPairEd25519() : super(publicKey: null, secretKey: null);

  // String secretKey;

  // KeyPairEd25519(this.secretKey) : super(publicKey: null, secretKey: null);

  // PublicKey getPubKey() {
  //   var keyParams =
  //       RSAKeyGeneratorParameters(BigInt.tryParse("65537")!, 2048, 5);

  //   var secureRandom = FortunaRandom();
  //   var random = Random.secure();
  //   List<int> seeds = [];
  //   for (int i = 0; i < 32; i++) {
  //     seeds.add(random.nextInt(255));
  //   }
  //   secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

  //   var rngParams = ParametersWithRandom(keyParams, secureRandom);
  //   var k = RSAKeyGenerator();
  //   k.init(rngParams);

  //   var keyPair = k.generateKeyPair();
  //   var s = keyPair.privateKey.toString();

  //   var publicKeyStr = keyPair.publicKey.toString();

  //   List<int> list = utf8.encode(publicKeyStr);
  //   Uint8List bytes = Uint8List.fromList(list);

  //   return PublicKey(0, bytes);
  // }

  /// The public key corresponding to this private key.

  // var keyPair = nacl.sign.keyPair.fromSecretKey(base_decode(secretKey));

  /// Generate a new random keypair.
  /// @example
  /// const keyRandom = KeyPair.fromRandom();
  /// keyRandom.publicKey
  ///  returns [PUBLIC_KEY]
  ///
  /// keyRandom.secretKey
  ///  returns [SECRET_KEY]

  frmRandom() {
    // var k = RSAKeyGenerator();

    // var keyPair = k.generateKeyPair();
    // var privateKey = keyPair.privateKey.toString();
    // String str = String.fromCharCodes(privateKey.codeUnits);
    // // var outputAsUint8List = Uint8List.fromList(str.codeUnits);

    // return KeyPairEd25519(str);
  }

  sign(message) {
    // const signature = nacl.sign.detached(message, base_decode(this.secretKey));
    var kp = Signature.keyPair();
    print("secretKey: \"${TweetNaclFast.hexEncodeToString(kp.secretKey)}\"");
    print("publicKey: \"${TweetNaclFast.hexEncodeToString(kp.publicKey)}\"");

    Uint8List bytes = Uint8List.fromList(message.codeUnits);

    Signature s1 = Signature(null, kp.secretKey);
    Uint8List signature = s1.detached(bytes);
    print("signature: \"${TweetNaclFast.hexEncodeToString(signature)}\"");

    return {'signature': signature, 'publicKey': kp.publicKey};
  }

  // verify(message, signature) {
  //     return publicKey.verify(message, signature);
  // }

  toString() {
    return 'ed25519:$secretKey';
  }

  getPublicKey() {
    // return getPubKey();
  }
}
