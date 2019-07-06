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

import Security

// MARK: - SecItem

extension DataStoreManager {

    /// An interface to the SecItem.
    class KeychainWorker {

        // MARK: - Type Aliases

        /// Type to mean instance of DataStoreProtocolType.
        public typealias ProtocolType = DataStoreProtocolType

        // MARK: - Properties

        var dataStoreManager: DataStoreManager?

        var genericPasswordService: String {
            if let manager = dataStoreManager, let service = manager.dataSource?.genericPasswordKeychainService?(for: manager) {
                return service
            }
            return Bundle.main.bundleIdentifier ?? "DataStoreManager"
        }

        var genericPasswordAccessGroup: String? {
            if let manager = dataStoreManager {
                return manager.dataSource?.genericPasswordKeychainAccessGroup?(for: manager)
            }
            return nil
        }

        var internetPasswordServer: URL? {
            if let manager = dataStoreManager {
                return manager.dataSource?.internetPasswordKeychainServer?(for: manager)
            }
            return nil
        }

        var internetPasswordProtocolType: ProtocolType? {
            if let manager = dataStoreManager {
                return manager.dataSource?.internetPasswordKeychainProtocolType?(for: manager)
            }
            return nil
        }

        var internetPasswordAuthenticationType: String? {
            if let manager = dataStoreManager {
                return manager.dataSource?.internetPasswordKeychainAuthenticationType?(for: manager)
            }
            return nil
        }

        var isSynchronizable: Bool {
            if let manager = dataStoreManager, let isSynchronizable = manager.dataSource?.keychainIsSynchronizable?(for: manager) {
                return isSynchronizable
            }
            return false
        }

        // MARK: - Enumerations

        @objc enum ItemClass : Int {

            case genericPassword
            case internetPassword
        }

        // MARK: - CRUD

        func create(value: Any, forKey key: String, forItemClass itemClass: ItemClass, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            create(value, forKey: key, forItemClass: itemClass, completionHandler: completionHandler)
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

            let error = DataStoreError(code: status.hashValue, value: status.description)
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

        func update(value: Any, forKey key: String, forItemClass itemClass: ItemClass, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            update(value, forKey: key, forItemClass: itemClass, completionHandler: completionHandler)
        }

        func delete(forKey key: String, forItemClass itemClass: ItemClass, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            let item = getKeychainItem(forAccount: key, forItemClass: itemClass)
            let status = SecItemDelete(item as CFDictionary)

            guard status == noErr else {
                let error = DataStoreError(type: .deleteFailed)
                completionHandler(false, nil, error)
                return
            }

            guard status == errSecItemNotFound else {
                let error = DataStoreError(type: .readFailed)
                completionHandler(false, nil, error)
                return
            }

            completionHandler(true, nil, nil)
        }

        func deleteAll(forItemClass itemClass: ItemClass, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            var item = [String : AnyObject]()

            switch itemClass {
            case .genericPassword:
                item[kSecClass as String] = kSecClassGenericPassword
                item[kSecAttrService as String] = genericPasswordService as AnyObject

                #if !targetEnvironment(simulator)
                if let accessGroup = self.genericPasswordAccessGroup {
                    item[kSecAttrAccessGroup as String] = accessGroup as AnyObject
                }
                #endif

            case .internetPassword:
                if let server = internetPasswordServer {
                    item[kSecAttrServer as String] = server.host as AnyObject
                    item[kSecAttrPort as String] = server.port as AnyObject
                }

                if let protocolType = internetPasswordProtocolType {
                    item[kSecAttrProtocol as String] = protocolType.rawValue as AnyObject
                }

                if let authenticationType = internetPasswordAuthenticationType {
                    item[kSecAttrAuthenticationType as String] = authenticationType as AnyObject
                }
            }

            let status = SecItemDelete(item as CFDictionary)

            guard status == errSecSuccess else {
                let error = DataStoreError(type: .deleteFailed)
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
                let error = DataStoreError(type: .createFailed)
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
                let error = DataStoreError(type: .updateFailed)
                completionHandler(false, nil, error)
                return
            }

            completionHandler(true, nil, nil)
        }

        // MARK: - Helper

        private final func getKeychainItem(forAccount account: String, forItemClass itemClass: ItemClass) -> [String : AnyObject] {

            var item = [String : AnyObject]()

            switch itemClass {
            case .genericPassword:
                let secAttrService: AnyObject = genericPasswordService as AnyObject
                item[kSecClass as String] = kSecClassGenericPassword
                item[kSecAttrService as String] = secAttrService
                item[kSecAttrGeneric as String] = account as AnyObject

                #if !targetEnvironment(simulator)
                if let accessGroup = self.genericPasswordAccessGroup {
                    item[kSecAttrAccessGroup as String] = accessGroup as AnyObject
                }
                #endif
                
            case .internetPassword:
                if let server = internetPasswordServer {
                    item[kSecAttrServer as String] = server.host as AnyObject
                    item[kSecAttrPort as String] = server.port as AnyObject
                }

                if let protocolType = internetPasswordProtocolType {
                    item[kSecAttrProtocol as String] = protocolType.rawValue as AnyObject
                }

                if let authenticationType = internetPasswordAuthenticationType {
                    item[kSecAttrAuthenticationType as String] = authenticationType as AnyObject
                }

            @unknown case _:
                assertionFailure("Use a representation that was unknown when this code was compiled.")
            }

            item[kSecAttrAccount as String] = account as AnyObject

            if isSynchronizable {
                item[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny
            }

            return item
        }
    }
}
