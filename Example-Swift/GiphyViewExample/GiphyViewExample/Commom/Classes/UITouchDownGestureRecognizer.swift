//
//  UITouchDownGestureRecognizer.swift
//  EmojiKeyboard
//
//  Created by qhcthanh on 8/15/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

class UITouchDownGestureRecognizer: UIGestureRecognizer
{
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        if self.state == .Possible
        {
            self.state = .Recognized
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        self.state = .Failed
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        self.state = .Failed
    }
}
