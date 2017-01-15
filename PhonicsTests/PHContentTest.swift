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
            XCTAssertNotNil(sound.rhymeText, "Missing rhyme text for \(sound.puzzleName).")
            
            let audioName = sound.rhymeAudioName
            XCTAssert(UAFileExists(name: audioName, ofType: "mp3"), "Missing rhyme audio for \(sound.puzzleName).")
        }
    }
    
    func testAllSoundsHavePronunciations() {
        for sound in PHContent.allSoundsSorted {
            XCTAssertNotNil(sound.ipaPronunciation, "\(sound.sourceLetter) (\(sound.soundId)) has no IPA pronunciation.")
        }
    }
    
    
    //MARK: - Words
    
    func testAllWordsHaveImages() {
        for word in PHContent.allWordsNoDuplicates {
            XCTAssertNotNil(word.image, "\(word.text) has no image.")
        }
    }
    
    func testForUnusedWordImages() {
        
        let images = Bundle.main.paths(forResourcesOfType: "jpg", inDirectory: nil, forLocalization: nil)
        let allWords = PHContent.allWords
        
        let imageNames = images.map { filePath -> String in
            let pathParts = filePath.components(separatedBy: "/")
            guard let fileName = pathParts.last else { return filePath }
            guard let withoutExtension: String = fileName.components(separatedBy: ".").first else { return fileName }
            return withoutExtension
        }
        
        for imageName in imageNames {
            let hasMatchingWord = allWords.contains(where: { $0.text == imageName })
            
            if !hasMatchingWord { print("\(imageName).jpg") }
            
            //XCTAssert(hasMatchingWord, "\(imageName).jpg is unused.")
        }
        
    }
    
    func testAllWordsHavePronunciations() {
        for word in PHContent.allWordsNoDuplicates {
            XCTAssertNotNil(word.pronunciation, "\(word.text) has no IPA pronunciation.")
        }
    }
    
}
