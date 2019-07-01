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

    class UserDefaultsWorker {

        // MARK: - CRUD

        class func create(value: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            update(value: value, forKey: key, completionHandler: completionHandler)
        }

        class func read(forKey key: String, completionHandler: @escaping (_ object: Any?) -> Void) {

            UserDefaults.standard.synchronize()
            let object = UserDefaults.standard.object(forKey: key)
            completionHandler(object)
        }

        class func update(value: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            UserDefaults.standard.setValue(value, forKey: key)
            UserDefaults.standard.synchronize()
            completionHandler(true)
        }

        class func delete(forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            UserDefaults.standard.removeObject(forKey: key)
            UserDefaults.standard.synchronize()
            completionHandler(true)
        }

        class func deleteAll(completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
                assertionFailure("Unable to get bundle identifier")
                completionHandler(false)
                return
            }
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
            UserDefaults.standard.synchronize()
            completionHandler(true)
        }
    }
}
