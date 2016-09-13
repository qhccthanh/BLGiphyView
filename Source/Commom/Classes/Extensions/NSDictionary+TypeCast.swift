//
//  NSDictionary+TypeCast.swift
//  EmojiKeyboard
//
//  Created by Quach Ha Chan Thanh on 8/21/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import Foundation

extension NSDictionary {
    
    func toStringAtKey(key: String) -> String? {
        return self.objectForKey(key) as? String
    }
    
    func toDictionaryAtKey(key: String) -> NSDictionary? {
        return self.objectForKey(key) as? NSDictionary
    }
    
    func toArrayAtKey(key: String) -> NSArray? {
        return self.objectForKey(key) as? NSArray
    }
    
    func toDoubleAtKey(key: String) -> Double? {
        return self.objectForKey(key) as? Double
    }
    
    func toFloatAtKey(key: String) -> Float? {
        return self.objectForKey(key) as? Float
    }
    
    func toIntegerAtKey(key: String) -> Int? {
        return self.objectForKey(key) as? Int
    }
    
    class func fromJSON(jsonData: NSData) -> NSDictionary? {
        if let dictionary = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
            
            return dictionary
        }
        
        return nil
    }
    
}