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

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import Cocoa
#else
import Foundation
#endif

// MARK: - NSCache

extension DataStoreManager {

    /// An interface to the NSCache.
    class CacheWorker {

        // MARK: - Initializers

        /// Implemented by subclasses to initialize a new object (the
        /// receiver) immediately after memory for it has been allocated.
        init() {
            cache.totalCostLimit = totalCostLimit
            #if os(iOS) || os(tvOS)
            NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
            #endif
        }

        /// A deinitializer is called immediately before a class instance is
        /// deallocated.
        deinit {
            #if os(iOS) || os(tvOS)
            NotificationCenter.default.removeObserver(self, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
            #endif
        }

        // MARK: - Properties

        /// An object representing the data store manager requesting this
        /// information.
        var dataStoreManager: DataStoreManager?

        /// Asks the delegate for the cost with which associate to the
        /// object.
        var costDelegate: ((DataStoreManager, Any) -> Int)?

        private lazy var cache: NSCache<NSString, AnyObject> = {
            return NSCache<NSString, AnyObject>()
        }()

        private var totalCostLimit: Int {
            if let manager = dataStoreManager, let totalCostLimit = manager.dataSource?.cacheTotalCostLimit?(for: manager) {
                return totalCostLimit
            }
            return 0
        }

        // MARK: - CRUD

        func create(object: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            setValue(object, forKey: key, completionHandler: completionHandler)
        }

        func read(forKey key: String, completionHandler: @escaping (_ object: Any?, _ objectID: Any?, _ error: Error?) -> Void) {

            let object = cache.object(forKey: NSString(string: key))
            completionHandler(object, nil, nil)
        }

        func update(object: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            setValue(object, forKey: key, completionHandler: completionHandler)
        }

        func delete(forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            cache.removeObject(forKey: NSString(string: key))
            completionHandler(true, nil, nil)
        }

        func deleteAll(completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            cache.removeAllObjects()
            completionHandler(true, nil, nil)
        }

        @objc private func didReceiveMemoryWarning() {
            deleteAll { (_, _, _) in
            }
        }

        private func setValue(_ value: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            if let manager = dataStoreManager, let delegate = costDelegate {
                cache.setObject(value as AnyObject, forKey: NSString(string: key), cost: delegate(manager, value))
            } else {
                cache.setObject(value as AnyObject, forKey: NSString(string: key), cost: 0)
            }
            completionHandler(true, nil, nil)
        }
    }
}
