import 'dart:convert';

class SignInModel {
  String publicKey;
  String accountName;
  String privateKey;
  bool? success;
  String? text;
  SignInModel({
    required this.publicKey,
    required this.accountName,
    required this.privateKey,
    this.success,
    this.text,
  });

  SignInModel copyWith({
    String? publicKey,
    String? accountName,
    String? privateKey,
    bool? success,
    String? text,
  }) {
    return SignInModel(
      publicKey: publicKey ?? this.publicKey,
      accountName: accountName ?? this.accountName,
      privateKey: privateKey ?? this.privateKey,
      success: success ?? this.success,
      text: text ?? this.text,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'publicKey': publicKey,
      'accountName': accountName,
      'privateKey': privateKey,
      'success': success,
      'text': text,
    };
  }

  factory SignInModel.fromMap(Map<String, dynamic> map) {
    return SignInModel(
      publicKey: map['publicKey'] ?? '',
      accountName: map['accountName'] ?? '',
      privateKey: map['privateKey'] ?? '',
      success: map['success'],
      text: map['text'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SignInModel.fromJson(String source) => SignInModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SignInModel(publicKey: $publicKey, accountName: $accountName, privateKey: $privateKey, success: $success, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is SignInModel &&
      other.publicKey == publicKey &&
      other.accountName == accountName &&
      other.privateKey == privateKey &&
      other.success == success &&
      other.text == text;
  }

  @override
  int get hashCode {
    return publicKey.hashCode ^
      accountName.hashCode ^
      privateKey.hashCode ^
      success.hashCode ^
      text.hashCode;
  }
}
