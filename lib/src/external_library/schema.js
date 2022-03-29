SCHEMA = new Map([
    [Signature, { kind: 'struct', fields: [
                ['keyType', 'u8'],
                ['data', [64]]
            ] }],
    [SignedTransaction, { kind: 'struct', fields: [
                ['transaction', Transaction],
                ['signature', Signature]
            ] }],
    [Transaction, { kind: 'struct', fields: [
                ['signerId', 'string'],
                ['publicKey', key_pair_1.PublicKey],
                ['nonce', 'u64'],
                ['receiverId', 'string'],
                ['blockHash', [32]],
                ['actions', [Action]]
            ] }],
    [key_pair_1.PublicKey, { kind: 'struct', fields: [
                ['keyType', 'u8'],
                ['data', [32]]
            ] }],
    [AccessKey, { kind: 'struct', fields: [
                ['nonce', 'u64'],
                ['permission', AccessKeyPermission],
            ] }],
    [AccessKeyPermission, { kind: 'enum', field: 'enum', values: [
                ['functionCall', FunctionCallPermission],
                ['fullAccess', FullAccessPermission],
            ] }],
    [FunctionCallPermission, { kind: 'struct', fields: [
                ['allowance', { kind: 'option', type: 'u128' }],
                ['receiverId', 'string'],
                ['methodNames', ['string']],
            ] }],
    [FullAccessPermission, { kind: 'struct', fields: [] }],
    [Action, { kind: 'enum', field: 'enum', values: [
                ['createAccount', CreateAccount],
                ['deployContract', DeployContract],
                ['functionCall', FunctionCall],
                ['transfer', Transfer],
                ['stake', Stake],
                ['addKey', AddKey],
                ['deleteKey', DeleteKey],
                ['deleteAccount', DeleteAccount],
            ] }],
    [CreateAccount, { kind: 'struct', fields: [] }],
    [DeployContract, { kind: 'struct', fields: [
                ['code', ['u8']]
            ] }],
    [FunctionCall, { kind: 'struct', fields: [
                ['methodName', 'string'],
                ['args', ['u8']],
                ['gas', 'u64'],
                ['deposit', 'u128']
            ] }],
    [Transfer, { kind: 'struct', fields: [
                ['deposit', 'u128']
            ] }],
    [Stake, { kind: 'struct', fields: [
                ['stake', 'u128'],
                ['publicKey', key_pair_1.PublicKey]
            ] }],
    [AddKey, { kind: 'struct', fields: [
                ['publicKey', key_pair_1.PublicKey],
                ['accessKey', AccessKey]
            ] }],
    [DeleteKey, { kind: 'struct', fields: [
                ['publicKey', key_pair_1.PublicKey]
            ] }],
    [DeleteAccount, { kind: 'struct', fields: [
                ['beneficiaryId', 'string']
            ] }],
]);