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
    var line: Int { get }
}

// MARK: Default Implementation
extension AbstractToken {
    var lexme: Lexme { lexmeGroup.lexme }
}

/// CustomStringConvertible
extension AbstractToken {
    var description: String {
        "[\(line)]".padding(toLength: 6, withPad: " ", startingAt: 0) + lexme.description.padding(toLength: 30, withPad: " ", startingAt: 0) + lexme.rawValue
    }
}

extension AbstractToken where Self == Token<LexmeProductionTerminal> {
    var description: String {
        "[\(line)]".padding(toLength: 6, withPad: " ", startingAt: 0) + lexme.description.padding(toLength: 30, withPad: " ", startingAt: 0) + "\(self.literal)"
    }
}

// MARK: Concrete Type
/// This type employs parameteric polymorphism ("generic over `LexmeGroup`") as opposed to subtype polymorphism (which is not semantically valid, given `lexmeGroup` is immutable).
/// - Important: Literal value is marked as `private` and is **only exporsed for certain generic parametes** (as this value only provides meaningful/vital information when `lexmeGroup` generic paramters is `LexmeProductionTerminal`).
struct Token<T: LexmeGroup>: AbstractToken {
    let lexmeGroup: T
    let line: Int
    private let _literal: String
    
    /// - Important: Only use this initialiser for non production terminals
    init(lexmeGroup: T, line: Int) {
        guard !(LexmeProductionTerminal.self is T) else { fatalError("Do not use this initialiser for production terminals (eg. literals). Use init(lexmeGroup: LexmeLiteral, literal: String, line: Int) instead") }
        
        self.lexmeGroup = lexmeGroup
        self.line = line
        self._literal = lexmeGroup.lexme.rawValue
    }
}

// MARK: Literal Exposure
extension Token where T == LexmeProductionTerminal {
    /// Important- if `lexmeGroup == LexmeProductionTerminal.number`, then the `String` representation of `_literal` is expected to be convertible to `Double`.
    init(lexmeGroup: LexmeProductionTerminal, literal: String, line: Int) {
        self.lexmeGroup = lexmeGroup
        self.line = line
        self._literal = literal
    }
    
    /// Note that literals are exposed for ``LexmeProductionTerminal``, as opposed to ``LexmeLiteral``. This is because ``LexmeLiteral`` is a set of variable literals (eg. string and numbers), and does not capture fixed literals (such as booleans and optionals). This is an artefact of the lexing process and results in an undesirable scenario where the case `leftParenthesis` (which is a part of ``LexmeProductionTerminal``) can have it's literal exposed. It is deemed acceptable to crash the application if it reaches this state.
    var literal: String {
        switch lexmeGroup {
        case .identifier, .string: return _literal
        case .number:
            /// Force unwrapping is accepted (see initialisation requirements)
            return Double(_literal)!.description
        case .true: return "true"
        case .false: return "false"
        case .nil: return "nil"
        case .leftParenthesis: fatalError("Invalid use of case")
        }
    }
}

// TODO: Determine if equality check for `lexmeGroup` is optimum
extension Token: Equatable {
    static func == (lhs: Token, rhs: Token) -> Bool {
        lhs.lexme == rhs.lexme && lhs._literal == rhs._literal && lhs.line == rhs.line && "\(type(of: lhs.lexmeGroup))" == "\(type(of: rhs.lexmeGroup))"
    }
}
