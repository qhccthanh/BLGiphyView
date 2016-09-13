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

let defaultLevelOfIntegrity: Float = 1

//Factors send to CADisplayLink.frameInterval
let displayRefreshFactors =  [60,30,20,15,12,10,6,5,4,3,2,1]

//maxFramePerSecond,default is 60
let maxFramePerSecond = displayRefreshFactors.first

//frame numbers per second
let displayRefreshRates = displayRefreshFactors.map{
    maxFramePerSecond!/$0
}

//time interval per frame
let displayRefreshDelayTime = displayRefreshRates.map {
    1.0/Float($0)
}

private var currentGifCreate = 0
private var currentGifSize: Float = 0


public class BLGif: UIImage {
    
//    public var imageData: NSData
    public var displayOrder: [Int]?
    public var imageCount: Int?
    public var imageSize: Float?
    public var displayRefreshFactor: Int?
    public var imageSource: CGImageSource?
    public var imageData: NSData?
   // public var listImageGif = [Int:UIImage]()
    
    // MARK: - Inits
    
    /**
     Convenience initializer. Creates a gif with its backing data. Defaulted level of integrity.
     - Parameter gifData: The actual gif data
     */
    public convenience init(gifData:NSData) {
        self.init()
        
        setGifFromData(gifData,levelOfIntegrity: defaultLevelOfIntegrity)
    }
    
    /**
     Convenience initializer. Creates a gif with its backing data.
     - Parameter gifData: The actual gif data
     - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
     */
    public convenience init(gifData:NSData, levelOfIntegrity:Float) {
        self.init()
        
        setGifFromData(gifData,levelOfIntegrity: levelOfIntegrity)
    }
    
    /**
     Convenience initializer. Creates a gif with its backing data. Defaulted level of integrity.
     - Parameter gifName: Filename
     */
    public convenience init(gifName: String) {
        self.init()
        
        setGif(gifName, levelOfIntegrity: defaultLevelOfIntegrity)
    }
    
    /**
     Convenience initializer. Creates a gif with its backing data.
     - Parameter gifName: Filename
     - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
     */
    public convenience init(gifName: String, levelOfIntegrity: Float) {
        self.init()
        
        setGif(gifName, levelOfIntegrity: levelOfIntegrity)
    }
    
    /**
     Set backing data for this gif. Overwrites any existing data.
     - Parameter data: The actual gif data
     - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
     */
    public func setGifFromData(data:NSData,levelOfIntegrity:Float) {
        
        currentGifCreate += 1
        self.imageData = data
        imageSource = CGImageSourceCreateWithData(data, nil)
        
        calculateFrameDelay(delayTimes(imageSource), levelOfIntegrity: levelOfIntegrity)
        calculateFrameSize()
    
        if let imageSize = self.imageSize {
            currentGifSize -= imageSize
        }
    }
    
    /**
     Set backing data for this gif. Overwrites any existing data.
     - Parameter name: Filename
     */
    public func setGif(name: String) {
        setGif(name, levelOfIntegrity: defaultLevelOfIntegrity)
    }
    
    /**
     Check the number of frame for this gif
     - Return number of frames
     */
    public func framesCount() -> Int{
        if let orders = self.displayOrder{
            return orders.count
        }
        return 0
    }
    
    /**
     Set backing data for this gif. Overwrites any existing data.
     - Parameter name: Filename
     - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
     */
    public func setGif(name: String, levelOfIntegrity: Float) {
        
        if let url = NSBundle.mainBundle().URLForResource(name, withExtension: "gif") {
            if let data = NSData(contentsOfURL:url) {
                setGifFromData(data,levelOfIntegrity: levelOfIntegrity)
            } else {
                BLPrint("Error : Invalid GIF data for \(name).gif")
            }
        } else {
            BLPrint("Error : Gif file \(name).gif not found")
        }
    }
    
    // MARK:  - Logic
    
    /**
     Get delay times for each frames
     - Parameter imageSource: reference to the gif image source
     - Returns array of delays
     */
    private func delayTimes(imageSource:CGImageSourceRef?) -> [Float] {
        
        let imageCount = CGImageSourceGetCount(imageSource!)
        var imageProperties = [CFDictionary]()
        for i in 0..<imageCount{
            imageProperties.append(CGImageSourceCopyPropertiesAtIndex(imageSource!, i, nil)!)
        }
        
        let frameProperties = imageProperties.map() {
            unsafeBitCast(
                CFDictionaryGetValue($0,
                    unsafeAddressOf(kCGImagePropertyGIFDictionary)),CFDictionary.self)
        }
        
        let EPS:Float = 1e-6
        
        var frameDelays:[Float] = []
        
        for framePropertie in frameProperties {
            var delayObject: AnyObject = unsafeBitCast(CFDictionaryGetValue(framePropertie, unsafeAddressOf(kCGImagePropertyGIFUnclampedDelayTime)), AnyObject.self)
            
            if (delayObject.floatValue<EPS) {
                delayObject = unsafeBitCast(CFDictionaryGetValue(framePropertie,
                    unsafeAddressOf(kCGImagePropertyGIFDelayTime)), AnyObject.self)
            }
            
            frameDelays.append(delayObject as! Float)
        }
        
        if frameDelays.count < 1 {
            frameDelays = [0.07,0.05,0.04,0.06]
        }
        return frameDelays
        
        
    }
    
    
    
    /**
     Compute backing data for this gif
     - Parameter delaysArray: decoded delay times for this gif
     - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
     */
    private func calculateFrameDelay(delaysArray: [Float], levelOfIntegrity:Float){
        
        var delays = delaysArray
        
        //caclulate the time when each frame should be displayed at(start at 0)
        for i in 1..<delays.count {
            delays[i] += delays[i-1]
        }
    
        
        //find the appropriate Factors then BREAK
        for i in 0..<displayRefreshDelayTime.count {
            
            let displayPosition = delays.map {
                Int($0/displayRefreshDelayTime[i])
            }
            
            var framelosecount: Float = 0
            for j in 1..<displayPosition.count{
                if displayPosition[j] == displayPosition[j-1] {
                    framelosecount += 1
                }
            }
            
            if framelosecount <= Float(displayPosition.count) * (1.0 - levelOfIntegrity) ||
                i == displayRefreshDelayTime.count - 1 {
                // Order frame
                self.imageCount = displayPosition.last!
                displayRefreshFactor = displayRefreshFactors[i]
                self.displayOrder = [Int]()
                var indexOfold = 0
                var indexOfnew = 1
                while indexOfnew <= imageCount {
                    if indexOfnew <= displayPosition[indexOfold] {
                        self.displayOrder!.append(indexOfold)
                        indexOfnew += 1
                    } else {
                        indexOfold += 1
                    }
                }
                break
            }
        }
        
    }
    
    /**
     Compute frame size for this gif
     */
    private func calculateFrameSize() {
        
        if let imageData = self.imageData {
            self.imageSize = Float(imageData.length)/(1024*1024)
        } else {
            self.imageSize = 0
        }
    }
    
    /**
     Get first image in gif to review. This function will cache first Gif
     
     - returns: The first image in gif
     */
    public func getImageGIFAtIndex(index: Int) -> UIImage? {

        if let imageSource = self.imageSource,
            let cgImage = CGImageSourceCreateImageAtIndex(imageSource, index, nil) {
            return UIImage(CGImage: cgImage)
        }
        
        return nil
    }
    
    deinit {
        
        
    }

}

