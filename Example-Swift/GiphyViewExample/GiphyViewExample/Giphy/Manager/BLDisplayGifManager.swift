//
//  SwiftyGifManager.swift
//
//
import ImageIO
import UIKit
import Foundation

public class BLDisplayGifManager {

    // A convenient default manager if we only have one gif to display here and there
    // Suggest need to 15 in iphone 5 iOS 9.3.4
    static var defaultManager = BLDisplayGifManager(memoryLimit: 3)
    
    private var timer: CADisplayLink?
    private var displayViews: [BLGifView] = []
    private var totalGifSize: Float
    private var memoryLimit: Float
    public var  haveCache: Bool
    
    let serialQueue: dispatch_queue_t = dispatch_queue_create("com.SwiftyGifManager.queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0))
    
    /**
     Initialize a manager
     - Parameter memoryLimit: The number of Mb max for this manager
     */
    public init(memoryLimit: Float) {
        
        self.memoryLimit = memoryLimit
        self.totalGifSize = 0
        self.haveCache = true
        self.timer = CADisplayLink(target: self, selector: #selector(self.updateImageView))
        self.timer!.addToRunLoop(.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }

    /**
     Add a new imageView to this manager if it doesn't exist
     - Parameter imageView: The BLGifView we're adding to this manager
     */
    public func addImageView(imageView: BLGifView) {
        
        if self.containsImageView(imageView) {
            return
        }

        self.totalGifSize += imageView.gifImage!.imageSize!
        
        // Remove ImageView playing if memory out of range and not displaying
        for imageViewRemove in self.displayViews {
            if self.totalGifSize > Float(memoryLimit) &&  !imageViewRemove.displaying {
                imageViewRemove.cleanGIF()
            } else if self.totalGifSize < Float(memoryLimit) {
                break
            }
        }
        
        self.displayViews.append(imageView)
    }

    /**
     Delete an imageView from this manager if it exists
     - Parameter imageView: The BLGifView we want to delete
     */
    public func deleteImageView(imageView: BLGifView) {
        
        if let index = self.displayViews.indexOf(imageView) {
            if let gifImage = imageView.gifImage,
                let imageSize = gifImage.imageSize
            {
                self.totalGifSize -= imageSize
                
                if self.displayViews.count != 0 {
                    self.displayViews.removeAtIndex(index)
                }
            }
        }
    }
    
    /**
     Delete all imageView from this manager
     */
    public func deleteAllImageView() {
        for imageView in self.displayViews {
            imageView.cleanGIF()
        }
    }

    /**
     Check if an imageView is already managed by this manager
     - Parameter imageView: The BLGifView we're searching
     - Returns : a boolean for wether the imageView was found
     */
    public func containsImageView(imageView: BLGifView) -> Bool {
        return self.displayViews.contains(imageView)
    }

    /**
     Check if this manager has cache for an imageView
     - Parameter imageView: The BLGifView we're searching cache for
     - Returns : a boolean for wether we have cache for the imageView
     */
    public func hasCache(imageView: BLGifView) -> Bool {
        if imageView.displaying == false {
            return false
        }

        if imageView.loopCount == -1 || imageView.loopCount >= 5 {
            return self.haveCache
        } else {
            return false
        }
    }
    var lastTimeCall: NSTimeInterval = 0
    /**
     Update imageView current image. This method is called by the main loop.
     This is what create the animation.
     */
    @objc func updateImageView(){
       
        for imageView in self.displayViews {
            if imageView.isAnimatingGif() && imageView.displaying {
                
                imageView.image = imageView.currentImage
                
                dispatch_async(serialQueue) {
                    imageView.updateCurrentImage()
                }
            } else if !imageView.displaying || imageView.window == nil {
                deleteImageView(imageView)
            }
            
        }
    }
    
}
