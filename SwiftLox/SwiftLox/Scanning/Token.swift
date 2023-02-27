//
//  Token.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 23/9/2022.
//

import Foundation

/// ``Token`` is generic over ``LexmeGroup`` and hence can not effectively be used in a `Collection` (which has numerous use cases, eg. passing a collection of ``Token`` objects for parsing). As a result, the below abstraction is created.
protocol AbstractToken: CustomStringConvertible {
    associatedtype Group: LexmeGroup
    var lexmeGroup: Group { get }
    var lexme: Lexme { get }
    var literal: String? { get }
    var line: Int { get }
}

// MARK: Default Implementation
extension AbstractToken {
    var lexme: Lexme { lexmeGroup.lexme }
}

/// CustomStringConvertible
extension AbstractToken {
    var description: String {
        "[\(line)]".padding(toLength: 6, withPad: " ", startingAt: 0) + lexme.description.padding(toLength: 30, withPad: " ", startingAt: 0) + (literal ?? lexme.rawValue)
    }
}

// MARK: Concrete Type
/// This type is generic over `LexmeGroup` as implementing `polymorphism` is not semantically valid (given `lexmeGroup` is immutable).
struct Token<T: LexmeGroup>: AbstractToken {
    let lexmeGroup: T
    var literal: String?
    let line: Int
}

// TODO: Determine if obviating `lexmeGroup` from the equality check is valid
extension Token: Equatable {
    static func == (lhs: Token, rhs: Token) -> Bool {
        lhs.lexme == rhs.lexme && lhs.literal == rhs.literal && lhs.line == rhs.line
    }
}
