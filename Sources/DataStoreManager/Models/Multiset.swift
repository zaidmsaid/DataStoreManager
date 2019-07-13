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

struct Multiset<Element: Hashable> {

    // MARK: - Initializers

    init() { }

    init<S: Sequence>(_ sequence: S) where S.Iterator.Element == AnyHashableMetatype {
        for element in sequence {
            add(element)
        }
    }

    init<S: Sequence>(_ sequence: S) where S.Iterator.Element == (key: AnyHashableMetatype, value: Int) {
        for (element, count) in sequence {
            add(element, occurrences: count)
        }
    }

    // MARK: - Properties

    var uniqueCount: Int {
        return contents.count
    }

    var totalCount: Int {
        return contents.values.reduce(0) { $0 + $1 }
    }

    fileprivate var contents: [AnyHashableMetatype: Int] = [:]

    // MARK: - CRUD

    mutating func add(_ member: AnyHashableMetatype, occurrences: Int = 1) {

        precondition(occurrences > 0, "Can only add a positive number of occurrences")

        if let currentCount = contents[member] {
            contents[member] = currentCount + occurrences
        } else {
            contents[member] = occurrences
        }
    }
}

struct AnyHashableMetatype : Hashable {

    static func ==(lhs: AnyHashableMetatype, rhs: AnyHashableMetatype) -> Bool {
        return lhs.base == rhs.base
    }

    let base: Any.Type

    init(_ base: Any.Type) {
        self.base = base
    }

    func hash(into hasher: inout Hasher) {
        ObjectIdentifier(base).hash(into: &hasher)
    }
}

extension Multiset: CustomStringConvertible {
    var description: String {
        return String(describing: contents)
    }
}

extension Multiset: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: AnyHashableMetatype...) {
        self.init(elements)
    }
}

extension Multiset: ExpressibleByDictionaryLiteral {

    /// The map converts elements to the "named" tuple the initializer expects.
    ///
    /// - Parameter elements: TODO
    init(dictionaryLiteral elements: (AnyHashableMetatype, Int)...) {
        self.init(elements.map { (key: $0.0, value: $0.1) })
    }
}

extension Multiset : Sequence {

    typealias Iterator = AnyIterator<(element: AnyHashableMetatype, count: Int)>

    func makeIterator() -> Iterator {
        var iterator = contents.makeIterator()

        return AnyIterator {
            return iterator.next()
        }
    }
}

extension Multiset : Collection {

    typealias Index = MultisetIndex<AnyHashableMetatype>

    var startIndex: Index {
        return MultisetIndex(contents.startIndex)
    }

    var endIndex: Index {
        return MultisetIndex(contents.endIndex)
    }

    subscript (position: Index) -> Iterator.Element {
        precondition((startIndex ..< endIndex).contains(position), "out of bounds")

        let dictionaryElement = contents[position.index]
        return (element: dictionaryElement.key, count: dictionaryElement.value)
    }

    func index(after i: Index) -> Index {
        return Index(contents.index(after: i.index))
    }
}

struct MultisetIndex<Element: Hashable> {

    fileprivate let index: DictionaryIndex<Element, Int>

    fileprivate init(_ dictionaryIndex: DictionaryIndex<Element, Int>) {
        self.index = dictionaryIndex
    }
}

extension MultisetIndex : Comparable {

    static func == (lhs: MultisetIndex, rhs: MultisetIndex) -> Bool {
        return lhs.index == rhs.index
    }

    static func < (lhs: MultisetIndex, rhs: MultisetIndex) -> Bool {
        return lhs.index < rhs.index
    }
}
