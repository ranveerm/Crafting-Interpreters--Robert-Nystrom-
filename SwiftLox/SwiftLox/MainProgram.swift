//
//  MainProgram.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 4/9/2022.
//

import Foundation

class MainProgram {
    let consoleIO = ConsoleIO()
    var hadError = false
    
    func mainLoop() {
        consoleIO.showPrompt()
        
        while let input = readLine() {
            run(input)
            
            guard !hadError else { exit(64) }
            consoleIO.showPrompt()
        }
    }
}

// MARK: Configuration
extension MainProgram {
    static let exitPrompt = [":quit", ":q"]
}

// MARK: Primary Methods
extension MainProgram {
    func run(_ input: String) {
        switch input {
        case _ where Self.exitPrompt.contains(input): exit(0)
        default:
            consoleIO.writeMessage("Input: \(input)")
            
            consoleIO.writeMessage("--- Scanning ---")
            let scanner = Scanner(input)
            do {
                try scanner.scanForTokens()
                consoleIO.writeMessage(scanner.description)
            } catch {
                hadError = true
                if let error = error as? ErrorType {
                    reportError(line: error.reportedErrorLine, errorType: error)
                } else { consoleIO.writeMessage("Unknown error", to: .error) }
            }
        }
    }
}

// MARK: Helper Methods
extension MainProgram {
    func reportError(line: Int, errorType: ErrorType) {
        consoleIO.writeMessage("[line \(line)] \(errorType.localizedDescription)", to: .error)
        hadError = true
    }
}

// MARK: Nested Types
extension MainProgram {
    enum ErrorType: Error {
        case mock
        case unexpectedChar(Int)
        case unterminatedString(Int)
        case unableToDetermineNumber(Int)
        
        var localizedDescription: String {
            switch self {
            case .mock: return "Mock Error"
            case .unexpectedChar: return "Unexpected Character"
            case .unterminatedString: return "Unterminated String"
            case .unableToDetermineNumber: return "Unable to determine input number"
            }
        }
        
        var reportedErrorLine: Int {
            switch self {
            case .unexpectedChar(let line), .unterminatedString(let line), .unableToDetermineNumber(let line): return line
            case .mock: return 0
            }
        }
    }
}
