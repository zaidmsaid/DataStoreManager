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

// MARK: - CloudKit

extension DataStoreManager {

    /// An interface to the CloudKit.
    @available(watchOSApplicationExtension 3.0, *)
    class CloudKitWorker {

        // MARK: - Enumerations

        @objc enum ContainerType : Int {

            case privateCloudDatabase

            case publicCloudDatabase

            case sharedCloudDatabase
        }

        // MARK: - Properties

        /// An object representing the data store manager requesting this
        /// information.
        var dataStoreManager: DataStoreManager?

        /// Asks the delegate for the cloud kit container record type of the
        /// data store manager.
        var recordIDDelegate: ((DataStoreManager, String) -> CKRecord.ID)?

        private var cloudKitContainer: CKContainer {
            if let manager = dataStoreManager, let containerIdentifier = manager.dataSource?.cloudKitContainerIdentifier?(for: manager) {
                return CKContainer(identifier: containerIdentifier)
            }
            return CKContainer.default()
        }

        private var recordType: String? {
            if let manager = dataStoreManager {
                return manager.dataSource?.cloudKitContainerRecordType?(for: manager)
            }
            return nil
        }

        private var predicate: NSPredicate {
            if let manager = dataStoreManager, let predicate = manager.dataSource?.cloudKitContainerPredicate?(for: manager) {
                return predicate
            }
            return NSPredicate(value: true)
        }

        private var zoneID: CKRecordZone.ID? {
            if let manager = dataStoreManager {
                return manager.dataSource?.cloudKitContainerZoneID?(for: manager)
            }
            return nil
        }

        private var allowsDuplicateKey: Bool {
            if let manager = dataStoreManager, let allowsDuplicateKey = manager.dataSource?.cloudKitContainerAllowsDuplicateKey?(for: manager) {
                return allowsDuplicateKey
            }
            return false
        }

        // MARK: - CRUD

        func create<T>(object: T, forKey key: String, forContainerType containerType: ContainerType, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            let recordType = self.recordType ?? key

            getCloudKitRecords(forRecordType: recordType, forContainerType: containerType) { [unowned self] (cloudKitRecords, cloudKitDatabase, error) in
                guard let database = cloudKitDatabase else {
                    DispatchQueue.main.async {
                        completionHandler(false, nil, error)
                    }
                    return
                }

                guard let records = cloudKitRecords else {
                    self.createValue(object, forKey: key, forRecordType: recordType, forCloudKitDatabase: database, completionHandler: completionHandler)
                    return
                }

                if !self.allowsDuplicateKey {
                    for record in records {
                        if let _ = record.object(forKey: key) as? T {
                            let error = ErrorObject(protocol: .duplicateObject(detail: "The key is \(key)."))
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

            getCloudKitRecords(forRecordType: recordType, forContainerType: containerType) { (cloudKitRecords, _, error) in
                guard let records = cloudKitRecords else {
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
                getCloudKitRecords(forRecordType: recordType, forContainerType: containerType) { [unowned self] (cloudKitRecords, cloudKitDatabase, error) in
                    guard let database = cloudKitDatabase else {
                        DispatchQueue.main.async {
                            completionHandler(false, nil, error)
                        }
                        return
                    }

                    guard let records = cloudKitRecords else {
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
                getCloudKitRecords(forRecordType: recordType, forContainerType: containerType) { [unowned self] (cloudKitRecords, cloudKitDatabase, error) in
                    guard let database = cloudKitDatabase else {
                        DispatchQueue.main.async {
                            completionHandler(false, nil, error)
                        }
                        return
                    }

                    guard let records = cloudKitRecords else {
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

                    let error = ErrorObject(protocol: .deleteFailed(detail: "The recordID is not found in \(records.description)."))
                    DispatchQueue.main.async {
                        completionHandler(false, nil, error)
                    }
                }
            }
        }

        func deleteAll(forContainerType containerType: ContainerType, completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void) {

            guard let recordType = self.recordType else {
                let error = ErrorObject(protocol: .datasourceNotAvailable(detail: "The missing data source is recordType from cloudKitContainerRecordType."))
                completionHandler(false, nil, error)
                return
            }

            getCloudKitRecords(forRecordType: recordType, forContainerType: containerType) { [unowned self] (cloudKitRecords, cloudKitDatabase, error) in
                guard let database = cloudKitDatabase else {
                    DispatchQueue.main.async {
                        completionHandler(false, nil, error)
                    }
                    return
                }

                guard let records = cloudKitRecords else {
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

        // MARK: - Helpers

        private final func getDatabase(forContainerType containerType: ContainerType) -> CKDatabase? {

            switch containerType {
            case .privateCloudDatabase:
                return cloudKitContainer.privateCloudDatabase

            case .publicCloudDatabase:
                return cloudKitContainer.publicCloudDatabase

            case .sharedCloudDatabase:
                if #available(iOS 10.0, macOS 10.12, tvOS 10.0, *) {
                    return cloudKitContainer.sharedCloudDatabase
                } else {
                    return nil
                }

            @unknown case _:
                assertionFailure("Use a representation that was unknown when this code was compiled.")
                return nil
            }
        }

        private final func getCloudKitRecords(forRecordType recordType: String, forContainerType containerType: ContainerType, completionHandler: @escaping (_ cloudKitRecords: [CKRecord]?, _ cloudKitDatabase: CKDatabase?, _ error: Error?) -> Void) {

            let query = CKQuery(recordType: recordType, predicate: predicate)

            guard let database = getDatabase(forContainerType: containerType) else {
                let error = ErrorObject(protocol: .databaseNotAvailable)
                completionHandler(nil, nil, error)
                return
            }

            database.perform(query, inZoneWith: zoneID) { (record, error) in
                guard error == nil else {
                    completionHandler(nil, database, error)
                    return
                }

                completionHandler(record, database, nil)
            }
        }
    }
}
