//
//  ASTPrinter.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 2/2/2023.
//

import Foundation

struct ASTPrinter {
    func print(_ expr: Expr) -> String { try! expr.acceptVisitor(self) }
}

extension ASTPrinter {
    /// Builder pattern used to construct output
    private func parenthesize(name: String, _ exprs: Expr...) -> String {
        var builder = ""
        
        builder.append("(" + name)
        
        for expr in exprs {
            builder.append(" ")
            builder.append(try! expr.acceptVisitor(self))
        }
        
        builder.append(")")
        
        return builder
    }
}

extension ASTPrinter: ExprVisitor {
    func visitBinaryExpr(expr: BinaryExpr) -> String {
        parenthesize(name: expr.operator.lexme.rawValue, expr.lhs, expr.rhs)
    }
    
    func visitUnaryExpr(expr: UnaryExpr) -> String {
        parenthesize(name: expr.operator.lexme.rawValue, expr.rhs)
    }
    
    func visitGroupingExpr(expr: GroupingExpr) -> String {
        // TODO: The below parameter for expression is confusing. Consider changing the parent function argument to groupExpr
        parenthesize(name: "group", expr.expr)
    }
    
    func visitLiteralExpr(expr: LiteralExpr) -> String {
        expr.literal.description
    }
}
