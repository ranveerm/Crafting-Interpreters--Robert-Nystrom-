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
    
    func visitBinaryExpr(expr: BinaryExpr) -> VisitorReturnType
    func visitUnaryExpr(expr: UnaryExpr) -> VisitorReturnType
    func visitGroupingExpr(expr: GroupingExpr) -> VisitorReturnType
    func visitLiteralExpr(expr: LiteralExpr) -> VisitorReturnType
}
