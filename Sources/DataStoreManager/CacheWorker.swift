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
    internal class CacheWorker {

        // MARK: - Initializers

        /// Implemented by subclasses to initialize a new object (the
        /// receiver) immediately after memory for it has been allocated.
        init() {
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
        var handler: ((DataStoreManager, Any) -> Int)?

        private lazy var cache: NSCache<NSString, CacheObject> = {
            let cache = NSCache<NSString, CacheObject>()
            if let manager = dataStoreManager {
                cache.name = manager.identifier
            }
            cache.totalCostLimit = totalCostLimit
            cache.countLimit = countLimit
            cache.evictsObjectsWithDiscardedContent = false
            return cache
        }()

        private var totalCostLimit: Int {
            if let manager = dataStoreManager, let totalCostLimit = manager.dataSource?.cacheTotalCostLimit?(for: manager) {
                return totalCostLimit
            }
            return 0
        }

        private var countLimit: Int {
            if let manager = dataStoreManager, let countLimit = manager.dataSource?.cacheCountLimit?(for: manager) {
                return countLimit
            }
            return 0
        }

        private let lock = NSLock()

        // MARK: - CRUD

        func create(object: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            setValue(object, forKey: key, completionHandler: completionHandler)
        }

        func read(forKey key: String, completionHandler: @escaping (_ object: Any?, _ objectID: Any?, _ error: Error?) -> Void) {

            lock.lock()
            let object = cache.object(forKey: NSString(string: key))
            lock.unlock()
            completionHandler(object, nil, nil)
        }

        func update(object: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            setValue(object, forKey: key, completionHandler: completionHandler)
        }

        func delete(forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            lock.lock()
            cache.removeObject(forKey: NSString(string: key))
            lock.unlock()
            completionHandler(true, nil, nil)
        }

        func deleteAll(completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            lock.lock()
            cache.removeAllObjects()
            lock.unlock()
            completionHandler(true, nil, nil)
        }

        private func setValue(_ value: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            lock.lock()
            if let object = value as? NSObject {
                let cacheObject = CacheObject(object: object)
                if let manager = dataStoreManager, let delegate = handler {
                    cache.setObject(cacheObject, forKey: NSString(string: key), cost: delegate(manager, value))
                } else {
                    cache.setObject(cacheObject, forKey: NSString(string: key), cost: 0)
                }
                lock.unlock()
                completionHandler(true, nil, nil)
            } else {
                let error = ErrorObject(protocol: .invalidStorageType)
                completionHandler(false, nil, error)
            }
        }

        @objc private func didReceiveMemoryWarning() {
            deleteAll { (_, _, _) in
            }
        }
    }
}

/// A type representing a cache object.
fileprivate final class CacheObject: NSObject, NSDiscardableContent {

    private let object: NSObject

    init(object: NSObject) {
        self.object = object
    }

    // MARK: - NSDiscardableContent

    /// Returns a Boolean value indicating whether the discardable
    /// contents are still available and have been successfully
    /// accessed.
    ///
    /// Call this method if the object’s memory is needed or is about to
    /// be used. This method increments the counter variable, thus
    /// protecting the object’s memory from possibly being discarded.
    /// The implementing class may decide that this method will try to
    /// recreate the contents if they have been discarded and return
    /// `true` if the re-creation was successful. Implementors of this
    /// protocol should raise exceptions if the `NSDiscardableContent`
    /// objects are used when the `beginContentAccess` method has not
    /// been called on them.
    ///
    /// - Returns: `true` if the discardable contents are still
    ///            available and have now been successfully accessed;
    ///            otherwise, `false`.
    func beginContentAccess() -> Bool {
        return true
    }

    /// Called if the discardable contents are no longer being accessed.
    ///
    /// This method decrements the counter variable of the object, which
    /// will usually bring the value of the counter variable back down
    /// to `0`, which allows the discardable contents of the object to
    /// be thrown away if necessary.
    func endContentAccess() {
    }

    /// Called to discard the contents of the receiver if the value of
    /// the accessed counter is `0`.
    ///
    /// This method should only discard the contents of the object if
    /// the value of the accessed counter is `0`. Otherwise, it should
    /// do nothing.
    func discardContentIfPossible() {
    }

    /// Returns a Boolean value indicating whether the content has been
    /// discarded.
    ///
    /// - Returns: `true` if the content has been discarded; otherwise,
    ///            `false`.
    func isContentDiscarded() -> Bool {
        return false
    }
}
