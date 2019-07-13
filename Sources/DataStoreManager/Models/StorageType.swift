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
import Security

/// Constants that provide information regarding storage type of data store manager.
@objcMembers open class DataStoreStorageType : NSObject {

    // MARK: - Initializers

    /// Creates a new instance with the specified raw value.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    init(_ rawValue: String) {
        self.rawValue = rawValue
        super.init()
    }

    /// Creates a new instance with the specified raw value.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    ///
    /// If there is no value of the type that corresponds with the specified string value, this initializer returns nil.
    public required init?(rawValue: String) {

        DataStoreStorageType.entity.add(value: DataStoreStorageType.userDefaults, forKey: AnyHashableMetatype(DataStoreStorageType.self))
        DataStoreStorageType.entity.add(value: DataStoreStorageType.documentDirectory, forKey: AnyHashableMetatype(DataStoreStorageType.self))
        DataStoreStorageType.entity.add(value: DataStoreStorageType.userDirectory, forKey: AnyHashableMetatype(DataStoreStorageType.self))
        DataStoreStorageType.entity.add(value: DataStoreStorageType.libraryDirectory, forKey: AnyHashableMetatype(DataStoreStorageType.self))
        DataStoreStorageType.entity.add(value: DataStoreStorageType.applicationDirectory, forKey: AnyHashableMetatype(DataStoreStorageType.self))
        DataStoreStorageType.entity.add(value: DataStoreStorageType.coreServiceDirectory, forKey: AnyHashableMetatype(DataStoreStorageType.self))
        DataStoreStorageType.entity.add(value: DataStoreStorageType.temporaryDirectory, forKey: AnyHashableMetatype(DataStoreStorageType.self))
        DataStoreStorageType.entity.add(value: DataStoreStorageType.cache, forKey: AnyHashableMetatype(DataStoreStorageType.self))
        DataStoreStorageType.entity.add(value: DataStoreStorageType.genericKeychain, forKey: AnyHashableMetatype(DataStoreStorageType.self))
        DataStoreStorageType.entity.add(value: DataStoreStorageType.internetKeychain, forKey: AnyHashableMetatype(DataStoreStorageType.self))
        DataStoreStorageType.entity.add(value: DataStoreStorageType.coreData, forKey: AnyHashableMetatype(DataStoreStorageType.self))
        DataStoreStorageType.entity.add(value: DataStoreStorageType.privateCloudDatabase, forKey: AnyHashableMetatype(DataStoreStorageType.self))
        DataStoreStorageType.entity.add(value: DataStoreStorageType.publicCloudDatabase, forKey: AnyHashableMetatype(DataStoreStorageType.self))
        DataStoreStorageType.entity.add(value: DataStoreStorageType.sharedCloudDatabase, forKey: AnyHashableMetatype(DataStoreStorageType.self))
        DataStoreStorageType.entity.add(value: DataStoreStorageType.ubiquitousCloudStore, forKey: AnyHashableMetatype(DataStoreStorageType.self))

        for type in DataStoreStorageType.allCases {
            if type.rawValue == rawValue {
                self.rawValue = rawValue
                super.init()
                return
            }
        }
        return nil
    }

    // MARK: - Properties

    /// The corresponding value of the raw type.
    public final var rawValue: String
}

extension DataStoreStorageType : RawRepresentable {

    // MARK: - Enumerations

    /// The storage type [UserDefaults](apple-reference-documentation://hsARFaqWd3).
    public static let userDefaults = DataStoreStorageType("UserDefaults")

    /// The storage type [FileManager](apple-reference-documentation://hsQQiy1kjA)
    /// with the search path document directory (`~/Documents`).
    public static let documentDirectory = DataStoreStorageType("FileManager.documentDirectory")

    /// The storage type [FileManager](apple-reference-documentation://hsQQiy1kjA)
    /// with the search path user home directories (`/Users`).
    public static let userDirectory = DataStoreStorageType("FileManager.userDirectory")

    /// The storage type [FileManager](apple-reference-documentation://hsQQiy1kjA)
    /// with the search path various user-visible documentation, support, and
    /// configuration files (`/Library`).
    public static let libraryDirectory = DataStoreStorageType("FileManager.libraryDirectory")

    /// The storage type [FileManager](apple-reference-documentation://hsQQiy1kjA)
    /// with the search path supported applications (`/Applications`).
    public static let applicationDirectory = DataStoreStorageType("FileManager.applicationDirectory")

    /// The storage type [FileManager](apple-reference-documentation://hsQQiy1kjA)
    /// with the search path core services (`/System/Library/CoreServices`).
    public static let coreServiceDirectory = DataStoreStorageType("FileManager.coreServiceDirectory")

    /// The storage type [FileManager](apple-reference-documentation://hsQQiy1kjA)
    /// with the temporary directory for the current user (`/tmp`).
    public static let temporaryDirectory = DataStoreStorageType("FileManager.temporaryDirectory")

    /// The storage type [NSCache](apple-reference-documentation://hs3dlYnTwl).
    public static let cache = DataStoreStorageType("NSCache")

    /// The storage type [Security](https://developer.apple.com/documentation/security/keychain_services)
    /// with [kSecClass](https://developer.apple.com/documentation/security/ksecclass) value defined as
    /// [kSecClassGenericPassword](https://developer.apple.com/documentation/security/ksecclassgenericpassword).
    public static let genericKeychain = DataStoreStorageType("Security.kSecClassGenericPassword")

    /// The storage type [Security](https://developer.apple.com/documentation/security/keychain_services)
    /// with [kSecClass](https://developer.apple.com/documentation/security/ksecclass) value defined as
    /// [kSecClassGenericPassword](https://developer.apple.com/documentation/security/ksecclassinternetpassword).
    public static let internetKeychain = DataStoreStorageType("Security.kSecClassInternetPassword")

    public static let coreData = DataStoreStorageType("CoreData")

    /// The storage type [CKContainer](apple-reference-documentation://hsS7IJpn_8)
    /// with [privateCloudDatabase](apple-reference-documentation://hsl8OIqKuV).
    public static let privateCloudDatabase = DataStoreStorageType("CKContainer.privateCloudDatabase")

    /// The storage type [CKContainer](apple-reference-documentation://hsS7IJpn_8)
    /// with [publicCloudDatabase](apple-reference-documentation://hsr3N4H2SH).
    public static let publicCloudDatabase = DataStoreStorageType("CKContainer.publicCloudDatabase")

    /// The storage type [CKContainer](apple-reference-documentation://hsS7IJpn_8)
    /// with [sharedCloudDatabase](apple-reference-documentation://hse91QSrM6).
    public static let sharedCloudDatabase = DataStoreStorageType("CKContainer.sharedCloudDatabase")

    /// The storage type [NSUbiquitousKeyValueStore](apple-reference-documentation://hskNNwzU6H).
    public static let ubiquitousCloudStore = DataStoreStorageType("NSUbiquitousKeyValueStore")
}

// MARK: - CaseIterable

extension DataStoreStorageType : Entity, CaseIterable {
    public typealias PrimaryKey = String

    fileprivate static var entity = EntityCollection<DataStoreStorageType>()

    /// A collection of all values of this type.
    public static var allCases: [DataStoreStorageType] {
        var cases = [DataStoreStorageType]()
        for value in entity.values {
            cases.append(value)
        }
        return cases
    }
}

// MARK: - CustomStringConvertible

extension DataStoreStorageType {

    /// A textual representation of this instance.
    open override var description: String {
        switch self {
        case .userDefaults:
            return "UserDefaults"

        case .documentDirectory:
            return "FileManager"

        case .userDirectory:
            return "FileManager"

        case .libraryDirectory:
            return "FileManager"

        case .applicationDirectory:
            return "FileManager"

        case .coreServiceDirectory:
            return "FileManager"

        case .temporaryDirectory:
            return "FileManager"

        case .cache:
            return "NSCache"

        case .genericKeychain:
            return "Security"

        case .internetKeychain:
            return "Security"

        case .coreData:
            return "CoreData"

        case .privateCloudDatabase:
            return "CKContainer"

        case .publicCloudDatabase:
            return "CKContainer"

        case .sharedCloudDatabase:
            return "CKContainer"

        case .ubiquitousCloudStore:
            return "NSUbiquitousKeyValueStore"

        default:
            assertionFailure("Use a representation that was unknown when this code was compiled.")
            return "Use a representation that was unknown when this code was compiled."
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension DataStoreStorageType {

    /// A textual representation of this instance, suitable for debugging.
    open override var debugDescription: String {
        switch self {
        case .userDefaults:
            return "UserDefaults"

        case .documentDirectory:
            return "FileManager"

        case .userDirectory:
            return "FileManager"

        case .libraryDirectory:
            return "FileManager"

        case .applicationDirectory:
            return "FileManager"

        case .coreServiceDirectory:
            return "FileManager"

        case .temporaryDirectory:
            return "FileManager"

        case .cache:
            return "NSCache"

        case .genericKeychain:
            return "Security"

        case .internetKeychain:
            return "Security"

        case .coreData:
            return "CoreData"

        case .privateCloudDatabase:
            return "CKContainer"

        case .publicCloudDatabase:
            return "CKContainer"

        case .sharedCloudDatabase:
            return "CKContainer"

        case .ubiquitousCloudStore:
            return "NSUbiquitousKeyValueStore"

        default:
            assertionFailure("Use a representation that was unknown when this code was compiled.")
            return "Use a representation that was unknown when this code was compiled."
        }
    }
}
