//
//  AptosKeyPair.swift
//  
//
//  Created by 薛跃杰 on 2022/8/2.
//

import Foundation
import TweetNacl
import BIP39swift
import CryptoSwift

public struct AptosAddress {
    public var data:Data
    
    public static let SIZE: Int = 32
    
    public var address:String {
        self.data.toHexString()
    }
    
    public init(_ pubKey:Data) {
        self.data = Data(pubKey.bytes + [0]).sha3(.sha256)
    }
    
    public init?(_ string:String) {
        let addressData = Data(hex: string)
        guard addressData.count == AptosAddress.SIZE else {
            return nil
        }
        self.data = addressData
    }
}

public struct AptosKeyPair {
    public var mnemonics: String?
    public var secretKey:Data
    
    public var privateKey:Data {
        return secretKey[0..<32]
    }
    
    public var publicKey:Data {
        return secretKey[32..<64]
    }
    
    public var address:AptosAddress {
        return AptosAddress(pubKey:self.publicKey)
    }
    
    public init(privateKey:Data) throws {
        let keyPair = try NaclSign.KeyPair.keyPair(fromSeed:privateKey)
        self.secretKey = keyPair.secretKey
    }
    
    public init(seed: Data) throws {
        try self.init(privateKey: seed[0..<32])
    }
    
    public init(mnemonics:String) throws {
        guard let seed = BIP39.seedFromMmemonics(mnemonics) else {
            throw Error.invalidMnemonic
        }
        try self.init(seed: seed)
        self.mnemonics = mnemonics
    }
    
    public static func randomKeyPair() throws -> AptosKeyPair {
        guard let mnemonic = try? BIP39.generateMnemonics(bitsOfEntropy: 128) else{
            throw AptosKeyPair.Error.invalidMnemonic
        }
        return try AptosKeyPair(mnemonics: mnemonic)
    }
}

// MARK: - Sign&Verify

extension AptosKeyPair {
    public func signDigest(messageDigest:Data) throws -> Data {
        return try NaclSign.signDetached(message: messageDigest, secretKey: secretKey)
    }
    
    public func signVerify(message: Data, signature: Data) -> Bool {
        guard let ret = try? NaclSign.signDetachedVerify(message: message, sig: signature, publicKey: publicKey) else {
            return false
        }
        return ret
    }
}

extension AptosKeyPair {
    public enum Error: String, LocalizedError {
        case invalidMnemonic
        case invalidDerivePath
        case unknown
        
        public var errorDescription: String? {
            return "AptosKeyPair.Error.\(rawValue)"
        }
    }
}
