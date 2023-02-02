//
//  Expr.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 21/11/2022.
//

import Foundation

/**
 Container to server as a mechanism to group concrete expression types.
 - Note: There is no specification for state or method specific to the concept of expression as this protocol purely serves as a grouping mechanism. However, it does act as an Visitor interface for expression types (see [Visitor Pattern](https://refactoring.guru/design-patterns/visitor) for more details).
 */
protocol Expr {
    func acceptVisitor<T: ExprVisitor>(_ visitor: T) -> T.VisitorReturnType
}

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
    
    func acceptVisitor<T>(_ visitor: T) -> T.VisitorReturnType where T : ExprVisitor { visitor.visitBinaryExpr(expr: self) }
}

struct UnaryExpr: Expr {
    let `operator`: TokenType
    let rhs: Expr
    
    func acceptVisitor<T>(_ visitor: T) -> T.VisitorReturnType where T : ExprVisitor { visitor.visitUnaryExpr(expr: self) }
}

struct GroupingExpr: Expr {
    let expr: Expr
    
    func acceptVisitor<T>(_ visitor: T) -> T.VisitorReturnType where T : ExprVisitor { visitor.visitGroupingExpr(expr: self) }
}

struct LiteralExpr: Expr {
    let type: Literals
    let value: String
    
    func acceptVisitor<T>(_ visitor: T) -> T.VisitorReturnType where T : ExprVisitor { visitor.visitLiteralExpr(expr: self) }
}
