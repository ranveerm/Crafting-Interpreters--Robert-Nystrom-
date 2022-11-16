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
"""
        let sut = Scanner(inputText)
        let expectedTokens: [Token] = [
            Token(tokenType: SingleCharToken.plus, lexme: "+", literal: nil, line: 1),
            Token(tokenType: SingleCharToken.minus, lexme: "-", literal: nil, line: 1),
            Token(tokenType: SingleCharToken.leftBrace, lexme: "{", literal: nil, line: 1),
            Token(tokenType: SingleCharToken.star, lexme: "*", literal: nil, line: 2),
            Token(tokenType: PotentiallyMuliCharOperatorToken.less, lexme: "<", literal: nil, line: 3),
            Token(tokenType: MultiCharOperatorToken.equalEqual, lexme: "==", literal: nil, line: 3),
            Token(tokenType: SingleCharToken.leftParenthesis, lexme: "(", literal: nil, line: 3),
            Token(tokenType: SpecialOperatorToken.slash, lexme: "/", literal: nil, line: 5),
            Token(tokenType: Literals.string, lexme: "\"\(mockLiteral)\"", literal: mockLiteral, line: 7),
            Token(tokenType: Literals.string, lexme: "\"\(mockLiteral)\n\"", literal: mockLiteral + "\n", line: 8),
            Token(tokenType: Literals.number, lexme: "1", literal: "1", line: 10),
            Token(tokenType: Literals.number, lexme: "12", literal: "12", line: 10),
            Token(tokenType: Literals.number, lexme: "12.2", literal: "12.2", line: 10),
            Token(tokenType: Literals.identifier, lexme: "\(mockIdentifier)", literal: "\(mockIdentifier)", line: 11),
            Token(tokenType: Literals.identifier, lexme: "_\(mockIdentifier)", literal: "_\(mockIdentifier)", line: 11),
            Token(tokenType: SpecialToken.eof, lexme: "", literal: nil, line: 11)
        ]
        
        /// When
        let computedTokens = try sut.scanForTokens()
        
        /// Then
        zip(expectedTokens, computedTokens).forEach { XCTAssertEqual($0, $1) }
    }
}
