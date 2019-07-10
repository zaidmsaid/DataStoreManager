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

    // MARK: - Initializers

    /// Return a data store manager with the specified identifier.
    ///
    /// - Parameter identifier: A string identifying the data store manager object.
    ///
    /// Initialize a new data store manager object immediately after memory for it has been allocated.
    ///
    /// - Returns: An initialized object, or `nil` if an object could not be created for some reason that
    ///            would not result in an exception.
    public required init(identifier: String) {
        self.ID = identifier
        self.defaultType = .userDefaults
        super.init()
    }

    // MARK: - Type Aliases

    /// Type to mean instance of DataStoreStorageType.
    public typealias StorageType = DataStoreStorageType

    // MARK: - Properties

    /// Returns the data store manager framework short version string.
    open var version: String? {
        return Bundle(for: DataStoreManager.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    /// Returns the identifier of the data store manager.
    open var identifier: String {
        return ID
    }

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
        worker.costDelegate = self.delegate?.dataStoreManager(_:cacheCostLimitForObject:)
        return worker
    }()

    /// An interface to the SecItem.
    lazy var keychainWorker: KeychainWorker = {
        let worker = KeychainWorker()
        worker.dataStoreManager = self
        return worker
    }()

    /// An interface to the CKContainer.
    @available(watchOSApplicationExtension 3.0, *)
    lazy var cloudKitWorker: CloudKitWorker = {
        let worker = CloudKitWorker()
        worker.dataStoreManager = self
        worker.recordIDDelegate = self.delegate?.dataStoreManager(_:cloudKitContainerRecordIDForKey:)
        return worker
    }()

    /// An interface to the NSUbiquitousKeyValueStore.
    @available(watchOS, unavailable)
    lazy var ubiquitousKeyValueStoreWorker: UbiquitousKeyValueStoreWorker = {
        return UbiquitousKeyValueStoreWorker()
    }()

    private let ID: String
    private var defaultType: StorageType

    // MARK: - CRUD

    /// Create the property of the receiver specified by a given key to a given object.
    ///
    /// - Parameters:
    ///   - object: The object for the property identified by key.
    ///   - key: The name of one of the receiver's properties.
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    /// - Parameter objectID: The unique ID of the object. For CloudKit, the type is
    ///                       [CKRecord.ID](apple-reference-documentation://hsWjEyXEsV)
    ///                       and it is the object that uniquely identifies a record in a database.
    /// - Parameter error: An error object, or `nil` if it was completed successfully. Use the information
    ///                    in the error object to determine whether a problem has a workaround.
    open func create<T>(object: T, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

        create(object: object, forKey: key, forStorageType: defaultType, completionHandler: completionHandler)
    }

    /// Create the property of the receiver specified by a given key to a given object.
    ///
    /// - Parameters:
    ///   - object: The object for the property identified by key.
    ///   - key: The key to identify the data store manager object.
    ///   - storageType: A storage type constant.
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    /// - Parameter objectID: The unique ID of the object. For CloudKit, the type is
    ///                       [CKRecord.ID](apple-reference-documentation://hsWjEyXEsV)
    ///                       and it is the object that uniquely identifies a record in a database.
    /// - Parameter error: An error object, or `nil` if it was completed successfully. Use the information
    ///                    in the error object to determine whether a problem has a workaround.
    open func create<T>(object: T, forKey key: String, forStorageType storageType: StorageType, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

        switch storageType {
        case .userDefaults:
            userDefaultsWorker.create(object: object, forKey: key, completionHandler: completionHandler)

        case .documentDirectory:
            fileManagerWorker.create(object: object, forKey: key, forDirectory: .documentDirectory, completionHandler: completionHandler)

        case .userDirectory:
            fileManagerWorker.create(object: object, forKey: key, forDirectory: .userDirectory, completionHandler: completionHandler)

        case .libraryDirectory:
            fileManagerWorker.create(object: object, forKey: key, forDirectory: .libraryDirectory, completionHandler: completionHandler)

        case .applicationDirectory:
            fileManagerWorker.create(object: object, forKey: key, forDirectory: .applicationDirectory, completionHandler: completionHandler)

        case .coreServiceDirectory:
            fileManagerWorker.create(object: object, forKey: key, forDirectory: .coreServiceDirectory, completionHandler: completionHandler)

        case .temporaryDirectory:
            fileManagerWorker.create(object: object, forKey: key, forDirectory: .temporaryDirectory, completionHandler: completionHandler)

        case .cache:
            cacheWorker.create(object: object, forKey: key, completionHandler: completionHandler)

        case .genericKeychain:
            keychainWorker.create(object: object, forKey: key, forItemClass: .generic, completionHandler: completionHandler)

        case .internetKeychain:
            keychainWorker.create(object: object, forKey: key, forItemClass: .internet, completionHandler: completionHandler)

        case .privateCloudDatabase:
            if #available(watchOSApplicationExtension 3.0, *) {
                cloudKitWorker.create(object: object, forKey: key, forContainerType: .privateCloudDatabase, completionHandler: completionHandler)
            } else {
                // Fallback on earlier versions
            }

        case .publicCloudDatabase:
            if #available(watchOSApplicationExtension 3.0, *) {
                cloudKitWorker.create(object: object, forKey: key, forContainerType: .publicCloudDatabase, completionHandler: completionHandler)
            } else {
                // Fallback on earlier versions
            }

        case .sharedCloudDatabase:
            if #available(watchOSApplicationExtension 3.0, *) {
                cloudKitWorker.create(object: object, forKey: key, forContainerType: .sharedCloudDatabase, completionHandler: completionHandler)
            } else {
                // Fallback on earlier versions
            }

        case .ubiquitousKeyValueStore:
            #if !os(watchOS)
            ubiquitousKeyValueStoreWorker.create(object: object, forKey: key, completionHandler: completionHandler)
            #endif

        default:
            let error = ErrorObject(protocol: .unknownRepresentation)
            completionHandler(false, nil, error)
        }
    }

    /// Returns the object associated with the specified key.
    ///
    /// - Parameters:
    ///   - key: The key to identify the data store manager object.
    ///   - objectType: The type of object for the property identified by key.
    ///   - completionHandler: The block to execute with the associated object.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter object: The object associated with the specified key, or nil if the key was not found.
    /// - Parameter objectID: The unique ID of the object. For CloudKit, the type is
    ///                       [CKRecord.ID](apple-reference-documentation://hsWjEyXEsV)
    ///                       and it is the object that uniquely identifies a record in a database.
    /// - Parameter error: An error object, or `nil` if it was completed successfully. Use the information
    ///                    in the error object to determine whether a problem has a workaround.
    open func read<T>(forKey key: String, withObjectType objectType: T.Type, completionHandler: @escaping (_ object: Any?, _ objectID: Any?, _ error: Error?) -> Void) {

        read(forKey: key, withObjectType: objectType, forStorageType: defaultType, completionHandler: completionHandler)
    }

    /// Returns the object associated with the specified key.
    ///
    /// - Parameters:
    ///   - key: The key to identify the data store manager object.
    ///   - objectType: The type of object for the property identified by key.
    ///   - storageType: A storage type constant.
    ///   - completionHandler: The block to execute with the associated object.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter object: The object associated with the specified key, or nil if the key was not found.
    /// - Parameter objectID: The unique ID of the object. For CloudKit, the type is
    ///                       [CKRecord.ID](apple-reference-documentation://hsWjEyXEsV)
    ///                       and it is the object that uniquely identifies a record in a database.
    /// - Parameter error: An error object, or `nil` if it was completed successfully. Use the information
    ///                    in the error object to determine whether a problem has a workaround.
    open func read<T>(forKey key: String, withObjectType objectType: T.Type, forStorageType storageType: StorageType, completionHandler: @escaping (_ object: Any?, _ objectID: Any?, _ error: Error?) -> Void) {

        switch storageType {
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

        case .genericKeychain:
            keychainWorker.read(forKey: key, forItemClass: .generic, completionHandler: completionHandler)

        case .internetKeychain:
            keychainWorker.read(forKey: key, forItemClass: .internet, completionHandler: completionHandler)

        case .privateCloudDatabase:
            if #available(watchOSApplicationExtension 3.0, *) {
                cloudKitWorker.read(forKey: key, withObjectType: objectType, forContainerType: .privateCloudDatabase, completionHandler: completionHandler)
            } else {
                // Fallback on earlier versions
            }

        case .publicCloudDatabase:
            if #available(watchOSApplicationExtension 3.0, *) {
                cloudKitWorker.read(forKey: key, withObjectType: objectType, forContainerType: .publicCloudDatabase, completionHandler: completionHandler)
            } else {
                // Fallback on earlier versions
            }

        case .sharedCloudDatabase:
            if #available(watchOSApplicationExtension 3.0, *) {
                cloudKitWorker.read(forKey: key, withObjectType: objectType, forContainerType: .sharedCloudDatabase, completionHandler: completionHandler)
            } else {
                // Fallback on earlier versions
            }

        case .ubiquitousKeyValueStore:
            #if !os(watchOS)
            ubiquitousKeyValueStoreWorker.read(forKey: key, completionHandler: completionHandler)
            #endif

        default:
            let error = ErrorObject(protocol: .unknownRepresentation)
            completionHandler(nil, nil, error)
        }
    }

    /// Update the property of the receiver specified by a given key to a given object.
    ///
    /// - Parameters:
    ///   - object: The object for the property identified by key.
    ///   - key: The name of one of the receiver's properties.
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    /// - Parameter objectID: The unique ID of the object. For CloudKit, the type is
    ///                       [CKRecord.ID](apple-reference-documentation://hsWjEyXEsV)
    ///                       and it is the object that uniquely identifies a record in a database.
    /// - Parameter error: An error object, or `nil` if it was completed successfully. Use the information
    ///                    in the error object to determine whether a problem has a workaround.
    open func update<T>(object: T, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

        update(object: object, forKey: key, forStorageType: defaultType, completionHandler: completionHandler)
    }

    /// Update the property of the receiver specified by a given key to a given object.
    ///
    /// - Parameters:
    ///   - object: The object for the property identified by key.
    ///   - key: The key to identify the data store manager object.
    ///   - storageType: A storage type constant.
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    /// - Parameter objectID: The unique ID of the object. For CloudKit, the type is
    ///                       [CKRecord.ID](apple-reference-documentation://hsWjEyXEsV)
    ///                       and it is the object that uniquely identifies a record in a database.
    /// - Parameter error: An error object, or `nil` if it was completed successfully. Use the information
    ///                    in the error object to determine whether a problem has a workaround.
    open func update<T>(object: T, forKey key: String, forStorageType storageType: StorageType, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

        switch storageType {
        case .userDefaults:
            userDefaultsWorker.update(object: object, forKey: key, completionHandler: completionHandler)

        case .documentDirectory:
            fileManagerWorker.update(object: object, forKey: key, forDirectory: .documentDirectory, completionHandler: completionHandler)

        case .userDirectory:
            fileManagerWorker.update(object: object, forKey: key, forDirectory: .userDirectory, completionHandler: completionHandler)

        case .libraryDirectory:
            fileManagerWorker.update(object: object, forKey: key, forDirectory: .libraryDirectory, completionHandler: completionHandler)

        case .applicationDirectory:
            fileManagerWorker.update(object: object, forKey: key, forDirectory: .applicationDirectory, completionHandler: completionHandler)

        case .coreServiceDirectory:
            fileManagerWorker.update(object: object, forKey: key, forDirectory: .coreServiceDirectory, completionHandler: completionHandler)

        case .temporaryDirectory:
            fileManagerWorker.update(object: object, forKey: key, forDirectory: .temporaryDirectory, completionHandler: completionHandler)

        case .cache:
            cacheWorker.update(object: object, forKey: key, completionHandler: completionHandler)

        case .genericKeychain:
            keychainWorker.update(object: object, forKey: key, forItemClass: .generic, completionHandler: completionHandler)

        case .internetKeychain:
            keychainWorker.update(object: object, forKey: key, forItemClass: .internet, completionHandler: completionHandler)

        case .privateCloudDatabase:
            if #available(watchOSApplicationExtension 3.0, *) {
                cloudKitWorker.update(object: object, forKey: key, forContainerType: .privateCloudDatabase, completionHandler: completionHandler)
            } else {
                // Fallback on earlier versions
            }

        case .publicCloudDatabase:
            if #available(watchOSApplicationExtension 3.0, *) {
                cloudKitWorker.update(object: object, forKey: key, forContainerType: .publicCloudDatabase, completionHandler: completionHandler)
            } else {
                // Fallback on earlier versions
            }

        case .sharedCloudDatabase:
            if #available(watchOSApplicationExtension 3.0, *) {
                cloudKitWorker.update(object: object, forKey: key, forContainerType: .sharedCloudDatabase, completionHandler: completionHandler)
            } else {
                // Fallback on earlier versions
            }

        case .ubiquitousKeyValueStore:
            #if !os(watchOS)
            ubiquitousKeyValueStoreWorker.update(object: object, forKey: key, completionHandler: completionHandler)
            #endif

        default:
            let error = ErrorObject(protocol: .unknownRepresentation)
            completionHandler(false, nil, error)
        }
    }

    /// Removes the object of the specified default key.
    ///
    /// - Parameters:
    ///   - key: The key to identify the data store manager object.
    ///   - objectType: The type of object for the property identified by key.
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    /// - Parameter objectID: The unique ID of the object. For CloudKit, the type is
    ///                       [CKRecord.ID](apple-reference-documentation://hsWjEyXEsV)
    ///                       and it is the object that uniquely identifies a record in a database.
    /// - Parameter error: An error object, or `nil` if it was completed successfully. Use the information
    ///                    in the error object to determine whether a problem has a workaround.
    open func delete<T>(forKey key: String, withObjectType objectType: T.Type, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

       delete(forKey: key, withObjectType: objectType, forStorageType: defaultType, completionHandler: completionHandler)
    }

    /// Removes the object of the specified default key.
    ///
    /// - Parameters:
    ///   - key: The key to identify the data store manager object.
    ///   - objectType: The type of object for the property identified by key.
    ///   - storageType: A storage type constant.
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    /// - Parameter objectID: The unique ID of the object. For CloudKit, the type is
    ///                       [CKRecord.ID](apple-reference-documentation://hsWjEyXEsV)
    ///                       and it is the object that uniquely identifies a record in a database.
    /// - Parameter error: An error object, or `nil` if it was completed successfully. Use the information
    ///                    in the error object to determine whether a problem has a workaround.
    open func delete<T>(forKey key: String, withObjectType objectType: T.Type, forStorageType storageType: StorageType, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

        switch storageType {
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

        case .genericKeychain:
            keychainWorker.delete(forKey: key, forItemClass: .generic, completionHandler: completionHandler)

        case .internetKeychain:
            keychainWorker.delete(forKey: key, forItemClass: .internet, completionHandler: completionHandler)

        case .privateCloudDatabase:
            if #available(watchOSApplicationExtension 3.0, *) {
                cloudKitWorker.delete(forKey: key, withObjectType: objectType, forContainerType: .privateCloudDatabase, completionHandler: completionHandler)
            } else {
                // Fallback on earlier versions
            }

        case .publicCloudDatabase:
            if #available(watchOSApplicationExtension 3.0, *) {
                cloudKitWorker.delete(forKey: key, withObjectType: objectType, forContainerType: .publicCloudDatabase, completionHandler: completionHandler)
            } else {
                // Fallback on earlier versions
            }

        case .sharedCloudDatabase:
            if #available(watchOSApplicationExtension 3.0, *) {
                cloudKitWorker.delete(forKey: key, withObjectType: objectType, forContainerType: .sharedCloudDatabase, completionHandler: completionHandler)
            } else {
                // Fallback on earlier versions
            }

        case .ubiquitousKeyValueStore:
            #if !os(watchOS)
            ubiquitousKeyValueStoreWorker.delete(forKey: key, completionHandler: completionHandler)
            #endif

        default:
            let error = ErrorObject(protocol: .unknownRepresentation)
            completionHandler(false, nil, error)
        }
    }

    /// Empties the data store manager for the given type.
    ///
    /// - Parameters:
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    /// - Parameter objectID: The unique ID of the object. For CloudKit, the type is
    ///                       [CKRecord.ID](apple-reference-documentation://hsWjEyXEsV)
    ///                       and it is the object that uniquely identifies a record in a database.
    /// - Parameter error: An error object, or `nil` if it was completed successfully. Use the information
    ///                    in the error object to determine whether a problem has a workaround.
    open func deleteAll(completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

        deleteAll(forStorageType: defaultType, completionHandler: completionHandler)
    }

    /// Empties the data store manager for the given type.
    ///
    /// - Parameters:
    ///   - storageType: A storage type constant.
    ///   - completionHandler: The block to execute with the successful flag.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    /// - Parameter isSuccessful: true on successful; false if not.
    /// - Parameter objectID: The unique ID of the object. For CloudKit, the type is
    ///                       [CKRecord.ID](apple-reference-documentation://hsWjEyXEsV)
    ///                       and it is the object that uniquely identifies a record in a database.
    /// - Parameter error: An error object, or `nil` if it was completed successfully. Use the information
    ///                    in the error object to determine whether a problem has a workaround.
    open func deleteAll(forStorageType storageType: StorageType, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

        switch storageType {
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

        case .genericKeychain:
            keychainWorker.deleteAll(forItemClass: .generic, completionHandler: completionHandler)

        case .internetKeychain:
            keychainWorker.deleteAll(forItemClass: .internet, completionHandler: completionHandler)

        case .privateCloudDatabase:
            if #available(watchOSApplicationExtension 3.0, *) {
                cloudKitWorker.deleteAll(forContainerType: .privateCloudDatabase, completionHandler: completionHandler)
            } else {
                // Fallback on earlier versions
            }

        case .publicCloudDatabase:
            if #available(watchOSApplicationExtension 3.0, *) {
                cloudKitWorker.deleteAll(forContainerType: .publicCloudDatabase, completionHandler: completionHandler)
            } else {
                // Fallback on earlier versions
            }

        case .sharedCloudDatabase:
            if #available(watchOSApplicationExtension 3.0, *) {
                cloudKitWorker.deleteAll(forContainerType: .sharedCloudDatabase, completionHandler: completionHandler)
            } else {
                // Fallback on earlier versions
            }

        case .ubiquitousKeyValueStore:
            #if !os(watchOS)
            ubiquitousKeyValueStoreWorker.deleteAll(completionHandler: completionHandler)
            #endif

        default:
            let error = ErrorObject(protocol: .unknownRepresentation)
            completionHandler(false, nil, error)
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
    /// - Parameter error: An error object, or `nil` if it was completed successfully. Use the information
    ///                    in the error object to determine whether a problem has a workaround.
    ///
    /// Call this function at the point where you app can migrate the schema. It will check first
    /// if the schema version is the same or not.If the schema needs to be migrated, it will call
    /// [dataStoreManager(_:performMigrationFromOldVersion:forType:)](https://zaidmsaid.github.io/DataStoreManager/Protocols/DataStoreManagerDelegate.html#/c:@M@DataStoreManager@objc(pl)DataStoreManagerDelegate(im)dataStoreManager:performMigrationFromOldVersion:forType:)
    /// delegate method.
    open func migrateSchema(forStorageType storageType: StorageType, completionHandler: @escaping (_ isSuccessful: Bool, _ error: Error?) -> Void) {

        let key = "kSchemaVersion|DataStoreManager|\(identifier)|\(storageType.rawValue)"

        let oldSchemaVersion = UserDefaults.standard.integer(forKey: key)
        let newSchemaVersion = dataSource?.dataStoreManager?(self, currentSchemaVersionForType: storageType) ?? 0

        if oldSchemaVersion < newSchemaVersion {
            delegate?.dataStoreManager?(self, performMigrationFromOldVersion: oldSchemaVersion, forType: storageType)
            UserDefaults.standard.set(newSchemaVersion, forKey: key)
            completionHandler(true, nil)

        } else if oldSchemaVersion > newSchemaVersion {
            let error = ErrorObject(protocol: .lowerSchemaVersion(detail: "The oldSchemaVersion is \(oldSchemaVersion), newSchemaVersion is \(newSchemaVersion)."))
            completionHandler(false, error)

        } else {
            completionHandler(true, nil)
        }
    }
}
