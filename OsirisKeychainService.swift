//
//  OsirisKeychainService.swift
//  Osiris
//
//  Created by Julian Reyes on 12/25/23.
//

import Foundation
import CryptoKit
import Security
import UIKit
import SwiftUI


class KeychainItem {
    private let service: String
    private let account: String

    init(service: String, account: String) {
        self.service = service
        self.account = account
    }
    
    // Function to save CryptoKit keys
    func saveCryptoKey(_ key: P256.Signing.PrivateKey) throws {
           let keyData = key.x963Representation
           try saveItem(keyData)
    }

    // Function to read CryptoKit keys
    func readCryptoKey() throws -> P256.Signing.PrivateKey? {
        guard let keyData = try readItem() as Data? else { return nil }
        return try? P256.Signing.PrivateKey(x963Representation: keyData)
    }

    // Function to save Data
    func saveItem(_ item: Data) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: self.account,
                                    kSecAttrServer as String: self.service,
                                    kSecValueData as String: item]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }

    // Function to read Data
    func readItem() throws -> Data? {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: self.account,
                                    kSecAttrServer as String: self.service,
                                    kSecReturnData as String: kCFBooleanTrue!,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        guard let data = dataTypeRef as? Data else { throw KeychainError.unexpectedPasswordData }
        return data
    }
}

enum KeychainError: Error {
    case unhandledError(status: OSStatus)
    case unexpectedPasswordData
    case unexpectedItemData
}

// Declare this variable as an optional, populate it when the user logs in
var currentUserEmail: String? = nil

// Function to update currentUserEmail after a successful login or registration
func userDidLogIn(with email: String) {
    currentUserEmail = email
}

// Login function that would call userDidLogIn
func loginUser(email: String, password: String) {
    // Authentication logic here...
    // On successful login:
    userDidLogIn(with: email)
    // Then proceed to save the key for this user
    saveKey()
}

// Saving a key to the keychain
func saveKey() {
    do {
        guard let email = currentUserEmail else {
            print("User not logged in.")
            return
        }
        
        let privateKey = P256.Signing.PrivateKey()
        let keychainItem = KeychainItem(service: "com.cognitivepcsolutions.confuciusapp", account: email)
        try keychainItem.saveCryptoKey(privateKey)
    } catch {
        print("An error occurred: \(error)")
    }
}

// Reading a key from the keychain
func readKey() -> P256.Signing.PrivateKey? {
    guard let email = currentUserEmail else {
        print("User not logged in.")
        return nil
    }
    
    let keychainItem = KeychainItem(service: "com.cognitivepcsolutions.confuciusapp", account: email)
    do {
        let retrievedKey = try keychainItem.readCryptoKey()
        return retrievedKey
    } catch {
        print("An error occurred: \(error)")
        return nil
    }
}

enum InnerKeychainError: Error {
    class KeychainItem {
        private let service: String
        private let account: String
        init(service: String, account: String) {
            self.service = service
            self.account = account
        }
        
        func saveItem(_ item: String) throws {
            guard let data = item.data(using: .utf8) else { return }
            
            let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                        kSecAttrAccount as String: account,
                                        kSecAttrServer as String: service,
                                        kSecValueData as String: data]
            
            SecItemDelete(query as CFDictionary)
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        }
        
        func readItem() throws -> String {
            let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                        kSecAttrAccount as String: account,
                                        kSecAttrServer as String: service,
                                        kSecReturnData as String: kCFBooleanTrue!,
                                        kSecMatchLimit as String: kSecMatchLimitOne]
            
            var dataTypeRef: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
            
            guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
            guard let data = dataTypeRef as? Data else { throw KeychainError.unexpectedPasswordData }
            guard let item = String(data: data, encoding: .utf8) else { throw KeychainError.unexpectedItemData }
            return item
        }
        
        func deleteItem() throws {
            let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                        kSecAttrAccount as String: account,
                                        kSecAttrServer as String: service]
            let status = SecItemDelete(query as CFDictionary)
            guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        }
    }
    
    enum KeychainError: Error {
        case unhandledError(status: OSStatus)
        case unexpectedPasswordData
        case unexpectedItemData
    }
}

class KeychainService {
    
    private let service: String
    private let account: String
    
    init(service: String, account: String) {
        self.service = service
        self.account = account
    }
    
    static func storeAuthorizationKey(_ authKey: String) -> OSStatus {
        let authKeyData = Data(authKey.utf8)
        let keychainItemQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "authorizationKey",
            kSecValueData as String: authKeyData
        ]
        return SecItemAdd(keychainItemQuery as CFDictionary, nil)
    }
    
    static func fetchAuthorizationKey() -> String? {
        let keychainQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: "authorizationKey",
                kSecReturnData as String: kCFBooleanTrue!,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            
            var retrievedData: AnyObject?
            var result: String? = nil
            
            let status = withUnsafeMutablePointer(to: &retrievedData) {
                SecItemCopyMatching(keychainQuery as CFDictionary, UnsafeMutablePointer($0))
            }
            
            if status == errSecSuccess {
                if let data = retrievedData as? Data {
                    result = String(data: data, encoding: .utf8)
                }
            }
            
            return result
        }
    
    func generateNewKey() -> P256.Signing.PrivateKey {
        return P256.Signing.PrivateKey()
    }
    
    func saveCryptoKey(_ key: P256.Signing.PrivateKey) throws {
        let keyData = key.x963Representation
        try saveItem(keyData)
    }
    
    func readCryptoKey() throws -> P256.Signing.PrivateKey? {
        if let keyData = try readItem() {
            return try? P256.Signing.PrivateKey(x963Representation: keyData)
        }
        return nil
    }
    
    func saveItem(_ item: Data) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: account,
                                    kSecAttrServer as String: service,
                                    kSecValueData as String: item]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }
    
    func readItem() throws -> Data? {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: account,
                                    kSecAttrServer as String: service,
                                    kSecReturnData as String: kCFBooleanTrue!,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        return dataTypeRef as? Data
    }
    
    class SecurityService {
        
        static let shared = SecurityService()
        private let keychainItem: KeychainItem
        
        private init() {
            // Initialize KeychainItem
            self.keychainItem = KeychainItem(service: "com.cognitivepcsolutions.confuciusapp", account: "defaultAccount")
        }
        
        // Public method to securely save CryptoKey
        func saveSecureCryptoKey(_ key: P256.Signing.PrivateKey) throws {
            // Perform additional security checks or logging
            try keychainItem.saveCryptoKey(key)
        }
        
        // Public method to securely read CryptoKey
        func readSecureCryptoKey() throws -> P256.Signing.PrivateKey? {
            // Perform additional security checks or logging
            return try keychainItem.readCryptoKey()
        }
        
        // Additional methods related to security service can be added
    }
    
    // Client code for Security Service
    class Client {
        func someFunction() {
            do {
                // Generating a new private key
                let newPrivateKey = P256.Signing.PrivateKey()
                
                // Saving the key securely via SecurityService
                try SecurityService.shared.saveSecureCryptoKey(newPrivateKey)
                
                // Reading the saved key
                _ = try SecurityService.shared.readSecureCryptoKey()
                
                // Use the retrieved key
                // ...
                
            } catch {
                print("An error occurred: \(error)")
            }
        }
    }
}

