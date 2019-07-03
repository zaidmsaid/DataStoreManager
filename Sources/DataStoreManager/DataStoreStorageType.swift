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

/// Constants that provide information regarding storage type of data store manager.
@objc public enum DataStoreStorageType : Int, CaseIterable {

    /// The storage type [UserDefaults](apple-reference-documentation://hsARFaqWd3).
    case userDefaults

    /// The storage type [FileManager](apple-reference-documentation://hsQQiy1kjA)
    /// with the search path document directory.
    case documentDirectory

    /// The storage type [FileManager](apple-reference-documentation://hsQQiy1kjA)
    /// with the search path user home directories (`/Users`).
    case userDirectory

    /// The storage type [FileManager](apple-reference-documentation://hsQQiy1kjA)
    /// with the search path various user-visible documentation, support, and
    /// configuration files (`/Library`).
    case libraryDirectory

    /// The storage type [FileManager](apple-reference-documentation://hsQQiy1kjA)
    /// with the search path supported applications (`/Applications`).
    case applicationDirectory

    /// The storage type [FileManager](apple-reference-documentation://hsQQiy1kjA)
    /// with the search path core services (`System/Library/CoreServices`).
    case coreServiceDirectory

    /// The storage type [FileManager](apple-reference-documentation://hsQQiy1kjA)
    /// with the temporary directory for the current user.
    case temporaryDirectory

    /// The storage type [NSCache](apple-reference-documentation://hs3dlYnTwl).
    case cache

    /// The storage type [SecItem](https://developer.apple.com/documentation/security/keychain_services).
    case keychain

    /// The storage type [NSUbiquitousKeyValueStore](apple-reference-documentation://hskNNwzU6H).
    case ubiquitousKeyValueStore

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

        case .ubiquitousKeyValueStore:
            return "NSUbiquitousKeyValueStore"

        @unknown case _:
            assertionFailure("Use a representation that was unknown when this code was compiled.")
            return ""
        }
    }

    /// Creates a new instance with the specified string value.
    ///
    /// - Parameter stringValue: The string value to use for the new instance.
    ///
    /// If there is no value of the type that corresponds with the specified string value, this initializer returns nil. For example:
    /// ```
    /// print(DataStoreStorageType(stringValue: "UserDefaults"))
    /// // Prints "Optional("DataStoreStorageType.userDefaults")"
    ///
    /// print(DataStoreStorageType(stringValue: "Invalid"))
    /// // Prints "nil"
    /// ```
    public init?(stringValue: String) {
        for type in DataStoreStorageType.allCases {
            if type.toString() == stringValue {
                self = type
            }
        }
        return nil
    }
}
