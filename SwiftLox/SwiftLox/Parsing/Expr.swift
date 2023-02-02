//
//  Expr.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 21/11/2022.
//

import Foundation

protocol Expr { }
// MARK: Grammar
/*:
 # Grammar
 expression     → literal
                | unary
                | binary
                | grouping ;

 literal        → NUMBER | STRING | "true" | "false" | "nil" ;
 grouping       → "(" expression ")" ;
 unary          → ( "-" | "!" ) expression ;
 binary         → expression operator expression ;
 operator       → "==" | "!=" | "<" | "<=" | ">" | ">="
                | "+"  | "-"  | "*" | "/" ;
 
 # Notes
 - CAPITALISED terminals are single lexme whose representation may vary (eg. NUMBER can be 42, 1, etc.)
 - Recursive (eg. `binary` production contains `expression`, which can again contain `binary`)
 */

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
