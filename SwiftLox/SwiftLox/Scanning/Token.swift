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

extension Token: CustomStringConvertible {
    var description: String {
        "[\(line)] " + tokenType.description + "\t\t" + lexme + " " + (literal ?? "")
    }
}
