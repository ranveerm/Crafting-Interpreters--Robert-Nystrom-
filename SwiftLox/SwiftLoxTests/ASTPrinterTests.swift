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
        let expression = BinaryExpr(lhs: UnaryExpr(operator: SingleCharToken(rawValue: "-")!,
                                                   rhs: LiteralExpr(type: .number, value: "123")),
                                    rhs: GroupingExpr(expr: LiteralExpr(type: .number, value: "42.67")),
                                    operator: SingleCharToken(rawValue: "*")!)
        
        /// When
        let computedOutptut = expression.acceptVisitor(printer)
        
        /// Then
        XCTAssertEqual(expectedOutput, computedOutptut)
    }
}
