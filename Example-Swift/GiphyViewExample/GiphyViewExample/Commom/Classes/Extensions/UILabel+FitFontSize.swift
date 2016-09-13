//
//  UILabel+FitFontSize.swift
//  EmojiKeyboard
//
//  Created by qhcthanh on 8/17/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import UIKit


extension UILabel {
    
    func fitFontForSize(constrainedSize : CGSize, maxFontSize : CGFloat = 300.0, minFontSize : CGFloat = 5.0, accuracy : CGFloat = 1.0) -> UIFont {
        assert(maxFontSize > minFontSize)
        
        var minFontSize = minFontSize
        var maxFontSize = maxFontSize
        
        while maxFontSize - minFontSize > accuracy {
            let midFontSize : CGFloat = ((minFontSize + maxFontSize) / 2)
            font = font.fontWithSize(midFontSize)
            sizeToFit()
            let checkSize : CGSize = bounds.size
            if  checkSize.height < constrainedSize.height && checkSize.width < constrainedSize.width {
                minFontSize = midFontSize
            } else {
                maxFontSize = midFontSize
            }
        }
        font = font.fontWithSize(maxFontSize)
        sizeToFit()
        
        return font
    }
    
}