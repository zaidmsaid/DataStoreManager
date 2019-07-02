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

// MARK: - NSCache

extension DataStoreManager {

    /// An interface to the NSCache.
    class CacheWorker {

        // MARK: - Properties

        var dataStoreManager: DataStoreManager?
        var totalCostLimit: Int?
        var totalCostLimitDataSource: ((DataStoreManager) -> Int)?
        var costDataSource: ((DataStoreManager, Any) -> Int)?

        lazy var cache: NSCache<NSString, AnyObject> = {
            return NSCache<NSString, AnyObject>()
        }()

        // MARK: - Init

        init() {
            if let manager = dataStoreManager, let datasource = totalCostLimitDataSource {
                cache.totalCostLimit = datasource(manager)
            }
            NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        }

        deinit {
            NotificationCenter.default.removeObserver(self, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        }

        @objc private func didReceiveMemoryWarning() {
            deleteAll { (_) in }
        }

        // MARK: - CRUD

        func create(value: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            update(value: value, forKey: key, completionHandler: completionHandler)
        }

        func read(forKey key: String, completionHandler: @escaping (_ object: Any?) -> Void) {

            let object = cache.object(forKey: NSString(string: key))
            completionHandler(object)
        }

        func update(value: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            if let manager = dataStoreManager, let datasource = costDataSource {
                cache.setObject(value as AnyObject, forKey: NSString(string: key), cost: datasource(manager, value))
            } else {
                cache.setObject(value as AnyObject, forKey: NSString(string: key), cost: 0)
            }
            completionHandler(true)
        }

        func delete(forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            cache.removeObject(forKey: NSString(string: key))
            completionHandler(true)
        }

        func deleteAll(completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            cache.removeAllObjects()
            completionHandler(true)
        }
    }
}
