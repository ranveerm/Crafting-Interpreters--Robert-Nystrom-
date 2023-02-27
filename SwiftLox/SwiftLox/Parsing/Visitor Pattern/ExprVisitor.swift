//
//  ExprVisitory.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 1/2/2023.
//

import Foundation

/**
 Blueprint for the [Visitor Pattern]() relevant to ``Expr`` conforming type.
 
 
 */
protocol ExprVisitor {
    associatedtype VisitorReturnType
    
    func visitBinaryExpr(expr: BinaryExpr) throws -> VisitorReturnType
    func visitUnaryExpr(expr: UnaryExpr) throws -> VisitorReturnType
    func visitGroupingExpr(expr: GroupingExpr) throws -> VisitorReturnType
    func visitLiteralExpr(expr: LiteralExpr) throws -> VisitorReturnType
}
