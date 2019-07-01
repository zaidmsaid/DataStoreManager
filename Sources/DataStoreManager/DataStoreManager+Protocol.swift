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
    /// If adding this object to the cache causes the cache’s total cost to rise above totalCostLimit, the cache may automatically
    /// evict objects until its total cost falls below totalCostLimit. The order in which the cache evicts objects is not guaranteed.
    ///
    /// This is not a strict limit, and if the cache goes over the limit, an object in the cache could be evicted instantly, at a later
    /// point in time, or possibly never, all depending on the implementation details of the cache.
    @objc optional func cacheTotalCostLimit(for manager: DataStoreManager) -> Int

    /// Asks the data source for the cost with which associate to the object.
    ///
    /// - Parameters:
    ///   - manager: An object representing the data store manager requesting this information.
    ///   - object: The object to be cached.
    /// - Returns: The cost value is used to compute a sum encompassing the costs of all the objects in the cache.
    ///
    /// When memory is limited or when the total cost of the cache eclipses the maximum allowed total cost, the cache could begin an
    /// eviction process to remove some of its elements. However, this eviction process is not in a guaranteed order. As a consequence,
    /// if you try to manipulate the cost values to achieve some specific behavior, the consequences could be detrimental to your program.
    /// Typically, the obvious cost is the size of the value in bytes. If that information is not readily available, you should not go
    /// through the trouble of trying to compute it, as doing so will drive up the cost of using the cache. Pass in 0 for the cost value
    /// if you otherwise have nothing useful to pass, or simply use the setObject:forKey: method, which does not require a cost value to
    /// be passed in.
    @objc optional func dataStoreManager(_ manager: DataStoreManager, cacheCostLimitForObject object: Any) -> Int

    // MARK: SecurityItem

    /// Asks the data source for the keychain service of the data store manager.
    ///
    /// - Parameter manager: An object representing the data store manager requesting this information.
    /// - Returns: The corresponding value is a string of type CFString that represents the service associated with this item.
    ///            Items of class kSecClassGenericPassword have this attribute.
    @objc optional func keychainService(for manager: DataStoreManager) -> String

    /// Asks the data source for the keychain account name of the data store manager.
    ///
    /// - Parameter manager: An object representing the data store manager requesting this information.
    /// - Returns: The corresponding value is of type CFString and contains an account name. Items of class kSecClassGenericPassword
    ///            and kSecClassInternetPassword have this attribute.
    @objc optional func keychainAccount(for manager: DataStoreManager) -> String

    /// Asks the data source for a string indicating the keychain access group of the data store manager.
    ///
    /// - Parameter manager: An object representing the data store manager requesting this information.
    /// - Returns: The corresponding value is of type CFString and indicates the item’s one and only access group.
    ///
    /// For an app to access a keychain item, one of the groups to which the app belongs must be the item’s group.
    /// The list of an app’s access groups consists of the following string identifiers, in this order:
    /// * The strings in the app’s Keychain Access Groups Entitlement
    /// * The app ID string
    /// * The strings in the App Groups Entitlement
    ///
    /// Two or more apps that are in the same access group can share keychain items. For more details,
    /// see Sharing Access to Keychain Items Among a Collection of Apps.
    ///
    /// Specify which access group a keychain item belongs to when you create it by setting the kSecAttrAccessGroup
    /// attribute in the query you send to the SecItemAdd(_:_:) method. Naming a group that’s not among the creating
    /// app’s access groups—including the empty string, which is always an invalid group—generates an error. If you
    /// don’t explicitly set a group, keychain services defaults to the app’s first access group, which is either the
    /// first keychain access group, or the app ID when the app has no keychain groups. In the latter case, the item
    /// is only accessible to the app creating the item, since no other app can be in that group.
    ///
    /// By default, the SecItemUpdate(_:_:), SecItemDelete(_:), and SecItemCopyMatching(_:_:) methods search all the
    /// app’s access groups. Add the kSecAttrAccessGroup attribute to the query to limit the search to a particular
    /// group.
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
    @objc optional func dataStoreManager(_ manager: DataStoreManager, performMigrationFromOldVersion version: Int, forType type: DataStoreManager.StorageType)
}
