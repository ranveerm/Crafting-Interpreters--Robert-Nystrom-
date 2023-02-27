//
//  LexmeGroup.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 24/2/2023.
//

import Foundation

/**
 Top-level grouping specification for concrete types that semantically group `Lexme` componennts.
 
 It is beneficial
 - Important: All conforming types are required to be `enum` (although this is not enforcable).
 */
protocol LexmeGroup: CaseIterable {
    var lexme: Lexme { get }
}

// MARK: Concrete Groups
enum LexmeSingleChar: LexmeGroup {
    case leftParenthesis
    case rightParenthesis
    case leftBrace
    case rightBrace
    case comma
    case dot
    case minus
    case plus
    case star
    
    var lexme: Lexme {
        switch self {
        case .leftParenthesis: return .leftParenthesis
        case .rightParenthesis: return .rightParenthesis
        case .leftBrace: return .leftBrace
        case .rightBrace: return .rightBrace
        case .comma: return .comma
        case .dot: return .dot
        case .minus: return .minus
        case .plus: return .plus
        case .star: return .star
        }
    }
//    
//    var convertedForParsing: LexmeGroup {
//        switch self {
//        case .leftParenthesis: return LexmeProductionTerminal.leftParenthesis
//        case .rightParenthesis: return LexmeEndSignifier.rightParenthesis
//        case .leftBrace, .rightBrace, .comma, .dot: return self
//        case .minus: return .minus
//        case .plus: return .plus
//        case .star: return .star
//        }
//    }
}

enum LexmePotentiallyMuliCharOperator: LexmeGroup {
    case bang
    case equal
    case greater
    case less
    static let succeedingRawCharForMultiCharOperator = "="
    
    var lexme: Lexme {
        switch self {
        case .bang: return .bang
        case .equal: return .equal
        case .greater: return .greater
        case .less: return .less
        }
    }
    
    var matchingMultiCharOperator: LexmeMultiCharOperator {
        switch self {
        case .bang: return .bangEqual
        case .equal: return .equalEqual
        case .greater: return .greaterEqual
        case .less: return .lessEqual
        }
    }
}

enum LexmeMultiCharOperator: LexmeGroup {
    case bangEqual
    case equalEqual
    case greaterEqual
    case lessEqual
    
    var lexme: Lexme {
        switch self {
        case .bangEqual: return .bangEqual
        case .equalEqual: return .equalEqual
        case .greaterEqual: return .greaterEqual
        case .lessEqual: return .lessEqual
        }
    }
}

enum LexmeSpecialOperator: LexmeGroup {
    case slash
    
    var lexme: Lexme {
        switch self { case .slash: return .slash }
    }
    
    static let commentStart = LexmeSpecialOperator.slash.lexme.rawValue
}

enum LexmeLiteral: LexmeGroup {
    case identifier
    case string
    case number
    
    var lexme: Lexme {
        switch self {
        case .identifier: return .identifier
        case .string: return .string
        case .number: return .number
        }
    }
    
    var groupForToken: any LexmeGroup {
        switch self {
        case .identifier: return self
        case .string: return LexmeProductionTerminal.string
        case .number: return LexmeProductionTerminal.number
        }
    }
    
    static let stringTerminals = LexmeLiteral.string.lexme.rawValue
    static let numericDecimalSeparator = Lexme.dot.rawValue
}

enum LemeKeyword: LexmeGroup {
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
    
    var lexme: Lexme {
        switch self {
        case .and: return .`and`
        case .or: return .or
        case .if: return .`if`
        case .else: return .`else`
        case .true: return .true
        case .false: return .false
        case .class: return .class
        case .super: return .super
        case .for: return .`for`
        case .while: return .`while`
        case .nil: return .nil
        case .print: return .print
        case .return: return .return
        case .this: return .this
        case .var: return .var
        case .fun: return .fun
        }
    }
}

enum LexmeEndSignifier: LexmeGroup {
    case eof
    case semicolon
    case rightParenthesis
    
    var lexme: Lexme {
        switch self {
        case .eof: return .eof
        case .semicolon: return .semicolon
        case .rightParenthesis: return .rightParenthesis
        }
    }
    
    static let statementBoundary = LexmeEndSignifier.semicolon.lexme
    static let endOfFile = LexmeEndSignifier.eof.lexme
    static let endOfGroup = LexmeEndSignifier.rightParenthesis.lexme
}

enum LexmeUnaryOperator: LexmeGroup {
    case bang, minus
    
    var lexme: Lexme {
        switch self {
        case .bang: return .bang
        case .minus: return .minus
        }
    }
}

enum LexmeBinaryOperator: LexmeGroup {
    case equal
    case equalEqual, bangEqual
    case greater, less
    case greaterEqual, lessEqual
    case plus,minus
    case star, slash
    
    var lexme: Lexme {
        switch self {
        case .equal: return .equal
        case .equalEqual: return .equalEqual
        case .bangEqual: return .bangEqual
        case .greater: return .greater
        case .less: return .less
        case .greaterEqual: return .greaterEqual
        case .lessEqual: return .lessEqual
        case .plus: return .plus
        case .minus: return .minus
        case .star: return .star
        case .slash: return .slash
        }
    }
    
    /// Relavant to grammar precedence for parsing
    static let equality: [Self] = [.bangEqual, .equalEqual]
    static let comparison: [Self] = [.greater, .greaterEqual, .less, .lessEqual]
    static let term: [Self] = [.plus, .minus]
    static let factor: [Self] = [.star, .slash]
}

enum LexmeSynchronisation: LexmeGroup {
    case `class`, `var`, `for`, `if`, `while`, `print`, `return`
    case fun
    
    var lexme: Lexme {
        switch self {
        case .class: return .class
        case .var: return .var
        case .for: return .`for`
        case .if: return .`if`
        case .while: return .`while`
        case .print: return .print
        case .return: return .return
        case .fun: return .fun
        }
    }
}

/// Lexmes that represent **leaves of sytax tree**. These are terminals in the production symbols.
enum LexmeProductionTerminal: LexmeGroup {
    case `true`, `false`, `nil`, number, string, leftParenthesis
    
    var lexme: Lexme {
        switch self {
        case .true: return .true
        case .false: return .false
        case .nil: return .nil
        case .number: return .number
        case .string: return .string
        case .leftParenthesis: return .leftParenthesis
        }
    }
}

