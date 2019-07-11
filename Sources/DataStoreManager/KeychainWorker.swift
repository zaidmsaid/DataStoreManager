//
//  Copyright 2019 Zaid M. Said
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import Security
#if os(iOS) || os(macOS)
import LocalAuthentication
#endif

// MARK: - SecItem

extension DataStoreManager {

    /// An interface to the SecItem.
    class KeychainWorker {

        // MARK: - Enumerations

        @objc enum ItemClass : Int {

            case generic
            case internet
        }

        // MARK: - Type Aliases

        /// Type to mean instance of DataStoreProtocolType.
        typealias ProtocolType = DataStoreProtocolType

        /// Type to mean instance of DataStoreAuthenticationType.
        typealias AuthenticationType = DataStoreAuthenticationType

        // MARK: - Properties

        var dataStoreManager: DataStoreManager?

        private var genericKeychainService: String {
            if let manager = dataStoreManager, let service = manager.dataSource?.genericKeychainService?(for: manager) {
                return service
            }
            return Bundle.main.bundleIdentifier ?? "DataStoreManager"
        }

        private var genericKeychainAccessGroup: String? {
            if let manager = dataStoreManager {
                return manager.dataSource?.genericKeychainAccessGroup?(for: manager)
            }
            return nil
        }

        private var internetKeychainServer: URL? {
            if let manager = dataStoreManager {
                return manager.dataSource?.internetKeychainServer?(for: manager)
            }
            return nil
        }

        private var internetKeychainProtocolType: ProtocolType? {
            if let manager = dataStoreManager {
                return manager.dataSource?.internetKeychainProtocolType?(for: manager)
            }
            return nil
        }

        private var internetKeychainAuthenticationType: AuthenticationType? {
            if let manager = dataStoreManager {
                return manager.dataSource?.internetKeychainAuthenticationType?(for: manager)
            }
            return nil
        }

        private var isSynchronizable: Bool {
            if let manager = dataStoreManager, let isSynchronizable = manager.dataSource?.keychainIsSynchronizable?(for: manager) {
                return isSynchronizable
            }
            return false
        }

        #if os(iOS) || os(macOS)
        private var operationPrompt: String? {
            if let manager = dataStoreManager {
                return manager.dataSource?.keychainOperationPrompt?(for: manager)
            }
            return nil
        }

        private var localAuthenticationContext: LAContext? {
            if let manager = dataStoreManager {
                return manager.dataSource?.keychainLocalAuthenticationContext?(for: manager)
            }
            return nil
        }
        #endif

        // MARK: - CRUD

        func create(object: Any, forKey key: String, forItemClass itemClass: ItemClass, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            create(object, forKey: key, forItemClass: itemClass, completionHandler: completionHandler)
        }

        func read(forKey key: String, forItemClass itemClass: ItemClass, completionHandler: @escaping (_ object: Any?, _ objectID: Any?, _ error: Error?) -> Void) {

            var query = getKeychainQuery(forAccount: key, forItemClass: itemClass)
            query[kSecMatchLimit as String] = kSecMatchLimitOne
            query[kSecReturnAttributes as String] = kCFBooleanTrue
            query[kSecReturnData as String] = kCFBooleanTrue

            var object: AnyObject?
            let status = withUnsafeMutablePointer(to: &object) {
                SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
            }

            let error = ErrorObject(code: status.hashValue, value: status.description)
            guard status == noErr else {
                completionHandler(nil, nil, error)
                return
            }

            guard status == errSecItemNotFound else {
                completionHandler(nil, nil, error)
                return
            }

            completionHandler(object, nil, nil)
        }

        func update(object: Any, forKey key: String, forItemClass itemClass: ItemClass, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            update(object, forKey: key, forItemClass: itemClass, completionHandler: completionHandler)
        }

        func delete(forKey key: String, forItemClass itemClass: ItemClass, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            let query = getKeychainQuery(forAccount: key, forItemClass: itemClass)
            let status = SecItemDelete(query as CFDictionary)

            guard status == noErr else {
                let error = ErrorObject(protocol: .deleteFailed(detail: status.description))
                completionHandler(false, nil, error)
                return
            }

            guard status == errSecItemNotFound else {
                let error = ErrorObject(protocol: .readFailed(detail: status.description))
                completionHandler(false, nil, error)
                return
            }

            completionHandler(true, nil, nil)
        }

        func deleteAll(forItemClass itemClass: ItemClass, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            var query = [String : AnyObject]()

            switch itemClass {
            case .generic:
                query[kSecClass as String] = kSecClassGenericPassword
                query[kSecAttrService as String] = genericKeychainService as AnyObject

                #if !targetEnvironment(simulator)
                if let accessGroup = self.genericKeychainAccessGroup {
                    query[kSecAttrAccessGroup as String] = accessGroup as AnyObject
                }
                #endif

            case .internet:
                query[kSecClass as String] = kSecClassInternetPassword

                if let server = internetKeychainServer {
                    query[kSecAttrServer as String] = server.host as AnyObject
                    query[kSecAttrPort as String] = server.port as AnyObject
                }

                if let protocolType = internetKeychainProtocolType {
                    query[kSecAttrProtocol as String] = protocolType.rawValue as AnyObject
                }

                if let authenticationType = internetKeychainAuthenticationType {
                    query[kSecAttrAuthenticationType as String] = authenticationType.rawValue as AnyObject
                }
            }

            #if arch(i386) || arch(x86_64)
            query[kSecMatchLimit as String] = kSecMatchLimitAll
            #endif

            let status = SecItemDelete(query as CFDictionary)

            guard status == errSecSuccess else {
                let error = ErrorObject(protocol: .deleteFailed(detail: status.description))
                completionHandler(false, nil, error)
                return
            }

            completionHandler(true, nil, nil)
        }

        private func create(_ value: Any, forKey key: String, forItemClass itemClass: ItemClass, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            var query = getKeychainQuery(forAccount: key, forItemClass: itemClass)
            query[kSecValueData as String] = value as AnyObject

            let status = SecItemAdd(query as CFDictionary, nil)

            guard status == noErr else {
                let error = ErrorObject(protocol: .createFailed(detail: status.description))
                completionHandler(false, nil, error)
                return
            }
            
            completionHandler(true, nil, nil)
        }

        private func update(_ value: Any, forKey key: String, forItemClass itemClass: ItemClass, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            var newQuery = [String : AnyObject]()
            newQuery[kSecValueData as String] = value as AnyObject

            let query = getKeychainQuery(forAccount: key, forItemClass: itemClass)
            let status = SecItemUpdate(query as CFDictionary, newQuery as CFDictionary)

            guard status == noErr else {
                let error = ErrorObject(protocol: .updateFailed(detail: status.description))
                completionHandler(false, nil, error)
                return
            }

            completionHandler(true, nil, nil)
        }

        // MARK: - Helpers

        private final func getKeychainQuery(forAccount account: String, forItemClass itemClass: ItemClass) -> [String : AnyObject] {

            var query = [String : AnyObject]()

            switch itemClass {
            case .generic:
                let secAttrService: AnyObject = genericKeychainService as AnyObject
                query[kSecClass as String] = kSecClassGenericPassword
                query[kSecAttrService as String] = secAttrService
                query[kSecAttrGeneric as String] = account as AnyObject

                #if !targetEnvironment(simulator)
                if let accessGroup = self.genericKeychainAccessGroup {
                    query[kSecAttrAccessGroup as String] = accessGroup as AnyObject
                }
                #endif
                
            case .internet:
                query[kSecClass as String] = kSecClassInternetPassword

                if let server = internetKeychainServer {
                    query[kSecAttrServer as String] = server.host as AnyObject
                    query[kSecAttrPort as String] = server.port as AnyObject
                }

                if let protocolType = internetKeychainProtocolType {
                    query[kSecAttrProtocol as String] = protocolType.rawValue as AnyObject
                }

                if let authenticationType = internetKeychainAuthenticationType {
                    query[kSecAttrAuthenticationType as String] = authenticationType.rawValue as AnyObject
                }

            @unknown case _:
                assertionFailure("Use a representation that was unknown when this code was compiled.")
            }

            query[kSecAttrAccount as String] = account as AnyObject

            if isSynchronizable {
                query[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny
            }

            #if os(iOS) || os(macOS)
            if #available(iOS 8.0, macOS 10.10, *) {
                if let useOperationPrompt = operationPrompt {
                    query[kSecUseOperationPrompt as String] = useOperationPrompt as AnyObject
                }
            }

            if #available(iOS 9.0, macOS 10.11, *) {
                if let useAuthenticationContext = localAuthenticationContext {
                    query[kSecUseAuthenticationContext as String] = useAuthenticationContext as AnyObject
                }
            }
            #endif

            query[kSecMatchLimit as String] = kSecMatchLimitOne

            return query
        }
    }
}
