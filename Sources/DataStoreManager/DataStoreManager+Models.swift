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

// MARK: - Models

/// Constants that provide information regarding storage type of data store manager.
@objc public enum DataStoreStorageType : Int {

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
    case genericPasswordKeychain

    case internetPasswordKeychain

    /// The storage type [NSUbiquitousKeyValueStore](apple-reference-documentation://hskNNwzU6H).
    case ubiquitousKeyValueStore
}

extension DataStoreStorageType : RawRepresentable, CustomStringConvertible, CustomDebugStringConvertible, CaseIterable {

    /// Creates a new instance with the specified raw value.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    ///
    /// If there is no value of the type that corresponds with the specified string value, this initializer returns nil. For example:
    /// ```
    /// print(DataStoreStorageType(rawValue: "UserDefaults"))
    /// // Prints "Optional("DataStoreStorageType.userDefaults")"
    ///
    /// print(DataStoreStorageType(rawValue: "Invalid"))
    /// // Prints "nil"
    /// ```
    public init?(rawValue: String) {
        for type in DataStoreStorageType.allCases {
            if type.rawValue == rawValue {
                self = type
            }
        }
        return nil
    }

    /// The raw representation of the value.
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

        case .genericPasswordKeychain:
            return "SecItem.genericPassword"

        case .internetPasswordKeychain:
            return "SecItem.internetPassword"

        case .ubiquitousKeyValueStore:
            return "NSUbiquitousKeyValueStore"

        @unknown case _:
            assertionFailure("Use a representation that was unknown when this code was compiled.")
            return ""
        }
    }

    /// This `String` object.
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

        case .genericPasswordKeychain:
            return "SecItem"

        case .internetPasswordKeychain:
            return "SecItem"

        case .ubiquitousKeyValueStore:
            return "NSUbiquitousKeyValueStore"

        @unknown case _:
            assertionFailure("Use a representation that was unknown when this code was compiled.")
            return ""
        }
    }

    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        return description
    }
}

@objc public enum DataStoreProtocolType : Int {

    case ftp
    case ftpAccount
    case http
    case irc
    case nntp
    case pop3
    case smtp
    case socks
    case imap
    case ldap
    case appleTalk
    case afp
    case telnet
    case ssh
    case ftps
    case https
    case httpProxy
    case httpsProxy
    case ftpProxy
    case smb
    case rtsp
    case rtspProxy
    case daap
    case eppc
    case ipp
    case nntps
    case ldaps
    case telnetS
    case imaps
    case ircs
    case pop3S
}


extension DataStoreProtocolType: RawRepresentable, CustomStringConvertible, CustomDebugStringConvertible, CaseIterable {

    /// Creates a new instance with the specified raw value.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    ///
    /// If there is no value of the type that corresponds with the specified string value, this initializer returns nil. For example:
    /// ```
    /// print(DataStoreProtocolType(rawValue: "FTP"))
    /// // Prints "Optional("DataStoreStorageType.ftp")"
    ///
    /// print(DataStoreProtocolType(rawValue: "Invalid"))
    /// // Prints "nil"
    /// ```
    public init?(rawValue: String) {
        for type in DataStoreProtocolType.allCases {
            if type.rawValue == rawValue {
                self = type
            }
        }
        return nil
    }

    /// The raw representation of the value.
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
            return ""
        }
    }

    /// This `String` object.
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
            return ""
        }
    }

    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        return description
    }
}

@objc enum ErrorType : Int {
    case bundleIdentifierNotAvailable       = -1000
    case lowerSchemaVersion                 = -1100
    case datasourceNotAvailable             = -2000
    case createFailed                       = -3000
    case updateFailed                       = -3001
    case readFailed                         = -3002
    case deleteFailed                       = -3003
    case duplicateObject                    = -3100
    case documentURLNotAvailable            = -4000
    case documentFullURLNotAvailable        = -4001
    case documentListNotAvailable           = -4100
    case databaseNotAvailable               = -8000
    case recordNotAvailable                 = -8001
    case unknownRepresentation              = -9998
    case unexpectedError                    = -9999
}

extension ErrorType : CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        switch self {
        case .bundleIdentifierNotAvailable:
            return "The bundle identifier cannot be retrieved."

        case .lowerSchemaVersion:
            return "Current schema version is lower than old schema version"

        case .datasourceNotAvailable:
            return "The data source cannot be retrieved."

        case .createFailed:
            return "The object cannot be created."

        case .updateFailed:
            return "The object cannot be updated."

        case .readFailed:
            return "The object cannot be retrieved."

        case .deleteFailed:
            return "The object cannot be deleted."

        case .duplicateObject:
            return "The specified object already exists."

        case .documentURLNotAvailable:
            return "The document URL cannot be retrieved."

        case .documentFullURLNotAvailable:
            return "The document URL with path cannot be retrieved."

        case .documentListNotAvailable:
            return "Contents of directory cannot be retrieved."

        case .databaseNotAvailable:
            return "The database cannot be retrieved."

        case .recordNotAvailable:
            return "The record cannot be retrieved."

        case .unknownRepresentation:
            return "Use a representation that was unknown when this code was compiled."

        case .unexpectedError:
            return "Unexpected error has occurred."

        @unknown case _:
            return "Use a representation that was unknown when this code was compiled."
        }
    }

    var debugDescription: String {
        return description
    }
}

/// Information about an error condition including a domain, a domain-specific error code, and application-specific information.
///
/// Objective-C methods can signal an error condition by returning an `NSError` object by reference, which provides additional
/// information about the kind of error and any underlying cause, if one can be determined. An `NSError` object may also provide
/// localized error descriptions suitable for display to the user in its user info dictionary. See
/// [Error Handling Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ErrorHandlingCocoa/ErrorHandling/ErrorHandling.html#//apple_ref/doc/uid/TP40001806)
/// for more information.
class DataStoreError: NSError {
    required init(type: ErrorType, comment: String = "") {
        let userInfo =  [
            NSLocalizedDescriptionKey: NSLocalizedString("Error", value: type.description, comment: comment),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("Error", value: type.debugDescription, comment: comment)
            ]
        super.init(domain: "com.sentulasia.DataStoreManager.error", code: type.rawValue, userInfo: userInfo)
    }

    required init(code: Int, value: String, comment: String = "") {
        let userInfo =  [
            NSLocalizedDescriptionKey: NSLocalizedString("Error", value: value, comment: comment),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("Error", value: value, comment: comment)
        ]
        super.init(domain: "com.sentulasia.DataStoreManager.error", code: code, userInfo: userInfo)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
