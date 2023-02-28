//
//  LexmeTests.swift
//  SwiftLoxTests
//
//  Created by Ranveer Mamidpelliwar on 24/2/2023.
//

import XCTest

final class LexmeTests: XCTestCase {
    let concreteLexmeGroupsMeta: [any LexmeGroup.Type] = {
        var groups = [any LexmeGroup.Type]()
        Lexme.allCases.forEach { lexme in
            lexme.derivedCases.forEach { concreteGroup in
                let groupType = type(of: concreteGroup)
                if groups.first(where: { $0 == groupType }) == nil { groups.append(groupType)  }
            }
        }
        
        return groups
    }()
    
    
    override func setUpWithError() throws { }
    
    override func tearDownWithError() throws { }
    
    /// All the cases within conforming `LexmeGroup` must match the relevant case from `Lexme` (source of truth)
    func test_lexmeGroupsCaseValidity() {
        /// Given
        /// Cases from conforming types of `LexmeGroup`
        
        /// When
        concreteLexmeGroupsMeta.forEach { lexmeGroupMeta in
            lexmeGroupMeta.allCases.forEach { lexmeGroupCase in
                let lexmeGroupCaseCasted = lexmeGroupCase as! (any LexmeGroup)
                
                /// Then
                XCTAssertEqual("\(lexmeGroupCaseCasted)", "\(lexmeGroupCaseCasted.lexme)",
                               "Case \(lexmeGroupCaseCasted) from \(lexmeGroupMeta) specifies source of truth lexme to be \(lexmeGroupCaseCasted.lexme), which does not match.")
            }
        }
    }
    
    /**
     This test ensures all the derived cases are accounted for within the `derivedCases` property of the source of truth
     
     Matching condition-
     - Case inspected within derived case matches case within `derivedCases` (source of truth)
     - Group for above inspected case matches group within `derivedCases` (source of truth)
     */
    func test_lexmeGroupCaseAccountedInSourceOfTruth() {
        /// Given
        
        /// When
        concreteLexmeGroupsMeta.forEach { lexmeGroupMeta in
            lexmeGroupMeta.allCases.forEach { lexmeGroupCase in
                let lexmeGroupCaseCasted = lexmeGroupCase as! (any LexmeGroup)
                
                /// Then
                let matchingComponents = lexmeGroupCaseCasted.lexme.derivedCases.filter {
                    "\($0)" == "\(lexmeGroupCaseCasted)" && "\(type(of: $0))" == "\(type(of: lexmeGroupCaseCasted))"
                }
                XCTAssertFalse(matchingComponents.count == 0, "Derived case \(lexmeGroupCase) within \(lexmeGroupMeta) is not accounted for in source of truth")
                XCTAssertFalse(matchingComponents.count > 1, "Multiple redundant declarations of case \(lexmeGroupCase) within \(lexmeGroupMeta) source of truth")
//                XCTAssertNotNil(matchingComponents, "Derived case \(lexmeGroupCase) within \(lexmeGroupCaseCasted) does not match")
            }
        }
    }
}
