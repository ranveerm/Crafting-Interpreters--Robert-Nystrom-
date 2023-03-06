//
//  ParserTests.swift
//  SwiftLoxTests
//
//  Created by Ranveer Mamidpelliwar on 28/2/2023.
//

import XCTest

final class ParserTests: XCTestCase {
    override func setUpWithError() throws { }
    override func tearDownWithError() throws { }
    
    /// Parsing `1 + 1`
    func test_parserBinaryExpression() throws {
        /// Given
        let lineNumber = 1
        let tokens: [any AbstractToken] = [
            Token(lexmeGroup: LexmeProductionTerminal.number, literal: "4", line: lineNumber),
            Token(lexmeGroup: LexmeBinaryOperator.plus, line: lineNumber),
            Token(lexmeGroup: LexmeProductionTerminal.number, literal: "2", line: lineNumber),
            Token(lexmeGroup: LexmeEndSignifier.eof, line: lineNumber)
        ]
        let expectedExpr = BinaryExpr(
            lhs: LiteralExpr(type: Token(lexmeGroup: LexmeProductionTerminal.number, literal: "4", line: lineNumber)),
            rhs: LiteralExpr(type: Token(lexmeGroup: LexmeProductionTerminal.number, literal: "2", line: lineNumber)),
            operator: Token(lexmeGroup: LexmeBinaryOperator.plus, line: lineNumber)
        )
        
        
        /// When
        let parsedExprs = Parser(tokens).parse()
        
        /// Then
        if let computedExpr = parsedExprs.first as? BinaryExpr,
           let computedExprLhs = computedExpr.lhs as? LiteralExpr,
           let computedExprRhs = computedExpr.rhs as? LiteralExpr {
            XCTAssertEqual(expectedExpr.lhs as! LiteralExpr, computedExprLhs)
            XCTAssertEqual(expectedExpr.rhs as! LiteralExpr, computedExprRhs)
            XCTAssertEqual(expectedExpr.operator, computedExpr.operator)
        }
        else { XCTFail("\(expectedExpr) is not the same type as \(parsedExprs)") }
    }
    
    /// Parsing 12/(345-6789*"mock")
    func test_parseStatement() {
        /// Given
        let lineNumber = 1
        let tokens: [any AbstractToken] = [
            Token(lexmeGroup: LexmeProductionTerminal.number, literal: "12", line: lineNumber),
            Token(lexmeGroup: LexmeBinaryOperator.slash, line: lineNumber),
            Token(lexmeGroup: LexmeProductionTerminal.leftParenthesis, line: lineNumber),
            Token(lexmeGroup: LexmeProductionTerminal.number, literal: "345", line: lineNumber),
            Token(lexmeGroup: LexmeBinaryOperator.minus, line: lineNumber),
            Token(lexmeGroup: LexmeProductionTerminal.number, literal: "6789", line: lineNumber),
            Token(lexmeGroup: LexmeBinaryOperator.star, line: lineNumber),
            Token(lexmeGroup: LexmeProductionTerminal.string, literal: "mock", line: lineNumber),
            Token(lexmeGroup: LexmeEndSignifier.rightParenthesis, line: lineNumber),
            Token(lexmeGroup: LexmeEndSignifier.eof, line: lineNumber)
        ]
        let expectedExpr = BinaryExpr(
            lhs: LiteralExpr(type: Token(lexmeGroup: LexmeProductionTerminal.number, literal: "12", line: lineNumber)),
            rhs: GroupingExpr(expr: BinaryExpr(
                lhs: LiteralExpr(type: Token(lexmeGroup: LexmeProductionTerminal.number, literal: "345", line: lineNumber)),
                rhs: BinaryExpr(
                    lhs: LiteralExpr(type: Token(lexmeGroup: LexmeProductionTerminal.number, literal: "6789", line: lineNumber)),
                    rhs: LiteralExpr(type: Token(lexmeGroup: LexmeProductionTerminal.string, literal: "mock", line: lineNumber)),
                    operator: Token(lexmeGroup: LexmeBinaryOperator.star, line: lineNumber)),
                operator: Token(lexmeGroup: LexmeBinaryOperator.minus, line: lineNumber))),
            operator: Token(lexmeGroup: LexmeBinaryOperator.slash, line: lineNumber))
        
        /// Then
        let parsedExprs = Parser(tokens).parse()
        
        /// When
        if let computedExprRoot = parsedExprs.first as? BinaryExpr,
           let computedExprParentLhs = computedExprRoot.lhs as? LiteralExpr,
           let computedExprParentRhs = computedExprRoot.rhs as? GroupingExpr,
           let computedExprGroup = computedExprParentRhs.expr as? BinaryExpr,
           let computedExprGroupLhs = computedExprGroup.lhs as? LiteralExpr,
           let computedExprLeaf = computedExprGroup.rhs as? BinaryExpr,
           let computedExprLeafLhs = computedExprLeaf.lhs as? LiteralExpr,
           let computedExprLeafRhs = computedExprLeaf.rhs as? LiteralExpr {
            XCTAssertEqual(expectedExpr.lhs as! LiteralExpr, computedExprParentLhs)
            XCTAssertEqual(expectedExpr.operator, computedExprRoot.operator)
            
            let expectedExprGroup = (expectedExpr.rhs as! GroupingExpr).expr as! BinaryExpr
            XCTAssertEqual(expectedExprGroup.lhs as! LiteralExpr, computedExprGroupLhs)
            XCTAssertEqual(expectedExprGroup.operator, computedExprGroup.operator)
            
            let expectedExprLeaf = expectedExprGroup.rhs as! BinaryExpr
            XCTAssertEqual(expectedExprLeaf.lhs as! LiteralExpr, computedExprLeafLhs)
            XCTAssertEqual(expectedExprLeaf.rhs as! LiteralExpr, computedExprLeafRhs)
            XCTAssertEqual(expectedExprLeaf.operator, computedExprLeaf.operator)
        }
        else { XCTFail("") }
    }
}


