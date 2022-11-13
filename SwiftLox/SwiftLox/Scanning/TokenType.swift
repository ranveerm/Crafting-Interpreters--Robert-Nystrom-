//
//  TokenType.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 8/9/2022.
//

import Foundation

protocol TokenType {
    var rawValue: String { get }
}

extension TokenType where Self: CaseIterable {
    static var rawTokens: [String] { Self.allCases.map { $0.rawValue } }
}


// MARK: Single Character
enum SingleCharToken: String, CaseIterable, TokenType {
    case leftParenthesis = "("
    case rightParenthesis = ")"
    case leftBrace = "{"
    case rightBrace = "}"
    case comma = ","
    case dot = "."
    case minus = "-"
    case plus = "+"
    case star = "*"
    case semicolon = ";"
}
  
// MARK: Multi-character
enum PotentiallyMuliCharOperatorToken: String, CaseIterable, TokenType {
    case bang = "!"
    case equal = "="
    case greater = ">"
    case less = "<"
    
    static let succeedingTokenRawForMultiCharOperator = "="
    
    var matchingMultiCharOperator: MultiCharOperatorToken {
        switch self {
        case .bang: return .bangEqual
        case .equal: return .equalEqual
        case .greater: return .greaterEqual
        case .less: return .lessEqual
        }
    }
}

enum MultiCharOperatorToken: String, CaseIterable, TokenType {
    case bangEqual = "!="
    case equalEqual = "=="
    case greaterEqual = ">="
    case lessEqual = "<="
    
    /// Despite being unused, the presence of this variable ensures the two enums do not go out of sync (i.e. a case is added to an enum without the respective case being added to the matching enum)
    var matchingSingleCharOperator: PotentiallyMuliCharOperatorToken {
        switch self {
        case .bangEqual: return .bang
        case .equalEqual: return .equal
        case .greaterEqual: return .greater
        case .lessEqual: return .less
        }
    }
}

enum SpecialOperatorToken: String, CaseIterable, TokenType {
    case slash = "/"
}

// MARK: Literals
enum Literals: String, CaseIterable, TokenType {
    case identifier, string, number
}


enum Keywords: String, CaseIterable, TokenType {
    // MARK: Keywords
    case and, or
    case `if`, `else`
    case `true`, `false`
    case `class`, `super`
    case `for`, `while`
    case `nil`
    case `print`
    case `return`
    case this
    case `var`
    case fun
    
    case eof
}
