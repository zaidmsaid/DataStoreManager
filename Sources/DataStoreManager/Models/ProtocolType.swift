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

extension DataStoreProtocolType : RawRepresentable, CaseIterable {

    // MARK: - Initializers

    /// Creates a new instance with the specified raw value.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    ///
    /// If there is no value of the type that corresponds with the specified string value, this initializer returns nil.
    public init?(rawValue: String) {
        for type in DataStoreProtocolType.allCases {
            if type.rawValue == rawValue {
                self = type
                return
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
}

extension DataStoreProtocolType : CustomStringConvertible {

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
}

extension DataStoreProtocolType : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        return description
    }
}
