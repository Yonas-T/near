class AccountInfo {
    String accountId;
    String publicKey;
    String privateKey;
  AccountInfo({
    required this.accountId,
    required this.publicKey,
    required this.privateKey,
  });
  
  toJson() {
    return {
      "accountId": accountId,
      "publicKey": publicKey,
      "privateKey": privateKey,
    };
  }
    
} 
