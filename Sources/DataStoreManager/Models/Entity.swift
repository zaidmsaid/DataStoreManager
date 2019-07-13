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

public protocol Entity {
    associatedtype PrimaryKey
}

public struct EntityCollection<T : Entity> {

    // MARK: - Initializers

    init() { }

    init<S: Sequence>(_ sequence: S) where S.Iterator.Element == (key: AnyHashableMetatype, value: T) {
        for (key, value) in sequence {
            add(value: value, forKey: key)
        }
    }

    // MARK: - Properties

    fileprivate var _loadedEntities = [AnyHashableMetatype: Any]()

    public var values: [T] {
        return _loadedEntities[AnyHashableMetatype(T.self), default: []] as? [T] ?? []
    }

    public mutating func add<T>(value: T, forKey key: AnyHashableMetatype) {

        precondition(_loadedEntities[key] == nil, "Can only add a unique value")

        _loadedEntities[key] = value
    }
}

public struct AnyHashableMetatype : Entity, Hashable {
    public typealias PrimaryKey = String

    public static func ==(lhs: AnyHashableMetatype, rhs: AnyHashableMetatype) -> Bool {
        return lhs.base == rhs.base
    }

    let base: Any.Type

    init(_ base: Any.Type) {
        self.base = base
    }

    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(base).hash(into: &hasher)
    }
}

extension EntityCollection : CustomStringConvertible {
    public var description: String {
        return String(describing: _loadedEntities)
    }
}

extension EntityCollection : ExpressibleByDictionaryLiteral {

    /// The map converts elements to the "named" tuple the initializer expects.
    ///
    /// - Parameter elements: TODO
    public init(dictionaryLiteral elements: (AnyHashableMetatype, T)...) {
        self.init(elements.map { (key: $0.0, value: $0.1) })
    }
}

extension EntityCollection : Sequence {

    public typealias Iterator = AnyIterator<(element: AnyHashableMetatype, value: Any)>

    public func makeIterator() -> Iterator {
        var iterator = _loadedEntities.makeIterator()

        return AnyIterator {
            return iterator.next()
        }
    }
}

extension EntityCollection : Collection {

    public typealias Index = EntityIndex<AnyHashableMetatype>

    public var startIndex: Index {
        return EntityIndex(_loadedEntities.startIndex)
    }

    public var endIndex: Index {
        return EntityIndex(_loadedEntities.endIndex)
    }

    public subscript (position: Index) -> Iterator.Element {
        precondition(indices.contains(position), "out of bounds")

        let dictionaryElement = _loadedEntities[position.index]
        return (element: dictionaryElement.key, count: dictionaryElement.value) as! EntityCollection<T>.Iterator.Element
    }

    public func index(after i: Index) -> Index {
        return Index(_loadedEntities.index(after: i.index))
    }
}

public struct EntityIndex<Element: Hashable> {

    fileprivate let index: DictionaryIndex<AnyHashableMetatype, Any>

    fileprivate init(_ dictionaryIndex: DictionaryIndex<AnyHashableMetatype, Any>) {
        self.index = dictionaryIndex
    }
}

extension EntityIndex : Comparable {

    public static func == (lhs: EntityIndex, rhs: EntityIndex) -> Bool {
        return lhs.index == rhs.index
    }

    public static func < (lhs: EntityIndex, rhs: EntityIndex) -> Bool {
        return lhs.index < rhs.index
    }
}
