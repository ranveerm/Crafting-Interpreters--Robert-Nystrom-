//
//  Parser.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 2/2/2023.
//

import Foundation

/**
 Implementation details-
 - [Recursive descent parser](https://en.wikipedia.org/wiki/Recursive_descent_parser)
    - Top-down parser- parsing is started at the outermost/top ("widest scope") grammar rule
 */
class Parser {
    private let tokens: [any AbstractToken]
    public var errors = [Parser.Error]()
    /// Signifies the index for the next toke to consume
    private var nextTokenIndex = 0
    
    init(_ tokens: [any AbstractToken]) {
        self.tokens = tokens
    }
}

extension Parser {
    func parse() -> [Expr] {
        var expressions = [Expr]()
        
        while !isAtEnd {
            do { expressions.append(try expression()) }
            catch {
                if let parserError = error as? Parser.Error { errors.append(parserError) }
                else { fatalError("Unknown state while parsing") }
                synchronise()
            }
        }
        
        return expressions
    }
}

// MARK: Grammar
/**
 # Grammar
 ```
 expression     → equality ;                                                              Lower         Top
 equality       → comparison ( ( "!=" | "==" ) comparison )* ;                              ▲            ▲
 comparison     → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;                              │            │
 term           → factor ( ( "-" | "+" ) factor )* ;                                   Precedence     Grammar
 factor         → unary ( ( "/" | "*" ) unary )* ;                                          │            │
 unary          → ( "!" | "-" ) unary | primary ;                                           ▼            ▼
 primary        → NUMBER | STRING | "true" | "false" | "nil" | "(" expression ")" ;      Higher       Bottom
 ```
 
 # Notes
 - CAPITALISED terminals are single lexme whose representation may vary (eg. NUMBER can be 42, 1, etc.)
 - Recursive (eg. `unary` production contains `unary` (eg. `!!<bool>`)
 - Production hierarhcy is specified at the **grammar level** and precedence level
 - Grammar level production hierarchy relatess to scope of production. Eg. `expression` contains the widest scope and is hence the outermost/top rule.
 - In order to disambiguate a string, the grammar specifies-
    - **Precedence**- each precedence level contains a rule and can only match the current precedence level or higher.
    - **Associativity**- left-associative (is a series containing the same operator, the left operator is evaluated first)
 - Flat sequence of lower precendence rules are preferred over left recursive rules for **pracrical purposes** (eg. `unary ( ( "/" | "*" ) unary )*` is preferred over `factor ( "/" | "*" ) unary | unary`, noting that both are semantically equivalent).
 */

// MARK: Rules
extension Parser {
    private func expression() throws -> Expr { try equality() }
    
    // MARK: Left-associative nested tree of binary operations
    private func equality() throws -> Expr {
        try parseLeftAssociativeNestedTreeOfBinaryOperations(matching: LexmeBinaryOperator.equality,
                                                         childExpression: comparison)
    }
    
    private func comparison() throws -> Expr {
        try parseLeftAssociativeNestedTreeOfBinaryOperations(matching: LexmeBinaryOperator.comparison,
                                                         childExpression: term)
    }
    
    private func term() throws -> Expr {
        try parseLeftAssociativeNestedTreeOfBinaryOperations(matching: LexmeBinaryOperator.term,
                                                         childExpression: factor)
    }
    
    private func factor() throws -> Expr {
        try parseLeftAssociativeNestedTreeOfBinaryOperations(matching: LexmeBinaryOperator.factor,
                                                         childExpression: unary)
    }
    
    private func unary() throws -> Expr {
        if let unaryOperatorToken = match(group: LexmeUnaryOperator.self) {
            let rhs = try unary()
            return UnaryExpr(operator: unaryOperatorToken, rhs: rhs)
        }
        else { return try primary() }
    }
    
    /// Important- This method forms the leaves of the AST and hence all the rulers higher in the grammer will eventually trickle to this method. If this method finds a token that can not start an expression, then the appropriate error needs to be thrown.
    private func primary() throws -> Expr {
        guard let primaryGroupingToken = match(group: LexmeProductionTerminal.self) else { throw Error(errorType: .expectExpression, line: currentlyParsedLine) }
        
        switch primaryGroupingToken.lexmeGroup {
        case .leftParenthesis:
            let groupedExpr = try expression()
            guard match(cases: [LexmeEndSignifier.rightParenthesis]) != nil else { throw Error(errorType: .rightParenthesisNotFound, line: currentlyParsedLine) }
            
            return GroupingExpr(expr: groupedExpr)
        default:
            return LiteralExpr(type: primaryGroupingToken)
        }
    }
}

extension Parser {
    /**
     Abstraction for parsing **left-associative nested tree of binary operations** class of output (eg. `term`, `factor`, etc.).
     
     The general format for production/rule encapsulated by this method in Backus–Naur form is `-> childExpression ((<binary operators to match> childExpression))*`. This equates to a flat sequence of binary operations at a specified precedence level (eg. `/` and `*`).
     ```
                          ┌────────────┐             ┌────────────┐                   ┌────────────┐
                          │            │             │            │                   │            │
        ┌───────┐         │   Binary   │     lhs     │   Binary   │             lhs   │   Binary   │
        │  lhs  │────────▶│  Operator  │────────────▶│  Operator  ├──▶   ...  ───────▶│  Operator  │
        └───────┘         │            │             │            │                   │            │
                          └────────────┘             └────────────┘                   └────────────┘
                                 ▲                          ▲                                ▲
                                 │                          │                                │
                                 │                          │                                │
                                 │                          │                                │
                             ┌───────┐                  ┌───────┐                        ┌───────┐
                             │  rhs  │                  │  rhs  │                        │  rhs  │
                             └───────┘                  └───────┘                        └───────┘
     ```
     */
    private func parseLeftAssociativeNestedTreeOfBinaryOperations(matching matchingOperators: [LexmeBinaryOperator],
                                                          childExpression: () throws -> Expr) throws -> Expr {
        var expr = try childExpression()
        
        while let matchedOperator = match(cases: matchingOperators) {
            let rhsExpr = try childExpression()
            /// After the first iteration, lhs represents nested tree of binary operations
            let lhsExpr = expr
            expr = BinaryExpr(lhs: lhsExpr, rhs: rhsExpr, operator: matchedOperator)
        }

        return expr
    }
}


// MARK: Helper Methods
extension Parser {
    /// Next token that is yet to be consumed
    private var peek: any AbstractToken { tokens[nextTokenIndex] }
    private var currentlyConsumedToken: any AbstractToken { tokens[nextTokenIndex - 1] }
    private var isAtEnd: Bool { peek.lexme == LexmeEndSignifier.endOfFile }
    private var currentlyParsedLine: Int {
        if nextTokenIndex == 0 { return 1 }
        else { return currentlyConsumedToken.line }
    }
    
    private func checkNext<T: LexmeGroup>(against group: T.Type) -> Bool {
        peek.lexme.checkMembership(for: group) != nil
    }
}

// MARK: Token Consumption
/// The below method all consume tokens, altering the state of the object
extension Parser {
    @discardableResult private func advance() -> any AbstractToken {
        if !isAtEnd { nextTokenIndex += 1 }
        return currentlyConsumedToken
    }
    
    // MARK: Token Matching Logic
    /// **Important**- The below methods handle matching tokens with specified inputs (with either `LexmeGroup.Type` or ``LexmeGroup`` instances). A match results in the token being returned. Note however, that the matching criteria isnt based on specialising `Token` to the specified input (eg. `peek as? Token<LexmeBinaryOperator>`). This is because semantics from the scanner might not necessarily match with the semantics of the Parser (for instance, the scanner will deep `+` to be an instance of ``LexmeSingleChar``, while the parser will view this as ``LexmeBinaryOperator``). As a result, `checkMembership` from ``Lexme`` is used to check raw values. This also has the added benefit of leveraging previously defined matching logic.
    
    private func match<T: LexmeGroup>(group lexmeGroupType: T.Type) -> Token<T>? {
        guard let tokenCasted = peek as? Token<T> else { return nil }
        advance()
        
        return tokenCasted
    }
    
    // TODO: Optimise
    private func match<T: LexmeGroup>(cases lexmeGroupCollection: [T]) -> Token<T>? {
        guard let nextTokenGroupCasted = peek.lexme.checkMembership(for: T.self) else { return nil }
        
        for lexmeGroup in lexmeGroupCollection {
            if nextTokenGroupCasted.lexme == lexmeGroup.lexme {
                advance()
                return Token(lexmeGroup: nextTokenGroupCasted, line: currentlyConsumedToken.line)
            }
        }
        return nil
    }
    
    /// Tokens discarded until a statement boundary is deemed to be found.
    private func synchronise() {
        advance()
        
        while !isAtEnd {
            if currentlyConsumedToken.lexme == LexmeEndSignifier.statementBoundary { return }
            
            let nextTokenType = peek.lexme
            guard nextTokenType.checkMembership(for: LexmeSynchronisation.self) == nil else { return }
            advance()
        }
    }
}
                

// MARK: Error Handling
extension Parser {
    struct Error: Swift.Error {
        let errorType: ErrorType
        let line: Int
        
        var localizedDescription: String { "[Line: \(line)] Syntax Error: \(errorType.description)" }
    }
    
    enum ErrorType {
        case rightParenthesisNotFound
        case expectExpression
        case literalValueNotPresentInToken
        
        var description: String {
            switch self {
            case .rightParenthesisNotFound: return "Expect ')' after expression"
            case .expectExpression: return "Expected expression"
            case .literalValueNotPresentInToken: return "Required literal value not present in token"
            }
        }
    }
}
