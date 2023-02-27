//
//  Token.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 23/9/2022.
//

import Foundation

struct Token {
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

    let line: Int
}

// TODO: Determine if obviating `lexmeGroup` from the equality check is valid
extension Token: Equatable {
    static func == (lhs: Token, rhs: Token) -> Bool {
        lhs.lexme == rhs.lexme && lhs.literal == rhs.literal && lhs.line == rhs.line
    }
}

extension Token: CustomStringConvertible {
    var description: String {
        "[\(line)] " + tokenType.description + "\t\t" + lexme + "\t\t" + (literal ?? "")
    }
}
