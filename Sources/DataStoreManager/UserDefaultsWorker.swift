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
    class UserDefaultsWorker {

        // MARK: - Properties

        var suiteName: String?

        lazy var userDefaults: UserDefaults = {
            return UserDefaults(suiteName: suiteName) ?? UserDefaults.standard
        }()

        // MARK: - CRUD

        func setValue(value: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            userDefaults.setValue(value, forKey: key)
            userDefaults.synchronize()
            completionHandler(true)
        }

        func object(forKey key: String, completionHandler: @escaping (_ object: Any?) -> Void) {

            userDefaults.synchronize()
            let object = userDefaults.object(forKey: key)
            completionHandler(object)
        }

        func removeObject(forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            userDefaults.removeObject(forKey: key)
            userDefaults.synchronize()
            completionHandler(true)
        }

        func removeAllObjects(completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

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
