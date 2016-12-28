//
//  NSCodingKey.swift
//  Phonics
//
//  Created by Cal Stephens on 12/22/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import Foundation

//Any String enum can conform to this protocol
protocol NSCodingKey {
    var rawValue: String { get }
}

extension NSCoder {
    
    func value(for key: NSCodingKey) -> Any? {
        return decodeObject(forKey: key.rawValue)
    }
    
    func setValue(_ value: Any?, for key: NSCodingKey) {
        self.encode(value, forKey: key.rawValue)
    }
    
}
