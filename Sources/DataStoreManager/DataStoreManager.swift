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

/// An interface to the data store manager, where you store key-value pairs persistently across launches of your app.
@objcMembers open class DataStoreManager : NSObject {

    // MARK: - Type Aliases

    /// Type to mean instance of DataStoreStorageType.
    public typealias StorageType = DataStoreStorageType

    // MARK: - Properties

    /// An integer that you can use to identify data store manager objects in your application.
    ///
    /// The default value is 0. You can set the value of this tag and use that value to identify the data store manager later.
    open var tag: Int = 0 {
        willSet {
        }
    }

    /// The object that acts as the data source of the data store manager.
    ///
    /// The data source must adopt the [DataStoreManagerDataSource](https://zaidmsaid.github.io/DataStoreManager/Protocols/DataStoreManagerDataSource.html)
    /// protocol. The data source is not retained.
    open weak var dataSource: DataStoreManagerDataSource? {
        willSet {
            if let defaultType = newValue?.defaultStorageType?(for: self) {
                self.defaultType = defaultType
            }
        }
    }

    /// The object that acts as the delegate of the data store manager.
    ///
    /// The delegate must adopt the [DataStoreManagerDelegate](https://zaidmsaid.github.io/DataStoreManager/Protocols/DataStoreManagerDelegate.html)
    /// protocol. The delegate is not retained.
    open weak var delegate: DataStoreManagerDelegate? {
        willSet {
        }
    }

    /// An interface to the UserDefaults.
    lazy var userDefaultsWorker: UserDefaultsWorker = {
        let worker = UserDefaultsWorker()
        worker.suiteName = self.dataSource?.userDefaultsSuiteName?(for: self)
        return worker
    }()

    /// An interface to the FileManager.
    lazy var fileManagerWorker: FileManagerWorker = {
        FileManagerWorker()
    }()

    /// An interface to the NSCache.
    lazy var cacheWorker: CacheWorker = {
        let worker = CacheWorker()
        worker.dataStoreManager = self
        worker.totalCostLimit = self.dataSource?.cacheTotalCostLimit?(for: self)
        worker.costDataSource = self.dataSource?.dataStoreManager(_:cacheCostLimitForObject:)
        return worker
    }()

    /// An interface to the SecItem.
    lazy var keychainWorker: KeychainWorker = {
        let worker = KeychainWorker()
        worker.service = self.dataSource?.keychainService?(for: self)
        worker.account = self.dataSource?.keychainAccount?(for: self)
        worker.accessGroup = self.dataSource?.keychainAccessGroup?(for: self)
        return worker
    }()

    /// An interface to the NSUbiquitousKeyValueStore.
    lazy var ubiquitousKeyValueStoreWorker: UbiquitousKeyValueStoreWorker = {
        return UbiquitousKeyValueStoreWorker()
    }()

    /// Returns the data store manager framework short version string for internal use.
    var version: String? {
        return Bundle(for: DataStoreManager.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    private var defaultType: StorageType = .userDefaults

    // MARK: - CRUD

    /// Sets the property of the receiver specified by a given key to a given value.
    ///
    /// - Parameters:
    ///   - value: The value for the property identified by key.
    ///   - key: The name of one of the receiver's properties.
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    open func setValue<T>(value: T, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        setValue(value: value, forKey: key, forStorageType: defaultType, completionHandler: completionHandler)
    }

    /// Sets the property of the receiver specified by a given key to a given value.
    ///
    /// - Parameters:
    ///   - value: The value for the property identified by key.
    ///   - key: The key to identify the data store manager object.
    ///   - storageType: A storage type constant.
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    open func setValue<T>(value: T, forKey key: String, forStorageType storageType: StorageType, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        switch storageType {
        case .userDefaults:
            userDefaultsWorker.setValue(value: value, forKey: key, completionHandler: completionHandler)

        case .documentDirectory:
            fileManagerWorker.setValue(value: value, forKey: key, forDirectory: .documentDirectory, completionHandler: completionHandler)

        case .userDirectory:
            fileManagerWorker.setValue(value: value, forKey: key, forDirectory: .userDirectory, completionHandler: completionHandler)

        case .libraryDirectory:
            fileManagerWorker.setValue(value: value, forKey: key, forDirectory: .libraryDirectory, completionHandler: completionHandler)

        case .applicationDirectory:
            fileManagerWorker.setValue(value: value, forKey: key, forDirectory: .applicationDirectory, completionHandler: completionHandler)

        case .coreServiceDirectory:
            fileManagerWorker.setValue(value: value, forKey: key, forDirectory: .coreServiceDirectory, completionHandler: completionHandler)

        case .temporaryDirectory:
            fileManagerWorker.setValue(value: value, forKey: key, forDirectory: .temporaryDirectory, completionHandler: completionHandler)

        case .cache:
            cacheWorker.setValue(value: value, forKey: key, completionHandler: completionHandler)

        case .keychain:
            keychainWorker.setValue(value: value, forKey: key, completionHandler: completionHandler)

        case .ubiquitousKeyValueStore:
            ubiquitousKeyValueStoreWorker.setValue(value: value, forKey: key, completionHandler: completionHandler)

        @unknown case _:
            assertionFailure("Use a representation that was unknown when this code was compiled.")
            completionHandler(false)
        }
    }

    /// Returns the object associated with the specified key.
    ///
    /// - Parameters:
    ///   - key: The key to identify the data store manager object.
    ///   - valueType: The type of value for the property identified by key.
    ///                Only needed by CloudKit.
    ///   - completionHandler: The block to execute with the associated object.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter object: The object associated with the specified key, or nil if the key was not found.
    ///
    /// For CloudKit, the `valueType` are needed to properly map the array of data.
    /// The `valueType` will be the type of the expected object. For example:
    /// ```
    /// let manager = DataStoreManager()
    /// manager.read(forKey: "Key", withValueType: String.self) { (object) in
    ///     if let object = object {
    ///         print("successfully read \(object) from Cloud Kit")
    ///     }
    /// }
    /// ```
    open func object<T>(forKey key: String, withValueType valueType: T.Type, completionHandler: @escaping (_ object: Any?) -> Void) {

        object(forKey: key, withValueType: valueType, forStorageType: defaultType, completionHandler: completionHandler)
    }

    /// Returns the object associated with the specified key.
    ///
    /// - Parameters:
    ///   - key: The key to identify the data store manager object.
    ///   - valueType: The type of value for the property identified by key.
    ///                Only needed by CloudKit.
    ///   - storageType: A storage type constant.
    ///   - completionHandler: The block to execute with the associated object.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter object: The object associated with the specified key, or nil if the key was not found.
    open func object<T>(forKey key: String, withValueType valueType: T.Type, forStorageType storageType: StorageType, completionHandler: @escaping (_ object: Any?) -> Void) {

        switch storageType {
        case .userDefaults:
            userDefaultsWorker.object(forKey: key, completionHandler: completionHandler)

        case .documentDirectory:
            fileManagerWorker.object(forKey: key, forDirectory: .documentDirectory, completionHandler: completionHandler)

        case .userDirectory:
            fileManagerWorker.object(forKey: key, forDirectory: .userDirectory, completionHandler: completionHandler)

        case .libraryDirectory:
            fileManagerWorker.object(forKey: key, forDirectory: .libraryDirectory, completionHandler: completionHandler)

        case .applicationDirectory:
            fileManagerWorker.object(forKey: key, forDirectory: .applicationDirectory, completionHandler: completionHandler)

        case .coreServiceDirectory:
            fileManagerWorker.object(forKey: key, forDirectory: .coreServiceDirectory, completionHandler: completionHandler)

        case .temporaryDirectory:
            fileManagerWorker.object(forKey: key, forDirectory: .temporaryDirectory, completionHandler: completionHandler)

        case .cache:
            cacheWorker.object(forKey: key, completionHandler: completionHandler)

        case .keychain:
            keychainWorker.object(forKey: key, completionHandler: completionHandler)

        case .ubiquitousKeyValueStore:
            ubiquitousKeyValueStoreWorker.object(forKey: key, completionHandler: completionHandler)

        @unknown case _:
            assertionFailure("Use a representation that was unknown when this code was compiled.")
            completionHandler(nil)
        }
    }

    /// Removes the value of the specified default key.
    ///
    /// - Parameters:
    ///   - key: The key to identify the data store manager object.
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    open func removeObject(forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

       removeObject(forKey: key, forStorageType: defaultType, completionHandler: completionHandler)
    }

    /// Removes the value of the specified default key.
    ///
    /// - Parameters:
    ///   - key: The key to identify the data store manager object.
    ///   - storageType: A storage type constant.
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    open func removeObject(forKey key: String, forStorageType storageType: StorageType, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        switch storageType {
        case .userDefaults:
            userDefaultsWorker.removeObject(forKey: key, completionHandler: completionHandler)

        case .documentDirectory:
            fileManagerWorker.removeObject(forKey: key, forDirectory: .documentDirectory, completionHandler: completionHandler)

        case .userDirectory:
            fileManagerWorker.removeObject(forKey: key, forDirectory: .userDirectory, completionHandler: completionHandler)

        case .libraryDirectory:
            fileManagerWorker.removeObject(forKey: key, forDirectory: .libraryDirectory, completionHandler: completionHandler)

        case .applicationDirectory:
            fileManagerWorker.removeObject(forKey: key, forDirectory: .applicationDirectory, completionHandler: completionHandler)

        case .coreServiceDirectory:
            fileManagerWorker.removeObject(forKey: key, forDirectory: .coreServiceDirectory, completionHandler: completionHandler)

        case .temporaryDirectory:
            fileManagerWorker.removeObject(forKey: key, forDirectory: .temporaryDirectory, completionHandler: completionHandler)

        case .cache:
            cacheWorker.removeObject(forKey: key, completionHandler: completionHandler)

        case .keychain:
            keychainWorker.removeObject(forKey: key, completionHandler: completionHandler)

        case .ubiquitousKeyValueStore:
            ubiquitousKeyValueStoreWorker.removeObject(forKey: key, completionHandler: completionHandler)

        @unknown case _:
            assertionFailure("Use a representation that was unknown when this code was compiled.")
            completionHandler(false)
        }
    }

    /// Empties the data store manager for the given type.
    ///
    /// - Parameters:
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    open func removeAllObjects(completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        removeAllObjects(forStorageType: defaultType, completionHandler: completionHandler)
    }

    /// Empties the data store manager for the given type.
    ///
    /// - Parameters:
    ///   - storageType: A storage type constant.
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    open func removeAllObjects(forStorageType storageType: StorageType, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        switch storageType {
        case .userDefaults:
            userDefaultsWorker.removeAllObjects(completionHandler: completionHandler)

        case .documentDirectory:
            fileManagerWorker.removeAllObjects(forDirectory: .documentDirectory, completionHandler: completionHandler)

        case .userDirectory:
            fileManagerWorker.removeAllObjects(forDirectory: .userDirectory, completionHandler: completionHandler)

        case .libraryDirectory:
            fileManagerWorker.removeAllObjects(forDirectory: .libraryDirectory, completionHandler: completionHandler)

        case .applicationDirectory:
            fileManagerWorker.removeAllObjects(forDirectory: .applicationDirectory, completionHandler: completionHandler)

        case .coreServiceDirectory:
            fileManagerWorker.removeAllObjects(forDirectory: .coreServiceDirectory, completionHandler: completionHandler)

        case .temporaryDirectory:
            fileManagerWorker.removeAllObjects(forDirectory: .temporaryDirectory, completionHandler: completionHandler)

        case .cache:
            cacheWorker.removeAllObjects(completionHandler: completionHandler)

        case .keychain:
            keychainWorker.removeAllObjects(completionHandler: completionHandler)

        case .ubiquitousKeyValueStore:
            ubiquitousKeyValueStoreWorker.removeAllObjects(completionHandler: completionHandler)

        @unknown case _:
            assertionFailure("Use a representation that was unknown when this code was compiled.")
            completionHandler(false)
        }
    }

    // MARK: - Migrate

    /// Migrate the schema if the version differs.
    ///
    /// - Parameters:
    ///   - storageType: A storage type constant.
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    ///
    /// Call this function at the point where you app can migrate the schema. It will check first
    /// if the schema version is the same or not.If the schema needs to be migrated, it will call
    /// [dataStoreManager(_:performMigrationFromOldVersion:forType:)](https://zaidmsaid.github.io/DataStoreManager/Protocols/DataStoreManagerDelegate.html#/c:@M@DataStoreManager@objc(pl)DataStoreManagerDelegate(im)dataStoreManager:performMigrationFromOldVersion:forType:)
    /// delegate method.
    open func migrateSchema(forStorageType storageType: StorageType, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        var key: String

        switch storageType {
        case .documentDirectory, .userDirectory, .libraryDirectory, .applicationDirectory, .coreServiceDirectory, .temporaryDirectory:
            key = ".data_store_manager/kSchemaVersion|\(tag).txt"

        default:
            key = "kSchemaVersion|\(tag)"
        }

        object(forKey: key, withValueType: Int.self, forStorageType: storageType) { (object) in

            let oldSchemaVersion = object as? Int ?? 0
            let newSchemaVersion = self.dataSource?.dataStoreManager?(self, currentSchemaVersionForType: storageType) ?? 0

            if oldSchemaVersion < newSchemaVersion {
                self.delegate?.dataStoreManager?(self, performMigrationFromOldVersion: oldSchemaVersion, forType: storageType)
                self.setValue(value: newSchemaVersion, forKey: key, forStorageType: storageType, completionHandler: completionHandler)

            } else if oldSchemaVersion > newSchemaVersion {
                assertionFailure("Current schema version is lower than old schema version")
                completionHandler(false)
                return

            } else {
                completionHandler(true)
                return
            }
        }
    }
}
