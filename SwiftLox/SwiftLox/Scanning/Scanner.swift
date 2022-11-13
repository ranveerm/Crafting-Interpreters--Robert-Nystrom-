//
//  Scanner.swift
//  SwiftLox
//
//  Created by Ranveer Mamidpelliwar on 13/11/2022.
//

import Foundation

struct Scanner {
    private let source: String
    private var tokens = [Token]()
    
    init(_ source: String) {
        self.source = source
    }
}
