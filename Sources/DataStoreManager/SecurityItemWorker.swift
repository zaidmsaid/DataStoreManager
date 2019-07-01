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

extension DataStoreManager {

    /// An interface to the SecItem.
    class SecurityItemWorker {

        // MARK: - CRUD

        static var service: String?
        static var account: String?
        static var accessGroup: String?

        class func create(value: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            var newItem = keychainItem(withService: service, account: account ?? key, accessGroup: accessGroup)
            newItem[kSecValueData as String] = value as AnyObject?
            let status = SecItemAdd(newItem as CFDictionary, nil)
            completionHandler(status == noErr)
        }

        class func read(forKey key: String, completionHandler: @escaping (_ object: Any?) -> Void) {

            var item = keychainItem(withService: service, account: account ?? key, accessGroup: accessGroup)
            item[kSecMatchLimit as String] = kSecMatchLimitOne
            item[kSecReturnAttributes as String] = kCFBooleanTrue
            item[kSecReturnData as String] = kCFBooleanTrue

            var object: AnyObject?
            let status = withUnsafeMutablePointer(to: &object) {
                SecItemCopyMatching(item as CFDictionary, UnsafeMutablePointer($0))
            }

            guard status == noErr || status == errSecItemNotFound else {
                assertionFailure("Unable to get object from keychain")
                completionHandler(nil)
                return
            }

            completionHandler(object)
        }

        class func update(value: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            read(forKey: key) { (object) in
                if object == nil {
                    create(value: value, forKey: key, completionHandler: completionHandler)
                } else {
                    var newItem = [String : AnyObject]()
                    newItem[kSecValueData as String] = value as AnyObject?

                    let item = keychainItem(withService: service, account: account ?? key, accessGroup: accessGroup)
                    let status = SecItemUpdate(item as CFDictionary, newItem as CFDictionary)

                    guard status == noErr else {
                        assertionFailure("Unable to update object to keychain")
                        completionHandler(false)
                        return
                    }
                    completionHandler(true)
                }
            }
        }

        class func delete(forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            let item = keychainItem(withService: service, account: account ?? key, accessGroup: accessGroup)
            let status = SecItemDelete(item as CFDictionary)

            guard status == noErr || status == errSecItemNotFound else {
                assertionFailure("Unable to delete object from keychain")
                completionHandler(false)
                return
            }
            completionHandler(true)
        }

        class func deleteAll(completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            var item = [String : AnyObject]()
            item[kSecClass as String] = kSecClassGenericPassword
            item[kSecAttrService as String] = service as AnyObject?
            if let accessGroup = self.accessGroup {
                item[kSecAttrAccessGroup as String] = accessGroup as AnyObject
            }
            let status = SecItemDelete(item as CFDictionary)

            guard status == errSecSuccess else {
                assertionFailure("Unable to delete all object from keychain")
                completionHandler(false)
                return
            }
            completionHandler(true)
        }

        // MARK: - Helper

        private static func keychainItem(withService service: String?, account: String? = nil, accessGroup: String? = nil) -> [String : AnyObject] {
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
