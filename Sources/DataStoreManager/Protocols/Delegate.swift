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

import CloudKit

/// Methods for performing actions in a data store manager.
@objc public protocol DataStoreManagerDelegate: class {

    // MARK: Core

    /// Tells the delegate that the specified storage type of a data store
    /// needs to perform migration.
    ///
    /// Handle the logic to perform the migration. For example:
    /// ```
    /// switch version {
    /// case 0:
    ///     migrateFromVersionZeroToOne()
    ///     fallthrough
    /// case 1:
    ///     migrateFromVersionOneToTwo()
    /// default:
    ///     break
    /// }
    /// ```
    /// After the delegate method is called, the schema version will be
    /// updated to the version defined in
    /// [dataStoreManager(_:currentSchemaVersionForType:)](https://zaidmsaid.github.io/DataStoreManager/Protocols/DataStoreManagerDataSource.html#/c:@M@DataStoreManager@objc(pl)DataStoreManagerDataSource(im)dataStoreManager:currentSchemaVersionForType:)
    ///
    /// - Parameters:
    ///   - manager: The data store manager object informing the delegate of
    ///              this event.
    ///   - oldVersion: The old schema version for reference to do
    ///                 migration.
    ///   - type: A storage type constant.
    @objc optional func dataStoreManager(
        _ manager: DataStoreManager,
        performMigrationFromOldVersion oldVersion: Int,
        forType type: DataStoreStorageType
    )

    // MARK: Cache

    /// Asks the delegate for the cost with which associate to the object.
    ///
    /// When memory is limited or when the total cost of the cache eclipses
    /// the maximum allowed total cost, the cache could begin an eviction
    /// process to remove some of its elements. However, this eviction
    /// process is not in a guaranteed order. As a consequence, if you try
    /// to manipulate the cost values to achieve some specific behavior, the
    /// consequences could be detrimental to your program. Typically, the
    /// obvious cost is the size of the value in bytes. If that information
    /// is not readily available, you should not go through the trouble of
    /// trying to compute it, as doing so will drive up the cost of using
    /// the cache. Pass in 0 for the cost value if you otherwise have
    /// nothing useful to pass.
    ///
    /// Unlike an `NSMutableDictionary` object, a cache does not copy the
    /// key objects that are put into it.
    ///
    /// - Parameters:
    ///   - manager: An object representing the data store manager
    ///              requesting this information.
    ///   - object: The object to be cached.
    /// - Returns: The `cost` value is used to compute a sum encompassing
    ///            the costs of all the objects in the cache.
    @objc optional func dataStoreManager(
        _ manager: DataStoreManager,
        cacheCostLimitForObject object: Any
        ) -> Int

    // MARK: Cloud Kit Container

    /// Asks the delegate for the cloud kit container record type of the
    /// data store manager.
    ///
    /// Use this string to differentiate between different record types in
    /// your app. The string is primarily for your benefit, so choose type
    /// names that reflect the data in the corresponding records.
    ///
    /// - Parameters:
    ///   - manager: An object representing the data store manager
    ///              requesting this information.
    ///   - key: The key to identify the data store manager object.
    /// - Returns: The app-defined string that identifies the type of the
    ///            record.
    @available(watchOSApplicationExtension 3.0, *)
    @objc optional func dataStoreManager(
        _ manager: DataStoreManager,
        cloudKitContainerRecordIDForKey key: String
        ) -> CKRecord.ID

    // MARK: iCloud Key-value Storage

    /// Tells the delegate that the specified storage type of a data store
    /// needs to handle when the value of one or more keys in the local
    /// key-value store changed due to incoming data pushed from iCloud.
    ///
    /// The user info dictionary can contain the reason for the notification
    /// as well as a list of which values changed, as follows:
    /// * The value of the
    ///   [NSUbiquitousKeyValueStoreChangeReasonKey](apple-reference-documentation://hsUJ2fgaPt)
    ///   key, when present, indicates why the key-value store changed. Its
    ///   value is one of the constants in
    ///   [Change Reason Values](apple-reference-documentation://ts1433687).
    /// * The value of the
    ///   [NSUbiquitousKeyValueStoreChangedKeysKey(apple-reference-documentation://hsxKbLUIAR),
    ///   when present, is an array of strings, each the name of a key whose
    ///   value changed.
    ///
    /// - Parameters:
    ///   - manager: An object representing the data store manager
    ///              requesting this information.
    ///   - userInfo: The user info dictionary.
    @objc optional func dataStoreManager(
        _ manager: DataStoreManager,
        ubiquitousCloudStoreDidChangeExternallyWithUserInfo userInfo: [AnyHashable: Any]?
    )
}
