//
//  MainProgram.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 4/9/2022.
//

import Foundation

class MainProgram {
    let consoleIO = ConsoleIO()
    
    func mainLoop() {
        consoleIO.showPrompt()
        
        while let input = readLine() {
            run(input)
            
            consoleIO.showPrompt()
        }
    }
}

extension MainProgram {
    static let exitPrompt = [":quit", ":q"]
}

extension MainProgram {
    func run(_ input: String) {
        switch input {
        case _ where Self.exitPrompt.contains(input): exit(0)
        default: consoleIO.writeMessage("Input: \(input)")
        }
    }
}
