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

import CloudKit

extension DataStoreManager {

    /// An interface to the CKContainer.
    class CloudKitWorker {

        // MARK: - Enumerations

        @objc enum ContainerType : Int {

            case privateCloudDatabase

            case publicCloudDatabase

            case sharedCloudDatabase
        }

        // MARK: - Properties

        var dataStoreManager: DataStoreManager?
        var recordIDDelegate: ((DataStoreManager, String) -> CKRecord.ID)?

        var recordType: String? {
            if let manager = dataStoreManager {
                return manager.dataSource?.cloudKitContainerRecordType?(for: manager)
            }
            return nil
        }

        var allowsDuplicateKey: Bool {
            if let manager = dataStoreManager, let allowsDuplicateKey = manager.dataSource?.cloudKitContainerAllowsDuplicateKey?(for: manager) {
                return allowsDuplicateKey
            }
            return false
        }

        lazy var cloudKitContainer: CKContainer = {
            if let manager = dataStoreManager, let containerIdentifier = manager.dataSource?.cloudKitContainerIdentifier?(for: manager) {
                return CKContainer(identifier: containerIdentifier)
            }
            return CKContainer.default()
        }()

        // MARK: - CRUD

        func create<T>(object: T, forKey key: String, forContainerType containerType: ContainerType, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            let recordType = self.recordType ?? key

            getCloudKitRecord(forRecordType: recordType, forContainerType: containerType) { [unowned self] (cloudKitRecord, cloudKitDatabase, error) in
                guard let database = cloudKitDatabase else {
                    DispatchQueue.main.async {
                        completionHandler(false, nil, error)
                    }
                    return
                }

                guard let records = cloudKitRecord else {
                    self.createValue(object, forKey: key, forRecordType: recordType, forCloudKitDatabase: database, completionHandler: completionHandler)
                    return
                }

                if !self.allowsDuplicateKey {
                    for record in records {
                        if let _ = record.object(forKey: key) as? T {
                            let error = ErrorObject(protocol: .duplicateObject(detail: key))
                            completionHandler(false, record.recordID, error)
                            return
                        }
                    }
                }

                self.createValue(object, forKey: key, forRecordType: recordType, forCloudKitDatabase: database, completionHandler: completionHandler)
            }
        }

        func read<T>(forKey key: String, withObjectType objectType: T.Type, forContainerType containerType: ContainerType, completionHandler: @escaping (_ object: Any?, _ objectID: Any?, _ error: Error?) -> Void) {

            let recordType = self.recordType ?? key

            getCloudKitRecord(forRecordType: recordType, forContainerType: containerType) { (cloudKitRecord, _, error) in
                guard let records = cloudKitRecord else {
                    DispatchQueue.main.async {
                        completionHandler(nil, nil, error)
                    }
                    return
                }

                for record in records {
                    if let object = record.object(forKey: key) as? T {
                        // TODO: how to handle if allowed duplicate keys
                        DispatchQueue.main.async {
                            completionHandler(object, record.recordID, error)
                        }
                        return
                    }
                }

                completionHandler(nil, nil, error)
            }
        }

        func update<T>(object: T, forKey key: String, forContainerType containerType: ContainerType, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            let recordType = self.recordType ?? key

            if let delegate = recordIDDelegate, let manager = dataStoreManager, let database = getDatabase(forContainerType: containerType) {
                updateValue(object, forKey: key, forRecordType: recordType, forRecordID: delegate(manager, key), forCloudKitDatabase: database, completionHandler: completionHandler)

            } else {
                getCloudKitRecord(forRecordType: recordType, forContainerType: containerType) { [unowned self] (cloudKitRecord, cloudKitDatabase, error) in
                    guard let database = cloudKitDatabase else {
                        DispatchQueue.main.async {
                            completionHandler(false, nil, error)
                        }
                        return
                    }

                    guard let records = cloudKitRecord else {
                        DispatchQueue.main.async {
                            completionHandler(false, nil, error)
                        }
                        return
                    }

                    for record in records {
                        if let object = record.object(forKey: key) as? T {
                            // TODO: how to handle if allowed duplicate keys
                            self.updateValue(object, forKey: key, forRecordType: recordType, forRecordID: record.recordID, forCloudKitDatabase: database, completionHandler: completionHandler)
                            return
                        }
                    }

                    DispatchQueue.main.async {
                        completionHandler(false, nil, error)
                    }
                }
            }
        }

        func delete<T>(forKey key: String, withObjectType objectType: T.Type, forContainerType containerType: ContainerType, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            let recordType = self.recordType ?? key

            if let delegate = recordIDDelegate, let manager = dataStoreManager, let database = getDatabase(forContainerType: containerType) {
                delete(forRecordID: delegate(manager, key), forCloudKitDatabase: database, completionHandler: completionHandler)

            } else {
                getCloudKitRecord(forRecordType: recordType, forContainerType: containerType) { [unowned self] (cloudKitRecord, cloudKitDatabase, error) in
                    guard let database = cloudKitDatabase else {
                        DispatchQueue.main.async {
                            completionHandler(false, nil, error)
                        }
                        return
                    }

                    guard let records = cloudKitRecord else {
                        DispatchQueue.main.async {
                            completionHandler(false, nil, error)
                        }
                        return
                    }

                    for record in records {
                        if let _ = record.object(forKey: key) as? T {
                            // TODO: how to handle if allowed duplicate keys
                            self.delete(forRecordID: record.recordID, forCloudKitDatabase: database, completionHandler: { (isSuccessful, recordID, error) in
                                guard error == nil else {
                                    DispatchQueue.main.async {
                                        completionHandler(false, recordID, error)
                                    }
                                    return
                                }

                                DispatchQueue.main.async {
                                    completionHandler(true, recordID, nil)
                                }
                            })
                            return
                        }
                    }

                    let error = ErrorObject(protocol: .deleteFailed(detail: "recordID not found in \(records)."))
                    DispatchQueue.main.async {
                        completionHandler(false, nil, error)
                    }
                }
            }
        }

        func deleteAll(forContainerType containerType: ContainerType, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            guard let recordType = self.recordType else {
                let error = ErrorObject(protocol: .datasourceNotAvailable(detail: "recordType"))
                completionHandler(false, nil, error)
                return
            }

            getCloudKitRecord(forRecordType: recordType, forContainerType: containerType) { [unowned self] (cloudKitRecord, cloudKitDatabase, error) in
                guard let database = cloudKitDatabase else {
                    DispatchQueue.main.async {
                        completionHandler(false, nil, error)
                    }
                    return
                }

                guard let records = cloudKitRecord else {
                    DispatchQueue.main.async {
                        completionHandler(false, nil, error)
                    }
                    return
                }

                for record in records {
                    self.delete(forRecordID: record.recordID, forCloudKitDatabase: database, completionHandler: { (isSuccessful, recordID, error) in
                        guard error == nil else {
                            DispatchQueue.main.async {
                                completionHandler(false, recordID, error)
                            }
                            return
                        }
                    })
                }

                DispatchQueue.main.async {
                    completionHandler(true, nil, nil)
                }
            }
        }

        private func createValue(_ value: Any, forKey key: String, forRecordType recordType: String, forCloudKitDatabase database: CKDatabase, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            let newRecord = CKRecord(recordType: recordType)
            newRecord.setValue(value, forKey: key)
            saveRecord(newRecord, forCloudKitDatabase: database, completionHandler: completionHandler)
        }

        private func updateValue(_ value: Any, forKey key: String, forRecordType recordType: String, forRecordID recordID: CKRecord.ID, forCloudKitDatabase database: CKDatabase, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            let newRecord = CKRecord(recordType: recordType, recordID: recordID)
            newRecord.setValue(value, forKey: key)
            saveRecord(newRecord, forCloudKitDatabase: database, completionHandler: completionHandler)
        }

        private func saveRecord(_ newRecord: CKRecord, forCloudKitDatabase database: CKDatabase, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            database.save(newRecord) { (record, error) in
                guard error == nil else {
                    DispatchQueue.main.async {
                        completionHandler(false, record?.recordID, error)
                    }
                    return
                }

                DispatchQueue.main.async {
                    completionHandler(true, record?.recordID, nil)
                }
            }
        }

        private func delete(forRecordID recordID: CKRecord.ID, forCloudKitDatabase database: CKDatabase, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            database.delete(withRecordID: recordID, completionHandler: { (recordID, error) in
                guard error == nil else {
                    DispatchQueue.main.async {
                        completionHandler(false, recordID, error)
                    }
                    return
                }

                DispatchQueue.main.async {
                    completionHandler(true, recordID, nil)
                }
            })
        }

        // MARK: - Helper

        private final func getDatabase(forContainerType containerType: ContainerType) -> CKDatabase? {

            switch containerType {
            case .privateCloudDatabase:
                return cloudKitContainer.privateCloudDatabase

            case .publicCloudDatabase:
                return cloudKitContainer.publicCloudDatabase

            case .sharedCloudDatabase:
                if #available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *) {
                    return cloudKitContainer.sharedCloudDatabase
                } else {
                    return nil
                }

            @unknown case _:
                assertionFailure("Use a representation that was unknown when this code was compiled.")
                return nil
            }
        }

        private final func getCloudKitRecord(forRecordType recordType: String, forContainerType containerType: ContainerType, completionHandler: @escaping (_ cloudKitRecord: [CKRecord]?, _ cloudKitDatabase: CKDatabase?, _ error: Error?) -> Void) {

            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: recordType, predicate: predicate)

            guard let database = getDatabase(forContainerType: containerType) else {
                let error = ErrorObject(protocol: .databaseNotAvailable)
                completionHandler(nil, nil, error)
                return
            }

            database.perform(query, inZoneWith: nil) { (record, error) in
                guard error == nil else {
                    completionHandler(nil, database, error)
                    return
                }

                completionHandler(record, database, nil)
            }
        }
    }
}
