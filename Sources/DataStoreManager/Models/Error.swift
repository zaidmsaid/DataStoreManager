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

/// A type representing an error value.
enum ErrorProtocol : Error {

    // MARK: - Enumerations

    /// The bundle identifier cannot be retrieved.
    case bundleIdentifierNotAvailable

    /// The platform cannot use this property or function.
    ///
    /// - Parameter detail: The detail to place after description of the
    ///                     error description.
    case platformNotSupported(detail: String)

    /// The platform version cannot use this property or function.
    ///
    /// - Parameter detail: The detail to place after description of the
    ///                     error description.
    case platformVersionNotSupported(detail: String)

    /// Current schema version is lower than old schema version.
    ///
    /// - Parameter detail: The detail to place after description of the
    ///                     error description.
    case lowerSchemaVersion(detail: String)

    /// The data source cannot be retrieved.
    ///
    /// - Parameter detail: The detail to place after description of the
    ///                     error description.
    case datasourceNotAvailable(detail: String)

    /// The object cannot be created.
    ///
    /// - Parameter detail: The detail to place after description of the
    ///                     error description.
    case createFailed(detail: String)

    /// The object cannot be retrieved.
    ///
    /// - Parameter detail: The detail to place after description of the
    ///                     error description.
    case readFailed(detail: String)

    /// The object cannot be updated.
    ///
    /// - Parameter detail: The detail to place after description of the
    ///                     error description.
    case updateFailed(detail: String)

    /// The object cannot be deleted.
    ///
    /// - Parameter detail: The detail to place after description of the
    ///                     error description.
    case deleteFailed(detail: String)

    /// The specified object already exists.
    ///
    /// - Parameter detail: The detail to place after description of the
    ///                     error description.
    case duplicateObject(detail: String)

    /// The directory URL cannot be retrieved.
    case directoryURLNotAvailable

    /// The directory URL with path cannot be retrieved.
    case directoryFullURLNotAvailable

    /// Contents of directory cannot be retrieved.
    ///
    /// - Parameter detail: The detail to place after description of the
    ///                     error description.
    case directoryListNotAvailable(detail: String)

    /// The database cannot be retrieved.
    case databaseNotAvailable

    /// Use a representation that was unknown when this code was compiled.
    case unknownRepresentation
}

// MARK: - RawRepresentable

extension ErrorProtocol : RawRepresentable {

    // MARK: Initializers

    /// Creates a new instance with the specified raw value.
    ///
    /// If there is no value of the type that corresponds with the specified
    /// string value, this initializer returns nil.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    init?(rawValue: Int) {

        ErrorProtocol.setupEntities()

        for `protocol` in ErrorProtocol.allCases {
            if `protocol`.rawValue == rawValue {
                self = `protocol`
                return
            }
        }
        return nil
    }

    // MARK: Properties

    /// The corresponding value of the raw type.
    var rawValue: Int {
        switch self {
        case .bundleIdentifierNotAvailable:
            return -1000

        case .platformNotSupported:
            return -1100

        case .platformVersionNotSupported:
            return -1200

        case .lowerSchemaVersion:
            return -1300

        case .datasourceNotAvailable:
            return -2000

        case .createFailed:
            return -3000

        case .readFailed:
            return -3001

        case .updateFailed:
            return -3002

        case .deleteFailed:
            return -3003

        case .duplicateObject:
            return -3100

        case .directoryURLNotAvailable:
            return -4000

        case .directoryFullURLNotAvailable:
            return -4001

        case .directoryListNotAvailable:
            return -4100

        case .databaseNotAvailable:
            return -8000

        case .unknownRepresentation:
            return -9000
        }
    }
}

// MARK: - Equatable

extension ErrorProtocol : Equatable {

    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    /// - Returns: `true` if the first argument equals the second argument;
    ///            `false` if not.
    public static func == (lhs: ErrorProtocol, rhs: ErrorProtocol) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

// MARK: - Hashable

extension ErrorProtocol : Hashable {

    /// Hashes the essential components of this value by feeding them into
    /// the given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components
    /// compared in your type's `==` operator implementation. Call
    /// `hasher.combine(_:)` with each of these components.
    ///
    /// - Important: Never call `finalize()` on `hasher`. Doing so may
    ///              become a compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///                     of this instance.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

// MARK: - CaseIterable

extension ErrorProtocol : CaseIterable {

    /// A collection of all values of this type.
    public static var allCases: [ErrorProtocol] {
        return entities.values
    }

    fileprivate static var entities = EntityCollection<ErrorProtocol>()

    /// Setup entities before ErrorProtocol receives its first message.
    public static func setupEntities() {

        ErrorProtocol.entities.add(value: ErrorProtocol.bundleIdentifierNotAvailable.rawValue, forKey: ErrorProtocol.bundleIdentifierNotAvailable)
        ErrorProtocol.entities.add(value: ErrorProtocol.platformNotSupported(detail: "").rawValue, forKey: ErrorProtocol.platformNotSupported(detail: ""))
        ErrorProtocol.entities.add(value: ErrorProtocol.platformVersionNotSupported(detail: "").rawValue, forKey: ErrorProtocol.platformVersionNotSupported(detail: ""))
        ErrorProtocol.entities.add(value: ErrorProtocol.lowerSchemaVersion(detail: "").rawValue, forKey: ErrorProtocol.lowerSchemaVersion(detail: ""))
        ErrorProtocol.entities.add(value: ErrorProtocol.datasourceNotAvailable(detail: "").rawValue, forKey: ErrorProtocol.datasourceNotAvailable(detail: ""))
        ErrorProtocol.entities.add(value: ErrorProtocol.createFailed(detail: "").rawValue, forKey: ErrorProtocol.createFailed(detail: ""))
        ErrorProtocol.entities.add(value: ErrorProtocol.readFailed(detail: "").rawValue, forKey: ErrorProtocol.readFailed(detail: ""))
        ErrorProtocol.entities.add(value: ErrorProtocol.updateFailed(detail: "").rawValue, forKey: ErrorProtocol.updateFailed(detail: ""))
        ErrorProtocol.entities.add(value: ErrorProtocol.deleteFailed(detail: "").rawValue, forKey: ErrorProtocol.deleteFailed(detail: ""))
        ErrorProtocol.entities.add(value: ErrorProtocol.duplicateObject(detail: "").rawValue, forKey: ErrorProtocol.duplicateObject(detail: ""))
        ErrorProtocol.entities.add(value: ErrorProtocol.directoryURLNotAvailable.rawValue, forKey: ErrorProtocol.directoryURLNotAvailable)
        ErrorProtocol.entities.add(value: ErrorProtocol.directoryFullURLNotAvailable.rawValue, forKey: ErrorProtocol.directoryFullURLNotAvailable)
        ErrorProtocol.entities.add(value: ErrorProtocol.directoryListNotAvailable(detail: "").rawValue, forKey: ErrorProtocol.directoryListNotAvailable(detail: ""))
        ErrorProtocol.entities.add(value: ErrorProtocol.databaseNotAvailable.rawValue, forKey: ErrorProtocol.databaseNotAvailable)
        ErrorProtocol.entities.add(value: ErrorProtocol.unknownRepresentation.rawValue, forKey: ErrorProtocol.unknownRepresentation)
    }
}

// MARK: - CustomNSError

extension ErrorProtocol : CustomNSError {

    /// The key of the error.
    static var key: String {
        return "Error"
    }

    /// The domain of the error.
    static var errorDomain: String {
        return "com.sentulasia.DataStoreManager.error"
    }

    /// The error code within the given domain.
    var errorCode: Int {
        return rawValue
    }

    /// The user-info dictionary.
    var errorUserInfo: [String : Any] {
        return [
            NSLocalizedDescriptionKey : NSLocalizedString(ErrorProtocol.key, value: debugDescription, comment: description)
        ]
    }
}

// MARK: - LocalizedError

extension ErrorProtocol : LocalizedError {

    /// A localized message describing what error occurred.
    var errorDescription: String? {
        switch self {
        case .bundleIdentifierNotAvailable:
            let message = description
            return NSLocalizedString(message, comment: description)

        case .platformNotSupported(let detail):
            let message = detail.isEmpty ? description : description + " " + detail
            return NSLocalizedString(message, comment: description)

        case .platformVersionNotSupported(let detail):
            let message = detail.isEmpty ? description : description + " " + detail
            return NSLocalizedString(message, comment: description)

        case .lowerSchemaVersion(let detail):
            let message = detail.isEmpty ? description : description + " " + detail
            return NSLocalizedString(message, comment: description)

        case .datasourceNotAvailable(let detail):
            let message = detail.isEmpty ? description : description + " " + detail
            return NSLocalizedString(message, comment: description)

        case .createFailed(let detail):
            let message = detail.isEmpty ? description : description + " " + detail
            return NSLocalizedString(message, comment: description)

        case .updateFailed(let detail):
            let message = detail.isEmpty ? description : description + " " + detail
            return NSLocalizedString(message, comment: description)

        case .readFailed(let detail):
            let message = detail.isEmpty ? description : description + " " + detail
            return NSLocalizedString(message, comment: description)

        case .deleteFailed(let detail):
            let message = detail.isEmpty ? description : description + " " + detail
            return NSLocalizedString(message, comment: description)

        case .duplicateObject(let detail):
            let message = detail.isEmpty ? description : description + " " + detail
            return NSLocalizedString(message, comment: description)

        case .directoryURLNotAvailable:
            let message = description
            return NSLocalizedString(message, comment: description)

        case .directoryFullURLNotAvailable:
            let message = description
            return NSLocalizedString(message, comment: description)

        case .directoryListNotAvailable(let detail):
            let message = detail.isEmpty ? description : description + " " + detail
            return NSLocalizedString(message, comment: description)

        case .databaseNotAvailable:
            let message = description
            return NSLocalizedString(message, comment: description)

        case .unknownRepresentation:
            let message = description
            return NSLocalizedString(message, comment: description)
        }
    }
}

// MARK: - CustomStringConvertible

extension ErrorProtocol : CustomStringConvertible {

    /// A textual representation of this instance.
    var description: String {
        switch self {
        case .bundleIdentifierNotAvailable:
            return "The bundle identifier cannot be retrieved."

        case .platformNotSupported:
            return "The platform cannot use this property or function."

        case .platformVersionNotSupported:
            return "The platform version cannot use this property or function."

        case .lowerSchemaVersion:
            return "Current schema version is lower than old schema version."

        case .datasourceNotAvailable:
            return "The data source cannot be retrieved."

        case .createFailed:
            return "The object cannot be created."

        case .readFailed:
            return "The object cannot be retrieved."

        case .updateFailed:
            return "The object cannot be updated."

        case .deleteFailed:
            return "The object cannot be deleted."

        case .duplicateObject:
            return "The specified object already exists."

        case .directoryURLNotAvailable:
            return "The directory URL cannot be retrieved."

        case .directoryFullURLNotAvailable:
            return "The directory URL with path cannot be retrieved."

        case .directoryListNotAvailable:
            return "Contents of directory cannot be retrieved."

        case .databaseNotAvailable:
            return "The database cannot be retrieved."

        case .unknownRepresentation:
            return "Use a representation that was unknown when this code was compiled."
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension ErrorProtocol : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    var debugDescription: String {
        return errorDescription ?? "Unexpected error has occurred."
    }
}

/// Information about an error condition including a domain, a
/// domain-specific error code, and application-specific information.
///
/// Objective-C methods can signal an error condition by returning an
/// `NSError` object by reference, which provides additional information
/// about the kind of error and any underlying cause, if one can be
/// determined. An `NSError` object may also provide localized error
/// descriptions suitable for display to the user in its user info
/// dictionary. See
/// [Error Handling Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ErrorHandlingCocoa/ErrorHandling/ErrorHandling.html#//apple_ref/doc/uid/TP40001806)
/// for more information.
class ErrorObject : NSError {

    // MARK: - Initializers

    /// Returns an NSError object initialized for a given error type.
    ///
    /// - Parameters:
    ///   - type: An error object type.
    ///   - comment: The comment to place above the key-value pair in the
    ///              strings file.
    /// - Returns: An `NSError` object initialized for domain with the
    ///            specified error code and the dictionary of arbitrary data
    ///            userInfo.
    required init(protocol: ErrorProtocol) {
        super.init(domain: ErrorProtocol.errorDomain, code: `protocol`.rawValue, userInfo: `protocol`.errorUserInfo)
    }

    /// Returns an NSError object initialized for a given code.
    ///
    /// - Parameters:
    ///   - code: The error code for the error.
    ///   - value: The value to return if key is nil or if a localized
    ///            string for key can’t be found in the table.
    ///   - comment: The comment to place above the key-value pair in the
    ///              strings file.
    /// - Returns: An `NSError` object initialized for domain with the
    ///            specified error code and the dictionary of arbitrary data
    ///            userInfo.
    required init(code: Int, value: String) {
        let userInfo =  [
            NSLocalizedDescriptionKey: NSLocalizedString(ErrorProtocol.key, value: value, comment: value)
        ]
        super.init(domain: ErrorProtocol.errorDomain, code: code, userInfo: userInfo)
    }

    /// Returns an object initialized from data in a given unarchiver.
    ///
    /// - Parameter aDecoder: An unarchiver object.
    /// - Returns: `self`, initialized using the data in decoder.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
