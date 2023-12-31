//
//  OsirisSecurityService.swift
//  Osiris
//
//  Created by Julian Reyes on 12/25/23.
//


import CryptoKit
import Security
import Foundation
import UIKit
import SwiftUI


class SecurityService {
    
    // Encrypts a plaintext message using AES GCM
    static func encryptMessage(_ message: Data, using key: SymmetricKey) throws -> AES.GCM.SealedBox {
        return try AES.GCM.seal(message, using: key)
    }
    
    // Decrypts a sealed box using AES GCM
    static func decryptMessage(_ sealedBox: AES.GCM.SealedBox, using key: SymmetricKey) throws -> Data {
        return try AES.GCM.open(sealedBox, using: key)
    }
    
    // Encrypts a message and additional authenticated data
    static func encryptMessageWithAuthenticatedData(_ message: Data, using key: SymmetricKey, authenticating authenticatedData: Data) throws -> AES.GCM.SealedBox {
        return try AES.GCM.seal(message, using: key, authenticating: authenticatedData)
    }
    
    // Decrypts a sealed box and verifies additional authenticated data
    static func decryptMessageWithAuthenticatedData(_ sealedBox: AES.GCM.SealedBox, using key: SymmetricKey, authenticating authenticatedData: Data) throws -> Data {
        return try AES.GCM.open(sealedBox, using: key, authenticating: authenticatedData)
    }
    
    // Wraps a Symmetric Key
    static func wrapKey(_ keyToWrap: SymmetricKey, using kek: SymmetricKey) throws -> Data {
        return try AES.KeyWrap.wrap(keyToWrap, using: kek)
    }
    
    // Unwraps a Symmetric Key
    static func unwrapKey(_ wrappedKey: Data, using kek: SymmetricKey) throws -> SymmetricKey {
        return try AES.KeyWrap.unwrap(wrappedKey, using: kek)
    }
    
    // Send encrypted stream of message//
    static func sendEncryptedStream(_ ciphertexts: [Data], encapsulatedKey: Data, privateKey:
                                    P256.KeyAgreement.PrivateKey) throws -> [Data] {
        
        // Receive encrypted stream of messages
        func receiveEncryptedStream(_ ciphertexts: [Data], encapsulatedKey: Data, privateKey: P256.KeyAgreement.PrivateKey) throws -> [Data] {
            return [Data()] // Replace with your encrypted data
         }
            
            // Step 1: Decrypt the Encapsulated Key
            guard let sharedSecret = try? privateKey.sharedSecretFromKeyAgreement(with: P256.KeyAgreement.PublicKey(rawRepresentation: encapsulatedKey)) else {
                throw NSError(domain: "Could not generate shared secret", code: 1, userInfo: nil)
            }
            
            // Derive the symmetric key from the shared secret
            _ = sharedSecret.hkdfDerivedSymmetricKey(using: SHA256.self, salt: Data(), sharedInfo: Data(), outputByteCount: 32)
            
            // Implement your decryption logic here using symmetricKey
            return [Data()]  // Replace with your decrypted data
        }
        
        class KeychainItem {
            private let service: String
            private let account: String
            
            init(service: String, account: String) {
                self.service = service
                self.account = account
            }
            
            // Nested SealedBox struct
            struct SealedBox {
                let nonce: AES.GCM.Nonce
                let ciphertext: Data
                let tag: Data
                
                static func seal<Plaintext>(
                    _ message: Plaintext,
                    using key: SymmetricKey,
                    nonce: AES.GCM.Nonce? = nil
                ) throws -> SealedBox where Plaintext: DataProtocol {
                    let aesSealedBox = try AES.GCM.seal(message, using: key, nonce: nonce)
                    return try SealedBox(nonce: aesSealedBox.nonce, ciphertext: aesSealedBox.ciphertext, tag: aesSealedBox.tag)
                }
                // Initialize a SealedBox
                init<C, T>(
                    nonce: AES.GCM.Nonce,
                    ciphertext: C,
                    tag: T
                ) throws where C: DataProtocol, T: DataProtocol {
                    self.nonce = nonce
                    self.ciphertext = Data(ciphertext)
                    self.tag = Data(tag)
                }
                
            }
        }
        }



