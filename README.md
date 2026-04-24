# AptosSwift

A comprehensive Swift library for Aptos blockchain interactions, providing wallet management, RPC communication, transaction building, and Borsh serialization.

## Features

- **Wallet Management**: Key pair generation with BIP39 mnemonic support
- **RPC Client**: Complete Aptos REST API client (Node API, Faucet)
- **Transaction Operations**: Create, sign, simulate, and submit transactions
- **Borsh Serialization**: Full Borsh binary encoding/decoding support
- **Entry Function**: Build and call Aptos entry functions with type arguments
- **Account Management**: Account creation, resource queries, and module management

## Requirements

- Swift 5.5+
- iOS 13.0+ / macOS 10.15+

## Installation

### Swift Package Manager

Add AptosSwift to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/xueyuejie/AptosSwift.git", from: "0.0.5")
]
```

## Usage

### Key Pair Generation

```swift
import AptosSwift

// Generate random key pair
let keyPair = try AptosKeyPairEd25519.randomKeyPair()

// Create from mnemonic
let keyPair = try AptosKeyPairEd25519(
    mnemonics: "talk speak heavy can high immune romance language alarm sorry capable flame"
)

// Create from private key
let keyPair = try AptosKeyPairEd25519(
    privateKeyData: Data(hex: "2e0c19e199f9ba403e35817f078114bdcb6ea6341e749f02e4fea83ca055baa7")
)

// Access keys
print(keyPair.privateKeyHex)       // Private key hex
print(keyPair.publicKey.hex)       // Public key hex
print(keyPair.address.address)     // Account address
```

### Node API

#### Faucet Client

```swift
import AptosSwift

let faucetUrl = URL(string: "https://faucet.devnet.aptoslabs.com")!
let faucetClient = AptosFaucetClient(url: faucetUrl)

let address = try AptosAddress("0xde1cbede2618446ed917826e79cc30d93c39eeeef635f76225f714dc2d7e26b6")
let hash = try faucetClient.fundAccount(address: address, amount: 1000000).wait()
```

#### Client

```swift
import AptosSwift

let nodeUrl = URL(string: "https://fullnode.devnet.aptoslabs.com")!
let client = AptosClient(url: nodeUrl)

// Health check
let healthy = try client.healthy().wait()

// Ledger info
let ledgerInfo = try client.getLedgerInfo().wait()

// Account data
let address = try AptosAddress("0x689b6d1d3e54ebb582bef82be2e6781cccda150a6681227b4b0e43ab754834e5")
let accountData = try client.getAccount(address: address).wait()

// Account resource (e.g., coin balance)
let resourceType = "0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>"
let accountResource = try client.getAccountResource(address: address, resourceType: resourceType).wait()
let coinStore = try accountResource.to(AptosClient.AccountResourceData.CoinStore.self)

// Account modules
let accountModules = try client.getAccountModules(address: try AptosAddress("0x1")).wait()

// Block by height
let block = try client.getBlock(0).wait()
```

### Submit Transaction

```swift
import AptosSwift

let nodeUrl = URL(string: "https://fullnode.devnet.aptoslabs.com")!
let client = AptosClient(url: nodeUrl)

let keyPair = try AptosKeyPairEd25519.randomKeyPair()
let sequenceNumber = try client.getAccount(address: keyPair.address).wait().sequenceNumber
let chainId = try client.getLedgerInfo().wait().chainId
let to = try AptosAddress("0xde1cbede2618446ed917826e79cc30d93c39eeeef635f76225f714dc2d7e26b6")
let amount = UInt64(10)

// Build entry function
let function = try AptosEntryFunction.natural(
    module: "0x1::coin",
    func: "transfer",
    typeArgs: [
        AptosTypeTag.Struct(AptosStructTag.fromString("0x1::aptos_coin::AptosCoin"))
    ],
    args: [
        to.data,
        try BorshEncoder().encode(amount)
    ]
)

// Build and sign transaction
let payload = AptosTransactionPayloadEntryFunction(value: function)
let date = UInt64(Date().timeIntervalSince1970 + 60)
let transaction = AptosRawTransaction(
    sender: keyPair.address,
    sequenceNumber: UInt64(sequenceNumber)!,
    maxGasAmount: 1000,
    gasUnitPrice: 1,
    expirationTimestampSecs: date,
    chainId: UInt8(chainId),
    payload: AptosTransactionPayload.EntryFunction(payload)
)

let signedTransaction = try transaction.sign(keyPair)
let result = try client.submitSignedTransaction(signedTransaction).wait()
```

### Simulate Transaction

```swift
import AptosSwift

let nodeUrl = URL(string: "https://fullnode.devnet.aptoslabs.com")!
let client = AptosClient(url: nodeUrl)

// Build transaction (same as above)
// ...

// Simulate without signing
let result = try client.simulateTransaction(transaction, publicKey: keyPair.publicKey).wait()
```

### Borsh Serialization

```swift
import AptosSwift

// Borsh encoding
let encoded = try BorshEncoder().encode(amount)

// Borsh decoding
let decoded = try BorshDecoder().decode(Int.self, from: data)
```

## Dependencies

- **PromiseKit**: Promise-based async operations
- **TweetNacl**: Ed25519 signatures
- **BIP39swift**: Mnemonic code generation
- **BigInt**: Arbitrary precision integers

## License

MIT License

---

# AptosSwift 中文文档

一个全面的 Aptos 区块链交互 Swift 库，提供钱包管理、RPC 通信、交易构建和 Borsh 序列化功能。

## 功能特性

- **钱包管理**：支持 BIP39 助记词的密钥对生成
- **RPC 客户端**：完整的 Aptos REST API 客户端（节点 API、水龙头）
- **交易操作**：创建、签名、模拟和提交交易
- **Borsh 序列化**：完整的 Borsh 二进制编解码支持
- **入口函数**：构建和调用 Aptos 入口函数，支持类型参数
- **账户管理**：账户创建、资源查询和模块管理

## 系统要求

- Swift 5.5+
- iOS 13.0+ / macOS 10.15+

## 安装方式

### Swift Package Manager

在 `Package.swift` 中添加依赖：

```swift
dependencies: [
    .package(url: "https://github.com/xueyuejie/AptosSwift.git", from: "0.0.5")
]
```

## 使用示例

### 密钥对生成

```swift
import AptosSwift

// 生成随机密钥对
let keyPair = try AptosKeyPairEd25519.randomKeyPair()

// 从助记词创建
let keyPair = try AptosKeyPairEd25519(
    mnemonics: "talk speak heavy can high immune romance language alarm sorry capable flame"
)

// 从私钥创建
let keyPair = try AptosKeyPairEd25519(
    privateKeyData: Data(hex: "2e0c19e199f9ba403e35817f078114bdcb6ea6341e749f02e4fea83ca055baa7")
)

// 访问密钥
print(keyPair.privateKeyHex)       // 私钥十六进制
print(keyPair.publicKey.hex)       // 公钥十六进制
print(keyPair.address.address)     // 账户地址
```

### 节点 API

#### 水龙头客户端

```swift
import AptosSwift

let faucetUrl = URL(string: "https://faucet.devnet.aptoslabs.com")!
let faucetClient = AptosFaucetClient(url: faucetUrl)

let address = try AptosAddress("0xde1cbede2618446ed917826e79cc30d93c39eeeef635f76225f714dc2d7e26b6")
let hash = try faucetClient.fundAccount(address: address, amount: 1000000).wait()
```

#### 客户端

```swift
import AptosSwift

let nodeUrl = URL(string: "https://fullnode.devnet.aptoslabs.com")!
let client = AptosClient(url: nodeUrl)

// 健康检查
let healthy = try client.healthy().wait()

// 获取账本信息
let ledgerInfo = try client.getLedgerInfo().wait()

// 获取账户数据
let address = try AptosAddress("0x689b6d1d3e54ebb582bef82be2e6781cccda150a6681227b4b0e43ab754834e5")
let accountData = try client.getAccount(address: address).wait()

// 获取账户资源（如代币余额）
let resourceType = "0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>"
let accountResource = try client.getAccountResource(address: address, resourceType: resourceType).wait()
let coinStore = try accountResource.to(AptosClient.AccountResourceData.CoinStore.self)

// 获取账户模块
let accountModules = try client.getAccountModules(address: try AptosAddress("0x1")).wait()

// 按高度获取区块
let block = try client.getBlock(0).wait()
```

### 提交交易

```swift
import AptosSwift

let nodeUrl = URL(string: "https://fullnode.devnet.aptoslabs.com")!
let client = AptosClient(url: nodeUrl)

let keyPair = try AptosKeyPairEd25519.randomKeyPair()
let sequenceNumber = try client.getAccount(address: keyPair.address).wait().sequenceNumber
let chainId = try client.getLedgerInfo().wait().chainId
let to = try AptosAddress("0xde1cbede2618446ed917826e79cc30d93c39eeeef635f76225f714dc2d7e26b6")
let amount = UInt64(10)

// 构建入口函数
let function = try AptosEntryFunction.natural(
    module: "0x1::coin",
    func: "transfer",
    typeArgs: [
        AptosTypeTag.Struct(AptosStructTag.fromString("0x1::aptos_coin::AptosCoin"))
    ],
    args: [
        to.data,
        try BorshEncoder().encode(amount)
    ]
)

// 构建并签名交易
let payload = AptosTransactionPayloadEntryFunction(value: function)
let date = UInt64(Date().timeIntervalSince1970 + 60)
let transaction = AptosRawTransaction(
    sender: keyPair.address,
    sequenceNumber: UInt64(sequenceNumber)!,
    maxGasAmount: 1000,
    gasUnitPrice: 1,
    expirationTimestampSecs: date,
    chainId: UInt8(chainId),
    payload: AptosTransactionPayload.EntryFunction(payload)
)

let signedTransaction = try transaction.sign(keyPair)
let result = try client.submitSignedTransaction(signedTransaction).wait()
```

### 模拟交易

```swift
import AptosSwift

let nodeUrl = URL(string: "https://fullnode.devnet.aptoslabs.com")!
let client = AptosClient(url: nodeUrl)

// 构建交易（同上）
// ...

// 无需签名即可模拟
let result = try client.simulateTransaction(transaction, publicKey: keyPair.publicKey).wait()
```

### Borsh 序列化

```swift
import AptosSwift

// Borsh 编码
let encoded = try BorshEncoder().encode(amount)

// Borsh 解码
let decoded = try BorshDecoder().decode(Int.self, from: data)
```

## 依赖库

- **PromiseKit**: 基于 Promise 的异步操作
- **TweetNacl**: Ed25519 签名
- **BIP39swift**: 助记词生成
- **BigInt**: 任意精度整数

## 许可证

MIT License
