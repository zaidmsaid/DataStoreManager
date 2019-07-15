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

/// An observable collection of `Entity` instances where each entity has a
/// unique id.
public struct EntityCollection<T: Hashable> {

    // MARK: - Initializers

    /// Implemented by subclasses to initialize a new object (the receiver)
    /// immediately after memory for it has been allocated.
    init() { }

    /// Creates a new instance with the specified sequence of the generic
    /// type.
    ///
    /// - Parameter sequence: The sequence to use for the new instance.
    init<S: Sequence>(_ sequence: S) where S.Iterator.Element == T {
        for element in sequence {
            add(forKey: element)
        }
    }

    /// Creates a new instance with the specified sequence of the generic
    /// type.
    ///
    /// - Parameter sequence: The sequence to use for the new instance.
    init<S: Sequence>(_ sequence: S) where S.Iterator.Element == (key: T, value: Any) {
        for (element, value) in sequence {
            add(value: value, forKey: element)
        }
    }

    // MARK: - Properties

    /// A collection containing the values of the `EntityCollection`.
    public var values: [T] {
        var values = [T]()
        for value in contents.keys {
            values.append(value)
        }
        return values
    }

    fileprivate var contents = [T: Any]()

    // MARK: - CRUD

    /// Adds an element to the contents of EntityCollection.
    ///
    /// - Parameters:
    ///   - value: The object to store in the contents of EntityCollection.
    ///   - key: The key with which to associate the value.
    public mutating func add(value: Any? = nil, forKey key: T) {

        precondition(contents[key] == nil, "Can only add a unique value")

        contents[key] = value
    }
}

// MARK: - CustomStringConvertible

extension EntityCollection : CustomStringConvertible {

    /// A textual representation of this instance.
    public var description: String {
        return String(describing: contents)
    }
}

// MARK: - CustomDebugStringConvertible

extension EntityCollection : CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        return description
    }
}

// MARK: - ExpressibleByArrayLiteral

extension EntityCollection: ExpressibleByArrayLiteral {

    /// Creates a new instance with the specified array literal.
    ///
    /// - Parameter elements: Elements to be stored in a EntityCollection.
    public init(arrayLiteral elements: T...) {
        self.init(elements)
    }
}

// MARK: - ExpressibleByDictionaryLiteral

extension EntityCollection : ExpressibleByDictionaryLiteral {

    /// Creates a new instance with the specified dictionary literal.
    ///
    /// - Parameter elements: Elements to be stored in a EntityCollection.
    public init(dictionaryLiteral elements: (T, Any)...) {
        // The map converts elements to the "named" tuple the initializer
        // expects.
        self.init(elements.map { (key: $0.0, value: $0.1) })
    }
}

// MARK: - Sequence

extension EntityCollection : Sequence {

    /// Type to mean instance of
    /// [AnyIterator](apple-reference-documentation://hsAabAoau8).
    public typealias Iterator = AnyIterator<(element: T, value: Any)>

    /// Returns an iterator over the elements of the collection.
    ///
    /// - Returns: Advances to the next element and returns it, or `nil` if
    ///            no next element exists.
    public func makeIterator() -> Iterator {
        var iterator = contents.makeIterator()

        return AnyIterator {
            return iterator.next()
        }
    }
}

// MARK: - Collection

extension EntityCollection : Collection {

    /// Type to mean instance of DictionaryIndex.
    public typealias Index = EntityCollectionIndex<T>

    /// The position of the first element in a nonempty dictionary.
    public var startIndex: Index {
        return EntityCollectionIndex(contents.startIndex)
    }

    /// The dictionary’s “past the end” position—that is, the position one
    /// greater than the last valid subscript argument.
    public var endIndex: Index {
        return EntityCollectionIndex(contents.endIndex)
    }

    /// Returns an element where the given element is contained within the
    /// range expression.
    ///
    /// - Parameter position: The index value of contents of
    ///                       EntityCollection.
    public subscript (position: Index) -> Iterator.Element {
        precondition((startIndex ..< endIndex).contains(position), "out of bounds")

        let dictionaryElement = contents[position.index]
        return (element: dictionaryElement.key, value: dictionaryElement.value)
    }

    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less
    ///                than `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Index) -> Index {
        return Index(contents.index(after: i.index))
    }
}

// MARK: - Index

/// The index value of EntityCollection.
public struct EntityCollectionIndex<T: Hashable> {

    fileprivate let index: DictionaryIndex<T, Any>

    fileprivate init(_ dictionaryIndex: DictionaryIndex<T, Any>) {
        self.index = dictionaryIndex
    }
}

// MARK: - Equatable

extension EntityCollectionIndex : Equatable {

    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    /// - Returns: true if the first argument equals the second argument;
    ///            false if not.
    public static func == (lhs: EntityCollectionIndex, rhs: EntityCollectionIndex) -> Bool {
        return lhs.index == rhs.index
    }
}

// MARK: - Comparable

extension EntityCollectionIndex : Comparable {

    /// This function is the only requirement of the `Comparable` protocol.
    /// The remainder of the relational operator functions are implemented
    /// by the standard library for any type that conforms to `Comparable`.
    ///
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    /// - Returns: true if the first argument is less than the second
    ///            argument; false if not.
    public static func < (lhs: EntityCollectionIndex, rhs: EntityCollectionIndex) -> Bool {
        return lhs.index < rhs.index
    }

    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than or equal to that of the second argument.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    /// - Returns: true if the first argument is less than or equal the
    ///            second argument; false if not.
    public static func <= (lhs: EntityCollectionIndex, rhs: EntityCollectionIndex) -> Bool {
        return lhs.index <= rhs.index
    }

    /// Return a Boolean value indicating whether the value of the first
    /// argument is greater than or equal to that of the second argument.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    /// - Returns: true if the first argument is greater than or equal the
    ///            second argument; false if not.
    public static func >= (lhs: EntityCollectionIndex, rhs: EntityCollectionIndex) -> Bool {
        return lhs.index >= rhs.index
    }

    /// Return a Boolean value indicating whether the value of the first
    /// argument is greater than that of the second argument.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    /// - Returns: true if the first argument is greater than the second
    ///            argument; false if not.
    public static func > (lhs: EntityCollectionIndex, rhs: EntityCollectionIndex) -> Bool {
        return lhs.index > rhs.index
    }
}
