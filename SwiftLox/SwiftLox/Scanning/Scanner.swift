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
        /*:
         Note: Alternative pattern- `case _ where SingleCharToken.rawTokens.contains(currentChar):`
         */
        if let tokenType = SingleCharToken(rawValue: currentChar.asString) {
            addToken(type: tokenType)
        } else if let tokenType = PotentiallyMuliCharOperatorToken(rawValue: currentChar.asString) {
            if nextCharMatches(PotentiallyMuliCharOperatorToken.succeedingTokenRawForMultiCharOperator) {
                advanceCurrentIndex()
                addToken(type: tokenType.matchingMultiCharOperator)
            } else { addToken(type: tokenType) }
        } else if let tokenType = SpecialOperatorToken(rawValue: currentChar.asString) {
            /// Comment
            if nextCharMatches(SpecialOperatorToken.slash.rawValue) {
                /// Note that while `isAtEnd` is checked prior to invoking `scanToken` in `scanForTokens`, the below loop also advances `currentIndex`, for which reason this condition needs to be evaluated again.
            commentLoop: while !isAtEnd() {
                    switch peekAtNextChar().asString {
                    /// Newline escapes loop and and enters the "non-Token" branch to implement new line logic
                    case NonTokenInputs.newLine.rawValue, "\0":
                        startIndex = currentIndex
                        break commentLoop
                    default: advanceCurrentIndex()
                    }
                }
            } else { addToken(type: tokenType) }
        } else if let nonToken = NonTokenInputs(rawValue: currentChar.asString) {
            switch nonToken {
            case .newLine: line += 1
            default: break
            }
        } else if currentChar.asString == Literals.string.rawValue {
            /// String Literals
            var newLinesInLiteral = 0
            
            /// Opening `"`
            advanceCurrentIndex()
            while !isAtEnd() && peekAtNextChar().asString != Literals.string.rawValue {
                if peekAtNextChar().asString == NonTokenInputs.newLine.rawValue { newLinesInLiteral += 1 }
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
            if peekAtNextChar().asString == SingleCharToken.dot.rawValue {
                advanceCurrentIndex()
                /// Require at least 1 number after decimal point
                guard isNextCharANumber else { throw MainProgram.ErrorType.unexpectedChar(line)  }
                advanceUntilNextCharIsNotDigit()
            }
            
            let numberLiteral = literalFromIndicies
            /// Pre-emptively checking if literal can be converted to a double precision floating point
            if Double(numberLiteral) == nil { throw MainProgram.ErrorType.unableToDetermineNumber(line) }
            addToken(type: Literals.number, literal: numberLiteral)
        } else if isCharStartOfAnIdentifier(currentChar) {
            /// Identifiers- matched using **maximal munch principle**, to ensure it recieves preference over keywords
            advanceUntilNextCharIsNotAnIdentifier()
            if let keyword = keywordFromIndicies { addToken(type: keyword) }
            else { addToken(type: Literals.identifier, literal: literalFromIndicies) }
        } else { throw MainProgram.ErrorType.unexpectedChar(line) }
    }
    
    private func addToken(type tokenType: TokenType) {
        addToken(type: tokenType, literal: nil)
    }
    
    private func addToken(type tokenType: TokenType, literal: String?) {
        let tokenToAdd = Token(tokenType: tokenType, lexme: literalFromIndicies, literal: literal, line: line)
        tokens.append(tokenToAdd)
    }
    
    private func nextCharMatches(_ inputChar: String) -> Bool {
        if isAtEnd() { return false }
        
        return peekAtNextChar().asString == inputChar
    }
    
    private func peekAtNextChar() -> Character {
        if nextIndex == source.endIndex { return "\0" }
        else { return source[nextIndex] }
    }
    
    
    private func isCharStartOfAnIdentifier(_ inputCharacter: Character) -> Bool {
        /// The start of an identiifier can be part of the specified alphabet or be `_`
        isAlphabet(inputCharacter) || inputCharacter == Character("_")
    }
    
    private func isAtEnd() -> Bool { currentIndex == source.endIndex }
    private func advanceCurrentIndex() { currentIndex = nextIndex }
    private func advanceUntilNextCharIsNotDigit() { while !isAtEnd() && isNextCharANumber { advanceCurrentIndex() } }
    private var nextIndex: String.Index { source.index(after: currentIndex) }
    private var isNextCharANumber: Bool { peekAtNextChar().isNumber }
    private var isCurrentCharANumber: Bool { currentChar.isNumber }
    private var currentChar: Character { source[currentIndex] }
    private var alphabetCharacterRegex: Regex<Substring> { /[a-zA-Z]/ }
    private func isAlphabet(_ inputCharacter: Character) -> Bool { !inputCharacter.asString.matches(of: alphabetCharacterRegex).isEmpty }
    private func isNextCharPartOfAnIdentifier() -> Bool { isNextCharANumber || isCharStartOfAnIdentifier(peekAtNextChar()) }
    private func advanceUntilNextCharIsNotAnIdentifier() { while !isAtEnd() && isNextCharPartOfAnIdentifier() { advanceCurrentIndex() } }
    private var literalFromIndicies: String { String(source[startIndex...currentIndex]) }
    private var keywordFromIndicies: Keyword? { Keyword(rawValue: literalFromIndicies) }
}

fileprivate extension Character {
    var asString: String { String(self) }
}
