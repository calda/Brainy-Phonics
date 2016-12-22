//
//  PhonicsTests.swift
//  PhonicsTests
//
//  Created by Cal on 8/10/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import XCTest

class PHContentTest: XCTestCase {
    
    
    //MARK: - Sounds
    
    func testAllSoundsHavePuzzles() {
        for sound in PHContent.allSounds {
            XCTAssertNotNil(sound.puzzle, "Puzzle \(sound.puzzleName) doesn't exist.")
            
            if sound.puzzle == nil {
                print("nil puzzle:")
                print(sound)
            }
        }
    }
    
    
    //MARK: - Words
    
    func testAllWordsHaveImages() {
        for word in PHContent.allWordsNoDuplicates {
            XCTAssertNotNil(word.image, "\(word.text) has no image.")
        }
    }
    
    func testAllWordsHavePronunciations() {
        for word in PHContent.allWordsNoDuplicates {
            XCTAssertNotNil(word.pronunciation, "\(word.text) has no IPA pronunciation.")
        }
    }
    
    func testAllWordsHaveAudio() {
        
    }
    
}
