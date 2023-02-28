//
//  ASTPrinterTests.swift
//  SwiftLoxTests
//
//  Created by Ranveer Mamidpelliwar on 2/2/2023.
//

import XCTest

final class ASTPrinterTests: XCTestCase {
    override func setUpWithError() throws { }
    
    override func tearDownWithError() throws { }
    
    func test_ASTPrinter() throws {
        /// Given
        let expectedOutput = "(* (- 123) (group 42.67))"
        let printer = ASTPrinter()
        let expression = BinaryExpr(lhs: UnaryExpr(operator: Token(lexmeGroup: LexmeUnaryOperator.minus, line: 1),
                                                   rhs: LiteralExpr(type: Token(lexmeGroup: LexmeProductionTerminal.number, line: 1), literal: "123")),
                                    rhs: GroupingExpr(expr: LiteralExpr(type: Token(lexmeGroup: LexmeProductionTerminal.number, line: 1), literal: "42.67")),
                                    operator: Token(lexmeGroup: LexmeBinaryOperator.star, line: 1))
        
        /// When
        let computedOutptut = try expression.acceptVisitor(printer)
        
        /// Then
        XCTAssertEqual(expectedOutput, computedOutptut)
    }
}
