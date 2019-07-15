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

/// Constants that provide information regarding authentication type of data
/// store manager.
@objc public enum DataStoreAuthenticationType : Int {

    // MARK: - Enumerations

    /// The authentication type NTLM.
    case ntlm

    /// The authentication type MSN.
    case msn

    /// The authentication type DPA.
    case dpa

    /// The authentication type RPA.
    case rpa

    /// The authentication type HTTPBasic.
    case httpBasic

    /// The authentication type HTTPDigest.
    case httpDigest

    /// The authentication type HTMLForm.
    case htmlForm

    /// The authentication type Default.
    case `default`
}

// MARK: - RawRepresentable

extension DataStoreAuthenticationType : RawRepresentable, CaseIterable {

    // MARK: Initializers

    /// Creates a new instance with the specified raw value.
    ///
    /// If there is no value of the type that corresponds with the specified
    /// string value, this initializer returns nil.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    public init?(rawValue: String) {
        for type in DataStoreAuthenticationType.allCases {
            if type.rawValue == rawValue {
                self = type
                return
            }
        }
        return nil
    }

    // MARK: Properties

    /// The corresponding value of the raw type.
    public var rawValue: String {
        switch self {
        case .ntlm:
            return String(kSecAttrAuthenticationTypeNTLM)

        case .msn:
            return String(kSecAttrAuthenticationTypeMSN)

        case .dpa:
            return String(kSecAttrAuthenticationTypeDPA)

        case .rpa:
            return String(kSecAttrAuthenticationTypeRPA)

        case .httpBasic:
            return String(kSecAttrAuthenticationTypeHTTPBasic)

        case .httpDigest:
            return String(kSecAttrAuthenticationTypeHTTPDigest)

        case .htmlForm:
            return String(kSecAttrAuthenticationTypeHTMLForm)

        case .default:
            return String(kSecAttrAuthenticationTypeDefault)

        @unknown case _:
            assertionFailure("Use a representation that was unknown when this code was compiled.")
            return "Use a representation that was unknown when this code was compiled."
        }
    }
}

// MARK: - CustomStringConvertible

extension DataStoreAuthenticationType : CustomStringConvertible {

    /// A textual representation of this instance.
    public var description: String {
        switch self {
        case .ntlm:
            return "NTLM"

        case .msn:
            return "MSN"

        case .dpa:
            return "DPA"

        case .rpa:
            return "RPA"

        case .httpBasic:
            return "HTTPBasic"

        case .httpDigest:
            return "HTTPDigest"

        case .htmlForm:
            return "HTMLForm"

        case .default:
            return "Default"

        @unknown case _:
            assertionFailure("Use a representation that was unknown when this code was compiled.")
            return "Use a representation that was unknown when this code was compiled."
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension DataStoreAuthenticationType : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        return description
    }
}
