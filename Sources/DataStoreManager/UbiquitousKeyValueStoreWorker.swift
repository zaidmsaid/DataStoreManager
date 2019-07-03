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

// MARK: - NSUbiquitousKeyValueStore

extension DataStoreManager {

    /// An interface to the NSUbiquitousKeyValueStore.
    class UbiquitousKeyValueStoreWorker {

        // MARK: - Properties

        private lazy var ubiquitousKeyValueStore: NSUbiquitousKeyValueStore = {
            return NSUbiquitousKeyValueStore.default
        }()

        // MARK: - Init

        init() {
            NotificationCenter.default.addObserver(self, selector: #selector(onUbiquitousKeyValueStoreDidChangeExternally(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: ubiquitousKeyValueStore)
        }

        deinit {
            NotificationCenter.default.removeObserver(self, name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: ubiquitousKeyValueStore)
        }

        @objc private func onUbiquitousKeyValueStoreDidChangeExternally(notification: Notification) {
            // TODO: let userInfo = notification.userInfo
        }

        // MARK: - CRUD

        func setValue(value: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            ubiquitousKeyValueStore.setValue(value, forKey: key)
            ubiquitousKeyValueStore.synchronize()
            completionHandler(true)
        }

        func object(forKey key: String, completionHandler: @escaping (_ object: Any?) -> Void) {

            ubiquitousKeyValueStore.synchronize()
            let object = ubiquitousKeyValueStore.object(forKey: key)
            completionHandler(object)
        }

        func removeObject(forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            ubiquitousKeyValueStore.removeObject(forKey: key)
            ubiquitousKeyValueStore.synchronize()
            completionHandler(true)
        }

        func removeAllObjects(completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            let keys = ubiquitousKeyValueStore.dictionaryRepresentation.keys
            for key in keys {
                ubiquitousKeyValueStore.removeObject(forKey: key)
            }
            ubiquitousKeyValueStore.synchronize()
            completionHandler(true)
        }
    }
}
