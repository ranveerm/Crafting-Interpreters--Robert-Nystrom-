//
//  Expr.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 21/11/2022.
//

import Foundation

protocol Expr { }

// MARK: Concrete Types
struct BinaryExpr: Expr {
    let lhs: Expr
    let rhs: Expr
    let `operator`: TokenType
}

struct UnaryExpr: Expr {
    let `operator`: TokenType
    let rhs: Expr
}

struct GroupingExpr: Expr {
    let expr: Expr
}

struct LiteralExpr: Expr {
    let type: Literals
    let value: String
}
