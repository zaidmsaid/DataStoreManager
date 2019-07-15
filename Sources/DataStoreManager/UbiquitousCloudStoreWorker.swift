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
    @available(watchOS, unavailable)
    class UbiquitousCloudStoreWorker {

        // MARK: - Initializers

        /// Implemented by subclasses to initialize a new object (the
        /// receiver) immediately after memory for it has been allocated.
        init() {
            NotificationCenter.default.addObserver(self, selector: #selector(onUbiquitousCloudStoreDidChangeExternally(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: ubiquitousCloudStore)
        }

        /// A deinitializer is called immediately before a class instance is
        /// deallocated.
        deinit {
            NotificationCenter.default.removeObserver(self, name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: ubiquitousCloudStore)
        }

        // MARK: - Properties

        /// An object representing the data store manager requesting this
        /// information.
        var dataStoreManager: DataStoreManager?

        /// Tells the delegate that the specified storage type of a data
        /// store needs to handle when the value of one or more keys in the
        /// local key-value store changed due to incoming data pushed from
        /// iCloud.
        var notificationDelegate: ((DataStoreManager, [AnyHashable : Any]?) -> Void)?

        private lazy var ubiquitousCloudStore: NSUbiquitousKeyValueStore = {
            return NSUbiquitousKeyValueStore.default
        }()

        // MARK: - CRUD

        func create(object: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            setValue(object, forKey: key, completionHandler: completionHandler)
        }

        func read(forKey key: String, completionHandler: @escaping (_ object: Any?, _ objectID: Any?, _ error: Error?) -> Void) {

            ubiquitousCloudStore.synchronize()
            let object = ubiquitousCloudStore.object(forKey: key)
            completionHandler(object, nil, nil)
        }

        func update(object: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            setValue(object, forKey: key, completionHandler: completionHandler)
        }

        func delete(forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            ubiquitousCloudStore.removeObject(forKey: key)
            ubiquitousCloudStore.synchronize()
            completionHandler(true, nil, nil)
        }

        func deleteAll(completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            let keys = ubiquitousCloudStore.dictionaryRepresentation.keys
            for key in keys {
                ubiquitousCloudStore.removeObject(forKey: key)
            }
            ubiquitousCloudStore.synchronize()
            completionHandler(true, nil, nil)
        }

        private func setValue(_ value: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            ubiquitousCloudStore.setValue(value, forKey: key)
            ubiquitousCloudStore.synchronize()
            completionHandler(true, nil, nil)
        }

        // MARK: - Helpers

        @objc private func onUbiquitousCloudStoreDidChangeExternally(notification: Notification) {
            if let manager = dataStoreManager, let delegate = notificationDelegate {
                delegate(manager, notification.userInfo)
            }
        }
    }
}
