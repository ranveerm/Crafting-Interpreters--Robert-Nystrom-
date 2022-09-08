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
        default: consoleIO.writeMessage("Input: \(input)")
        }
    }
}

// MARK: Helper Methods
extension MainProgram {
    func reportError(line: Int, errorType: ErrorType, message: String) {
        consoleIO.writeMessage("[line \(line)] \(errorType): message", to: .error)
        hadError = true
    }
}

// MARK: Nested Types
extension MainProgram {
    enum ErrorType: CustomStringConvertible, Swift.Error {
        case mock
        
        var description: String {
            switch self {
            case .mock: return "Mock Error"
            }
        }
    }
}
