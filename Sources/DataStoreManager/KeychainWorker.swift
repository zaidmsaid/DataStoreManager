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
        public typealias ProtocolType = DataStoreProtocolType

        /// Type to mean instance of DataStoreAuthenticationType.
        public typealias AuthenticationType = DataStoreAuthenticationType

        // MARK: - Properties

        var dataStoreManager: DataStoreManager?

        var genericKeychainService: String {
            if let manager = dataStoreManager, let service = manager.dataSource?.genericKeychainService?(for: manager) {
                return service
            }
            return Bundle.main.bundleIdentifier ?? "DataStoreManager"
        }

        var genericKeychainAccessGroup: String? {
            if let manager = dataStoreManager {
                return manager.dataSource?.genericKeychainAccessGroup?(for: manager)
            }
            return nil
        }

        var internetKeychainServer: URL? {
            if let manager = dataStoreManager {
                return manager.dataSource?.internetKeychainServer?(for: manager)
            }
            return nil
        }

        var internetKeychainProtocolType: ProtocolType? {
            if let manager = dataStoreManager {
                return manager.dataSource?.internetKeychainProtocolType?(for: manager)
            }
            return nil
        }

        var internetKeychainAuthenticationType: AuthenticationType? {
            if let manager = dataStoreManager {
                return manager.dataSource?.internetKeychainAuthenticationType?(for: manager)
            }
            return nil
        }

        var isSynchronizable: Bool {
            if let manager = dataStoreManager, let isSynchronizable = manager.dataSource?.keychainIsSynchronizable?(for: manager) {
                return isSynchronizable
            }
            return false
        }

        var operationPrompt: String? {
            #if os(iOS) || os(macOS)
            if let manager = dataStoreManager {
                return manager.dataSource?.keychainOperationPrompt?(for: manager)
            }
            #endif
            return nil
        }

        #if os(iOS) || os(macOS)
        var localAuthenticationContext: LAContext? {
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

            var item = getKeychainItem(forAccount: key, forItemClass: itemClass)
            item[kSecMatchLimit as String] = kSecMatchLimitOne
            item[kSecReturnAttributes as String] = kCFBooleanTrue
            item[kSecReturnData as String] = kCFBooleanTrue

            var object: AnyObject?
            let status = withUnsafeMutablePointer(to: &object) {
                SecItemCopyMatching(item as CFDictionary, UnsafeMutablePointer($0))
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

            let item = getKeychainItem(forAccount: key, forItemClass: itemClass)
            let status = SecItemDelete(item as CFDictionary)

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

            var item = [String : AnyObject]()

            switch itemClass {
            case .generic:
                item[kSecClass as String] = kSecClassGenericPassword
                item[kSecAttrService as String] = genericKeychainService as AnyObject

                #if !targetEnvironment(simulator)
                if let accessGroup = self.genericKeychainAccessGroup {
                    item[kSecAttrAccessGroup as String] = accessGroup as AnyObject
                }
                #endif

            case .internet:
                item[kSecClass as String] = kSecClassInternetPassword

                if let server = internetKeychainServer {
                    item[kSecAttrServer as String] = server.host as AnyObject
                    item[kSecAttrPort as String] = server.port as AnyObject
                }

                if let protocolType = internetKeychainProtocolType {
                    item[kSecAttrProtocol as String] = protocolType.rawValue as AnyObject
                }

                if let authenticationType = internetKeychainAuthenticationType {
                    item[kSecAttrAuthenticationType as String] = authenticationType.rawValue as AnyObject
                }
            }

            #if arch(i386) || arch(x86_64)
            item[kSecMatchLimit as String] = kSecMatchLimitAll
            #endif

            let status = SecItemDelete(item as CFDictionary)

            guard status == errSecSuccess else {
                let error = ErrorObject(protocol: .deleteFailed(detail: status.description))
                completionHandler(false, nil, error)
                return
            }

            completionHandler(true, nil, nil)
        }

        private func create(_ value: Any, forKey key: String, forItemClass itemClass: ItemClass, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            var newItem = getKeychainItem(forAccount: key, forItemClass: itemClass)
            newItem[kSecValueData as String] = value as AnyObject

            let status = SecItemAdd(newItem as CFDictionary, nil)

            guard status == noErr else {
                let error = ErrorObject(protocol: .createFailed(detail: status.description))
                completionHandler(false, nil, error)
                return
            }
            
            completionHandler(true, nil, nil)
        }

        private func update(_ value: Any, forKey key: String, forItemClass itemClass: ItemClass, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            var newItem = [String : AnyObject]()
            newItem[kSecValueData as String] = value as AnyObject

            let item = getKeychainItem(forAccount: key, forItemClass: itemClass)
            let status = SecItemUpdate(item as CFDictionary, newItem as CFDictionary)

            guard status == noErr else {
                let error = ErrorObject(protocol: .updateFailed(detail: status.description))
                completionHandler(false, nil, error)
                return
            }

            completionHandler(true, nil, nil)
        }

        // MARK: - Helper

        private final func getKeychainItem(forAccount account: String, forItemClass itemClass: ItemClass) -> [String : AnyObject] {

            var item = [String : AnyObject]()

            switch itemClass {
            case .generic:
                let secAttrService: AnyObject = genericKeychainService as AnyObject
                item[kSecClass as String] = kSecClassGenericPassword
                item[kSecAttrService as String] = secAttrService
                item[kSecAttrGeneric as String] = account as AnyObject

                #if !targetEnvironment(simulator)
                if let accessGroup = self.genericKeychainAccessGroup {
                    item[kSecAttrAccessGroup as String] = accessGroup as AnyObject
                }
                #endif
                
            case .internet:
                item[kSecClass as String] = kSecClassInternetPassword

                if let server = internetKeychainServer {
                    item[kSecAttrServer as String] = server.host as AnyObject
                    item[kSecAttrPort as String] = server.port as AnyObject
                }

                if let protocolType = internetKeychainProtocolType {
                    item[kSecAttrProtocol as String] = protocolType.rawValue as AnyObject
                }

                if let authenticationType = internetKeychainAuthenticationType {
                    item[kSecAttrAuthenticationType as String] = authenticationType.rawValue as AnyObject
                }

            @unknown case _:
                assertionFailure("Use a representation that was unknown when this code was compiled.")
            }

            item[kSecAttrAccount as String] = account as AnyObject

            if isSynchronizable {
                item[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny
            }

            #if !os(watchOS) && !os(tvOS)
            if #available(iOS 8.0, macOS 10.10, *) {
                if let useOperationPrompt = operationPrompt {
                    item[kSecUseOperationPrompt as String] = useOperationPrompt as AnyObject
                }
            }

            if #available(iOS 9.0, macOS 10.11, *) {
                if let useAuthenticationContext = localAuthenticationContext {
                    item[kSecUseAuthenticationContext as String] = useAuthenticationContext as AnyObject
                }
            }
            #endif

            item[kSecMatchLimit as String] = kSecMatchLimitOne

            return item
        }
    }
}
