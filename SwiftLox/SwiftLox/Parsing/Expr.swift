//
//  Expr.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 21/11/2022.
//

import Foundation

/**
 Container to server as a mechanism to **group** concrete expression types.
 - Note: There is no specification for state or method as the concept of expression by this protocol purely serves as a grouping mechanism. However, it does act as an Visitor interface for expression types (see [Visitor Pattern](https://refactoring.guru/design-patterns/visitor) for more details).
 */
protocol Expr {
    func acceptVisitor<T: ExprVisitor>(_ visitor: T) throws -> T.VisitorReturnType
}

// MARK: Concrete Types

struct BinaryExpr: Expr {
    let lhs: Expr
    let rhs: Expr
    let `operator`: Token<LexmeBinaryOperator>
    
    func acceptVisitor<T>(_ visitor: T) throws -> T.VisitorReturnType where T : ExprVisitor { try visitor.visitBinaryExpr(expr: self) }
}

struct UnaryExpr: Expr {
    let `operator`: Token<LexmeUnaryOperator>
    let rhs: Expr
    
    func acceptVisitor<T>(_ visitor: T) throws -> T.VisitorReturnType where T : ExprVisitor { try visitor.visitUnaryExpr(expr: self) }
}

// Todo: Determine if tokens for `(` and `)` need to be stored (currently they are discarded)
struct GroupingExpr: Expr {
    let expr: Expr
    
    func acceptVisitor<T>(_ visitor: T) throws -> T.VisitorReturnType where T : ExprVisitor { try visitor.visitGroupingExpr(expr: self) }
}

// Todo: determine if there is value in `literal` property when `type.literal` (in ``Token`` object) contains the same value. In addition, there is no synchronisation mechanism between these values.
/// **Syntax tree node**, forming the atomic component that all other expressions are composed from.
struct LiteralExpr: Expr, Equatable {
    let type: Token<LexmeProductionTerminal>
    var literal: String { type.literal }
    
    func acceptVisitor<T>(_ visitor: T) throws -> T.VisitorReturnType where T : ExprVisitor { try visitor.visitLiteralExpr(expr: self) }
}
