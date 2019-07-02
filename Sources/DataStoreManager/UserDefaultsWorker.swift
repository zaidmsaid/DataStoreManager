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

    /// An interface to the UserDefaults.
    class UserDefaultsWorker {

        // MARK: - Properties

        var dataStoreManager: DataStoreManager?

        lazy var userDefaults: UserDefaults = {
            if let manager = dataStoreManager, let suiteName = manager.dataSource?.userDefaultsSuiteName?(for: manager) {
                return UserDefaults(suiteName: suiteName) ?? UserDefaults.standard
            }
            return UserDefaults.standard
        }()

        // MARK: - CRUD

        func create(value: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            update(value: value, forKey: key, completionHandler: completionHandler)
        }

        func read(forKey key: String, completionHandler: @escaping (_ object: Any?) -> Void) {

            userDefaults.synchronize()
            let object = userDefaults.object(forKey: key)
            completionHandler(object)
        }

        func update(value: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            userDefaults.setValue(value, forKey: key)
            userDefaults.synchronize()
            completionHandler(true)
        }

        func delete(forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            userDefaults.removeObject(forKey: key)
            userDefaults.synchronize()
            completionHandler(true)
        }

        func deleteAll(completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
                assertionFailure("Unable to get bundle identifier")
                completionHandler(false)
                return
            }
            userDefaults.removePersistentDomain(forName: bundleIdentifier)
            userDefaults.synchronize()
            completionHandler(true)
        }
    }
}
