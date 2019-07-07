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

import Security

/// Constants that provide information regarding storage type of data store manager.
@objcMembers open class DataStoreStorageType : NSObject {

    // MARK: - Initializers

    /// Creates a new instance with the specified raw value.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    init(_ rawValue: RawValue) {
        self.rawValue = rawValue
        super.init()
    }

    /// Creates a new instance with the specified raw value.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    ///
    /// If there is no value of the type that corresponds with the specified string value, this initializer returns nil.
    public required init?(rawValue: RawValue) {
        for type in DataStoreStorageType.allCases {
            if type.rawValue == rawValue {
                self.rawValue = rawValue
                super.init()
                return
            }
        }
        return nil
    }

    // MARK: - Type Aliases

    public typealias RawValue = String

    // MARK: - Properties

    /// The corresponding value of the raw type.
    public final var rawValue: String

    /// The storage type [UserDefaults](apple-reference-documentation://hsARFaqWd3).
    public static let userDefaults = DataStoreStorageType("UserDefaults")

    /// The storage type [FileManager](apple-reference-documentation://hsQQiy1kjA)
    /// with the search path document directory.
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
    /// with the search path core services (`System/Library/CoreServices`).
    public static let coreServiceDirectory = DataStoreStorageType("FileManager.coreServiceDirectory")

    /// The storage type [FileManager](apple-reference-documentation://hsQQiy1kjA)
    /// with the temporary directory for the current user.
    public static let temporaryDirectory = DataStoreStorageType("FileManager.temporaryDirectory")

    /// The storage type [NSCache](apple-reference-documentation://hs3dlYnTwl).
    public static let cache = DataStoreStorageType("NSCache")

    /// The storage type [SecItem](https://developer.apple.com/documentation/security/keychain_services)
    /// with [kSecClass](https://developer.apple.com/documentation/security/ksecclass) value defined as
    /// [kSecClassGenericPassword](https://developer.apple.com/documentation/security/ksecclassgenericpassword).
    public static let genericKeychain = DataStoreStorageType("SecItem.kSecClassGenericPassword")

    /// The storage type [SecItem](https://developer.apple.com/documentation/security/keychain_services)
    /// with [kSecClass](https://developer.apple.com/documentation/security/ksecclass) value defined as
    /// [kSecClassGenericPassword](https://developer.apple.com/documentation/security/ksecclassinternetpassword).
    public static let internetKeychain = DataStoreStorageType("SecItem.kSecClassInternetPassword")

    public static let privateCloudDatabase = DataStoreStorageType("CKContainer.privateCloudDatabase")

    public static let publicCloudDatabase = DataStoreStorageType("CKContainer.publicCloudDatabase")

    public static let sharedCloudDatabase = DataStoreStorageType("CKContainer.sharedCloudDatabase")

    /// The storage type [NSUbiquitousKeyValueStore](apple-reference-documentation://hskNNwzU6H).
    public static let ubiquitousKeyValueStore = DataStoreStorageType("NSUbiquitousKeyValueStore")

    /// A collection of all values of this type.
    public static var allCases: [DataStoreStorageType] {
        return [
            DataStoreStorageType.userDefaults,
            DataStoreStorageType.documentDirectory,
            DataStoreStorageType.userDirectory,
            DataStoreStorageType.libraryDirectory,
            DataStoreStorageType.applicationDirectory,
            DataStoreStorageType.coreServiceDirectory,
            DataStoreStorageType.temporaryDirectory,
            DataStoreStorageType.cache,
            DataStoreStorageType.genericKeychain,
            DataStoreStorageType.internetKeychain,
            DataStoreStorageType.privateCloudDatabase,
            DataStoreStorageType.publicCloudDatabase,
            DataStoreStorageType.sharedCloudDatabase,
            DataStoreStorageType.ubiquitousKeyValueStore
        ]
    }
}

// MARK: - CustomStringConvertible

extension DataStoreStorageType : RawRepresentable, CaseIterable {

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
            return "SecItem"

        case .internetKeychain:
            return "SecItem"

        case .privateCloudDatabase:
            return "CKContainer"

        case .publicCloudDatabase:
            return "CKContainer"

        case .sharedCloudDatabase:
            return "CKContainer"

        case .ubiquitousKeyValueStore:
            return "NSUbiquitousKeyValueStore"

        default:
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
            return "SecItem"

        case .internetKeychain:
            return "SecItem"

        case .privateCloudDatabase:
            return "CKContainer"

        case .publicCloudDatabase:
            return "CKContainer"

        case .sharedCloudDatabase:
            return "CKContainer"

        case .ubiquitousKeyValueStore:
            return "NSUbiquitousKeyValueStore"

        default:
            return "Use a representation that was unknown when this code was compiled."
        }
    }
}
