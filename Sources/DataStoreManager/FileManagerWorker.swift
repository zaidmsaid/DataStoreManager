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

#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#else
import Cocoa
#endif

// MARK: - Enumerations

/// Constants that provide information regarding directory of file
/// manager worker.
@objc enum Directory: Int {

    /// The directory document directory (`~/Documents`).
    case documentDirectory

    /// The directory user home directories (`/Users`).
    case userDirectory

    /// The directory library (`/Library`).
    case libraryDirectory

    /// The directory supported applications (`/Applications`).
    case applicationDirectory

    /// The directory core services
    /// (`/System/Library/CoreServices`).
    case coreServiceDirectory

    /// The directory the temporary directory for the current user
    /// (`/tmp`).
    case temporaryDirectory
}

// MARK: - FileManager

extension DataStoreManager {

    /// An interface to the FileManager.
    internal class FileManagerWorker {

        // MARK: - Properties

        private lazy var fileManager: FileManager = {
            return FileManager.default
        }()

        // MARK: - CRUD

        func create(
            object: Any,
            forKey fileName: String,
            forDirectory directory: Directory,
            completionHandler: @escaping (
            _ isSuccessful: Bool,
            _ objectID: Any?,
            _ error: Error?
            ) -> Void
            ) {

            guard let url = getURL(for: directory, withFileName: fileName) else {
                let error = ErrorObject(protocol: .directoryURLNotAvailable)
                completionHandler(false, nil, error)
                return
            }

            let filePath = url.path + "/" + fileName
            let data = (object as? AnySubclass)?.toData()
            let isSuccessful = fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
            completionHandler(isSuccessful, nil, nil)
        }

        func read(
            forKey fileName: String,
            forDirectory directory: Directory,
            completionHandler: @escaping (
            _ object: Any?,
            _ objectID: Any?,
            _ error: Error?
            ) -> Void
            ) {

            guard let url = getURL(for: directory, withFileName: fileName) else {
                let error = ErrorObject(protocol: .directoryURLNotAvailable)
                completionHandler(nil, nil, error)
                return
            }

            let filePath = url.path + "/" + fileName
            let object = fileManager.contents(atPath: filePath)
            completionHandler(object, nil, nil)
        }

        func update(
            object: Any,
            forKey fileName: String,
            forDirectory directory: Directory,
            completionHandler: @escaping (
            _ isSuccessful: Bool,
            _ objectID: Any?,
            _ error: Error?
            ) -> Void
            ) {

            // TODO: change to update file logic
            guard let url = getURL(for: directory, withFileName: fileName) else {
                let error = ErrorObject(protocol: .directoryURLNotAvailable)
                completionHandler(false, nil, error)
                return
            }

            let filePath = url.path + "/" + fileName
            let data = (object as? AnySubclass)?.toData()
            let isSuccessful = fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
            completionHandler(isSuccessful, nil, nil)
        }

        func delete(
            forKey fileName: String,
            forDirectory directory: Directory,
            completionHandler: @escaping (
            _ isSuccessful: Bool,
            _ objectID: Any?,
            _ error: Error?
            ) -> Void
            ) {

            guard let url = getURL(for: directory, withFileName: fileName)?.appendingPathComponent(fileName) else {
                let error = ErrorObject(protocol: .directoryFullURLNotAvailable)
                completionHandler(false, nil, error)
                return
            }

            do {
                try fileManager.removeItem(at: url)
                completionHandler(true, nil, nil)

            } catch {
                completionHandler(false, nil, error)
            }
        }

        func deleteAll(
            forDirectory directory: Directory,
            completionHandler: @escaping (
            _ isSuccessful: Bool,
            _ objectID: Any?,
            _ error: Error?
            ) -> Void
            ) {

            guard let url = getURL(for: directory) else {
                let error = ErrorObject(protocol: .directoryURLNotAvailable)
                completionHandler(false, nil, error)
                return
            }

            if let files = list(at: url) {
                for fileName in files {
                    delete(forKey: fileName, forDirectory: directory, completionHandler: completionHandler)
                }
            } else {
                let detail = "The URL is \(url.description)."
                let error = ErrorObject(protocol: .directoryListNotAvailable(detail: detail))
                completionHandler(false, nil, error)
            }
        }

        // MARK: - Helpers

        private final func getPathComponent(
            forKey fileName: String
            ) -> [String]? {

            // Check if file should contain in a folder.
            if fileName.contains("/") {
                var paths = fileName.components(separatedBy: "/")
                paths.removeLast() // last is the actual fileName
                return paths
            }
            return nil
        }

        private final func getURL(
            for directory: Directory,
            withFileName fileName: String? = nil
            ) -> URL? {

            var url: URL?
            switch directory {
            case .documentDirectory:
                url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first

            case .userDirectory:
                url = fileManager.urls(for: .userDirectory, in: .userDomainMask).first

            case .libraryDirectory:
                url = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first

            case .applicationDirectory:
                url = fileManager.urls(for: .applicationDirectory, in: .userDomainMask).first

            case .coreServiceDirectory:
                url = fileManager.urls(for: .coreServiceDirectory, in: .userDomainMask).first

            case .temporaryDirectory:
                if #available(iOS 10.0, macOS 10.12, watchOSApplicationExtension 3.0, tvOS 10.0, *) {
                    url = fileManager.temporaryDirectory

                } else {
                    url = URL(fileURLWithPath: NSTemporaryDirectory())
                }

            @unknown case _:
                assertionFailure("Use a representation that was unknown when this code was compiled.")
                url = nil
            }

            if let name = fileName, let pathComponents = getPathComponent(forKey: name) {
                for pathComponent in pathComponents {
                    url = url?.appendingPathComponent(pathComponent)
                }
            }

            return url
        }

        private final func list(
            at directory: URL
            ) -> [String]? {

            if let listing = try? fileManager.contentsOfDirectory(atPath: directory.path), listing.count > 0 {
                return listing
                
            } else {
                return nil
            }
        }
    }
}

// MARK: - Private Extensions

fileprivate protocol AnySubclass: Any {
}

fileprivate extension AnySubclass {
    func toData() -> Data? {
        #if os(iOS) || os(watchOS) || os(tvOS)
        if self is UIImage {
            return (self as? UIImage)?.data
        }
        #endif
        switch self {
        case is Bool:
            return (self as? Bool)?.data

        case is UInt16:
            return (self as? UInt16)?.data

        case is Int:
            return (self as? Int)?.data

        case is Decimal:
            return (self as? Decimal)?.data

        case is Float:
            return (self as? Float)?.data

        case is Double:
            return (self as? Double)?.data

        case is String:
            return (self as? String)?.data

        case is Data:
            return self as? Data

        default:
            return nil
        }
    }
}

fileprivate protocol DataConvertible {
    init?(data: Data)
    var data: Data { get }
}

fileprivate extension DataConvertible {
    var data: Data {
        return withUnsafeBytes(of: self) { Data($0) }
    }
}

fileprivate extension DataConvertible where Self: ExpressibleByIntegerLiteral {
    init?(data: Data) {
        var value: Self = 0

        guard data.count == MemoryLayout.size(ofValue: value) else {
            return nil
        }

        _ = withUnsafeMutableBytes(of: &value, { data.copyBytes(to: $0)} )
        self = value
    }
}

extension Int: DataConvertible {
}

extension Float: DataConvertible {
}

extension Double: DataConvertible {
}

extension Decimal: DataConvertible {
}

extension Bool: DataConvertible {

    /// Creates a new instance with the specified data.
    ///
    /// If there is non Boolean value of the type that corresponds with the
    /// specified data, this initializer returns nil.
    ///
    /// - Parameter data: The data to use for the new instance.
    init?(data: Data) {
        guard data.count == MemoryLayout<Bool>.size else {
            return nil
        }

        self = data.withUnsafeBytes { $0.load(as: Bool.self) }
    }
}

extension UInt16: DataConvertible {

    /// Creates a new instance with the specified data.
    ///
    /// If there is non 16-bit unsigned integer value of the type that
    /// corresponds with the specified data, this initializer returns nil.
    ///
    /// - Parameter data: The data to use for the new instance.
    init?(data: Data) {
        guard data.count == MemoryLayout<UInt16>.size else {
            return nil
        }

        self = data.withUnsafeBytes { $0.load(as: UInt16.self) }
    }

    /// A byte buffer in memory.
    var data: Data {
        var value = CFSwapInt16HostToBig(self)
        return Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
}

extension String: DataConvertible {

    /// Creates a new instance with the specified data.
    ///
    /// If there is non string value of the type that corresponds with the
    /// specified data, this initializer returns nil.
    ///
    /// - Parameter data: The data to use for the new instance.
    init?(data: Data) {
        self.init(data: data, encoding: .utf8)
    }

    /// A byte buffer in memory.
    var data: Data {
        if let utf8 = self.data(using: .utf8) {
            return utf8
        }
        return withUnsafeBytes(of: self) { Data($0) }
    }
}

#if os(iOS) || os(watchOS) || os(tvOS)
extension UIImage: DataConvertible {

    /// A byte buffer in memory.
    var data: Data {
        if let pngData = self.pngData() {
            return pngData
        }
        return withUnsafeBytes(of: self) { Data($0) }
    }
}
#endif
