        //
//  UIImage+SwiftyGif.swift
//

import ImageIO
import UIKit

//private let _imageSourceKey = malloc(4)
//private let _displayRefreshFactorKey = malloc(4)
//private let _imageCountKey = malloc(4)
//private let _displayOrderKey = malloc(4)
//private let _imageSizeKey = malloc(4)
//private let _imageDataKey = malloc(4)

        
public extension UIImage {

//    // MARK: - Inits
//
//    /**
//     Convenience initializer. Creates a gif with its backing data. Defaulted level of integrity.
//     - Parameter gifData: The actual gif data
//     */
//    public convenience init(gifData:NSData) {
//        self.init()
//        setGifFromData(gifData,levelOfIntegrity: defaultLevelOfIntegrity)
//    }
//
//    /**
//     Convenience initializer. Creates a gif with its backing data.
//     - Parameter gifData: The actual gif data
//     - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
//     */
//    public convenience init(gifData:NSData, levelOfIntegrity:Float) {
//        self.init()
//        setGifFromData(gifData,levelOfIntegrity: levelOfIntegrity)
//    }
//
//    /**
//     Convenience initializer. Creates a gif with its backing data. Defaulted level of integrity.
//     - Parameter gifName: Filename
//     */
//    public convenience init(gifName: String) {
//        self.init()
//        setGif(gifName, levelOfIntegrity: defaultLevelOfIntegrity)
//    }
//
//    /**
//     Convenience initializer. Creates a gif with its backing data.
//     - Parameter gifName: Filename
//     - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
//     */
//    public convenience init(gifName: String, levelOfIntegrity: Float) {
//        self.init()
//        setGif(gifName, levelOfIntegrity: levelOfIntegrity)
//    }
//
//    /**
//     Set backing data for this gif. Overwrites any existing data.
//     - Parameter data: The actual gif data
//     - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
//     */
//    public func setGifFromData(data:NSData,levelOfIntegrity:Float) {
//        //self.imageData = data
//        imageSource = CGImageSourceCreateWithData(data, nil)
//
//        calculateFrameDelay(delayTimes(imageSource), levelOfIntegrity: levelOfIntegrity)
//        calculateFrameSize()
//    }
//
//    /**
//     Set backing data for this gif. Overwrites any existing data.
//     - Parameter name: Filename
//     */
//    public func setGif(name: String) {
//        setGif(name, levelOfIntegrity: defaultLevelOfIntegrity)
//    }
//
//    /**
//     Check the number of frame for this gif
//     - Return number of frames
//     */
//    public func framesCount() -> Int{
//        if let orders = self.displayOrder{
//            return orders.count
//        }
//        return 0
//    }
//
//    /**
//     Set backing data for this gif. Overwrites any existing data.
//     - Parameter name: Filename
//     - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
//     */
//    public func setGif(name: String, levelOfIntegrity: Float) {
//        if let url = NSBundle.mainBundle().URLForResource(name, withExtension: "gif") {
//            if let data = NSData(contentsOfURL:url) {
//                setGifFromData(data,levelOfIntegrity: levelOfIntegrity)
//            } else {
//                print("Error : Invalid GIF data for \(name).gif")
//            }
//        } else {
//            print("Error : Gif file \(name).gif not found")
//        }
//    }
//
//    // MARK:  - Logic
//
//    /**
//     Get delay times for each frames
//     - Parameter imageSource: reference to the gif image source
//     - Returns array of delays
//     */
//    private func delayTimes(imageSource:CGImageSourceRef?) -> [Float] {
//        
//        let imageCount = CGImageSourceGetCount(imageSource!)
//        var imageProperties = [CFDictionary]()
//        for i in 0..<imageCount{
//            imageProperties.append(CGImageSourceCopyPropertiesAtIndex(imageSource!, i, nil)!)
//        }
//        
//        let frameProperties = imageProperties.map() {
//            unsafeBitCast(
//                CFDictionaryGetValue($0,
//                    unsafeAddressOf(kCGImagePropertyGIFDictionary)),CFDictionary.self)
//        }
//    
//        let EPS:Float = 1e-6
//        
//        var frameDelays:[Float] = []
//        
//        for framePropertie in frameProperties {
//            var delayObject: AnyObject = unsafeBitCast(CFDictionaryGetValue(framePropertie, unsafeAddressOf(kCGImagePropertyGIFUnclampedDelayTime)), AnyObject.self)
//            
//            if (delayObject.floatValue<EPS) {
//                delayObject = unsafeBitCast(CFDictionaryGetValue(framePropertie,
//                    unsafeAddressOf(kCGImagePropertyGIFDelayTime)), AnyObject.self)
//            }
//            
//            frameDelays.append(delayObject as! Float)
//        }
//        
////        let frameDelays:[Float] = frameProperties.map() {
////            
////            var delayObject: AnyObject = unsafeBitCast(CFDictionaryGetValue($0, unsafeAddressOf(kCGImagePropertyGIFUnclampedDelayTime)), AnyObject.self)
////            
////            if(delayObject.floatValue<EPS){
////                delayObject = unsafeBitCast(CFDictionaryGetValue($0,
////                    unsafeAddressOf(kCGImagePropertyGIFDelayTime)), AnyObject.self)
////            }
////            return delayObject as! Float
////        }
//        if frameDelays.count < 1 {
//            frameDelays = [0.07,0.05,0.04,0.06]
//        }
//        return frameDelays
//    
//    
//    }
//    
//    
//    
//    /**
//     Compute backing data for this gif
//     - Parameter delaysArray: decoded delay times for this gif
//     - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
//     */
//    private func calculateFrameDelay(delaysArray: [Float], levelOfIntegrity:Float){
//        
//        var delays = delaysArray
//        
//        //caclulate the time when each frame should be displayed at(start at 0)
//        for i in 1..<delays.count {
//            delays[i] += delays[i-1]
//        }
//        
//        
//        //find the appropriate Factors then BREAK
//        for i in 0..<displayRefreshDelayTime.count {
//            
//            let displayPosition = delays.map {
//                Int($0/displayRefreshDelayTime[i])
//            }
//            
//            var framelosecount: Float = 0
//            for j in 1..<displayPosition.count{
//                if displayPosition[j] == displayPosition[j-1] {
//                    framelosecount += 1
//                }
//            }
//            
//            if framelosecount <= Float(displayPosition.count) * (1.0 - levelOfIntegrity) ||
//                i == displayRefreshDelayTime.count - 1 {
//                // Order frame
//                self.imageCount = displayPosition.last!
//                displayRefreshFactor = displayRefreshFactors[i]
//                self.displayOrder = [Int]()
//                var indexOfold = 0
//                var indexOfnew = 1
//                while indexOfnew <= imageCount {
//                    if indexOfnew <= displayPosition[indexOfold] {
//                        self.displayOrder!.append(indexOfold)
//                        indexOfnew += 1
//                    } else {
//                        indexOfold += 1
//                    }
//                }
//                break
//            }
//        }
//        
//    }
//
//    /**
//     Compute frame size for this gif
//     */
//    private func calculateFrameSize() {
//        if let cgImage = CGImageSourceCreateImageAtIndex(self.imageSource!,0,nil) {
//            let image = UIImage(CGImage: cgImage)
//            self.imageSize = Int(image.size.height*image.size.width*4) * self.imageCount!/1000000
//        } else {
//            self.imageSize = 100
//        }
//    }
//
//    // MARK:  - get / set associated values
//
//    public var imageSource: CGImageSource? {
//        get {
//            return (objc_getAssociatedObject(self, _imageSourceKey) as! CGImageSource?)
//        }
//        set {
//            objc_setAssociatedObject(self, _imageSourceKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
//        }
//    }
//
//    public var displayRefreshFactor: Int? {
//        get {
//            return (objc_getAssociatedObject(self, _displayRefreshFactorKey) as! Int)
//        }
//        set {
//            objc_setAssociatedObject(self, _displayRefreshFactorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
//        }
//    }
//
//    public var imageSize: Int? {
//        get {
//            return (objc_getAssociatedObject(self, _imageSizeKey) as! Int)
//        }
//        set {
//            objc_setAssociatedObject(self, _imageSizeKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
//        }
//    }
//
//    public var imageCount: Int? {
//        get {
//            return (objc_getAssociatedObject(self, _imageCountKey) as! Int)
//        }
//        set {
//            objc_setAssociatedObject(self, _imageCountKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
//        }
//    }
//
//    public var displayOrder: [Int]? {
//        get {
//            return (objc_getAssociatedObject(self, _displayOrderKey) as! [Int])
//        }
//        set {
//            objc_setAssociatedObject(self, _displayOrderKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
//        }
//    }
//
//    public var imageData: NSData {
//        get {
//            return (objc_getAssociatedObject(self, _imageDataKey) as! NSData)
//        }
//        set {
//            objc_setAssociatedObject(self, _imageDataKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
//        }
//    }
}
