/**
 * NEAR RPC API request types and responses
 * @module
 */

import 'dart:convert';
import 'dart:typed_data';

import '../transaction.dart';

class SyncInfo {
  String latest_block_hash;
  int block_height;
  String latest_block_time;
  String latest_state_root;
  bool syncing;
  SyncInfo({
    required this.latest_block_hash,
    required this.block_height,
    required this.latest_block_time,
    required this.latest_state_root,
    required this.syncing,
  });
}

class Version {
  String version;
  String build;

  Version({
    required this.version,
    required this.build,
  });
}

class NodeStatusResult {
  String chain_id;
  String rpc_addr;
  String sync_info;
  List<String> validators;
  Version version;
  NodeStatusResult({
    required this.chain_id,
    required this.rpc_addr,
    required this.sync_info,
    required this.validators,
    required this.version,
  });
}

String blockHash = '';
int? blockHeight;
var BlockId;

var Finality; // 'optimistic' | 'near-final' | 'final'

var BlockReference; // { blockId: BlockId } | { finality: Finality } | { sync_checkpoint: 'genesis' | 'earliest_available' }

enum ExecutionStatusBasic {
  Unknown,
  Pending,
  failure,
}

class ExecutionStatus {
  String? successValue;
  String? successReceiptId;
  ExecutionError? failure;
}

enum FinalExecutionStatusBasic {
  NotStarted,
  Started,
  failure,
}

class ExecutionError {
  String error_message;
  String error_type;
  ExecutionError({
    required this.error_message,
    required this.error_type,
  });
}

class FinalExecutionStatus {
  String? successValue;
  ExecutionError? failure;
}

class ExecutionOutcomeWithId {
  String id;
  ExecutionOutcome outcome;
  ExecutionOutcomeWithId({
    required this.id,
    required this.outcome,
  });
}

class ExecutionOutcome {
  List<String> logs;
  List<String> receipt_ids;
  int gas_burnt;
  dynamic status; // type is ExecutionStatus | ExecutionStatusBasic
  ExecutionOutcome({
    required this.logs,
    required this.receipt_ids,
    required this.gas_burnt,
    required this.status,
  });
}

class ExecutionOutcomeWithIdView {
  List<MerkleNode> proof;
  String block_hash;
  String id;
  ExecutionOutcome outcome;
  ExecutionOutcomeWithIdView({
    required this.proof,
    required this.block_hash,
    required this.id,
    required this.outcome,
  });
}

class FinalExecutionOutcome {
  dynamic status; // FinalExecutionStatus | FinalExecutionStatusBasic;
  dynamic transaction;
  ExecutionOutcomeWithId transaction_outcome;
  List<ExecutionOutcomeWithId> receipts_outcome;
  FinalExecutionOutcome({
    required this.status,
    required this.transaction,
    required this.transaction_outcome,
    required this.receipts_outcome,
  });
}

class TotalWeight {
  int num;
  TotalWeight({
    required this.num,
  });
}

class BlockHeader {
  int height;
  String epoch_id;
  String next_epoch_id;
  String hash;
  String prev_hash;
  String prev_state_root;
  String chunk_receipts_root;
  String chunk_headers_root;
  String chunk_tx_root;
  String outcome_root;
  int chunks_included;
  String challenges_root;
  int timestamp;
  String timestamp_nanosec;
  String random_value;
  List<bool> validator_proposals;
  List<bool> chunk_mask;
  String gas_price;
  String rent_paid;
  String validator_reward;
  String total_supply;
  List<dynamic> challenges_result;
  String last_final_block;
  String last_ds_final_block;
  String next_bp_hash;
  String block_merkle_root;
  List<String> approvals;
  String signature;
  int latest_protocol_version;
  BlockHeader({
    required this.height,
    required this.epoch_id,
    required this.next_epoch_id,
    required this.hash,
    required this.prev_hash,
    required this.prev_state_root,
    required this.chunk_receipts_root,
    required this.chunk_headers_root,
    required this.chunk_tx_root,
    required this.outcome_root,
    required this.chunks_included,
    required this.challenges_root,
    required this.timestamp,
    required this.timestamp_nanosec,
    required this.random_value,
    required this.validator_proposals,
    required this.chunk_mask,
    required this.gas_price,
    required this.rent_paid,
    required this.validator_reward,
    required this.total_supply,
    required this.challenges_result,
    required this.last_final_block,
    required this.last_ds_final_block,
    required this.next_bp_hash,
    required this.block_merkle_root,
    required this.approvals,
    required this.signature,
    required this.latest_protocol_version,
  });
}

class ChunkHash {
  String chunkHash;
  ChunkHash({
    required this.chunkHash,
  });
}

int shardId = 0;

class ShardChunk {
  List shardChunk = [BlockId, shardId];
}

ShardChunk? blockshardId;
// ChunkId = ChunkHash | BlockshardId;

class ChunkHeader {
  String balance_burnt;
  dynamic chunk_hash; // ChunkHash
  int encoded_length;
  String encoded_merkle_root;
  int gas_limit;
  int gas_used;
  int height_created;
  int height_included;
  String outgoing_receipts_root;
  String prev_block_hash;
  int prev_state_num_parts;
  String prev_state_root_hash;
  String rent_paid;
  int shard_id;
  String signature;
  String tx_root;
  List<dynamic> validator_proposals;
  String validator_reward;
  ChunkHeader({
    required this.balance_burnt,
    required this.chunk_hash,
    required this.encoded_length,
    required this.encoded_merkle_root,
    required this.gas_limit,
    required this.gas_used,
    required this.height_created,
    required this.height_included,
    required this.outgoing_receipts_root,
    required this.prev_block_hash,
    required this.prev_state_num_parts,
    required this.prev_state_root_hash,
    required this.rent_paid,
    required this.shard_id,
    required this.signature,
    required this.tx_root,
    required this.validator_proposals,
    required this.validator_reward,
  });
}

class ChunkResult {
  ChunkHeader header;
  List<dynamic> receipts;
  List<Transaction> transactions;
  ChunkResult({
    required this.header,
    required this.receipts,
    required this.transactions,
  });
}

class Chunk {
  String chunk_hash;
  String prev_block_hash;
  String outcome_root;
  String prev_state_root;
  String encoded_merkle_root;
  int encoded_length;
  int height_created;
  int height_included;
  int shard_id;
  int gas_used;
  int gas_limit;
  String rent_paid;
  String validator_reward;
  String balance_burnt;
  String outgoing_receipts_root;
  String tx_root;
  List<dynamic> validator_proposals;
  String signature;
  Chunk({
    required this.chunk_hash,
    required this.prev_block_hash,
    required this.outcome_root,
    required this.prev_state_root,
    required this.encoded_merkle_root,
    required this.encoded_length,
    required this.height_created,
    required this.height_included,
    required this.shard_id,
    required this.gas_used,
    required this.gas_limit,
    required this.rent_paid,
    required this.validator_reward,
    required this.balance_burnt,
    required this.outgoing_receipts_root,
    required this.tx_root,
    required this.validator_proposals,
    required this.signature,
  });
}

class Transaction {
  String hash;
  String public_key;
  String signature;
  dynamic body;
  Transaction({
    required this.hash,
    required this.public_key,
    required this.signature,
    required this.body,
  });
}

class BlockResult {
  String author;
  BlockHeader header;
  List<Chunk> chunks;
  BlockResult({
    required this.author,
    required this.header,
    required this.chunks,
  });
}

class BlockChange {
  String type;
  String account_id;
  BlockChange({
    required this.type,
    required this.account_id,
  });
}

class BlockChangeResult {
  String block_hash;
  List<BlockChange> changes;
  BlockChangeResult({
    required this.block_hash,
    required this.changes,
  });
}

class ChangeResult {
  String block_hash;
  List<dynamic> changes;
  ChangeResult({
    required this.block_hash,
    required this.changes,
  });
}

class CurrentEpochValidatorInfo {
  String account_id;
  String public_key;
  bool is_slashed;
  String stake;
  List<int> shards;
  int num_produced_blocks;
  int num_expected_blocks;
  CurrentEpochValidatorInfo({
    required this.account_id,
    required this.public_key,
    required this.is_slashed,
    required this.stake,
    required this.shards,
    required this.num_produced_blocks,
    required this.num_expected_blocks,
  });
}

class NextEpochValidatorInfo {
  String account_id;
  String public_key;
  String stake;
  List<int> shards;
  NextEpochValidatorInfo({
    required this.account_id,
    required this.public_key,
    required this.stake,
    required this.shards,
  });
}

class ValidatorStakeView {
  String account_id;
  String public_key;
  String stake;
  ValidatorStakeView({
    required this.account_id,
    required this.public_key,
    required this.stake,
  });
}

class NearProtocolConfig {
  dynamic runtime_config;
  NearProtocolConfig({
    required this.runtime_config,
  });
}

class NearProtocolRuntimeConfig {
  String storage_amount_per_byte;
  NearProtocolRuntimeConfig({
    required this.storage_amount_per_byte,
  });
}

class EpochValidatorInfo {
  // Validators for the current epoch.
  List<NextEpochValidatorInfo> next_validators;
  // Validators for the next epoch.
  List<CurrentEpochValidatorInfo> current_validators;
  // Fishermen for the current epoch.
  List<ValidatorStakeView> next_fisherman;
  // Fishermen for the next epoch.
  List<ValidatorStakeView> current_fisherman;
  // Proposals in the current epoch.
  List<ValidatorStakeView> current_proposals;
  // Kickout in the previous epoch.
  List<ValidatorStakeView> prev_epoch_kickout;
  // Epoch start height.
  int epoch_start_height;
  EpochValidatorInfo({
    required this.next_validators,
    required this.current_validators,
    required this.next_fisherman,
    required this.current_fisherman,
    required this.current_proposals,
    required this.prev_epoch_kickout,
    required this.epoch_start_height,
  });
}

class MerkleNode {
  String hash;
  String direction;
  MerkleNode({
    required this.hash,
    required this.direction,
  });
}

class BlockHeaderInnerLiteView {
  int height;
  String epoch_id;
  String next_epoch_id;
  String prev_state_root;
  String outcome_root;
  int timestamp;
  String next_bp_hash;
  String block_merkle_root;
  BlockHeaderInnerLiteView({
    required this.height,
    required this.epoch_id,
    required this.next_epoch_id,
    required this.prev_state_root,
    required this.outcome_root,
    required this.timestamp,
    required this.next_bp_hash,
    required this.block_merkle_root,
  });
}

class LightClientBlockLiteView {
  String prev_block_hash;
  String inner_rest_hash;
  BlockHeaderInnerLiteView inner_lite;
  LightClientBlockLiteView({
    required this.prev_block_hash,
    required this.inner_rest_hash,
    required this.inner_lite,
  });
}

class LightClientProof {
  ExecutionOutcomeWithIdView outcome_proof;
  List<MerkleNode> outcome_root_proof;
  LightClientBlockLiteView block_header_lite;
  List<MerkleNode> block_proof;
  LightClientProof({
    required this.outcome_proof,
    required this.outcome_root_proof,
    required this.block_header_lite,
    required this.block_proof,
  });
}

enum IdType {
  transaction,
  receipt,
}

class LightClientProofRequest {
  IdType type;
  String light_client_hea;
  String? transaction_hash;
  String? sender_id;
  String? receipt_id;
  String? receiver_id;
  LightClientProofRequest({
    required this.type,
    required this.light_client_hea,
    this.transaction_hash,
    this.sender_id,
    this.receipt_id,
    this.receiver_id,
  });
}

class GasPrice {
  String gas_price;
  GasPrice({
    required this.gas_price,
  });
}

class AccessKeyWithPublicKey {
  String account_id;
  String public_key;
  AccessKeyWithPublicKey({
    required this.account_id,
    required this.public_key,
  });
}

abstract class QueryResponseKind {
  int block_height;
  String block_hash;
  QueryResponseKind({
    required this.block_height,
    required this.block_hash,
  });
}

class AccountView {
  String amount;
  String locked;
  String code_hash;
  int storage_usage;
  int storage_paid_at;
  AccountView({
    required this.amount,
    required this.locked,
    required this.code_hash,
    required this.storage_usage,
    required this.storage_paid_at,
  });

  factory AccountView.fromJson(Map<String, dynamic> json) {
    return AccountView(
        amount: json['amount'],
        locked: json['locked'],
        code_hash: json['code_hash'],
        storage_usage: json['storage_usage'],
        storage_paid_at: json['storage_paid_at']);
  }
}

class StateItem {
  String key;
  String value;
  List<String> proof;
  StateItem({
    required this.key,
    required this.value,
    required this.proof,
  });
}

class ViewStateResult {
  List<StateItem> values;
  List<String> proof;
  ViewStateResult({
    required this.values,
    required this.proof,
  });
}

class CodeResult {
  List<int> result;
  List<String> logs;
  CodeResult({
    required this.result,
    required this.logs,
  });
}

class ContractCodeView {
  String code_base64;
  String hash;
  ContractCodeView({
    required this.code_base64,
    required this.hash,
  });
}

class FunctionCallPermissionView {
  String allowance;
  String receiver_id;
  List<String> method_names;
  FunctionCallPermissionView({
    required this.allowance,
    required this.receiver_id,
    required this.method_names,
  });
  // FunctionCall: {
  //     allowance: string;
  //     receiver_id: string;
  //     method_names: string[];
  // };
}

class AccessKeyView {
  int nonce;
  dynamic permission;
  AccessKeyView({
    required this.nonce,
    required this.permission,
  });
}

class AccessKeyInfoView {
  String public_key;
  AccessKeyView access_key;
  AccessKeyInfoView({
    required this.public_key,
    required this.access_key,
  });
}

class AccessKeyList {
  List<AccessKeyInfoView> keys;
  AccessKeyList({
    required this.keys,
  });
}

class ViewAccountRequest {
  String request_type = 'view_account';
  String account_id;
  ViewAccountRequest({
    required this.request_type,
    required this.account_id,
  });
}

class ViewCodeRequest {
  String request_type = 'view_code';
  String account_id;
  ViewCodeRequest({
    required this.request_type,
    required this.account_id,
  });
}

class ViewStateRequest {
  String request_type = 'view_state';
  String account_id;
  String prefix_base64;
  ViewStateRequest({
    required this.request_type,
    required this.account_id,
    required this.prefix_base64,
  });
}

class ViewAccessKeyRequest {
  String request_type = 'view_access_key';
  String account_id;
  String public_key;
  ViewAccessKeyRequest({
    required this.request_type,
    required this.account_id,
    required this.public_key,
  });
}

class ViewAccessKeyListRequest {
  String request_type = 'view_access_key_list';
  String account_id;
  ViewAccessKeyListRequest({
    required this.request_type,
    required this.account_id,
  });
}

class CallFunctionRequest {
  String request_type = 'call_function';
  String account_id;
  String method_name;
  String args_base64;
  CallFunctionRequest({
    required this.request_type,
    required this.account_id,
    required this.method_name,
    required this.args_base64,
  });
}

// export type RpcQueryRequest = (
//     ViewAccountRequest |
//     ViewCodeRequest |
//     ViewStateRequest |
//     ViewAccountRequest |
//     ViewAccessKeyRequest |
//     ViewAccessKeyListRequest |
//     CallFunctionRequest) & BlockReference

abstract class Provider {
  Future<NodeStatusResult> status();

  Future<FinalExecutionOutcome> sendTransaction(
      SignedTransaction signedTransaction);
  Future<FinalExecutionOutcome> sendTransactionAsync(
      SignedTransaction signedTransaction);
  Future<FinalExecutionOutcome> txStatus(var txHash, String accountId);
  Future<FinalExecutionOutcome> txStatusReceipts(var txHash, String accountId);
  Future<T> query<T>(args);

  // Future<T> query<T extends QueryResponseKind>(dynamic params, String? path, String? data);
  // Future<T> query<T extends QueryResponseKind>(String path, String data);

  Future<dynamic> block(blockQuery);
  Future<BlockChangeResult> blockChanges(blockQuery);
  Future<ChunkResult> chunk(var chunkId);

  Future<EpochValidatorInfo> validators(var blockId);
  Future<NearProtocolConfig> experimental_genesisConfig();
  Future<NearProtocolConfig> experimental_protocolConfig(var blockReference);
  Future<LightClientProof> lightClientProof(LightClientProofRequest request);
  Future<GasPrice> gasPrice(var blockId);
  Future<ChangeResult> accessKeyChanges(
      List<String> accountIdArray, blockQuery);
  Future<ChangeResult> singleAccessKeyChanges(
      List<AccessKeyWithPublicKey> accessKeyArray, blockQuery);
  Future<ChangeResult> accountChanges(List<String> accountIdArray, blockQuery);
  Future<ChangeResult> contractStateChanges(
      List<String> accountIdArray, blockQuery, String? keyPrefix);
  Future<ChangeResult> contractCodeChanges(
      List<String> accountIdArray, blockQuery);
}

getTransactionLastResult(FinalExecutionOutcome txResult) {
  if (txResult.status is Object && txResult.status.successValue is String) {
    final re = Uint8List(txResult.status.successValue)
      ..buffer.asByteData().setUint64(0, 64);
    var cList = re.reversed.toList();
    var value = cList.toString();
    try {
      return jsonDecode(value);
    } catch (e) {
      return value;
    }
  }
  return null;
}
