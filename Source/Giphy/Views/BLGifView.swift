//
//  BLGifView.swift
//  EmojiKeyboard
//
//  Created by Quach Ha Chan Thanh on 8/25/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

public class BLGifView: UIImageView {
    
    // MARK: Private properties
    
    // Private var cache: NSCache?
    private var isPlaying: Bool = false
    private var syncFactor: Int = 0
    private var displayOrderIndex: Int = 0
    
    // MARK: Public properties 
    
    public var displaying: Bool = false
    public weak var animationManager: BLDisplayGifManager? = nil
    public var loopCount: Int = 0
    public var currentImage: UIImage?
    public var gifImage: BLGif?
    
    // MARK:  - Inits

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
    }
    
    /**
     Convenience initializer. Creates a gif holder (defaulted to infinite loop).
     - Parameter gifImage: The UIImage containing the gif backing data
     - Parameter manager: The manager to handle the gif display
     */
    public convenience init(gifImage:BLGif, contentMode: UIViewContentMode = .ScaleToFill, manager:BLDisplayGifManager = BLDisplayGifManager.defaultManager) {
        
        self.init(frame: CGRectZero)
        
        setGifImage(gifImage,manager: manager, loopCount: -1)
    }

    /**
     Convenience initializer. Creates a gif holder.
     - Parameter gifImage: The UIImage containing the gif backing data
     - Parameter manager: The manager to handle the gif display
     - Parameter loopCount: The number of loops we want for this gif. -1 means infinite.
     */
    public convenience init(gifImage:BLGif, contentMode: UIViewContentMode = .ScaleToFill, manager:BLDisplayGifManager = BLDisplayGifManager.defaultManager, loopCount:Int) {
        
        self.init(frame: CGRectZero)
        
        setGifImage(gifImage,manager: manager, loopCount: loopCount)
    }
    
    required public init?(coder aDecoder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /**
     Set a gif image and a manager to an existing UIImageView. The gif will default to infinite loop.
     WARNING : this overwrite any previous gif.
     - Parameter gifImage: The UIImage containing the gif backing data
     - Parameter manager: The manager to handle the gif display
     */
    public func setGifImage(gifImage:BLGif, contentMode: UIViewContentMode = .ScaleToFill, manager:BLDisplayGifManager = BLDisplayGifManager.defaultManager) {
        
        setGifImage(gifImage, manager: manager, loopCount: -1)
    }

    /**
     Set a gif image and a manager to an existing UIImageView.
     WARNING : this overwrite any previous gif.
     - Parameter gifImage: The UIImage containing the gif backing data
     - Parameter manager: The manager to handle the gif display
     - Parameter loopCount: The number of loops we want for this gif. -1 means infinite.
     */
    public func setGifImage(gifImage:BLGif, contentMode: UIViewContentMode = .ScaleToFill, manager:BLDisplayGifManager = BLDisplayGifManager.defaultManager, loopCount:Int) {
        
        self.contentMode = contentMode
        if gifImage.imageCount < 1 {
            //self.image = UIImage(data: gifImage.imageData)
            return
        }
        
        self.cleanGIF()

        self.loopCount = loopCount
        self.gifImage = gifImage
        self.animationManager = manager
        self.syncFactor = 0
        self.displayOrderIndex = 0
//        self.cache = NSCache()
        

        if let gif = self.gifImage {

            if let firstImage = gif.getImageGIFAtIndex(0)  {
                
                self.currentImage = firstImage

                if !manager.containsImageView(self) {
                    manager.addImageView(self)
                    startDisplay()
                    startAnimatingGif()
                }
            }
        }
    }
    
    // MARK:  - Logic
    /**
     Start displaying the gif for this UIImageView.
     */
    public func startDisplay() {
        
        self.displaying = true
    }

    /**
     Stop displaying the gif for this UIImageView.
     */
    public func stopDisplay() {
        
        self.displaying = false
    }

    /**
     Start displaying the gif for this UIImageView.
     */
    public func startAnimatingGif() {
        
        self.isPlaying = true
    }

    /**
     Stop displaying the gif for this UIImageView.
     */
    public func stopAnimatingGif() {
        
        self.isPlaying = false
    }

    /**
     Check if this imageView is currently playing a gif
     - Returns wether the gif is currently playing
     */
    public func isAnimatingGif() -> Bool {
        
        return self.isPlaying
    }

    /**
     Show a specific frame based on a delta from current frame
      - Parameter delta: The delsta from current frame we want
     */
    public func showFrameForIndexDelta(delta: Int) {
        
        if let gifImage = self.gifImage {
            var nextIndex = self.displayOrderIndex + delta
            
            while nextIndex >= gifImage.framesCount(){
                nextIndex -= gifImage.framesCount()
            }
            
            while nextIndex < 0 {
                nextIndex += gifImage.framesCount()
            }
            
            showFrameAtIndex(nextIndex)
        }
        
    }

    /**
     Show a specific frame
      - Parameter index: The index of frame to show
     */
    public func showFrameAtIndex(index: Int) {
        
        self.displayOrderIndex = index
        updateFrame()
    }

    /**
     Update cache for the current imageView.
     */
//    public func updateCache() {
//        if let animationManager = self.animationManager {
//            if animationManager.hasCache(self) && !animationManager.haveCache {
//              //  prepareCache()
//                self.haveCache = true
//            } else if !animationManager.hasCache(self) && animationManager.haveCache {
//               // self.cache!.removeAllObjects()
//                self.haveCache = false
//            }
//        }
//    }

    /**
     Update current image displayed. This method is called by the manager.
     */
    public func updateCurrentImage() {

        if self.displaying {
            updateFrame()
            updateIndex()
            if loopCount == 0 || !isDisplayedInScreen(self)  || !self.isPlaying {
                stopDisplay()
            }
        } else {
            if(isDisplayedInScreen(self) && loopCount != 0 && self.isPlaying) {
                startDisplay()
            }
            if isDiscarded(self) {
                if let animationManager = self.animationManager {
                    animationManager.deleteImageView(self)
                }
            }
        }
    }

    /**
     Force update frame
     */
    private func updateFrame() {
        if let gifImage = self.gifImage,
            let currentImage = gifImage.getImageGIFAtIndex(gifImage.displayOrder![self.displayOrderIndex]) {
            self.currentImage = currentImage
        }
    }

    /**
     Check if the imageView has been discarded and is not in the view hierarchy anymore.
     - Returns : A boolean for weather the imageView was discarded
     */
    public func isDiscarded(imageView:UIView?) -> Bool{

        if(imageView == nil || imageView!.superview == nil) {
            return true
        }
        return false
    }

    /**
     Check if the imageView is displayed.
     - Returns : A boolean for weather the imageView is displayed
     */
    public func isDisplayedInScreen(imageView:UIView?) ->Bool{
        if (self.hidden) {
            return false
        }

        let screenRect = UIScreen.mainScreen().bounds
        
        if (UIApplication.sharedApplication().keyWindow != nil) {
            let viewRect = imageView!.convertRect(self.frame,toView:UIApplication.sharedApplication().keyWindow)
            
            let intersectionRect = CGRectIntersection(viewRect, screenRect);
            if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) {
                return false
            }
        }
        return (self.window != nil)
    }

    /**
     Update loop count and sync factor.
     */
    private func updateIndex() {
        if let gif = self.gifImage {
            self.syncFactor = (self.syncFactor+1) % gif.displayRefreshFactor!
            if self.syncFactor == 0 {
                self.displayOrderIndex = (self.displayOrderIndex+1) % gif.imageCount!
                if displayOrderIndex == 0 && self.loopCount > 0 {
                    self.loopCount -= 1;
                }
            }
        }
    }

    /**
     Clean Gif data to free memory
     */
    public func cleanGIF() {
        isPlaying = false
        displaying = false
        
        // Delete ImageView in cache
        if animationManager != nil {
            self.animationManager!.deleteImageView(self)
        }
        
        self.gifImage = nil
        self.currentImage = nil
        
    }
    
}