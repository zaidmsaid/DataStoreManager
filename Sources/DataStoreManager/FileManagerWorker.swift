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

import UIKit

extension DataStoreManager {

    /// An interface to the FileManager.
    class FileManagerWorker {

        // MARK: - Properties

        lazy var fileManager: FileManager = {
            return FileManager.default
        }()

        // MARK: - Enums

        enum Directory {

            case documentDirectory
            case userDirectory
            case libraryDirectory
            case applicationDirectory
            case coreServiceDirectory
            case temporaryDirectory
        }

        // MARK: - CRUD

        func create(value: Any, forKey fileName: String, forDirectory directory: Directory, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            guard let url = getURL(for: directory, withFileName: fileName) else {
                assertionFailure("Unable to get document URL")
                completionHandler(false)
                return
            }

            let filePath = url.path + "/" + fileName
            let data = (value as? AnySubclass)?.toData()
            let isSuccessful = fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
            completionHandler(isSuccessful)
        }

        func read(forKey fileName: String, forDirectory directory: Directory, completionHandler: @escaping (_ object: Any?) -> Void) {

            guard let url = getURL(for: directory, withFileName: fileName) else {
                completionHandler(nil)
                return
            }

            let filePath = url.path + "/" + fileName
            let object = fileManager.contents(atPath: filePath)
            completionHandler(object)
        }

        func update(value: Any, forKey fileName: String, forDirectory directory: Directory, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            guard let url = getFullPath(forFileName: fileName, inDirectory: directory) else {
                assertionFailure("Unable to get document URL")
                completionHandler(false)
                return
            }

            do {
                let data = (value as? AnySubclass)?.toData()
                try data?.write(to: url)
                completionHandler(true)
            } catch {
                assertionFailure("Unable to write to document URL")
                completionHandler(false)
            }
        }

        func delete(forKey fileName: String, forDirectory directory: Directory, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            guard let url = getFullPath(forFileName: fileName, inDirectory: directory) else {
                assertionFailure("Unable to get document URL")
                completionHandler(false)
                return
            }

            do {
                try fileManager.removeItem(at: url)
                completionHandler(true)

            } catch {
                assertionFailure("Unable to remote at document URL")
                completionHandler(false)
            }
        }

        func deleteAll(forDirectory directory: Directory, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

            guard let url = getURL(for: directory) else {
                assertionFailure("Unable to get document URL")
                completionHandler(false)
                return
            }

            if let files = list(at: url) {
                for fileName in files {
                    delete(forKey: fileName, forDirectory: directory, completionHandler: completionHandler)
                }
            } else {
                assertionFailure("Unable to get contents of document directory")
                completionHandler(false)
            }
        }

        // MARK: - Helper

        private final func getPathComponent(forKey fileName: String) -> [String]? {

            // Check if file should contain in a folder.
            if fileName.contains("/") {
                var paths = fileName.components(separatedBy: "/")
                paths.removeLast() // last is the actual fileName
                return paths
            }
            return nil
        }

        private final func getURL(for directory: Directory, withFileName fileName: String? = nil) -> URL? {

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
                if #available(iOS 10.0, *) {
                    url = fileManager.temporaryDirectory

                } else {
                    url = URL(fileURLWithPath: NSTemporaryDirectory())
                }
            }

            if let name = fileName, let pathComponents = getPathComponent(forKey: name) {
                for pathComponent in pathComponents {
                    url = url?.appendingPathComponent(pathComponent)
                }
            }

            return url
        }

        private final func getFullPath(forFileName fileName: String, inDirectory directory: Directory) -> URL? {

            return getURL(for: directory, withFileName: fileName)?.appendingPathComponent(fileName)
        }

        private final func list(at directory: URL) -> [String]? {

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

        case is UIImage:
            return (self as? UIImage)?.data

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
        guard data.count == MemoryLayout.size(ofValue: value) else { return nil }
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
    init?(data: Data) {
        guard data.count == MemoryLayout<Bool>.size else { return nil }
        self = data.withUnsafeBytes { $0.load(as: Bool.self) }
    }
}

extension UInt16: DataConvertible {
    init?(data: Data) {
        guard data.count == MemoryLayout<UInt16>.size else { return nil }
        self = data.withUnsafeBytes { $0.load(as: UInt16.self) }
    }

    var data: Data {
        var value = CFSwapInt16HostToBig(self)
        return Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
}

extension String: DataConvertible {
    init?(data: Data) {
        self.init(data: data, encoding: .utf8)
    }

    var data: Data {
        if let utf8 = self.data(using: .utf8) {
            return utf8
        }
        return withUnsafeBytes(of: self) { Data($0) }
    }
}

extension UIImage: DataConvertible {
    var data: Data {
        if let pngData = self.pngData() {
            return pngData
        }
        return withUnsafeBytes(of: self) { Data($0) }
    }
}
