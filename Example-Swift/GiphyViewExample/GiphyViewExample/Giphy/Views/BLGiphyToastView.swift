//
//  GiphyToastView.swift
//  EmojiKeyboard
//
//  Created by qhcthanh on 8/24/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import UIKit

public class BLGiphyToastView: UIView {
    
    // MARK: UI Properties
    public var toastLabel: UILabel!
    
    // MARK: Public Properties
    public var isAnimated: Bool  = false
    
    // MARK: Initialize
    public convenience init() {
        self.init(frame: CGRectZero)
        
        setupView()
    }
    
    public override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        setupView()
    }
    
    private func setupView() {
        
        self.toastLabel = UILabel()
        self.toastLabel.textAlignment = .Center
        self.toastLabel.textColor = .whiteColor()
        self.toastLabel.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.65)
        self.toastLabel.adjustsFontSizeToFitWidth = true
        
        self.addSubview(self.toastLabel)
        
        self.setupConstraint()
    }
    
    private func setupConstraint() {
        
        if self.toastLabel != nil {
            self.toastLabel.constrain(toEdgesOf: self)
        }
    }
    
    // MARK: Public method's
    
    /**
     This will use UIView.animateWithDuration move ToastView in superView.
     The animation can't call when running, we will check it from isAnimated public property
     @discussion: The animation will sperate 3 time.
     First to move toastView to mid superView, Second is the time hold in mid superView, Third is move to bottom and hidden toastView
     
     - parameter timer: The total time to run animation
     */
    public func animateShowToast(timer: NSTimeInterval = 2) {
        
        if let superView = self.superview where self.isAnimated == false {
            self.hidden = false
            self.isAnimated = true
            superView.clipsToBounds = true
            let superFrame = superView.frame
            
            self.frame.origin.y = -self.frame.size.height
            
            let timeAnimation = timer/3
            
            
            UIView.animateWithDuration(timeAnimation, animations: {
                self.frame.origin.y = (superFrame.height - self.frame.size.height) / 2
                }, completion: {
                    success in
                    if success {
                        UIView.animateWithDuration(timeAnimation, delay: timeAnimation, options: .CurveEaseInOut, animations: {
                            self.frame.origin.y = superFrame.height
                            }, completion: { (_) in
                                self.frame.origin.y = -self.frame.size.height
                                self.isAnimated = false
                                self.hidden = true
                        })
                    }
            })
            
        }
    }
    
    
}
