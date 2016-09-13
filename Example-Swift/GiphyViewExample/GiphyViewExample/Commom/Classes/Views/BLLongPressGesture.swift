//
//  BLLongPressGesture.swift
//  EmojiKeyboard
//
//  Created by qhcthanh on 8/17/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import UIKit

 @objc public protocol BLLongPressGestureDelegate: UIGestureRecognizerDelegate {
    
    optional func longPressGestureOnTouchDown(view: UIView)
    
    optional func longPressGestureOnTouchMove(view: UIView?)
    
    optional func longPressGestureOnTouchUp(view: UIView?)
    
    optional func longPressGestureOnTouchFail(view: UIView?)
    
}

public class BLLongPressGesture: UILongPressGestureRecognizer {
    
    private weak var delgateBL: BLLongPressGestureDelegate?
    public weak var owerView: UIView?
    
    public override var delegate: UIGestureRecognizerDelegate? {
        didSet {
            if let newValue = delegate, let blDelegate = newValue as? BLLongPressGestureDelegate {
                
                self.delgateBL = blDelegate
                
                // Clear gesture
                self.owerView?.removeGestureRecognizer(self)
                
                // Add gesture
                self.initialize()
            }
            else {
                delgateBL = nil
            }
        }
    }
    
    public var minimumCallGesture: Double = 0.05
    private var lastCallGesture: Double = 0
    
    private func initialize() {
        
        self.minimumPressDuration = 0.07
        
        self.addTarget(self, action: #selector(onLongPressGesture))
        self.owerView!.addGestureRecognizer(self)
        self.cancelsTouchesInView = false
    }
    
    public init(owerView: UIView) {
        super.init(target: nil, action: nil)
        self.owerView = owerView
    
    }
    
    private override init(target: AnyObject?, action: Selector) {
        super.init(target: nil, action: action)
    }
    
    private init() {
        super.init(target: nil, action: nil)
    }
    
    @objc private func onLongPressGesture(longGesture: UILongPressGestureRecognizer) {
        
        if (NSDate.startCount() - self.lastCallGesture < minimumCallGesture) && longGesture.state == .Changed {
            return
        }
        
        let position = longGesture.locationInView(self.owerView!)
        //BLPrint(longGesture.view?.gestureRecognizers?.count)
//        longGesture.view?.gestureRecognizers?.first!.requireGestureRecognizerToFail(<#T##otherGestureRecognizer: UIGestureRecognizer##UIGestureRecognizer#>)
        
        let array = self.owerView!.subviews.filter({view in
            let bool = CGRectContainsPoint(view.frame, position)
            return bool
        })
        
        
        if longGesture.state == .Began {
            print("Began")
            onTouchDown(array.first)
        } else if longGesture.state == .Changed {
            
            onTouchMove(array.first)
        } else if longGesture.state == .Ended {
            print("Ended")
            onTouchUp(array.first)
        } else {
            print("Failed")
            onTouchFail(array.first)
        }
        
        self.lastCallGesture = NSDate.startCount()
    }
    
    public override func shouldRequireFailureOfGestureRecognizer(otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    
    private func onTouchDown(view: UIView?) {
        if let delegate = self.delgateBL, let action = delegate.longPressGestureOnTouchDown, let view = view {
            action(view)
        }
    }
    
    private func onTouchMove(view: UIView?) {
        if let delegate = self.delgateBL, let action = delegate.longPressGestureOnTouchMove  {
            action(view)
        }
    }
    
    private func onTouchUp(view: UIView?) {
        
        if let delegate = self.delgateBL, let action = delegate.longPressGestureOnTouchUp {
            action(view)
        }
    }
    
    private func onTouchFail(view: UIView?) {
        if let delegate = self.delgateBL, let action = delegate.longPressGestureOnTouchFail {
            action(view)
        }
    }
    
    
}



