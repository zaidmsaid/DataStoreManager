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

// MARK: - UserDefaults

extension DataStoreManager {

    /// An interface to the UserDefaults.
    internal class UserDefaultsWorker {

        // MARK: - Properties

        /// An object representing the data store manager requesting this
        /// information.
        var dataStoreManager: DataStoreManager?

        private var userDefaults: UserDefaults {
            return UserDefaults(suiteName: suiteName) ?? UserDefaults.standard
        }
        
        private var suiteName: String? {
            if let manager = dataStoreManager {
                return manager.dataSource?.userDefaultsSuiteName?(for: manager)
            }
            return nil
        }

        // MARK: - CRUD

        func create(
            object: Any,
            forKey key: String,
            completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void
            ) {

            setValue(object, forKey: key, completionHandler: completionHandler)
        }

        func read(
            forKey key: String,
            completionHandler: @escaping (_ object: Any?, _ objectID: Any?, _ error: Error?) -> Void
            ) {

            userDefaults.synchronize()
            let object = userDefaults.object(forKey: key)
            completionHandler(object, nil, nil)
        }

        func update(
            object: Any,
            forKey key: String,
            completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void
            ) {

            setValue(object, forKey: key, completionHandler: completionHandler)
        }

        func delete(
            forKey key: String,
            completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void
            ) {

            userDefaults.removeObject(forKey: key)
            userDefaults.synchronize()
            completionHandler(true, nil, nil)
        }

        func deleteAll(
            completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void
            ) {

            guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
                let error = ErrorObject(protocol: .bundleIdentifierNotAvailable)
                completionHandler(false, nil, error)
                return
            }

            userDefaults.removePersistentDomain(forName: bundleIdentifier)
            userDefaults.synchronize()
            completionHandler(true, nil, nil)
        }

        private func setValue(
            _ value: Any,
            forKey key: String,
            completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void
            ) {

            userDefaults.setValue(value, forKey: key)
            userDefaults.synchronize()
            completionHandler(true, nil, nil)
        }
    }
}
