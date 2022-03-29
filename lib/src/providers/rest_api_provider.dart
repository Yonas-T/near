import 'dart:convert';

import 'package:http/http.dart' as http;

class RestApiProvider {
  Future<dynamic> transferRestApiProvider(
      accountId, receiverId, deposit) async {
    print(deposit + " " + accountId + " " + receiverId);
    int depositLen = deposit.length;
    int diff = 24;
    for (int i = 0; i < diff; i++) {
      deposit = deposit + "0";
    }
    print(deposit);

    Map<String, dynamic> postJson = {
      "account_id": accountId,
      "receiver_id": receiverId, //"inotel.pool.f863973.m0",
      "method": "!transfer",
      "params": {},
      "deposit": deposit,
      "gas": 30000000000000,
      "meta": "",
      "callback_url": "",
      "network": "testnet"
    };

    final response = await http.post(
      Uri.parse('https://rest.nearapi.org/sign_url'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: json.encode(postJson),
    );
    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<dynamic> callRestApiProvider(privateKey, accountId, contract, message, deposit) async {
    print(deposit + " " + accountId + " " + message);
    int depositLen = deposit.length;
    int diff = 24;
    for (int i = 0; i < diff; i++) {
      deposit = deposit + "0";
    }
    print(deposit);

    Map<String, dynamic> postJson = {
      "account_id": accountId,
      "private_key": privateKey,
          // "c9fq5sjYdEQxL3GQDt4iav64UE2crRp2GAGpsyWzarJEeVyDEtk7fehu9VJDivKfVU4QqkL2euRrMqRYDtj1L4A",
      "contract": contract,//"guest-book.testnet",
      "method": message, //"addMessage",
      "params": {"text": message},
      "attached_gas": "100000000000000",
      "attached_tokens": deposit
    };

    final response = await http.post(
      Uri.parse('https://rest.nearapi.org/call'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: json.encode(postJson),
    );
    print('RES '+response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<dynamic> transferNftApiProvider(tokenId, ownerAccountId, receiverAccountId, memo, privateKey, tokenContract) async {
    
    Map<String, dynamic> postJson = {
      "token_id": tokenId,
      "receiver_id": receiverAccountId,
      "enforce_owner_id": ownerAccountId,
      "memo": memo,
      "owner_private_key": privateKey,
      "contract": tokenContract
    };

    final response = await http.post(
      Uri.parse('https://rest.nearapi.org/transfer_nft'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: json.encode(postJson),
    );
    print('RES '+response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<dynamic> mintNftApiProvider(tokenId, metadata, ownerAccountId, privateKey, contractId) async {
    
    Map<String, dynamic> postJson = {
      "token_id": 'nearTokNearYonas',
      "metadata": metadata, //"https://bafkreigmdhxrb2qs6sufhea55jxgpljz2zxj42mo7kyny2el6iq5ll2bva.ipfs.nftstorage.link/",
      "account_id": ownerAccountId,
      "private_key": privateKey,
      "contract": "nearyonas.testnet"
    };

    final response = await http.post(
      Uri.parse('https://rest.nearapi.org/mint_nft'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: json.encode(postJson),
    );
    print('RES '+response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load');
    }
  }

}
