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

@objc open class DataStoreManager : NSObject {

    // MARK: - Properties

    @objc public static let shared = DataStoreManager()

    @objc open var tag: Int = 0 {
        willSet {
        }
    }

    @objc open weak var dataSource: DataStoreManagerDataSource? {
        willSet {
            if let defaultType = newValue?.defaultType?(for: self) {
                self.defaultType = defaultType
            }
        }
    }

    @objc open weak var delegate: DataStoreManagerDelegate? {
        willSet {
        }
    }

    private var defaultType: StorageType = .userDefaults

    // MARK: - Enums

    @objc public enum StorageType : Int, CaseIterable {

        case userDefaults
        case documentDirectory
        case userDirectory
        case libraryDirectory
        case temporaryDirectory

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

            case .temporaryDirectory:
                return "FileManager.temporaryDirectory"
            }
        }

        public init?(stringValue: String) {
            for type in StorageType.allCases {
                if type.toString() == stringValue {
                    self = type
                }
            }
            return nil
        }
    }

    // MARK: - CRUD

    @objc open func create(value: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        create(value: value, forKey: key, forType: defaultType, completionHandler: completionHandler)
    }

    @objc open func create(value: Any, forKey key: String, forType type: StorageType, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

       switch type {
        case .userDefaults:
            UserDefaultsWorker.create(value: value, forKey: key, completionHandler: completionHandler)

        case .documentDirectory:
            FileManagerWorker.create(value: value, forKey: key, forDirectory: .documentDirectory, completionHandler: completionHandler)

       case .userDirectory:
        FileManagerWorker.create(value: value, forKey: key, forDirectory: .userDirectory, completionHandler: completionHandler)

        case .libraryDirectory:
            FileManagerWorker.create(value: value, forKey: key, forDirectory: .libraryDirectory, completionHandler: completionHandler)

        case .temporaryDirectory:
            FileManagerWorker.create(value: value, forKey: key, forDirectory: .temporaryDirectory, completionHandler: completionHandler)
        }
    }

    @objc open func read(forKey key: String, completionHandler: @escaping (_ object: Any?) -> Void) {

        read(forKey: key, forType: defaultType, completionHandler: completionHandler)
    }

    @objc open func read(forKey key: String, forType type: StorageType, completionHandler: @escaping (_ object: Any?) -> Void) {

        switch type {
        case .userDefaults:
            UserDefaultsWorker.read(forKey: key, completionHandler: completionHandler)

        case .documentDirectory:
            FileManagerWorker.read(forKey: key, forDirectory: .documentDirectory, completionHandler: completionHandler)

        case .userDirectory:
            FileManagerWorker.read(forKey: key, forDirectory: .userDirectory, completionHandler: completionHandler)

        case .libraryDirectory:
            FileManagerWorker.read(forKey: key, forDirectory: .libraryDirectory, completionHandler: completionHandler)

        case .temporaryDirectory:
            FileManagerWorker.read(forKey: key, forDirectory: .temporaryDirectory, completionHandler: completionHandler)
        }
    }

    @objc open func update(value: Any, forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        update(value: value, forKey: key, forType: defaultType, completionHandler: completionHandler)
    }

    @objc open func update(value: Any, forKey key: String, forType type: StorageType, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        switch type {
        case .userDefaults:
            UserDefaultsWorker.update(value: value, forKey: key, completionHandler: completionHandler)

        case .documentDirectory:
            FileManagerWorker.update(value: value, forKey: key, forDirectory: .documentDirectory, completionHandler: completionHandler)

        case .userDirectory:
            FileManagerWorker.update(value: value, forKey: key, forDirectory: .userDirectory, completionHandler: completionHandler)

        case .libraryDirectory:
            FileManagerWorker.update(value: value, forKey: key, forDirectory: .libraryDirectory, completionHandler: completionHandler)

        case .temporaryDirectory:
            FileManagerWorker.update(value: value, forKey: key, forDirectory: .temporaryDirectory, completionHandler: completionHandler)
        }
    }

    @objc open func delete(forKey key: String, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

       delete(forKey: key, forType: defaultType, completionHandler: completionHandler)
    }

    @objc open func delete(forKey key: String, forType type: StorageType, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        switch type {
        case .userDefaults:
            UserDefaultsWorker.delete(forKey: key, completionHandler: completionHandler)

        case .documentDirectory:
            FileManagerWorker.delete(forKey: key, forDirectory: .documentDirectory, completionHandler: completionHandler)

        case .userDirectory:
            FileManagerWorker.delete(forKey: key, forDirectory: .userDirectory, completionHandler: completionHandler)

        case .libraryDirectory:
            FileManagerWorker.delete(forKey: key, forDirectory: .libraryDirectory, completionHandler: completionHandler)

        case .temporaryDirectory:
            FileManagerWorker.delete(forKey: key, forDirectory: .temporaryDirectory, completionHandler: completionHandler)
        }
    }

    @objc open func deleteAll(completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        deleteAll(forType: defaultType, completionHandler: completionHandler)
    }

    @objc open func deleteAll(forType type: StorageType, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        switch type {
        case .userDefaults:
            UserDefaultsWorker.deleteAll(completionHandler: completionHandler)

        case .documentDirectory:
            FileManagerWorker.deleteAll(forDirectory: .documentDirectory, completionHandler: completionHandler)

        case .userDirectory:
            FileManagerWorker.deleteAll(forDirectory: .userDirectory, completionHandler: completionHandler)

        case .libraryDirectory:
            FileManagerWorker.deleteAll(forDirectory: .libraryDirectory, completionHandler: completionHandler)

        case .temporaryDirectory:
            FileManagerWorker.deleteAll(forDirectory: .temporaryDirectory, completionHandler: completionHandler)
        }
    }

    // MARK: - Migrate

    @objc open func migrateSchema(forType type: StorageType, completionHandler: @escaping (_ isSuccessful: Bool) -> Void) {

        let key = "kSchemaVersion\(tag)"

        read(forKey: key, forType: type) { (object) in

            let oldSchemaVersion = object as? Int ?? 0
            let newSchemaVersion = self.dataSource?.dataStoreManager?(self, currentSchemaVersionForType: type) ?? 0

            if oldSchemaVersion < newSchemaVersion {
                self.delegate?.dataStoreManager?(self, performMigrationFromOldVersion: oldSchemaVersion, forType: type)

                if oldSchemaVersion == 0 {
                    self.create(value: newSchemaVersion, forKey: key, forType: type, completionHandler: completionHandler)

                } else {
                    self.update(value: newSchemaVersion, forKey: key, forType: type, completionHandler: completionHandler)
                }

            } else if oldSchemaVersion > newSchemaVersion {
                assertionFailure("Current schema version is lower than old schema version")
                completionHandler(false)
                return

            } else {
                completionHandler(true)
                return
            }
        }
    }
}
