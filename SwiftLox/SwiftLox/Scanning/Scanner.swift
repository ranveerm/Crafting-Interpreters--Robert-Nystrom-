//
//  Scanner.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 13/11/2022.
//

import Foundation

class Scanner {
    private let source: String
    private(set) var tokens = [any AbstractToken]()
    
    private lazy var startIndex = source.startIndex
    private lazy var currentIndex = source.startIndex
    private var line = 1
    
    init(_ source: String) {
        self.source = source
    }
}

extension Scanner {
    @discardableResult func scanForTokens() throws -> [any AbstractToken] {
        initialiseStateForScanning()
        
        if !source.isEmpty {
            while !isAtEnd() {
                startIndex = currentIndex
                try scanToken()
                advanceCurrentIndex()
            }
        }
        
        tokens.append(Token(lexmeGroup: LexmeEndSignifier.eof, line: line))
        return tokens
    }
    
    private func initialiseStateForScanning() {
        tokens = []
        startIndex = source.startIndex
        currentIndex = source.startIndex
        line = 1
    }
    
    private var lexmeFromCurrentChar: Lexme? { Lexme(rawValue: currentChar.asString) }
    private func scanToken() throws {
        /*:
         Note: Alternative pattern- `case _ where SingleCharToken.rawTokens.contains(currentChar):`
         */
        if let singleCharLexme = lexmeFromCurrentChar?.checkMembership(for: LexmeSingleChar.self) {
            addToken(for: singleCharLexme)
        } else if let potentiallyMuliCharOperatorLexme = lexmeFromCurrentChar?.checkMembership(for: LexmePotentiallyMuliCharOperator.self) {
            if nextCharMatches(LexmePotentiallyMuliCharOperator.succeedingRawCharForMultiCharOperator) {
                advanceCurrentIndex()
                addToken(for: potentiallyMuliCharOperatorLexme.matchingMultiCharOperator)
            } else { addToken(for: potentiallyMuliCharOperatorLexme) }
        } else if let specialOperatorLexme = lexmeFromCurrentChar?.checkMembership(for: LexmeSpecialOperator.self) {
            /// Comment
            if nextCharMatches(LexmeSpecialOperator.commentStart) {
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
            } else { addToken(for: specialOperatorLexme) }
        } else if let nonToken = NonTokenInputs(rawValue: currentChar.asString) {
            switch nonToken {
            case .newLine: line += 1
            default: break
            }
        } else if lexmeFromCurrentChar?.rawValue == LexmeLiteral.stringTerminals {
            /// String Literals
            var newLinesInLiteral = 0
            
            /// Opening `"`
            advanceCurrentIndex()
            while !isAtEnd() && peekAtNextChar().asString != LexmeLiteral.stringTerminals {
                if peekAtNextChar().asString == NonTokenInputs.newLine.rawValue { newLinesInLiteral += 1 }
                advanceCurrentIndex()
            }
            
            guard !isAtEnd() else { throw MainProgram.ErrorType.unterminatedString(line) }
            
            /// Closing `"`
            advanceCurrentIndex()
            let literalStartIndex = source.index(after: startIndex)
            let stringLiteral = source[literalStartIndex..<currentIndex]
            addToken(for: LexmeLiteral.string.groupForToken, literal: String(stringLiteral))
            
            line += newLinesInLiteral
        } else if currentChar.isNumber {
            /// Numeric Literals
            advanceUntilNextCharIsNotDigit()
            if peekAtNextChar().asString == LexmeLiteral.numericDecimalSeparator {
                advanceCurrentIndex()
                /// Require at least 1 number after decimal point
                guard isNextCharANumber else { throw MainProgram.ErrorType.unexpectedChar(line)  }
                advanceUntilNextCharIsNotDigit()
            }
            
            let numberLiteral = literalFromIndicies
            /// Pre-emptively checking if literal can be converted to a double precision floating point
            if Double(numberLiteral) == nil { throw MainProgram.ErrorType.unableToDetermineNumber(line) }
            addToken(for: LexmeLiteral.number.groupForToken, literal: numberLiteral)
        } else if isCharStartOfAnIdentifier(currentChar) {
            /// Identifiers- matched using **maximal munch principle**, to ensure it recieves preference over keywords
            advanceUntilNextCharIsNotAnIdentifier()
            if let lexmeKeyword = keywordFromIndicies { addToken(for: lexmeKeyword) }
            else { addToken(for: LexmeLiteral.identifier, literal: literalFromIndicies) }
        } else if let endSignifierLexme  = lexmeFromCurrentChar?.checkMembership(for: LexmeEndSignifier.self) {
            // TODO: Determine course of action if `eof` is part of input
            addToken(for: endSignifierLexme, literal: nil)
        } else { throw MainProgram.ErrorType.unexpectedChar(line) }
    }
    
    private func addToken<T: LexmeGroup>(for lexmeGroup: T) {
        addToken(for: lexmeGroup, literal: nil)
    }
    
    private func addToken<T: LexmeGroup>(for lexmeGroup: T, literal: String?) {
        let tokenToAdd = Token(lexmeGroup: lexmeGroup, literal: literal, line: line)
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
    private var keywordFromIndicies: LemeKeyword? { Lexme(rawValue: literalFromIndicies)?.checkMembership(for: LemeKeyword.self) }
}

fileprivate extension Character {
    var asString: String { String(self) }
}

extension Scanner: CustomStringConvertible {
    private var leadingPadding: String { "".padding(toLength: 4, withPad: " ", startingAt: 0) }
    
    var description: String {
        let header = leadingPadding + "Line".padding(toLength: 6, withPad: " ", startingAt: 0) + "Description".padding(toLength: 29, withPad: " ", startingAt: 0) + "Lexme\n"
        let headerDivider = leadingPadding + String(repeating: "-", count: 40) + "\n"
        let tokensPrinted: String = tokens.reduce("") { $0 + leadingPadding + $1.description + "\n" }
        return "Token:\n" + header + headerDivider + tokensPrinted
    }
}
