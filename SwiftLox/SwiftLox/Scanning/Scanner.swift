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
                    case "\n", "\0":
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
        }
        else { throw MainProgram.ErrorType.unexpectedChar }
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
    private var nextIndex: String.Index { source.index(after: currentIndex) }
}
