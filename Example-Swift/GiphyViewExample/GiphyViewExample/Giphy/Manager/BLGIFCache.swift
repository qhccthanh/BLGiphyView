//
//  BLGifCacheManager.swift
//  EmojiKeyboard
//
//  Created by qhcthanh on 8/25/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import UIKit
import ImageIO

public class BLGIFCache: NSObject {
    
    // MARK: Properties
    
    // Private static properties
    private static var shareCacheGIF: BLGIFCache!
    private static var managerToken: dispatch_once_t = 0
    
    // Private properties
    private var cachedGIF: Dictionary<String,BLGif>
    private var cacheThumbGIF: Dictionary<String,UIImage>
    
    private var internalSerialQueue: dispatch_queue_t
    private var gifPriorityQueue: NSMutableArray
    private var thumbPriorityQueue: NSMutableArray
    private var currentCacheSize: Float
    
    // Public properties
    public var cacheMode: YLCacheMode = YLCacheMode.LimitLength
    public var maxOfNubmerCacheItem: UInt = 10
    public var maxOfSizeCacheItem: Float = 10
    public var numberDeleteCacheItem: UInt = 3
    public var maxOfNumberGIFThumbCache = 15
    
    // MARK: Initialize
    
    private override init() {
        
        // Initialize variables
        self.cachedGIF = Dictionary<String,BLGif>()
        self.cacheThumbGIF = Dictionary<String, UIImage>()
        
        self.internalSerialQueue = dispatch_queue_create("com.vng.BLGIFCacheQueue", DISPATCH_QUEUE_SERIAL)
        self.gifPriorityQueue = NSMutableArray()
        self.thumbPriorityQueue = NSMutableArray()
        self.currentCacheSize = 0
        
        super.init()
    }
    
    /**
     Share cache gif manager singletion
     
     - returns: The singleton BLGIFCache object
     */
    public class func shareManager() -> BLGIFCache {
        
        dispatch_once(&managerToken, {
            shareCacheGIF = BLGIFCache()
        })
        
        return shareCacheGIF
    }
    
    // MARK: Public method's
    
    /**
     Add an gif associated with aKey to cache. It will cache thumb image in this gif
     
     - parameter data:   An image for aKey
     - parameter forKey: The key for value. The key is copied (using copyWithZone:; keys must conform to the NSCopying protocol). If aKey already exists in the cache, image takes its place.
     */
    public func cacheGIF(gif: BLGif, forKey aKey: String) {
        dispatch_async(internalSerialQueue, {
            let sizeOfGIF: Float = gif.imageSize == nil ? 0 : gif.imageSize!
            var isFullCache = false
            
            // Check is full cache
            if  (Bool(self.cacheMode.rawValue | YLCacheMode.LimitLength.rawValue) &&  UInt(self.cachedGIF.count) >= self.maxOfNubmerCacheItem) ||
                (Bool(self.cacheMode.rawValue | YLCacheMode.LimitSize.rawValue)
                    && (self.currentCacheSize + sizeOfGIF) > self.maxOfSizeCacheItem) {
                isFullCache = true
            }
            
            if !isFullCache {
                // Image cache is not full. Add this image to cache and push it to priority queue.
                
                self.cachedGIF[aKey] = gif
                self.gifPriorityQueue.addObject(aKey)
                
                if self.thumbPriorityQueue.count > self.maxOfNumberGIFThumbCache {
                    for _ in 1...self.numberDeleteCacheItem {
                        self.cacheThumbGIF.removeValueForKey(self.thumbPriorityQueue.firstObject as! String)
                        self.thumbPriorityQueue.removeObjectAtIndex(0)
                    }
                }
                
                if let thumbGIF = gif.getImageGIFAtIndex(0) {
                    self.cacheThumbGIF[aKey] = thumbGIF
                }
                
                self.thumbPriorityQueue.addObject(aKey)
            } else {
                // GIF Data cache is full.
                // Delete least recently used GIF Data until cache is available for this data.
                
                while isFullCache {
                    
                    for _ in 0..<self.numberDeleteCacheItem {
                        if let firstObject = self.gifPriorityQueue.firstObject {
                            self.currentCacheSize -= sizeOfGIF
                            
                            // Remove number cacheItem
                            
                            if self.gifPriorityQueue.count == 0 {
                                break
                            }
                            
                            self.cachedGIF.removeValueForKey(firstObject as! String)
                            self.gifPriorityQueue.removeObjectAtIndex(0)
                        }
                        
                        if  (Bool(self.cacheMode.rawValue | YLCacheMode.LimitLength.rawValue) &&  UInt(self.cachedGIF.count) < self.maxOfNubmerCacheItem) &&
                            (Bool(self.cacheMode.rawValue | YLCacheMode.LimitSize.rawValue)
                                && (self.currentCacheSize + sizeOfGIF) <= self.maxOfSizeCacheItem)
                        {
                            
                            isFullCache = false
                        }
                        
                    }
                }
            
                // Image cache is not full. Add this image to cache and push it to priority queue.
                
                self.cachedGIF[aKey] = gif
                self.gifPriorityQueue.addObject(aKey)
                
                if let thumbGIF = gif.getImageGIFAtIndex(0) {
                    self.cacheThumbGIF[aKey] = thumbGIF
                }
                
                if self.thumbPriorityQueue.count > self.maxOfNumberGIFThumbCache {
                    for _ in 1...self.numberDeleteCacheItem {
                        self.cacheThumbGIF.removeValueForKey(self.thumbPriorityQueue.firstObject as! String)
                        self.thumbPriorityQueue.removeObjectAtIndex(0)
                    }
                }
                
                self.thumbPriorityQueue.addObject(aKey)
                
            }
            
            self.currentCacheSize += sizeOfGIF
        })
    }
    
    public func thumbForKey(aKey: String) -> UIImage? {
        var returnThumbImage: UIImage?
        
        dispatch_sync(internalSerialQueue, {
            returnThumbImage = self.cacheThumbGIF[aKey]
            
            if returnThumbImage != nil {
                var index = -1
                for i in 0..<self.thumbPriorityQueue.count {
                    if aKey == self.thumbPriorityQueue.objectAtIndex(i) as! String {
                        index = i
                        break
                    }
                }
                
                if index != -1 {
                    self.thumbPriorityQueue.removeObjectAtIndex(index)
                    self.thumbPriorityQueue.addObject(aKey)
                }
            }
        })
        
        return returnThumbImage
    }
    
    /**
     Returns the thumb gif associated with a given key.
         The value associated with aKey, or nil if no value is associated with aKey.
     
     - @param aKey The key for which to return the corresponding value.
     
     -  @return The thumb gif in cache which associated with aKey
     */
    public func gifForKey(aKey: String) -> BLGif? {
        
        var returnData: BLGif?
        
        dispatch_sync(internalSerialQueue, {
            returnData = self.cachedGIF[aKey]
            
            if returnData != nil {
                var index = -1
                for i in 0..<self.gifPriorityQueue.count {
                    if aKey == self.gifPriorityQueue.objectAtIndex(i) as! String {
                        index = i
                        break
                    }
                }
                
                if index != -1 {
                    self.gifPriorityQueue.removeObjectAtIndex(index)
                    self.gifPriorityQueue.addObject(aKey)
                }
            }
        })

        return returnData
    }
    
    /**
     *  Remove an gif from cache associated with aKey
     *  Does nothing if aKey does not exist
     *
     *  @param aKey The key to remove
     */
    public func removeGIFDataForKey(aKey: String) {
        
        dispatch_async(internalSerialQueue, {
            let gif = self.cachedGIF[aKey]
            
            if let gif = gif {
                self.currentCacheSize -= gif.imageSize == nil ? 0 : gif.imageSize!
                self.cachedGIF.removeValueForKey(aKey)
                
                var index = -1
                for i in 0..<self.gifPriorityQueue.count {
                    if aKey == self.gifPriorityQueue.objectAtIndex(i) as! String {
                        index = i
                        break
                    }
                }
                
                if index != -1 {
                    self.gifPriorityQueue.removeObjectAtIndex(index)
                }
            }
            
        })
    }
    
    /**
     *  Remove all gifs from cache
     */
    public func removeAllDataInCache() {
        
        dispatch_sync(internalSerialQueue, {
            self.cachedGIF.removeAll()
            self.gifPriorityQueue.removeAllObjects()
            self.cacheThumbGIF.removeAll()
            self.thumbPriorityQueue.removeAllObjects()
            
            self.currentCacheSize = 0
        })
        
    }
    
    /**
     Get current number of item in cache. It run sync internalSerialQueue
     
     - returns: The current number of item in cache
     */
    public func numberItemInCache() -> Int {
        
        var numberItem = 0
        
        dispatch_sync(internalSerialQueue, {
            numberItem = self.cachedGIF.count
        })
        
        return numberItem
    }
}








