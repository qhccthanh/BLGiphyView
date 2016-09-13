//
//  NSDate+Couting.swift
//  EmojiKeyboard
//
//  Created by qhcthanh on 8/17/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import Foundation

private var currentTime: NSTimeInterval = 0

public extension NSDate {
    
    class func startCount() -> NSTimeInterval {
        currentTime = NSDate().timeIntervalSince1970
        return currentTime
    }
    
    class func endCount() -> NSTimeInterval {
        return NSDate().timeIntervalSince1970 - currentTime
    }
    
}