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

public struct EntityCollection<T: Hashable> {

    // MARK: - Initializers

    init() { }

    init<S: Sequence>(_ sequence: S) where S.Iterator.Element == T {
        for element in sequence {
            add(forKey: element)
        }
    }

    init<S: Sequence>(_ sequence: S) where S.Iterator.Element == (key: T, value: Any) {
        for (element, value) in sequence {
            add(value: value, forKey: element)
        }
    }

    // MARK: - Properties

    fileprivate var contents = [T: Any]()

    public var values: [T] {
        var values = [T]()
        for value in contents.keys {
            values.append(value)
        }
        return values
    }

    // MARK: - CRUD

    public mutating func add(value: Any = "", forKey key: T) {

        precondition(contents[key] == nil, "Can only add a unique value")

        contents[key] = value
    }
}

// MARK: - CustomStringConvertible

extension EntityCollection : CustomStringConvertible {
    public var description: String {
        return String(describing: contents)
    }
}

// MARK: - ExpressibleByArrayLiteral

extension EntityCollection: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: T...) {
        self.init(elements)
    }
}

// MARK: - ExpressibleByDictionaryLiteral

extension EntityCollection : ExpressibleByDictionaryLiteral {

    /// The map converts elements to the "named" tuple the initializer expects.
    ///
    /// - Parameter elements: TODO
    public init(dictionaryLiteral elements: (T, Any)...) {
        self.init(elements.map { (key: $0.0, value: $0.1) })
    }
}

// MARK: - Sequence

extension EntityCollection : Sequence {

    public typealias Iterator = AnyIterator<(element: T, value: Any)>

    public func makeIterator() -> Iterator {
        var iterator = contents.makeIterator()

        return AnyIterator {
            return iterator.next()
        }
    }
}

// MARK: - Collection

extension EntityCollection : Collection {

    public typealias Index = EntityCollectionIndex<T>

    public var startIndex: Index {
        return EntityCollectionIndex(contents.startIndex)
    }

    public var endIndex: Index {
        return EntityCollectionIndex(contents.endIndex)
    }

    public subscript (position: Index) -> Iterator.Element {
        precondition((startIndex ..< endIndex).contains(position), "out of bounds")

        let dictionaryElement = contents[position.index]
        return (element: dictionaryElement.key, value: dictionaryElement.value)
    }

    public func index(after i: Index) -> Index {
        return Index(contents.index(after: i.index))
    }
}

// MARK: - Index

public struct EntityCollectionIndex<T: Hashable> {

    fileprivate let index: DictionaryIndex<T, Any>

    fileprivate init(_ dictionaryIndex: DictionaryIndex<T, Any>) {
        self.index = dictionaryIndex
    }
}

// MARK: - Comparable

extension EntityCollectionIndex : Comparable {

    public static func == (lhs: EntityCollectionIndex, rhs: EntityCollectionIndex) -> Bool {
        return lhs.index == rhs.index
    }

    public static func < (lhs: EntityCollectionIndex, rhs: EntityCollectionIndex) -> Bool {
        return lhs.index < rhs.index
    }

    public static func <= (lhs: EntityCollectionIndex, rhs: EntityCollectionIndex) -> Bool {
        return lhs.index <= rhs.index
    }

    public static func >= (lhs: EntityCollectionIndex, rhs: EntityCollectionIndex) -> Bool {
        return lhs.index >= rhs.index
    }

    public static func > (lhs: EntityCollectionIndex, rhs: EntityCollectionIndex) -> Bool {
        return lhs.index > rhs.index
    }
}
