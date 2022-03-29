import 'dart:convert' show base64, json, jsonEncode, utf8;
import 'dart:developer';
import 'dart:typed_data';

import 'package:bs58/bs58.dart';
import 'package:http/http.dart';
import 'package:near_flutter/src/providers/json_rpc.dart';

import '../transaction.dart';
import '../utils/exponential_backoff.dart';
import '../utils/web.dart';
import 'provider.dart';

/// @hidden */

// Default number of retries before giving up on a request.
var REQUEST_RETRY_NUMBER = 12;

// Default wait until next retry in millis.
var REQUEST_RETRY_WAIT = 500;

// Exponential back off for waiting to retry.
var REQUEST_RETRY_WAIT_BACKOFF = 1.5;

/// Keep ids unique across all connections.
var _nextId = 123;

/// Client class to interact with the NEAR RPC API.
/// @see {@link https://github.com/near/nearcore/tree/master/chain/jsonrpc}
class JsonRpcProvider extends Provider {
  /// @hidden */
  ConnectionInfo connection;
  JsonRpcProvider(
    this.connection,
  );
  final Client client = Client();

  /// connectionInfoOrUrl ConnectionInfo or RPC API endpoint URL (deprecated)
  // varructor(connectionInfoOrUrl?: string | ConnectionInfo) {
  //     super();
  //     if (connectionInfoOrUrl != null && typeof connectionInfoOrUrl == 'object') {
  //         connection = connectionInfoOrUrl as ConnectionInfo;
  //     } else {
  //         var deprecate = depd('JsonRpcProvider(url?: string)');
  //         deprecate('use `JsonRpcProvider(connectionInfo: ConnectionInfo)` instead');
  //         connection = { url: connectionInfoOrUrl as string };
  //     }
  // }

  /// Gets the RPC's status
  /// @see {@link https://docs.near.org/docs/develop/front-end/rpc#general-validator-status}
  @override
  Future<NodeStatusResult> status() async {
    return sendJsonRpc('status', []);
  }

  /// Sends a signed transaction to the RPC and waits until transaction is fully complete
  /// @see {@link https://docs.near.org/docs/develop/front-end/rpc#send-transaction-await}
  ///
  /// signedTransaction The signed transaction being sent
  @override
  Future<FinalExecutionOutcome> sendTransaction(
      SignedTransaction signedTransaction) async {
    var message = jsonEncode(signedTransaction.toJson());
    print('signed MESSAGE: ' + message);

    // List<int> list = message.codeUnits;
    final bytes = utf8.encode(message);
    final base64Str = base64.encode(bytes);
    // Uint64List bytes = Uint64List.fromList(list);
    log('bbbYYY0000: ' + base64Str.toString());
    return sendJsonRpc('broadcast_tx_commit', [base64Str.toString()]);
  }

  /// Sends a signed transaction to the RPC and immediately returns transaction hash
  /// See [docs for more info](https://docs.near.org/docs/develop/front-end/rpc#send-transaction-async)
  /// signedTransaction The signed transaction being sent
  /// @returns {Future<FinalExecutionOutcome>}
  @override
  Future<FinalExecutionOutcome> sendTransactionAsync(
      SignedTransaction signedTransaction) async {
    var message = jsonEncode(signedTransaction.toJson());
    // List<int> list = message.codeUnits;
    // Uint8List bytes = Uint8List.fromList(list);

    final bytes = utf8.encode(message);
    final base64Str = base64.encode(bytes);

    return sendJsonRpc('broadcast_tx_async', [base64Str]);
  }

  /// Gets a transaction's status from the RPC
  /// @see {@link https://docs.near.org/docs/develop/front-end/rpc#transaction-status}
  ///
  /// txHash A transaction hash as either a Uint8Array or a base58 encoded string
  /// accountId The NEAR account that signed the transaction
  @override
  Future<FinalExecutionOutcome> txStatus(txHash, String accountId) async {
    if (txHash is String) {
      return txStatusString(txHash, accountId);
    } else {
      return txStatusUint8Array(txHash, accountId);
    }
  }

  Future<FinalExecutionOutcome> txStatusUint8Array(
      txHash, String accountId) async {
    return sendJsonRpc('tx', [utf8.encode(txHash), accountId]);
  }

  Future<FinalExecutionOutcome> txStatusString(
      String txHash, String accountId) async {
    return sendJsonRpc('tx', [txHash, accountId]);
  }

  /// Gets a transaction's status from the RPC with receipts
  /// See [docs for more info](https://docs.near.org/docs/develop/front-end/rpc#transaction-status-with-receipts)
  /// txHash The hash of the transaction
  /// accountId The NEAR account that signed the transaction
  /// @returns {Future<FinalExecutionOutcome>}
  @override
  Future<FinalExecutionOutcome> txStatusReceipts(
      txHash, String accountId) async {
    return sendJsonRpc(
        'EXPERIMENTAL_tx_status', [utf8.encode(txHash), accountId]);
  }

  /// Query the RPC as [shown in the docs](https://docs.near.org/docs/develop/front-end/rpc#accounts--contracts)
  /// Query the RPC by passing an {@link RpcQueryRequest}
  /// @see {@link https://docs.near.org/docs/develop/front-end/rpc#accounts--contracts}
  ///
  /// @typeParam T the shape of the returned query response
  @override
  Future<T> query<T>(args) async {
    print('ARGS: ' + args.toString());
    var result;
    if (args.length == 1) {
      result = await sendJsonRpc<T>('query', args[0]);
    } else {
      result = await sendJsonRpc<T>('query', args);
    }
    print('result' + result.toString());
    if (result != null && result.toString().contains('error')) {
      throw Error();
    }
    return result;
  }

  /// Query for block info from the RPC
  /// pass block_id OR finality as blockQuery, not both
  /// @see {@link https://docs.near.org/docs/interaction/rpc#block}
  ///
  /// blockQuery {@link } (passing a {@link BlockId} is deprecated)
  @override
  Future<dynamic> block(blockQuery) async {
    var finality = blockQuery['finality'];
    var blockId = blockQuery['blockId'];

    if (blockQuery is Object) {
      // var deprecate = depd('JsonRpcProvider.block(blockId)');
      // deprecate('use `block({ blockId })` or `block({ finality })` instead');
      blockId = blockQuery;
    }
    return sendJsonRpc('block', {
      // 'block_id': blockId,
      'finality': finality
    });
  }

  /// Query changes in block from the RPC
  /// pass block_id OR finality as blockQuery, not both
  /// See [docs for more info](https://docs.near.org/docs/develop/front-end/rpc#block-details)
  @override
  Future<BlockChangeResult> blockChanges(blockQuery) async {
    var finality = blockQuery.finality;
    var blockId = blockQuery.blockId;
    return sendJsonRpc('EXPERIMENTAL_changes_in_block',
        {'block_id': blockId, 'finality': finality});
  }

  /// Queries for details about a specific chunk appending details of receipts and transactions to the same chunk data provided by a block
  /// @see {@link https://docs.near.org/docs/interaction/rpc#chunk}
  ///
  /// chunkId Hash of a chunk ID or shard ID
  @override
  Future<ChunkResult> chunk(chunkId) async {
    return sendJsonRpc('chunk', [chunkId]);
  }

  /// Query validators of the epoch defined by the given block id.
  /// @see {@link https://docs.near.org/docs/develop/front-end/rpc#detailed-validator-status}
  ///
  /// blockId Block hash or height, or null for latest.
  @override
  Future<EpochValidatorInfo> validators(blockId) async {
    return sendJsonRpc('validators', [blockId]);
  }

  /// @deprecated
  /// Gets the genesis config from RPC
  /// @see {@link https://docs.near.org/docs/develop/front-end/rpc#genesis-config}
  @override
  Future<NearProtocolConfig> experimental_genesisConfig() async {
    // var deprecate = depd('JsonRpcProvider.experimental_protocolConfig()');
    // deprecate('use `experimental_protocolConfig({ sync_checkpoint: \'genesis\' })` to fetch the up-to-date or genesis protocol config explicitly');
    return await sendJsonRpc(
        'EXPERIMENTAL_protocol_config', {'sync_checkpoint': 'genesis'});
  }

  /// Gets the protocol config at a block from RPC
  ///
  ///  specifies the block to get the protocol config for
  @override
  Future<NearProtocolConfig> experimental_protocolConfig(blockReference) async {
    return NearProtocolConfig(
        runtime_config: (await sendJsonRpc(
            'EXPERIMENTAL_protocol_config', blockReference))['runtime_config']);
  }

  /// @deprecated Use {@link lightClientProof} instead
  Future<LightClientProof> experimental_lightClientProof(
      LightClientProofRequest request) async {
    // var deprecate = depd('JsonRpcProvider.experimental_lightClientProof(request)');
    // deprecate('use `lightClientProof` instead');
    return await lightClientProof(request);
  }

  /// Gets a light client execution proof for verifying execution outcomes
  /// @see {@link https://github.com/nearprotocol/NEPs/blob/master/specs/ChainSpec/LightClient.md#light-client-proof}
  @override
  Future<LightClientProof> lightClientProof(
      LightClientProofRequest request) async {
    return await sendJsonRpc('EXPERIMENTAL_light_client_proof', request);
  }

  /// Gets access key changes for a given array of accountIds
  /// See [docs for more info](https://docs.near.org/docs/develop/front-end/rpc#view-access-key-changes-all)
  /// @returns {Future<ChangeResult>}
  @override
  Future<ChangeResult> accessKeyChanges(
      List<String> accountIdArray, blockQuery) async {
    var finality = blockQuery.finality;
    var blockId = blockQuery.blockId;
    return sendJsonRpc('EXPERIMENTAL_changes', {
      'changes_type': 'all_access_key_changes',
      'account_ids': accountIdArray,
      'block_id': blockId,
      'finality': finality
    });
  }

  /// Gets single access key changes for a given array of access keys
  /// pass block_id OR finality as blockQuery, not both
  /// See [docs for more info](https://docs.near.org/docs/develop/front-end/rpc#view-access-key-changes-single)
  /// @returns {Future<ChangeResult>}
  @override
  Future<ChangeResult> singleAccessKeyChanges(
      List<AccessKeyWithPublicKey> accessKeyArray, blockQuery) async {
    var finality = blockQuery.finality;
    var blockId = blockQuery.blockId;
    return sendJsonRpc('EXPERIMENTAL_changes', {
      'changes_type': 'single_access_key_changes',
      'keys': accessKeyArray,
      'block_id': blockId,
      'finality': finality
    });
  }

  /// Gets account changes for a given array of accountIds
  /// pass block_id OR finality as blockQuery, not both
  /// See [docs for more info](https://docs.near.org/docs/develop/front-end/rpc#view-account-changes)
  /// @returns {Future<ChangeResult>}
  @override
  Future<ChangeResult> accountChanges(
      List<String> accountIdArray, blockQuery) async {
    var finality = blockQuery.finality;
    var blockId = blockQuery.blockId;
    return sendJsonRpc('EXPERIMENTAL_changes', {
      'changes_type': 'account_changes',
      'account_ids': accountIdArray,
      'block_id': blockId,
      'finality': finality
    });
  }

  /// Gets contract state changes for a given array of accountIds
  /// pass block_id OR finality as blockQuery, not both
  /// Note: If you pass a keyPrefix it must be base64 encoded
  /// See [docs for more info](https://docs.near.org/docs/develop/front-end/rpc#view-contract-state-changes)
  /// @returns {Future<ChangeResult>}
  @override
  Future<ChangeResult> contractStateChanges(
      List<String> accountIdArray, blockQuery, keyPrefix) async {
    keyPrefix = '';
    var finality = blockQuery.finality;
    var blockId = blockQuery.blockId;
    return sendJsonRpc('EXPERIMENTAL_changes', {
      'changes_type': 'data_changes',
      'account_ids': accountIdArray,
      'key_prefix_base64': keyPrefix,
      'block_id': blockId,
      'finality': finality
    });
  }

  /// Gets contract code changes for a given array of accountIds
  /// pass block_id OR finality as blockQuery, not both
  /// Note: Change is returned in a base64 encoded WASM file
  /// See [docs for more info](https://docs.near.org/docs/develop/front-end/rpc#view-contract-code-changes)
  /// @returns {Future<ChangeResult>}
  @override
  Future<ChangeResult> contractCodeChanges(
      List<String> accountIdArray, blockQuery) async {
    var finality = blockQuery.finality;
    var blockId = blockQuery.blockId;
    return sendJsonRpc('EXPERIMENTAL_changes', {
      'changes_type': 'contract_code_changes',
      'account_ids': accountIdArray,
      'block_id': blockId,
      'finality': finality
    });
  }

  /// Returns gas price for a specific block_height or block_hash.
  /// @see {@link https://docs.near.org/docs/develop/front-end/rpc#gas-price}
  ///
  /// blockId Block hash or height, or null for latest.
  @override
  Future<GasPrice> gasPrice(blockId) async {
    return await sendJsonRpc('gas_price', [blockId]);
  }

  /// Directly call the RPC specifying the method and params
  ///
  /// method RPC method
  /// params Parameters to the method
  Future<T> sendJsonRpc<T>(String method, params) async {
    var response = await exponentialBackoff(
        REQUEST_RETRY_WAIT, REQUEST_RETRY_NUMBER, REQUEST_RETRY_WAIT_BACKOFF,
        () async {
      try {
        params ??= {};

        final requestPayload = {
          'jsonrpc': '2.0',
          'method': method,
          'params': params,
          'id': _nextId++,
        };
        var url;
        if (connection is String) {
          url = connection;
        } else {
          url = (connection as ConnectionInfo).url;
        }

        // final response = await client.post(
        //   Uri.parse(url),
        //   headers: {'Content-Type': 'application/json'},
        //   body: json.encode(requestPayload),
        // );
        print('CONNECTION: ' + connection.user.toString());

        var response = await fetchJson(connection, jsonEncode(requestPayload));

        final data = json.decode(response.body) as Map<String, dynamic>;
        final id = data['id'] as int;
        print('DATTA' + data.toString());
        if (data.containsKey('error')) {
          final error = data['error'];
          print(error['code']);
          final code = jsonEncode(error['code']);
          final message = jsonEncode(error['message']);
          final errorData = error['data'];

          throw RPCError(code, message, errorData);
        }

        final result = data['result'];
        log('result ' + result.toString());
        return result;
        // NearProtocolConfig(
        //     runtime_config: result['runtime_config']);
      } catch (error) {
        if (error.toString().contains('TimeoutError')) {
          print('Retrying request to $method as it has timed out');

          return null;
        }

        rethrow;
      }
    });
    var result = response;
    print('Body ' + result.toString());
    // From jsonrpc spec:
    // result
    //   This member is REQUIRED on success.
    //   This member MUST NOT exist if there was an error invoking the method.
    if (result == null) {
      throw Error();
    }
    return result;
  }
}
