//
//  ScannerTests.swift
//  SwiftLoxTests
//
//  Created by Ranveer Mamidpelliwar on 14/11/2022.
//

import XCTest

final class ScannerTests: XCTestCase {
    var sut: Scanner!
    
    override func setUpWithError() throws {
        self.sut = Scanner("")
    }
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func test_scanForTokenBasic() throws {
        /// Given
        let mockLiteral = "Mock"
        let mockIdentifier = "mockIdentifier"
        let inputText = """
+ - {
*
< == (
// This is a comment
/ \t \n
"\(mockLiteral)"
"\(mockLiteral)
"
1 12 12.2
\(mockIdentifier) _\(mockIdentifier)
if \(mockIdentifier.uppercased()) ; else !
"""
        let sut = Scanner(inputText)
        let expectedTokens: [any AbstractToken] = [
            Token(lexmeGroup: LexmeSingleChar.plus, literal: nil, line: 1),
            Token(lexmeGroup: LexmeSingleChar.minus, literal: nil, line: 1),
            Token(lexmeGroup: LexmeSingleChar.leftBrace, literal: nil, line: 1),
            Token(lexmeGroup: LexmeSingleChar.star, literal: nil, line: 2),
            Token(lexmeGroup: LexmePotentiallyMuliCharOperator.less, literal: nil, line: 3),
            Token(lexmeGroup: LexmeMultiCharOperator.equalEqual, literal: nil, line: 3),
            Token(lexmeGroup: LexmeSingleChar.leftParenthesis, literal: nil, line: 3),
            Token(lexmeGroup: LexmeSpecialOperator.slash, literal: nil, line: 5),
            Token(lexmeGroup: LexmeProductionTerminal.string, literal: mockLiteral, line: 7),
            Token(lexmeGroup: LexmeProductionTerminal.string, literal: mockLiteral + "\n", line: 8),
            Token(lexmeGroup: LexmeProductionTerminal.number, literal: "1", line: 10),
            Token(lexmeGroup: LexmeProductionTerminal.number, literal: "12", line: 10),
            Token(lexmeGroup: LexmeProductionTerminal.number, literal: "12.2", line: 10),
            Token(lexmeGroup: LexmeLiteral.identifier, literal: "\(mockIdentifier)", line: 11),
            Token(lexmeGroup: LexmeLiteral.identifier, literal: "_\(mockIdentifier)", line: 11),
            Token(lexmeGroup: LemeKeyword.if, literal: nil, line: 12),
            Token(lexmeGroup: LexmeLiteral.identifier, literal: "\(mockIdentifier.uppercased())", line: 12),
            Token(lexmeGroup: LexmeEndSignifier.semicolon, literal: nil, line: 12),
            Token(lexmeGroup: LemeKeyword.else, literal: nil, line: 12),
            Token(lexmeGroup: LexmePotentiallyMuliCharOperator.bang, literal: nil, line: 12),
            Token(lexmeGroup: LexmeEndSignifier.eof, literal: nil, line: 12)
        ]
        
        /// When
        let computedTokens = try sut.scanForTokens()
        
        /// Then
        func sameType<T>(instance: Any, withType: T.Type) -> Bool {
            if instance is T { return true }
            else { return false }
        }
        
        zip(expectedTokens, computedTokens).forEach {
            XCTAssertEqual($0.lexme, $1.lexme, "Expected \($0.lexme), but found \($0.line)")
            // TODO: determine a more effective mechanism to check equality for `any LexmeGroup`
            XCTAssertEqual("\(type(of: $0.lexmeGroup))", "\(type(of: $1.lexmeGroup))", "Expected \(type(of: $0.lexmeGroup)), but found \(type(of: $1.lexmeGroup))")
            XCTAssertEqual($0.literal, $1.literal, "Expected \($0.literal ?? "nil"), but found \($1.literal ?? "nil")")
            XCTAssertEqual($0.line, $1.line, "Expected \($0.line), but found \($1.line)")
        }
    }
}
