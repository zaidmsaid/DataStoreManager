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

#if os(iOS) || os(macOS)
import LocalAuthentication
#else
import Foundation
#endif

/// The methods adopted by the object you use to manage data for a data store manager.
@objc public protocol DataStoreManagerDataSource: class {

    // MARK: Core

    /// Asks the data source for the default storage type for the data store manager.
    ///
    /// - Parameter manager: An object representing the data store manager requesting this information.
    /// - Returns: The default storage type of the data store manager.
    @objc optional func defaultStorageType(for manager: DataStoreManager) -> DataStoreStorageType

    /// Asks the data source for the current schema version for the storage type of data store manager.
    ///
    /// - Parameters:
    ///   - manager: An object representing the data store manager requesting this information.
    ///   - type: A storage type constant.
    /// - Returns: The current schema version number for the storage type of the data store manager.
    @objc optional func dataStoreManager(_ manager: DataStoreManager, currentSchemaVersionForType type: DataStoreStorageType) -> Int

    // MARK: User Defaults

    /// Asks the data source for the suite name for `UserDefaults` of the data store manager.
    ///
    /// - Parameter manager: An object representing the data store manager requesting this information.
    /// - Returns: The `UserDefaults` suite name for the data store manager.
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

    // MARK: Keychain

    /// Asks the data source for the generic keychain service of the data store manager.
    ///
    /// - Parameter manager: An object representing the data store manager requesting this information.
    /// - Returns: The corresponding value is a string that represents the service associated with this item.
    @objc optional func genericKeychainService(for manager: DataStoreManager) -> String

    /// Asks the data source for the generic keychain access group of the data store manager.
    ///
    /// - Parameter manager: An object representing the data store manager requesting this information.
    /// - Returns: The corresponding value is a string that indicates the item’s one and only access group.
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
    @objc optional func genericKeychainAccessGroup(for manager: DataStoreManager) -> String

    @objc optional func internetKeychainServer(for manager: DataStoreManager) -> URL

    @objc optional func internetKeychainProtocolType(for manager: DataStoreManager) -> DataStoreProtocolType

    @objc optional func internetKeychainAuthenticationType(for manager: DataStoreManager) -> DataStoreAuthenticationType

    /// Asks the data source to verify that the keychain of the data store manager is synchronized through iCloud.
    ///
    /// - Parameter manager: An object representing the data store manager requesting this information.
    /// - Returns: `true` if the item is synchronized through iCloud; otherwise `false`.
    @objc optional func keychainIsSynchronizable(for manager: DataStoreManager) -> Bool

    /// Asks the data source for the keychain operation prompt of the data store manager.
    ///
    /// - Parameter manager: An object representing the data store manager requesting this information.
    /// - Returns: The corresponding value is a string describing the operation for which the app is attempting to
    ///            authenticate. When performing user authentication, the system includes the string in the user prompt.
    ///            The app is responsible for text localization.
    @available(iOS 8.0, *)
    @available(macOS 10.10, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @objc optional func keychainOperationPrompt(for manager: DataStoreManager) -> String

    /// Asks the data source for the keychain local authentication context to use of the data store manager.
    ///
    /// - Parameter manager: An object representing the data store manager requesting this information.
    /// - Returns: The corresponding value is of type
    ///            [LAContext](https://developer.apple.com/documentation/localauthentication/lacontext),
    ///            and represents a reusable local authentication context that should be used for keychain
    ///            item authentication.
    ///
    /// It is according to the following rules:
    /// * If this key is not specified, and if the item requires authentication, a new context will be created,
    ///   used once, and discarded.
    /// * If this key is specified with a context that has been previously authenticated, the operation will
    ///   succeed without asking user for authentication.
    /// * If this key is specified with a context that has not been previously authenticated, the system attempts
    ///   authentication on the context. If successful, the context may be reused in subsequent keychain operations.
    ///
    /// - Important: Include the
    ///              [NSFaceIDUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nsfaceidusagedescription)
    ///              key in your app’s Info.plist file if your app allows biometric authentication. Otherwise, authorization
    ///              requests may fail.
    @available(iOS 8.0, *)
    @available(macOS 10.10, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @objc optional func keychainLocalAuthenticationContext(for manager: DataStoreManager) -> LAContext

    // MARK: Cloud Kit Container

    /// Asks the data source for the containerIdentifier for `CKContainer` of the data store manager.
    ///
    /// - Parameter manager: An object representing the data store manager requesting this information.
    /// - Returns: The `CKContainer` containerIdentifier for the data store manager.
    @objc optional func cloudKitContainerIdentifier(for manager: DataStoreManager) -> String

    /// Asks the data source for the cloud kit container record type of the data store manager.
    ///
    /// - Parameter manager: An object representing the data store manager requesting this information.
    /// - Returns: The app-defined string that identifies the type of the record.
    ///
    /// Use this string to differentiate between different record types in your app. The string is primarily for your benefit,
    /// so choose type names that reflect the data in the corresponding records.
    @objc optional func cloudKitContainerRecordType(for manager: DataStoreManager) -> String

    /// Asks the data source to verify that the cloud kit container of data source manager allows duplicate key.
    ///
    /// - Parameter manager: An object representing the data store manager requesting this information.
    /// - Returns: `true` if the key allowed to be duplicated; otherwise `false`.
    ///
    /// If you do not implement this method, the data store manager configures does not allow duplicate key.
    @objc optional func cloudKitContainerAllowsDuplicateKey(for manager: DataStoreManager) -> Bool
}
