//
//  TokenType.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 8/9/2022.
//

import Foundation

protocol TokenType: CustomStringConvertible {
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
    
    var description: String {
        switch self {
            
        case .leftParenthesis: return "Left Parenthesis"
        case .rightParenthesis: return "Right Parenthesis"
        case .leftBrace: return "Left Brace"
        case .rightBrace: return "Right Brace"
        case .comma: return "Comma"
        case .dot: return "Dot"
        case .minus: return "Minus"
        case .plus: return "Plus"
        case .star: return "Star"
        case .semicolon: return "Semicolon"
        }
    }
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
    
    var description: String {
        switch self {
            
        case .bang: return "Boolean Not"
        case .equal: return "Assignment"
        case .greater: return "Greater than"
        case .less: return "Less than"
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
    
    var description: String {
        switch self {
        case .bangEqual: return "Not Equal"
        case .equalEqual: return "Boolean Equality"
        case .greaterEqual: return "Greater than or equal to"
        case .lessEqual: return "Less than or equal to"
        }
    }
}

enum SpecialOperatorToken: String, CaseIterable, TokenType {
    case slash = "/"
    
    var description: String {
        switch self {
        case .slash: return "Slash"
        }
    }
}

// MARK: Literals
enum Literals: String, CaseIterable, TokenType {
    case identifier
    case string = "\""
    case number
    
    var description: String {
        switch self {
        case .identifier: return "Identifier"
        case .string: return "String"
        case .number: return "Number"
        }
    }
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
    
    // TODO: Provide more appropriate description values
    var description: String { self.rawValue.capitalized }
}

enum SpecialToken: String, CaseIterable, TokenType {
    case eof = "EOF"
    
    var description: String {
        switch self {
        case .eof: return "End of File"
        }
    }
}

enum NonTokenInputs: String {
    case space = " "
    case carriageReturn = "\r"
    case tab = "\t"
    case newLine = "\n"
}
