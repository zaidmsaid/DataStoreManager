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

// MARK: - DataSource

/// The methods adopted by the object you use to manage data for a data store manager.
@objc public protocol DataStoreManagerDataSource: class {

    // MARK: Core

    /// Asks the data source to return the default storage type for the data store manager.
    ///
    /// - Parameter manager: An object representing the data store manager requesting this information.
    /// - Returns: The default storage type of the data store manager.
    @objc optional func defaultType(for manager: DataStoreManager) -> DataStoreManager.StorageType

    /// Asks the data source to return the current schema version for the storage type of data store manager.
    ///
    /// - Parameters:
    ///   - manager: An object representing the data store manager requesting this information.
    ///   - type: A storage type constant.
    /// - Returns: The current schema version number for the storage type of the data store manager.
    @objc optional func dataStoreManager(_ manager: DataStoreManager, currentSchemaVersionForType type: DataStoreManager.StorageType) -> Int

    // MARK: UserDefaults

    /// Asks the data source to return a string that represent the suite name for UserDefaults of the data store manager.
    ///
    /// - Parameter manager: An object representing the data store manager requesting this information.
    /// - Returns: The UserDefaults suite name for the data store manager.
    @objc optional func userDefaultsSuiteName(for manager: DataStoreManager) -> String

    // MARK: Cache

    /// Asks the data source for the maximum total cost that the cache can hold before it starts evicting objects.
    ///
    /// - Parameter manager: An object representing the data store manager requesting this information.
    /// - Returns: The number of total cost limit.
    ///
    /// When you add an object to the cache, you may pass in a specified cost for the object, such as the size in bytes of the object.
    /// If adding this object to the cache causes the cache’s total cost to rise above `totalCostLimit`, the cache may automatically
    /// evict objects until its total cost falls below `totalCostLimit`. The order in which the cache evicts objects is not guaranteed.
    ///
    /// This is not a strict limit, and if the cache goes over the limit, an object in the cache could be evicted instantly, at a later
    /// point in time, or possibly never, all depending on the implementation details of the cache.
    @objc optional func cacheTotalCostLimit(for manager: DataStoreManager) -> Int

    /// Asks the data source for the cost with which associate to the object.
    ///
    /// - Parameters:
    ///   - manager: An object representing the data store manager requesting this information.
    ///   - object: The object to be cached.
    /// - Returns: The `cost` value is used to compute a sum encompassing the costs of all the objects in the cache.
    ///
    /// When memory is limited or when the total cost of the cache eclipses the maximum allowed total cost, the cache could begin an
    /// eviction process to remove some of its elements. However, this eviction process is not in a guaranteed order. As a consequence,
    /// if you try to manipulate the cost values to achieve some specific behavior, the consequences could be detrimental to your program.
    /// Typically, the obvious cost is the size of the value in bytes. If that information is not readily available, you should not go
    /// through the trouble of trying to compute it, as doing so will drive up the cost of using the cache. Pass in 0 for the cost value
    /// if you otherwise have nothing useful to pass.
    ///
    /// Unlike an `NSMutableDictionary` object, a cache does not copy the key objects that are put into it.
    @objc optional func dataStoreManager(_ manager: DataStoreManager, cacheCostLimitForObject object: Any) -> Int

    // MARK: SecurityItem

    /// Asks the data source for the keychain service of the data store manager.
    ///
    /// - Parameter manager: An object representing the data store manager requesting this information.
    /// - Returns: The corresponding value is a string of type [CFString](apple-reference-documentation://hsYWZv0wKs)
    ///            that represents the service associated with this item. Items of class
    ///            [kSecClassGenericPassword](apple-reference-documentation://hsgWgYNpc3) have this attribute.
    @objc optional func keychainService(for manager: DataStoreManager) -> String

    /// Asks the data source for the keychain account name of the data store manager.
    ///
    /// - Parameter manager: An object representing the data store manager requesting this information.
    /// - Returns: The corresponding value is of type [CFString](apple-reference-documentation://hsYWZv0wKs)
    ///            and contains an account name. Items of class
    ///            [kSecClassGenericPassword](apple-reference-documentation://hsgWgYNpc3) and
    ///            [kSecClassInternetPassword](apple-reference-documentation://hsT6cNjrp9) have this attribute.
    @objc optional func keychainAccount(for manager: DataStoreManager) -> String

    /// Asks the data source for a string indicating the keychain access group of the data store manager.
    ///
    /// - Parameter manager: An object representing the data store manager requesting this information.
    /// - Returns: The corresponding value is of type [CFString](apple-reference-documentation://hsYWZv0wKs)
    ///            and indicates the item’s one and only access group.
    ///
    /// For an app to access a keychain item, one of the groups to which the app belongs must be the item’s group.
    /// The list of an app’s access groups consists of the following string identifiers, in this order:
    /// * The strings in the app’s [Keychain Access Groups Entitlement](apple-reference-documentation://hsVfwaZeip)
    /// * The app ID string
    /// * The strings in the [App Groups Entitlement](apple-reference-documentation://hsSm4ftpCR)
    ///
    /// Two or more apps that are in the same access group can share keychain items. For more details,
    /// see [Sharing Access to Keychain Items Among a Collection of Apps](apple-reference-documentation://ts2972431).
    ///
    /// If you don’t explicitly set a group, keychain services defaults to the app’s first access group, which is either
    /// the first keychain access group, or the app ID when the app has no keychain groups. In the latter case, the item
    /// is only accessible to the app creating the item, since no other app can be in that group.
    @objc optional func keychainAccessGroup(for manager: DataStoreManager) -> String
}

// MARK: - Delegate

/// Methods for performing actions in a data store manager.
@objc public protocol DataStoreManagerDelegate: class {

    /// Tells the delegate that the specified storage type of a data store needs to perform migration.
    ///
    /// - Parameters:
    ///   - manager: The data store manager object informing the delegate of this event.
    ///   - version: The old schema version for reference to do migration.
    ///   - type: A storage type constant.
    ///
    /// Handle the logic to perform the migration. For example:
    /// ```
    /// switch version {
    /// case 0:
    ///     migrateFromVersionZeroToOne()
    ///     fallthrough
    ///
    /// case 1:
    ///     migrateFromVersionOneToTwo()
    ///
    /// default:
    ///     break
    /// }
    /// ```
    /// After the delegate method is called, the schema version will be updated to the version defined in
    /// [dataStoreManager(_:currentSchemaVersionForType:)](https://zaidmsaid.github.io/DataStoreManager/Protocols/DataStoreManagerDataSource.html#/c:@M@DataStoreManager@objc(pl)DataStoreManagerDataSource(im)dataStoreManager:currentSchemaVersionForType:)
    @objc optional func dataStoreManager(_ manager: DataStoreManager, performMigrationFromOldVersion version: Int, forType type: DataStoreManager.StorageType)
}
