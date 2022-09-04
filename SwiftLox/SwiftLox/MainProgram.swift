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
        while true {
            consoleIO.showPrompt()
            
            if let input = readLine() {
                print("Your input: \(input)")
            }
        }
    }
}
