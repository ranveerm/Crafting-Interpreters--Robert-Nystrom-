//
//  TokenType.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 8/9/2022.
//

import Foundation

/**
 A set of all valid lexmes within the language (as represented by the `rawValue`, with notable exceptions such as string literals).
 
 This enum does not provide any semantics. As a result, it is discouraged to used this type (except when dealing raw value inputs or usig it as a source of truth for derived `enum` types). For instance, when scanning for single character inputs, use another `enum` (such as ``LexmeSingleChar``) that is specifically constructed to contain a set of single character lexmes. This ensures targeted scope and prevents `Lexme` from being overcrowded with sprawling behaviour logic.
 
 The primary issue with creating derived classes is a potential desynchornisation between the source of truth and the derived class. The approach used to addres this is-
    - Make the derived class refer to the appropriate case in the source of truth (see `lexme` property in ``LexmeGroup``). Ensuring the cases match (eg. ``LexmeSingleChar.leftParenthesis.lexme`` == ``Lexme.leftParenthesis`` is the responsibility of the test suite). This ensures the derived class always references a valid member from the source of truth, being resistant to mutation within `Lexme`.
    - While the above approach allows a mechanism for the derived class to refer to the source of truth (and remain in synchrony), there also needs to be a mechanism to list all the derived classes from a case within the source of truth (eg. to determine if a lexme is a ``LexmeBinaryOperator`` while scanning). This is fulfilled by the `derivedCases` computed property. The contents of this property needs to be manually updated based on changes within the derived class (lack of synchrony is caugth by a test case). This unintended benefit of this property is that it keeps an account of all the derived objects, which is helpful during testing.
 */
enum Lexme: String, CaseIterable, Equatable {
    case leftParenthesis = "("
    case rightParenthesis = ")"
    case leftBrace = "{"
    case rightBrace = "}"
    case comma = ","
    case dot = "."
    case minus = "-"
    case plus = "+"
    case star = "*"
    
    case bang = "!"
    case equal = "="
    case greater = ">"
    case less = "<"
    
    case bangEqual = "!="
    case equalEqual = "=="
    case greaterEqual = ">="
    case lessEqual = "<="
    
    case slash = "/"
    
    case identifier
    case string = "\""
    case number
    
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
    
    case semicolon = ";"
    case eof = "EOF"
    
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
            
        case .bang: return "Boolean Not"
        case .equal: return "Assignment"
        case .greater: return "Greater than"
        case .less: return "Less than"
            
        case .bangEqual: return "Not Equal"
        case .equalEqual: return "Boolean Equality"
        case .greaterEqual: return "Greater than or equal to"
        case .lessEqual: return "Less than or equal to"
        
        case .slash: return "Slash"
            
        case .identifier: return "Identifier"
        case .string: return "String"
        case .number: return "Number"
           
        case .and, .or, .`if`, .`else`, .`true`, .`false`, .`class`, .`super`, .`for`, .`while`, .`nil`, .`print`, .`return`, .this, .`var`, .fun: return self.rawValue.capitalized
            
        case .eof: return "End of File"
        case .semicolon: return "Semicolon"
        }
    }

    private var derivedLexmeGroups: [any LexmeGroup.Type] { derivedCases.map { type(of: $0) } }
    
    internal var derivedCases: [any LexmeGroup] {
        switch self {
        case .leftParenthesis: return [LexmeSingleChar.leftParenthesis, LexmeProductionTerminal.leftParenthesis]
        case .rightParenthesis: return [LexmeSingleChar.rightParenthesis, LexmeEndSignifier.rightParenthesis]
        case .leftBrace: return [LexmeSingleChar.leftBrace]
        case .rightBrace: return [LexmeSingleChar.rightBrace]
        case .comma: return [LexmeSingleChar.comma]
        case .dot: return [LexmeSingleChar.dot]
        case .minus: return [LexmeSingleChar.minus, LexmeUnaryOperator.minus, LexmeBinaryOperator.minus]
        case .plus: return [LexmeSingleChar.plus, LexmeBinaryOperator.plus]
        case .star: return [LexmeSingleChar.star, LexmeBinaryOperator.star]
            
        case .bang: return [LexmePotentiallyMuliCharOperator.bang, LexmeUnaryOperator.bang]
        case .equal: return [LexmePotentiallyMuliCharOperator.equal, LexmeBinaryOperator.equal]
        case .greater: return [LexmePotentiallyMuliCharOperator.greater, LexmeBinaryOperator.greater]
        case .less: return [LexmePotentiallyMuliCharOperator.less, LexmeBinaryOperator.less]
           
        case .bangEqual: return [LexmeMultiCharOperator.bangEqual, LexmeBinaryOperator.bangEqual]
        case .equalEqual: return [LexmeMultiCharOperator.equalEqual, LexmeBinaryOperator.equalEqual]
        case .greaterEqual: return [LexmeMultiCharOperator.greaterEqual, LexmeBinaryOperator.greaterEqual]
        case .lessEqual: return [LexmeMultiCharOperator.lessEqual, LexmeBinaryOperator.lessEqual]
            
        case .identifier: return [LexmeLiteral.identifier]
        case .string: return [LexmeLiteral.string, LexmeProductionTerminal.string]
        case .number: return [LexmeLiteral.number, LexmeProductionTerminal.number]
            
        case .slash: return [LexmeSpecialOperator.slash, LexmeBinaryOperator.slash]
            
        case .and: return [LemeKeyword.`and`]
        case .or: return [LemeKeyword.or]
        case .if: return [LemeKeyword.`if`, LexmeSynchronisation.`if`]
        case .else: return [LemeKeyword.`else`]
        case .true: return [LemeKeyword.true, LexmeProductionTerminal.true]
        case .false: return [LemeKeyword.false, LexmeProductionTerminal.false]
        case .class: return [LemeKeyword.class, LexmeSynchronisation.class]
        case .super: return [LemeKeyword.super]
        case .for: return [LemeKeyword.`for`, LexmeSynchronisation.`for`]
        case .while: return [LemeKeyword.`while`, LexmeSynchronisation.`while`]
        case .nil: return [LemeKeyword.nil, LexmeProductionTerminal.nil]
        case .print: return [LemeKeyword.print, LexmeSynchronisation.print]
        case .return: return [LemeKeyword.return, LexmeSynchronisation.return]
        case .this: return [LemeKeyword.this]
        case .var: return [LemeKeyword.var, LexmeSynchronisation.var]
        case .fun: return [LemeKeyword.fun, LexmeSynchronisation.fun]
        
        case .eof: return [LexmeEndSignifier.eof]
        case .semicolon: return [LexmeEndSignifier.semicolon]
        }
    }
    
    public func checkMembership<T: LexmeGroup>(for groupType: T.Type) -> T? {
        return derivedCases.first { type(of: $0) == groupType } as? T
    }
}
