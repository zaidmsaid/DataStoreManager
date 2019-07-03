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

        // MARK: - Properties

        var service: String?
        var account: String?
        var accessGroup: String?

        // MARK: - CRUD

        func setValue(value: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            object(forKey: key) { (object) in
                if object == nil {
                    var newItem = self.getKeychainItem(withService: self.service, account: self.account ?? key, accessGroup: self.accessGroup)
                    newItem[kSecValueData as String] = value as AnyObject?
                    let status = SecItemAdd(newItem as CFDictionary, nil)
                    completionHandler(status == noErr)

                } else {
                    var newItem = [String : AnyObject]()
                    newItem[kSecValueData as String] = value as AnyObject?

                    let item = self.getKeychainItem(withService: self.service, account: self.account ?? key, accessGroup: self.accessGroup)
                    let status = SecItemUpdate(item as CFDictionary, newItem as CFDictionary)

                    guard status == noErr else {
                        assertionFailure("Unable to update object to Keychain")
                        completionHandler(false)
                        return
                    }
                    completionHandler(true)
                }
            }
        }

        func object(forKey key: String, completionHandler: @escaping (_ object: Any?) -> Void) {

            var item = getKeychainItem(withService: service, account: account ?? key, accessGroup: accessGroup)
            item[kSecMatchLimit as String] = kSecMatchLimitOne
            item[kSecReturnAttributes as String] = kCFBooleanTrue
            item[kSecReturnData as String] = kCFBooleanTrue

            var object: AnyObject?
            let status = withUnsafeMutablePointer(to: &object) {
                SecItemCopyMatching(item as CFDictionary, UnsafeMutablePointer($0))
            }

            guard status == noErr else {
                assertionFailure("Unable to get object from Keychain")
                completionHandler(nil)
                return
            }
            guard status == errSecItemNotFound else {
                completionHandler(nil)
                return
            }
            completionHandler(object)
        }

        func removeObject(forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            let item = getKeychainItem(withService: service, account: account ?? key, accessGroup: accessGroup)
            let status = SecItemDelete(item as CFDictionary)

            guard status == noErr else {
                assertionFailure("Unable to delete object from Keychain")
                completionHandler(false)
                return
            }
            guard status == errSecItemNotFound else {
                completionHandler(false)
                return
            }
            completionHandler(true)
        }

        func removeAllObjects(completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            var item = [String : AnyObject]()
            item[kSecClass as String] = kSecClassGenericPassword
            item[kSecAttrService as String] = service as AnyObject?
            if let accessGroup = self.accessGroup {
                item[kSecAttrAccessGroup as String] = accessGroup as AnyObject
            }
            let status = SecItemDelete(item as CFDictionary)

            guard status == errSecSuccess else {
                assertionFailure("Unable to delete all object from Keychain")
                completionHandler(false)
                return
            }
            completionHandler(true)
        }

        // MARK: - Helper

        private final func getKeychainItem(withService service: String?, account: String? = nil, accessGroup: String? = nil) -> [String : AnyObject] {
            let secAttrService: AnyObject = service as AnyObject? ?? Bundle.main.bundleIdentifier as AnyObject? ?? "DataStoreManager" as AnyObject
            var item = [String : AnyObject]()
            item[kSecClass as String] = kSecClassGenericPassword
            item[kSecAttrService as String] = secAttrService

            if let account = account {
                item[kSecAttrGeneric as String] = account as AnyObject?
                item[kSecAttrAccount as String] = account as AnyObject?
            }

            if let accessGroup = accessGroup {
                item[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
            }

            return item
        }
    }
}
