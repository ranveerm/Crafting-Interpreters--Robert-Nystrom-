//
//  ASTPrinter.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 2/2/2023.
//

import Foundation

struct ASTPrinter: ExprVisitor {
    func print(_ expr: Expr) -> String { expr.acceptVisitor(self) }
}

extension ASTPrinter {
    /// Builder pattern used to construct output
    private func parenthesize(name: String, _ exprs: Expr...) -> String {
        var builder = ""
        
        builder.append("(" + name)
        
        for expr in exprs {
            builder.append(" ")
            builder.append(expr.acceptVisitor(self))
        }
        
        builder.append(")")
        
        return builder
    }
}

extension ASTPrinter {
    func visitBinaryExpr(expr: BinaryExpr) -> String {
        parenthesize(name: expr.operator.rawValue, expr.lhs, expr.rhs)
    }
    
    func visitUnaryExpr(expr: UnaryExpr) -> String {
        parenthesize(name: expr.operator.rawValue, expr.rhs)
    }
    
    func visitGroupingExpr(expr: GroupingExpr) -> String {
        // TODO: The below parameter for expression is confusing. Consider changing the parent function argument to groupExpr
        parenthesize(name: "group", expr.expr)
    }
    
    func visitLiteralExpr(expr: LiteralExpr) -> String {
        if expr.value.isEmpty { return "Emtpy Literal" }
        else { return expr.value }
    }
}
