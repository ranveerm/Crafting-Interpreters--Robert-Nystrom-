//
//  Token.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 23/9/2022.
//

import Foundation

struct Token {
    let tokenType: TokenType
    let lexme: String
    let literal: String?
    let line: Int
}

extension Token: Equatable {
    static func == (lhs: Token, rhs: Token) -> Bool {
        lhs.tokenType.rawValue == rhs.tokenType.rawValue && lhs.lexme == rhs.lexme && lhs.literal == rhs.literal && lhs.line == rhs.line
    }
}

extension Token: CustomStringConvertible {
    var description: String {
        "[\(line)] " + tokenType.description + "\t\t" + lexme + "\t\t" + (literal ?? "")
    }
}
