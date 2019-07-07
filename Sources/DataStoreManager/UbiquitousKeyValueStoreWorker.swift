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

extension DataStoreManager {

    /// An interface to the NSUbiquitousKeyValueStore.
    class UbiquitousKeyValueStoreWorker {

        // MARK: - Initializers

        init() {
            NotificationCenter.default.addObserver(self, selector: #selector(onUbiquitousKeyValueStoreDidChangeExternally(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: ubiquitousKeyValueStore)
        }

        deinit {
            NotificationCenter.default.removeObserver(self, name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: ubiquitousKeyValueStore)
        }

        @objc private func onUbiquitousKeyValueStoreDidChangeExternally(notification: Notification) {
            // TODO: let userInfo = notification.userInfo
        }

        // MARK: - Properties

        private lazy var ubiquitousKeyValueStore: NSUbiquitousKeyValueStore = {
            return NSUbiquitousKeyValueStore.default
        }()

        // MARK: - CRUD

        func create(object: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            setValue(object, forKey: key, completionHandler: completionHandler)
        }

        func read(forKey key: String, completionHandler: @escaping (_ object: Any?, _ objectID: Any?, _ error: Error?) -> Void) {

            ubiquitousKeyValueStore.synchronize()
            let object = ubiquitousKeyValueStore.object(forKey: key)
            completionHandler(object, nil, nil)
        }

        func update(object: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            setValue(object, forKey: key, completionHandler: completionHandler)
        }

        func delete(forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            ubiquitousKeyValueStore.removeObject(forKey: key)
            ubiquitousKeyValueStore.synchronize()
            completionHandler(true, nil, nil)
        }

        func deleteAll(completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            let keys = ubiquitousKeyValueStore.dictionaryRepresentation.keys
            for key in keys {
                ubiquitousKeyValueStore.removeObject(forKey: key)
            }
            ubiquitousKeyValueStore.synchronize()
            completionHandler(true, nil, nil)
        }

        private func setValue(_ value: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            ubiquitousKeyValueStore.setValue(value, forKey: key)
            ubiquitousKeyValueStore.synchronize()
            completionHandler(true, nil, nil)
        }
    }
}
