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

import CoreData

// MARK: - CoreData

extension DataStoreManager {

    /// An interface to the CoreData.
    internal class CoreDataWorker {

        // MARK: - Properties

        /// An object representing the data store manager requesting this
        /// information.
        var dataStoreManager: DataStoreManager?

        private var managedObject: NSManagedObject? {
            if let context = managedContext, let entity = entityDescription {
                return NSManagedObject(entity: entity, insertInto: context)
            } else if let context = managedContext, #available(iOS 10.0, macOS 10.12, watchOSApplicationExtension 3.0, tvOS 10.0, *) {
                return NSManagedObject(context: context)
            }
            return nil
        }

        private var managedContext: NSManagedObjectContext? {
            if let manager = dataStoreManager {
                return manager.dataSource?.coreDataManagedObjectContext?(for: manager)
            }
            return nil
        }

        private var entityDescription: NSEntityDescription? {
            if let manager = dataStoreManager {
                return manager.dataSource?.coreDataEntityDescription?(for: manager)
            }
            return nil
        }

        // MARK: - CRUD

        func create<T>(
            object: T,
            forKey key: String,
            completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void
            ) {

            setValue(object, forKey: key, completionHandler: completionHandler)
        }

        func read<T>(
            forKey key: String,
            withObjectType objectType: T.Type,
            completionHandler: @escaping (_ object: Any?, _ objectID: Any?, _ error: Error?) -> Void
            ) {

            if let context = managedContext, let name = entityDescription?.name {
                getCoreDataRecords(context: context, name: name) { (coreDataRecords, _, error) in
                    guard let records = coreDataRecords else {
                        DispatchQueue.main.async {
                            completionHandler(false, nil, error)
                        }
                        return
                    }

                    for record in records {
                        if let object = record.value(forKey: key) as? T {
                            DispatchQueue.main.async {
                                completionHandler(object, record.objectID, error)
                            }
                            return
                        }
                    }
                }
            } else {
                let error = ErrorObject(protocol: .datasourceNotAvailable(detail: "The missing data source is managedContext from coreDataManagedObjectContext."))
                completionHandler(nil, nil, error)
            }
        }

        func update<T>(
            object: T,
            forKey key: String,
            completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void
            ) {

            setValue(object, forKey: key, completionHandler: completionHandler)
        }

        func delete<T>(
            forKey key: String,
            withObjectType objectType: T.Type,
            completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void
            ) {

            if let context = managedContext, let name = entityDescription?.name {
                getCoreDataRecords(context: context, name: name) { [unowned self] (coreDataRecords, managedObjectContext, error) in
                    guard let context = managedObjectContext else {
                        DispatchQueue.main.async {
                            completionHandler(false, nil, error)
                        }
                        return
                    }

                    guard let records = coreDataRecords else {
                        DispatchQueue.main.async {
                            completionHandler(false, nil, error)
                        }
                        return
                    }

                    for record in records {
                        if let _ = record.value(forKey: key) as? T {
                            context.delete(record)
                            self.saveRecord(self.managedObject, context: context, objectID: record.objectID, completionHandler: completionHandler)
                            return
                        }
                    }

                    let error = ErrorObject(protocol: .deleteFailed(detail: "The recordID is not found in \(records.description)."))
                    DispatchQueue.main.async {
                        completionHandler(false, nil, error)
                    }
                }
            } else {
                let error = ErrorObject(protocol: .datasourceNotAvailable(detail: "The missing data source is managedContext from coreDataManagedObjectContext."))
                completionHandler(false, nil, error)
            }
        }

        func deleteAll(
            completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void
            ) {

            if let context = managedContext, let name = entityDescription?.name {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                fetchRequest.returnsObjectsAsFaults = false

                if #available(iOS 9.0, macOS 10.11, watchOSApplicationExtension 2.0, tvOS 9.0, *) {
                    let query = NSBatchDeleteRequest(fetchRequest: fetchRequest)

                    do {
                        try context.execute(query)
                        try context.save()
                        DispatchQueue.main.async {
                            completionHandler(true, context, nil)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completionHandler(false, context, error)
                        }
                    }
                } else {
                    do {
                        var records = try context.fetch(fetchRequest)
                        records.removeAll()
                        try context.save()
                        DispatchQueue.main.async {
                            completionHandler(true, nil, nil)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completionHandler(false, context, error)
                        }
                    }
                }
            } else {
                let error = ErrorObject(protocol: .datasourceNotAvailable(detail: "The missing data source is managedContext from coreDataManagedObjectContext."))
                completionHandler(false, nil, error)
            }
        }

        private func setValue(
            _ value: Any,
            forKey key: String,
            completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void
            ) {

            managedObject?.setValue(value, forKey: key)

            if let context = managedContext {
                saveRecord(managedObject, context: context, objectID: nil, completionHandler: completionHandler)
            } else {
                let error = ErrorObject(protocol: .datasourceNotAvailable(detail: "The missing data source is managedContext from coreDataManagedObjectContext."))
                completionHandler(false, nil, error)
            }
        }

        private func saveRecord(
            _ managedObject: NSManagedObject?,
            context: NSManagedObjectContext,
            objectID: Any?,
            completionHandler: @escaping (_ isSuccessful: Bool, _ objectID: Any?, _ error: Error?) -> Void
            ) {

            do {
                try context.save()
                DispatchQueue.main.async {
                    if let id = objectID {
                        completionHandler(true, id, nil)
                    } else {
                        completionHandler(true, managedObject?.objectID, nil)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(false, objectID, error)
                }
            }
        }

        // MARK: - Helpers

        private final func getCoreDataRecords(
            context: NSManagedObjectContext,
            name: String,
            completionHandler: @escaping (_ records: [NSManagedObject]?, _ managedObjectContext: NSManagedObjectContext?, _ error: Error?) -> Void
            ) {

            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: name)
            fetchRequest.returnsObjectsAsFaults = false

            do {
                let records = try context.fetch(fetchRequest)
                completionHandler(records, context, nil)
            } catch {
                completionHandler(nil, context, error)
            }
        }
    }
}
