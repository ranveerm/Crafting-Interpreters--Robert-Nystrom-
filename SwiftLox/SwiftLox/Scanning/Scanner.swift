//
//  Scanner.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 13/11/2022.
//

import Foundation

class Scanner {
    private let source: String
    private(set) var tokens = [Token]()
    
    private lazy var startIndex = source.startIndex
    private lazy var currentIndex = source.startIndex
    private var line = 1
    
    init(_ source: String) {
        self.source = source
    }
}

extension Scanner {
    func scanForTokens() throws -> [Token] {
        initialiseStateForScanning()
        
        if !source.isEmpty {
            while !isAtEnd() {
                startIndex = currentIndex
                try scanToken()
                advanceCurrentIndex()
            }
        }
        
        tokens.append(Token(tokenType: SpecialToken.eof, lexme: "", literal: nil, line: line))
        return tokens
    }
    
    private func initialiseStateForScanning() {
        tokens = []
        startIndex = source.startIndex
        currentIndex = source.startIndex
        line = 1
    }
    
    private func scanToken() throws {
        let currentChar = String(source[currentIndex])
        
        /*:
         Note: Alternative pattern- `case _ where SingleCharToken.rawTokens.contains(currentChar):`
         */
        if let tokenType = SingleCharToken(rawValue: currentChar) {
            addToken(type: tokenType)
        } else if let tokenType = PotentiallyMuliCharOperatorToken(rawValue: currentChar) {
            if nextCharMatches(PotentiallyMuliCharOperatorToken.succeedingTokenRawForMultiCharOperator) {
                advanceCurrentIndex()
                addToken(type: tokenType.matchingMultiCharOperator)
            } else { addToken(type: tokenType) }
        } else if let tokenType = SpecialOperatorToken(rawValue: currentChar) {
            /// Comment
            if nextCharMatches(SpecialOperatorToken.slash.rawValue) {
                /// Note that while `isAtEnd` is checked prior to invoking `scanToken` in `scanForTokens`, the below loop also advances `currentIndex`, for which reason this condition needs to be evaluated again.
            commentLoop: while !isAtEnd() {
                    switch peekAtNextChar() {
                    /// Newline escapes loop and and enters the "non-Token" branch to implement new line logic
                    case NonTokenInputs.newLine.rawValue, "\0":
                        startIndex = currentIndex
                        break commentLoop
                    default: advanceCurrentIndex()
                    }
                }
            } else { addToken(type: tokenType) }
        } else if let nonToken = NonTokenInputs(rawValue: currentChar) {
            switch nonToken {
            case .newLine: line += 1
            default: break
            }
        } else if currentChar == Literals.string.rawValue {
            /// String Literals
            var newLinesInLiteral = 0
            
            /// Opening `"`
            advanceCurrentIndex()
            while !isAtEnd() && peekAtNextChar() != Literals.string.rawValue {
                if peekAtNextChar() == NonTokenInputs.newLine.rawValue { newLinesInLiteral += 1 }
                advanceCurrentIndex()
            }
            
            guard !isAtEnd() else { throw MainProgram.ErrorType.unterminatedString(line) }
            
            /// Closing `"`
            advanceCurrentIndex()
            let literalStartIndex = source.index(after: startIndex)
            let stringLiteral = source[literalStartIndex..<currentIndex]
            addToken(type: Literals.string, literal: String(stringLiteral))
            
            line += newLinesInLiteral
        } else if currentChar.isNumber {
            /// Numeric Literals
            advanceUntilNextCharIsNotDigit()
            if peekAtNextChar() == SingleCharToken.dot.rawValue {
                advanceCurrentIndex()
                /// Require at least 1 number after decimal point
                guard isNextCharANumber else { throw MainProgram.ErrorType.unexpectedChar(line)  }
                advanceUntilNextCharIsNotDigit()
            }
            
            let numberLiteral = String(source[startIndex...currentIndex])
            /// Pre-emptively checking if literal can be converted to a double precision floating point
            if Double(numberLiteral) == nil { throw MainProgram.ErrorType.unableToDetermineNumber(line) }
            addToken(type: Literals.number, literal: numberLiteral)
        } else { throw MainProgram.ErrorType.unexpectedChar(line) }
    }
    
    private func addToken(type tokenType: TokenType) {
        addToken(type: tokenType, literal: nil)
    }
    
    private func addToken(type tokenType: TokenType, literal: String?) {
        let lexme = source[startIndex...currentIndex]
        let tokenToAdd = Token(tokenType: tokenType, lexme: String(lexme), literal: literal, line: line)
        tokens.append(tokenToAdd)
    }
    
    private func nextCharMatches(_ inputChar: String) -> Bool {
        if isAtEnd() { return false }
        
        return peekAtNextChar() == inputChar
    }
    
    private func peekAtNextChar() -> String {
        if nextIndex == source.endIndex { return "\0" }
        else { return String(source[nextIndex]) }
    }
    
    private func isAtEnd() -> Bool { currentIndex == source.endIndex }
    private func advanceCurrentIndex() { currentIndex = nextIndex }
    private func advanceUntilNextCharIsNotDigit() { while !isAtEnd() && isNextCharANumber { advanceCurrentIndex() } }
    private var nextIndex: String.Index { source.index(after: currentIndex) }
    private var isNextCharANumber: Bool { Character(peekAtNextChar()).isNumber }
}
