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
        for sound in PHContent.allSounds {
            XCTAssertNotNil(sound.ipaPronunciation, "\(sound.sourceLetter) (\(sound.soundId)) has no IPA pronunciation.")
        }
    }
    
    func testAllSoundsHaveWordSetAudio() {
        for sound in PHContent.allSounds {
            XCTAssert(sound.lengthForAudio(withWords: true) != 0, "\(sound.sourceLetter) (\(sound.soundId)) has no Word Set audio")
            
            if sound.lengthForAudio(withWords: true) == 0 {
                print("\(sound.sourceLetter) (\(sound.soundId)): \(sound.primaryWords[0].text), \(sound.primaryWords[1].text), \(sound.primaryWords[2].text)")
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
        for word in PHContent.allWordsNoDuplicates {
            XCTAssertNotNil(word.audioInfo, "\(word.text) has no audio")
        }
    }
    
    func testForUnusedWordImages() {
        let allWords = PHContent.allWords
        
        for imageName in allFilesWithExtension("jpg") {
            
            //ignore certain images
            if imageName.hasPrefix("letter-icon-") { continue }
            
            let hasMatchingWord = allWords.contains(where: { $0.text == imageName })
            XCTAssert(hasMatchingWord, "\(imageName).jpg is unused.")
        }
    }
    
    func testForUnusedWordAudio() {
        let allWords = PHContent.allWords
        
        for audioName in allFilesWithExtension("mp3", inDirectory: "Words") {
            let hasMatchingWord = allWords.contains(where: { $0.text == audioName })
            XCTAssert(hasMatchingWord, "\(audioName).mp3 is unused.")
        }
    }
    
    func testGenerateTimings() {
        //PHContent["I"]["IGH"].printAudioTimings()
    }
    
    
    //MARK: - Letters
    
    func testAllLettersHaveIcons() {
        for letter in PHContent.letters.values {
            XCTAssertNotNil(letter.icon, "No image icon for letter \(letter.text.uppercased())")
        }
    }
    
    func testAllLettersHaveAudio() {
        for letter in PHContent.letters.values {
            XCTAssertNotNil(letter.audioInfo, "No audio for letter \(letter.text.uppercased())")
        }
    }
    
    //MARK: - Helpers
    
    func allFilesWithExtension(_ ext: String, inDirectory directory: String? = nil) -> [String] {
        let files = Bundle.main.paths(forResourcesOfType: ext, inDirectory: directory, forLocalization: nil)
        
        let fileNames = files.map { filePath -> String in
            let pathParts = filePath.components(separatedBy: "/")
            guard let fileName = pathParts.last else { return filePath }
            guard let withoutExtension: String = fileName.components(separatedBy: ".").first else { return fileName }
            return withoutExtension
        }
        
        return fileNames
    }
    
}
