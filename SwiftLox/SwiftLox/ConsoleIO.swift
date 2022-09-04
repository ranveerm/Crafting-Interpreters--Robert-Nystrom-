//
//  ConsoleIO.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 4/9/2022.
//

import Foundation

class ConsoleIO {
    enum OutputType {
        case standard
        case error
    }
    
    var promptString = "> "
    
    func writeMessage(_ message: String, to outputType: OutputType = .standard, terminator: String = "\n") {
        switch outputType {
        case .standard: print("\(message)", terminator: terminator)
        case .error: fputs("Error: \(message)\n", stderr)
        }
    }
    
    func showPrompt() {
        writeMessage(promptString, terminator: "")
    }
    
    func printUsage() {
        writeMessage("usage: ")
        writeMessage("<executableName> <root dir>")
        writeMessage("")
    }
}
