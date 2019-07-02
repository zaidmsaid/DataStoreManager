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
            if let defaultType = newValue?.defaultType?(for: self) {
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

    /// Returns the shared data store manager object.
    public static let shared = DataStoreManager()

    /// An interface to the UserDefaults.
    lazy var userDefaultsWorker: UserDefaultsWorker = {
        let worker = UserDefaultsWorker()
        worker.dataStoreManager = self
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
    lazy var securityItemWorker: SecurityItemWorker = {
        let worker = SecurityItemWorker()
        worker.service = self.dataSource?.keychainService?(for: self)
        worker.account = self.dataSource?.keychainAccount?(for: self)
        worker.accessGroup = self.dataSource?.keychainAccessGroup?(for: self)
        return worker
    }()

    /// An interface to the NSUbiquitousKeyValueStore.
    lazy var ubiquitousWorker: UbiquitousWorker = {
        return UbiquitousWorker()
    }()

    private var defaultType: StorageType = .userDefaults

    // MARK: - Enums

    /// Constants that provide information regarding storage type of data store manager.
    @objc public enum StorageType : Int, CaseIterable {

        /// The storage type UserDefaults.
        case userDefaults

        /// The storage type FileManager with the search path document directory.
        case documentDirectory

        /// The storage type FileManager with the search path user home directories (/Users).
        case userDirectory

        /// The storage type FileManager with the search path various user-visible documentation, support, and configuration files (/Library).
        case libraryDirectory

        /// The storage type FileManager with the search path supported applications (/Applications).
        case applicationDirectory

        /// The storage type FileManager with the search path core services (System/Library/CoreServices).
        case coreServiceDirectory

        /// The storage type FileManager with the temporary directory for the current user.
        case temporaryDirectory

        /// The storage type NSCache.
        case cache

        /// The storage type SecItem.
        case keychain

        /// The storage type NSUbiquitousKeyValueStore.
        case ubiquitous

        /// Converts the storage type value to a native string.
        ///
        /// - Returns: The string representation of the value.
        public func toString() -> String {
            switch self {
            case .userDefaults:
                return "UserDefaults"

            case .documentDirectory:
                return "FileManager.documentDirectory"

            case .userDirectory:
                return "FileManager.userDirectory"

            case .libraryDirectory:
                return "FileManager.libraryDirectory"

            case .applicationDirectory:
                return "FileManager.applicationDirectory"

            case .coreServiceDirectory:
                return "FileManager.coreServiceDirectory"

            case .temporaryDirectory:
                return "FileManager.temporaryDirectory"

            case .cache:
                return "NSCache"

            case .keychain:
                return "SecItem"

            case .ubiquitous:
                return "NSUbiquitousKeyValueStore"
            }
        }

        /// Creates a new instance with the specified string value.
        ///
        /// - Parameter stringValue: The string value to use for the new instance.
        ///
        /// If there is no value of the type that corresponds with the specified string value, this initializer returns nil. For example:
        /// ```
        /// print(StorageType(stringValue: "UserDefaults"))
        /// // Prints "Optional("StorageType.userDefaults")"
        ///
        /// print(StorageType(stringValue: "Invalid"))
        /// // Prints "nil"
        /// ```
        public init?(stringValue: String) {
            for type in StorageType.allCases {
                if type.toString() == stringValue {
                    self = type
                }
            }
            return nil
        }
    }

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
    open func create(value: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        create(value: value, forKey: key, forType: defaultType, completionHandler: completionHandler)
    }

    /// Sets the property of the receiver specified by a given key to a given value.
    ///
    /// - Parameters:
    ///   - value: The value for the property identified by key.
    ///   - key: The key to identify the data store manager object.
    ///   - type: A storage type constant.
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    open func create(value: Any, forKey key: String, forType type: StorageType, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        switch type {
        case .userDefaults:
            userDefaultsWorker.create(value: value, forKey: key, completionHandler: completionHandler)

        case .documentDirectory:
            fileManagerWorker.create(value: value, forKey: key, forDirectory: .documentDirectory, completionHandler: completionHandler)

        case .userDirectory:
            fileManagerWorker.create(value: value, forKey: key, forDirectory: .userDirectory, completionHandler: completionHandler)

        case .libraryDirectory:
            fileManagerWorker.create(value: value, forKey: key, forDirectory: .libraryDirectory, completionHandler: completionHandler)

        case .applicationDirectory:
            fileManagerWorker.create(value: value, forKey: key, forDirectory: .applicationDirectory, completionHandler: completionHandler)

        case .coreServiceDirectory:
            fileManagerWorker.create(value: value, forKey: key, forDirectory: .coreServiceDirectory, completionHandler: completionHandler)

        case .temporaryDirectory:
            fileManagerWorker.create(value: value, forKey: key, forDirectory: .temporaryDirectory, completionHandler: completionHandler)

        case .cache:
            cacheWorker.create(value: value, forKey: key, completionHandler: completionHandler)

        case .keychain:
            securityItemWorker.create(value: value, forKey: key, completionHandler: completionHandler)

        case .ubiquitous:
            ubiquitousWorker.create(value: value, forKey: key, completionHandler: completionHandler)
        }
    }

    /// Returns the object associated with the specified key.
    ///
    /// - Parameters:
    ///   - key: The key to identify the data store manager object.
    ///   - completionHandler: The block to execute with the associated object.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter object: The object associated with the specified key, or nil if the key was not found.
    open func read(forKey key: String, completionHandler: @escaping (_ object: Any?) -> Void) {

        read(forKey: key, forType: defaultType, completionHandler: completionHandler)
    }

    /// Returns the object associated with the specified key.
    ///
    /// - Parameters:
    ///   - key: The key to identify the data store manager object.
    ///   - type: A storage type constant.
    ///   - completionHandler: The block to execute with the associated object.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter object: The object associated with the specified key, or nil if the key was not found.
    open func read(forKey key: String, forType type: StorageType, completionHandler: @escaping (_ object: Any?) -> Void) {

        switch type {
        case .userDefaults:
            userDefaultsWorker.read(forKey: key, completionHandler: completionHandler)

        case .documentDirectory:
            fileManagerWorker.read(forKey: key, forDirectory: .documentDirectory, completionHandler: completionHandler)

        case .userDirectory:
            fileManagerWorker.read(forKey: key, forDirectory: .userDirectory, completionHandler: completionHandler)

        case .libraryDirectory:
            fileManagerWorker.read(forKey: key, forDirectory: .libraryDirectory, completionHandler: completionHandler)

        case .applicationDirectory:
            fileManagerWorker.read(forKey: key, forDirectory: .applicationDirectory, completionHandler: completionHandler)

        case .coreServiceDirectory:
            fileManagerWorker.read(forKey: key, forDirectory: .coreServiceDirectory, completionHandler: completionHandler)

        case .temporaryDirectory:
            fileManagerWorker.read(forKey: key, forDirectory: .temporaryDirectory, completionHandler: completionHandler)

        case .cache:
            cacheWorker.read(forKey: key, completionHandler: completionHandler)

        case .keychain:
            securityItemWorker.read(forKey: key, completionHandler: completionHandler)

        case .ubiquitous:
            ubiquitousWorker.read(forKey: key, completionHandler: completionHandler)
        }
    }

    /// Modifies the property of the receiver specified by a given key to a given value.
    ///
    /// - Parameters:
    ///   - value: The value for the property identified by key.
    ///   - key: The name of one of the receiver's properties.
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    open func update(value: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        update(value: value, forKey: key, forType: defaultType, completionHandler: completionHandler)
    }

    /// Modifies the property of the receiver specified by a given key to a given value.
    ///
    /// - Parameters:
    ///   - value: The value for the property identified by key.
    ///   - key: The key to identify the data store manager object.
    ///   - type: A storage type constant.
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    open func update(value: Any, forKey key: String, forType type: StorageType, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        switch type {
        case .userDefaults:
            userDefaultsWorker.update(value: value, forKey: key, completionHandler: completionHandler)

        case .documentDirectory:
            fileManagerWorker.update(value: value, forKey: key, forDirectory: .documentDirectory, completionHandler: completionHandler)

        case .userDirectory:
            fileManagerWorker.update(value: value, forKey: key, forDirectory: .userDirectory, completionHandler: completionHandler)

        case .libraryDirectory:
            fileManagerWorker.update(value: value, forKey: key, forDirectory: .libraryDirectory, completionHandler: completionHandler)

        case .applicationDirectory:
            fileManagerWorker.update(value: value, forKey: key, forDirectory: .applicationDirectory, completionHandler: completionHandler)

        case .coreServiceDirectory:
            fileManagerWorker.update(value: value, forKey: key, forDirectory: .coreServiceDirectory, completionHandler: completionHandler)

        case .temporaryDirectory:
            fileManagerWorker.update(value: value, forKey: key, forDirectory: .temporaryDirectory, completionHandler: completionHandler)

        case .cache:
            cacheWorker.update(value: value, forKey: key, completionHandler: completionHandler)

        case .keychain:
            securityItemWorker.update(value: value, forKey: key, completionHandler: completionHandler)

        case .ubiquitous:
            ubiquitousWorker.update(value: value, forKey: key, completionHandler: completionHandler)
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
    open func delete(forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

       delete(forKey: key, forType: defaultType, completionHandler: completionHandler)
    }

    /// Removes the value of the specified default key.
    ///
    /// - Parameters:
    ///   - key: The key to identify the data store manager object.
    ///   - type: A storage type constant.
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    open func delete(forKey key: String, forType type: StorageType, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        switch type {
        case .userDefaults:
            userDefaultsWorker.delete(forKey: key, completionHandler: completionHandler)

        case .documentDirectory:
            fileManagerWorker.delete(forKey: key, forDirectory: .documentDirectory, completionHandler: completionHandler)

        case .userDirectory:
            fileManagerWorker.delete(forKey: key, forDirectory: .userDirectory, completionHandler: completionHandler)

        case .libraryDirectory:
            fileManagerWorker.delete(forKey: key, forDirectory: .libraryDirectory, completionHandler: completionHandler)

        case .applicationDirectory:
            fileManagerWorker.delete(forKey: key, forDirectory: .applicationDirectory, completionHandler: completionHandler)

        case .coreServiceDirectory:
            fileManagerWorker.delete(forKey: key, forDirectory: .coreServiceDirectory, completionHandler: completionHandler)

        case .temporaryDirectory:
            fileManagerWorker.delete(forKey: key, forDirectory: .temporaryDirectory, completionHandler: completionHandler)

        case .cache:
            cacheWorker.delete(forKey: key, completionHandler: completionHandler)

        case .keychain:
            securityItemWorker.delete(forKey: key, completionHandler: completionHandler)

        case .ubiquitous:
            ubiquitousWorker.delete(forKey: key, completionHandler: completionHandler)
        }
    }

    /// Empties the data store manager for the given type.
    ///
    /// - Parameters:
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    open func deleteAll(completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        deleteAll(forType: defaultType, completionHandler: completionHandler)
    }

    /// Empties the data store manager for the given type.
    ///
    /// - Parameters:
    ///   - type: A storage type constant.
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    open func deleteAll(forType type: StorageType, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        switch type {
        case .userDefaults:
            userDefaultsWorker.deleteAll(completionHandler: completionHandler)

        case .documentDirectory:
            fileManagerWorker.deleteAll(forDirectory: .documentDirectory, completionHandler: completionHandler)

        case .userDirectory:
            fileManagerWorker.deleteAll(forDirectory: .userDirectory, completionHandler: completionHandler)

        case .libraryDirectory:
            fileManagerWorker.deleteAll(forDirectory: .libraryDirectory, completionHandler: completionHandler)

        case .applicationDirectory:
            fileManagerWorker.deleteAll(forDirectory: .applicationDirectory, completionHandler: completionHandler)

        case .coreServiceDirectory:
            fileManagerWorker.deleteAll(forDirectory: .coreServiceDirectory, completionHandler: completionHandler)

        case .temporaryDirectory:
            fileManagerWorker.deleteAll(forDirectory: .temporaryDirectory, completionHandler: completionHandler)

        case .cache:
            cacheWorker.deleteAll(completionHandler: completionHandler)

        case .keychain:
            securityItemWorker.deleteAll(completionHandler: completionHandler)

        case .ubiquitous:
            ubiquitousWorker.deleteAll(completionHandler: completionHandler)
        }
    }

    // MARK: - Migrate

    /// Migrate the schema if the version differs.
    ///
    /// - Parameters:
    ///   - type: A storage type constant.
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    ///
    /// Call this function at the point where you app can migrate the schema. It will check first
    /// if the schema version is the same or not.If the schema needs to be migrated, it will call
    /// [dataStoreManager(_:performMigrationFromOldVersion:forType:)](https://zaidmsaid.github.io/DataStoreManager/Protocols/DataStoreManagerDelegate.html#/c:@M@DataStoreManager@objc(pl)DataStoreManagerDelegate(im)dataStoreManager:performMigrationFromOldVersion:forType:)
    /// delegate method.
    open func migrateSchema(forType type: StorageType, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        let key = "kSchemaVersion|\(tag)"

        read(forKey: key, forType: type) { (object) in

            let oldSchemaVersion = object as? Int ?? 0
            let newSchemaVersion = self.dataSource?.dataStoreManager?(self, currentSchemaVersionForType: type) ?? 0

            if oldSchemaVersion < newSchemaVersion {
                self.delegate?.dataStoreManager?(self, performMigrationFromOldVersion: oldSchemaVersion, forType: type)

                if oldSchemaVersion == 0 {
                    self.create(value: newSchemaVersion, forKey: key, forType: type, completionHandler: completionHandler)

                } else {
                    self.update(value: newSchemaVersion, forKey: key, forType: type, completionHandler: completionHandler)
                }

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
