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

// MARK: - DataSource

@objc public protocol DataStoreManagerDataSource: class {

    // MARK: Core

    @objc optional func defaultType(for manager: DataStoreManager) -> DataStoreManager.StorageType
    @objc optional func dataStoreManager(_ manager: DataStoreManager, currentSchemaVersionForType type: DataStoreManager.StorageType) -> Int

    // MARK: Cache

    @objc optional func cacheTotalCostLimit(for manager: DataStoreManager) -> Int
    @objc optional func dataStoreManager(_ manager: DataStoreManager, cacheCostLimitForObject object: Any) -> Int

    // MARK: SecItem

    @objc optional func keychainService(for manager: DataStoreManager) -> String
    @objc optional func keychainAccount(for manager: DataStoreManager) -> String
    @objc optional func keychainAccessGroup(for manager: DataStoreManager) -> String
}

// MARK: - Delegate

@objc public protocol DataStoreManagerDelegate: class {

    @objc optional func dataStoreManager(_ manager: DataStoreManager, performMigrationFromOldVersion version: Int, forType type: DataStoreManager.StorageType)
}
