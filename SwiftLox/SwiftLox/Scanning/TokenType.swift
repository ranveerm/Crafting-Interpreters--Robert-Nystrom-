//
//  TokenType.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 8/9/2022.
//

import Foundation

enum TokenType: String {
    // MARK: Single Character
    case leftParenthesis, rightParenthesis
    case leftBracem, rightBrace
    case comma, dot
    case minus, plus, slash, star
    case semicolon
    
    // MARK: Multi-character
    case bang, bandEqual
    case equal, equalEqual
    case greater, greaterEqual
    case less, lessEqual
    
    // MARK: Literals
    case identifier, string, number
    
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
