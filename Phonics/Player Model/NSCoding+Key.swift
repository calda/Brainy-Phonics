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
    
    func value(forKey key: NSCodingKey) -> Any? {
        return value(forKey: key.rawValue)
    }
    
    func setValue(_ value: Any?, forKey key: NSCodingKey) {
        self.setValue(value, forKey: key.rawValue)
    }
    
}
