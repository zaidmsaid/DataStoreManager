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
@objc public enum DataStoreStorageType : Int {

    // MARK: - Enumerations

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

    /// The storage type [SecItem](https://developer.apple.com/documentation/security/keychain_services)
    /// with [kSecClass](https://developer.apple.com/documentation/security/ksecclass) value defined as
    /// [kSecClassGenericPassword](https://developer.apple.com/documentation/security/ksecclassgenericpassword).
    case genericKeychain

    /// The storage type [SecItem](https://developer.apple.com/documentation/security/keychain_services)
    /// with [kSecClass](https://developer.apple.com/documentation/security/ksecclass) value defined as
    /// [kSecClassGenericPassword](https://developer.apple.com/documentation/security/ksecclassinternetpassword).
    case internetKeychain

    case privateCloudDatabase

    case publicCloudDatabase

    case sharedCloudDatabase

    /// The storage type [NSUbiquitousKeyValueStore](apple-reference-documentation://hskNNwzU6H).
    case ubiquitousKeyValueStore
}

extension DataStoreStorageType : RawRepresentable, CaseIterable, CustomStringConvertible, CustomDebugStringConvertible {

    // MARK: - Init

    /// Creates a new instance with the specified raw value.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    ///
    /// If there is no value of the type that corresponds with the specified string value, this initializer returns nil.
    public init?(rawValue: String) {
        for type in DataStoreStorageType.allCases {
            if type.rawValue == rawValue {
                self = type
            }
        }
        return nil
    }

    // MARK: - Properties

    /// The corresponding value of the raw type.
    public var rawValue: String {
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

        case .genericKeychain:
            return "SecItem.kSecClassGenericPassword"

        case .internetKeychain:
            return "SecItem.kSecClassInternetPassword"

        case .privateCloudDatabase:
            return "CKContainer.privateCloudDatabase"

        case .publicCloudDatabase:
            return "CKContainer.publicCloudDatabase"

        case .sharedCloudDatabase:
            return "CKContainer.sharedCloudDatabase"

        case .ubiquitousKeyValueStore:
            return "NSUbiquitousKeyValueStore"

        @unknown case _:
            assertionFailure("Use a representation that was unknown when this code was compiled.")
            return "Use a representation that was unknown when this code was compiled."
        }
    }

    /// A textual representation of this instance.
    public var description: String {
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

        @unknown case _:
            assertionFailure("Use a representation that was unknown when this code was compiled.")
            return "Use a representation that was unknown when this code was compiled."
        }
    }

    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        return description
    }
}

/// Constants that provide information regarding protocol type of data store manager.
@objc public enum DataStoreProtocolType : Int {

    // MARK: - Enumerations

    /// The protocol type FTP.
    case ftp

    /// The protocol type FTPAccount.
    case ftpAccount

    /// The protocol type HTTP.
    case http

    /// The protocol type IRC.
    case irc

    /// The protocol type NNTP.
    case nntp

    /// The protocol type POP3.
    case pop3

    /// The protocol type SMTP.
    case smtp

    /// The protocol type SOCKS.
    case socks

    /// The protocol type IMAP.
    case imap

    /// The protocol type LDAP.
    case ldap

    /// The protocol type AppleTalk.
    case appleTalk

    /// The protocol type AFP.
    case afp

    /// The protocol type Telnet.
    case telnet

    /// The protocol type SSH.
    case ssh

    /// The protocol type FTPS.
    case ftps

    /// The protocol type HTTPS.
    case https

    /// The protocol type HTTPProxy.
    case httpProxy

    /// The protocol type HTTPSProxy.
    case httpsProxy

    /// The protocol type FTPProxy.
    case ftpProxy

    /// The protocol type SMB.
    case smb

    /// The protocol type RTSP.
    case rtsp

    /// The protocol type RTSPProxy.
    case rtspProxy

    /// The protocol type DAAP.
    case daap

    /// The protocol type EPPC.
    case eppc

    /// The protocol type IPP.
    case ipp

    /// The protocol type NNTPS.
    case nntps

    /// The protocol type LDAPS.
    case ldaps

    /// The protocol type TelnetS.
    case telnetS

    /// The protocol type IMAPS.
    case imaps

    /// The protocol type IRCS.
    case ircs

    /// The protocol type POP3S.
    case pop3S
}

extension DataStoreProtocolType: RawRepresentable, CaseIterable, CustomStringConvertible, CustomDebugStringConvertible {

    // MARK: - Init

    /// Creates a new instance with the specified raw value.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    ///
    /// If there is no value of the type that corresponds with the specified string value, this initializer returns nil.
    public init?(rawValue: String) {
        for type in DataStoreProtocolType.allCases {
            if type.rawValue == rawValue {
                self = type
            }
        }
        return nil
    }

    // MARK: - Properties

    /// The corresponding value of the raw type.
    public var rawValue: String {
        switch self {
        case .ftp:
            return String(kSecAttrProtocolFTP)

        case .ftpAccount:
            return String(kSecAttrProtocolFTPAccount)

        case .http:
            return String(kSecAttrProtocolHTTP)

        case .irc:
            return String(kSecAttrProtocolIRC)

        case .nntp:
            return String(kSecAttrProtocolNNTP)

        case .pop3:
            return String(kSecAttrProtocolPOP3)

        case .smtp:
            return String(kSecAttrProtocolSMTP)

        case .socks:
            return String(kSecAttrProtocolSOCKS)

        case .imap:
            return String(kSecAttrProtocolIMAP)

        case .ldap:
            return String(kSecAttrProtocolLDAP)

        case .appleTalk:
            return String(kSecAttrProtocolAppleTalk)

        case .afp:
            return String(kSecAttrProtocolAFP)

        case .telnet:
            return String(kSecAttrProtocolTelnet)

        case .ssh:
            return String(kSecAttrProtocolSSH)

        case .ftps:
            return String(kSecAttrProtocolFTPS)

        case .https:
            return String(kSecAttrProtocolHTTPS)

        case .httpProxy:
            return String(kSecAttrProtocolHTTPProxy)

        case .httpsProxy:
            return String(kSecAttrProtocolHTTPSProxy)

        case .ftpProxy:
            return String(kSecAttrProtocolFTPProxy)

        case .smb:
            return String(kSecAttrProtocolSMB)

        case .rtsp:
            return String(kSecAttrProtocolRTSP)

        case .rtspProxy:
            return String(kSecAttrProtocolRTSPProxy)

        case .daap:
            return String(kSecAttrProtocolDAAP)

        case .eppc:
            return String(kSecAttrProtocolEPPC)

        case .ipp:
            return String(kSecAttrProtocolIPP)

        case .nntps:
            return String(kSecAttrProtocolNNTPS)

        case .ldaps:
            return String(kSecAttrProtocolLDAPS)

        case .telnetS:
            return String(kSecAttrProtocolTelnetS)

        case .imaps:
            return String(kSecAttrProtocolIMAPS)

        case .ircs:
            return String(kSecAttrProtocolIRCS)

        case .pop3S:
            return String(kSecAttrProtocolPOP3S)

        @unknown case _:
            assertionFailure("Use a representation that was unknown when this code was compiled.")
            return "Use a representation that was unknown when this code was compiled."
        }
    }

    /// A textual representation of this instance.
    public var description: String {
        switch self {
        case .ftp:
            return "FTP"

        case .ftpAccount:
            return "FTPAccount"

        case .http:
            return "HTTP"

        case .irc:
            return "IRC"

        case .nntp:
            return "NNTP"

        case .pop3:
            return "POP3"

        case .smtp:
            return "SMTP"

        case .socks:
            return "SOCKS"

        case .imap:
            return "IMAP"

        case .ldap:
            return "LDAP"

        case .appleTalk:
            return "AppleTalk"

        case .afp:
            return "AFP"

        case .telnet:
            return "Telnet"

        case .ssh:
            return "SSH"

        case .ftps:
            return "FTPS"

        case .https:
            return "HTTPS"

        case .httpProxy:
            return "HTTPProxy"

        case .httpsProxy:
            return "HTTPSProxy"

        case .ftpProxy:
            return "FTPProxy"

        case .smb:
            return "SMB"

        case .rtsp:
            return "RTSP"

        case .rtspProxy:
            return "RTSPProxy"

        case .daap:
            return "DAAP"

        case .eppc:
            return "EPPC"

        case .ipp:
            return "IPP"

        case .nntps:
            return "NNTPS"

        case .ldaps:
            return "LDAPS"

        case .telnetS:
            return "TelnetS"

        case .imaps:
            return "IMAPS"

        case .ircs:
            return "IRCS"

        case .pop3S:
            return "POP3S"

        @unknown case _:
            assertionFailure("Use a representation that was unknown when this code was compiled.")
            return "Use a representation that was unknown when this code was compiled."
        }
    }

    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        return description
    }
}

/// Constants that provide information regarding authentication type of data store manager.
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

extension DataStoreAuthenticationType: RawRepresentable, CaseIterable, CustomStringConvertible, CustomDebugStringConvertible {

    // MARK: - Init

    /// Creates a new instance with the specified raw value.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    ///
    /// If there is no value of the type that corresponds with the specified string value, this initializer returns nil.
    public init?(rawValue: String) {
        for type in DataStoreAuthenticationType.allCases {
            if type.rawValue == rawValue {
                self = type
            }
        }
        return nil
    }

    // MARK: - Properties

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

    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        return description
    }
}

/// A type representing an error value.
enum ErrorProtocol : Error {

    // MARK: - Enumerations

    /// The bundle identifier cannot be retrieved.
    case bundleIdentifierNotAvailable

    /// Current schema version is lower than old schema version.
    ///
    /// - Parameter detail: The detail to place after description of the error description.
    case lowerSchemaVersion(detail: String)

    /// The data source cannot be retrieved.
    ///
    /// - Parameter detail: The detail to place after description of the error description.
    case datasourceNotAvailable(detail: String)

    /// The object cannot be created.
    ///
    /// - Parameter detail: The detail to place after description of the error description.
    case createFailed(detail: String)

    /// The object cannot be retrieved.
    ///
    /// - Parameter detail: The detail to place after description of the error description.
    case readFailed(detail: String)

    /// The object cannot be updated.
    ///
    /// - Parameter detail: The detail to place after description of the error description.
    case updateFailed(detail: String)

    /// The object cannot be deleted.
    ///
    /// - Parameter detail: The detail to place after description of the error description.
    case deleteFailed(detail: String)

    /// The specified object already exists.
    ///
    /// - Parameter detail: The detail to place after description of the error description.
    case duplicateObject(detail: String)

    /// The directory URL cannot be retrieved.
    case directoryURLNotAvailable

    /// The directory URL with path cannot be retrieved.
    case directoryFullURLNotAvailable

    /// Contents of directory cannot be retrieved.
    ///
    /// - Parameter detail: The detail to place after description of the error description.
    case directoryListNotAvailable(detail: String)

    /// The database cannot be retrieved.
    case databaseNotAvailable

    /// Use a representation that was unknown when this code was compiled.
    case unknownRepresentation
}

extension ErrorProtocol : RawRepresentable, CaseIterable, CustomNSError, LocalizedError, CustomStringConvertible, CustomDebugStringConvertible {

    // MARK: - Init

    /// Creates a new instance with the specified raw value.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    ///
    /// If there is no value of the type that corresponds with the specified string value, this initializer returns nil.
    init?(rawValue: Int) {
        for `protocol` in ErrorProtocol.allCases {
            if `protocol`.rawValue == rawValue {
                self = `protocol`
            }
        }
        return nil
    }

    // MARK: - Properties

    /// The corresponding value of the raw type.
    var rawValue: Int {
        switch self {
        case .bundleIdentifierNotAvailable:
            return -1000

        case .lowerSchemaVersion:
            return -1100

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

    static var allCases: [ErrorProtocol] {
        return [
            .bundleIdentifierNotAvailable,
            .lowerSchemaVersion(detail: ""),
            .datasourceNotAvailable(detail: ""),
            .createFailed(detail: ""),
            .readFailed(detail: ""),
            .updateFailed(detail: ""),
            .deleteFailed(detail: ""),
            .duplicateObject(detail: ""),
            .directoryURLNotAvailable,
            .directoryFullURLNotAvailable,
            .directoryListNotAvailable(detail: ""),
            .databaseNotAvailable,
            .unknownRepresentation
        ]
    }

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
            NSLocalizedDescriptionKey : NSLocalizedString(ErrorProtocol.key, value: errorDescription ?? "Unexpected error has occurred.", comment: description)
        ]
    }

    /// A localized message describing what error occurred.
    var errorDescription: String? {
        switch self {
        case .bundleIdentifierNotAvailable:
            let message = description
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

    /// A textual representation of this instance.
    var description: String {
        switch self {
        case .bundleIdentifierNotAvailable:
            return "The bundle identifier cannot be retrieved."

        case .lowerSchemaVersion:
            return "Current schema version is lower than old schema version."

        case .datasourceNotAvailable:
            return "Current schema version is lower than old schema version."

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

    /// A textual representation of this instance, suitable for debugging.
    var debugDescription: String {
        switch self {
        case .bundleIdentifierNotAvailable:
            return "The bundle identifier cannot be retrieved."

        case .lowerSchemaVersion:
            return "Current schema version is lower than old schema version."

        case .datasourceNotAvailable:
            return "Current schema version is lower than old schema version."

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

extension DataStoreManager {

    /// Information about an error condition including a domain, a domain-specific error code, and application-specific information.
    ///
    /// Objective-C methods can signal an error condition by returning an `NSError` object by reference, which provides additional
    /// information about the kind of error and any underlying cause, if one can be determined. An `NSError` object may also provide
    /// localized error descriptions suitable for display to the user in its user info dictionary. See
    /// [Error Handling Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ErrorHandlingCocoa/ErrorHandling/ErrorHandling.html#//apple_ref/doc/uid/TP40001806)
    /// for more information.
    class ErrorObject: NSError {

        // MARK: - Init

        /// Returns an NSError object initialized for a given error type.
        ///
        /// - Parameters:
        ///   - type: An error object type.
        ///   - comment: The comment to place above the key-value pair in the strings file.
        /// - Returns: An `NSError` object initialized for domain with the specified error code and the dictionary of arbitrary data userInfo.
        required init(protocol: ErrorProtocol) {
            super.init(domain: ErrorProtocol.errorDomain, code: `protocol`.rawValue, userInfo: `protocol`.errorUserInfo)
        }

        /// Returns an NSError object initialized for a given code.
        ///
        /// - Parameters:
        ///   - code: The error code for the error.
        ///   - value: The value to return if key is nil or if a localized string for key can’t be found in the table.
        ///   - comment: The comment to place above the key-value pair in the strings file.
        /// - Returns: An `NSError` object initialized for domain with the specified error code and the dictionary of arbitrary data userInfo.
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
}
