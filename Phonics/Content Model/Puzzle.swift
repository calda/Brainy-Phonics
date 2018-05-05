//
//  Puzzle.swift
//  Phonics
//
//  Created by Cal Stephens on 8/16/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import Foundation
import UIKit

struct Puzzle {
    
    let pieces: [[PuzzlePiece]]
    let rowCount: Int
    let colCount: Int
    let pixelSize: CGSize
    let name: String
    
    ///load from json spec (https://github.com/calda/Puzzle-Generator)
    init?(fromSpecForPuzzleNamed puzzleName: String) {
        self.name = puzzleName
        let specName = "\(puzzleName)-spec"
        guard let url = Bundle.phonicsBundle?.url(forResource: specName, withExtension: "json") else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        
        let unspecificJson = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let json = unspecificJson as? [String : Any] else { return nil }
        
        func int(for key: String) -> Int? {
            guard let value = json[key] as? Int else { return nil }
            return value
        }
        
        guard let rows = int(for: "rows"),
            let cols = int(for: "cols"),
            let pixelsTall = int(for: "pixelsTall"),
            let pixelsWide = int(for: "pixelsWide") else {
                return nil
        }
        
        guard let piecesJson = json["pieces"] as? [String : [String : String]] else { return nil }
        
        let emptyRow = [PuzzlePiece?](repeating: nil, count: cols)
        var pieces = [[PuzzlePiece?]](repeating: emptyRow, count: rows)
        
        //initialize pieces
        for row in 0 ..< rows {
            for col in 0 ..< cols {
                let pieceKey = "row\(row)-col\(col)"
                let pieceImageName = "\(puzzleName)-\(pieceKey)"
                guard let pieceJson = piecesJson[pieceKey] else { return nil }
                
                func direction(for key: String) -> PuzzlePiece.Direction? {
                    guard let string = pieceJson[key] else { return nil }
                    return PuzzlePiece.Direction.fromString(string)
                }
                
                let piece = PuzzlePiece(topNubDirection: direction(for: "topNub"),
                                        rightNubDirection: direction(for: "rightNub"),
                                        bottomNubDirection: direction(for: "bottomNub"),
                                        leftNubDirection: direction(for: "leftNub"),
                                        row: row,
                                        col: col,
                                        imageName: pieceImageName)
                
                pieces[row][col] = piece
                
            }
        }
        
        self.rowCount = rows
        self.colCount = cols
        self.pixelSize = CGSize(width: pixelsWide, height: pixelsTall)
        
        //reduce [[PuzzlePiece?]] to [[PuzzlePiece]]
        self.pieces = pieces.map { pieceRow in
            return pieceRow.compactMap{ $0 }
        }
    }
    
    
    //MARK: - Saving Puzzle Renders to the app bundle
    
    private static func path(forPuzzleNamed puzzleName: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return "\(paths[0])/\(puzzleName).png"
    }
    
    static func save(image: UIImage, asPuzzleNamed puzzleName: String) {
        let imageData = UIImagePNGRepresentation(image)
        let savePath = Puzzle.path(forPuzzleNamed: puzzleName)
        try? imageData?.write(to: URL(fileURLWithPath: savePath), options: [.atomic])
    }
    
    static func imageExists(forPuzzleNamed puzzleName: String) -> Bool {
        let path = Puzzle.path(forPuzzleNamed: puzzleName)
        return FileManager().fileExists(atPath: path)
    }
    
    static func completedImage(forPuzzleNamed puzzleName: String) -> UIImage? {
        let path = Puzzle.path(forPuzzleNamed: puzzleName)
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
    
}


//required to support Bundle operations in Interface Builder
extension Bundle {
    
    @nonobjc static var phonicsBundle: Bundle? = {
        for bundle in Bundle.allBundles {
            //check for a known file
            if bundle.url(forResource: "puzzle-A-AI-spec", withExtension: "json") != nil {
                return bundle
            }
        }
        
        return nil
    }()
    
}

