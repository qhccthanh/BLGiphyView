//
//  GiphyInfo.swift
//  EmojiKeyboard
//
//  Created by qhcthanh on 8/18/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import Foundation

// Constaint Class
private let kGiphyID = "id"
private let kGiphyURL = "url"
private let kGiphyMP4URL = "mp4"
private let kGiphyMP4Size = "mp4_size"
private let kGiphyImageWidth = "width"
private let kGiphyImageHeight = "height"
private let kGiphyImageSize = "size"
private let kGiphySlug = "slug"
private let kGiphyImages = "images"
private let kDefaultSize: Float = 2000

// Fixed Downsampled
private let kFixedHeight = "fixed_height"
private let kFixedWidth = "fixed_width"

// Fixed Small
private let kFixedHeightSmall = "fixed_height_small"
private let kFixedWidthSmall = "fixed_width_small"

// Origin key
private let kOriginalGiphy = "original"

// Options Gif Image
let gifOptions = [
    kFixedHeight, // Height set to 200px. Reduced to 6 frames to minimize file size to the lowest. Works well for unlimited scroll on mobile and as animated previews. See Giphy.com on mobile web as an example.
    kFixedWidth, // Width set to 200px. Reduced to 6 frames. Works well for unlimited scroll on mobile and as animated previews.
    kFixedHeightSmall, // Height set to 100px. Good for mobile keyboards.
    kFixedWidthSmall, // Width set to 100px. Good for mobile keyboards
    kOriginalGiphy // Original file size and file dimensions. Good for desktop use.
]

public enum GiphyRenditionOption: String {
    case FixedHeight = "fixed_height"
    case FixedWidth = "fixed_width"
    case FixedHeightSmall = "fixed_height_small"
    case FixedWidthSmall = "fixed_width_small"
    case OriginalGiphy = "original"
    
}

public class GiphyRendition {
    
    public var url: String
    public var fixedHeight: Float
    public var fixedWidth: Float
    public var size: Float
    public weak var giphyInfo: GiphyInfo?
    public var option: GiphyRenditionOption
    
    init(url: String, fixedHeight: Float, fixedWidth: Float, size: Float, option: GiphyRenditionOption) {
        
        self.url = url
        self.fixedWidth = fixedWidth
        self.fixedHeight = fixedHeight
        self.size = size
        self.option = option
    }
    
    /**
     Get id of giphy rendition via giphyInfo ID: giphyInfoID-renditiontype 
     Example: giphyInfo id: 123, rendition: small. The id: 123-small
     
     - returns: The id of giphy rendition
     */
    public func getID() -> String {
        if let giphyInfo = self.giphyInfo {
            return "\(giphyInfo.id)-\(option.rawValue)"
        }
        
        return ""
    }
    
}

@objc public class GiphyInfo: NSObject {
    
    // Properties
    public var id: String! // identifier gif in giphy
    public var slug: String! // Keyword in Giphy
    public var sourceGiphyURL: String! // String url Source gif in giphy
    private var images: Dictionary<String, GiphyRendition>! // The category gifs multi option
    
    public var fixedHeight: GiphyRendition? {
        if let image = images[kFixedHeight] {
            return image
        }
        
        return nil
    }
    
    public var fixedWidth: GiphyRendition? {
        if let image = images[kFixedWidth] {
            return image
        }
        
        return nil
    }
    
    public var fixedHeightSmall: GiphyRendition? {
        if let image = images[kFixedHeightSmall] {
            return image
        }
        
        return nil
    }
    
    public var fixedWidthSmall: GiphyRendition? {
        if let image = images[kFixedWidthSmall] {
            return image
        }
        
        return nil
    }
    
    public func getGiphyRendtion(rendition: GiphyRenditionOption) -> GiphyRendition? {
        if let image = images[rendition.rawValue] {
            return image
        }
        return nil
    }
    
    /**
     Private initialize object with empty param
     
     - returns: The GiphyInfo object with default value properties
     */
    private override init() {
        images = [:]
    }
    
    /**
     Generate GiphyInfo from Json data in Giphy API
     
     - parameter jsonData: The Json data to generate GiphyInfo. If The json is not struct of generate function this will return GiphyInfo nil
     @Example json struct in https://github.com/Giphy/GiphyAPI (Exception: Respone from Random)
     
     - returns: The GiphyInfo generated maybe nil if json is not correct
     */
    class func generateFormJSON(jsonData: NSDictionary) -> GiphyInfo? {
        var giphyInfo: GiphyInfo!
        
        if let id = jsonData.toStringAtKey(kGiphyID),
            let sourceGiphyURL = jsonData.toStringAtKey(kGiphyURL),
            let slug = jsonData.toStringAtKey(kGiphySlug),
            let images = jsonData.toDictionaryAtKey(kGiphyImages)
        {
            // Init new giphy
            giphyInfo = GiphyInfo()
            giphyInfo.id = id
            giphyInfo.sourceGiphyURL = sourceGiphyURL
            giphyInfo.slug = slug
            
            // Foreach option get info in jsonData
            for option in gifOptions {
                if let imageData = images.toDictionaryAtKey(option),
                    let url = imageData.toStringAtKey(kGiphyURL),
                    let width = imageData.toStringAtKey(kGiphyImageWidth),
                    let height = imageData.toStringAtKey(kGiphyImageHeight),
                    let size = imageData.toStringAtKey(kGiphyImageSize)
                {
                    let value = GiphyRendition(url: url, fixedHeight: Float(height)!, fixedWidth: Float(width)!, size: Float(size)!, option: GiphyRenditionOption(rawValue: option)!)
                    value.giphyInfo = giphyInfo
                    
                    giphyInfo.images[option] = value
                }
            }
        }
        
        return giphyInfo
    }
    
    /**
      Generate GiphyInfo from Json data in Giphy API. Just only use for getRandomGiphy
     
     - parameter jsonData: The Json data to generate GiphyInfo. If The json is not struct of generate function this will return GiphyInfo nil
      @Example json struct in https://github.com/Giphy/GiphyAPI - Respone from Random
     
     - returns: The GiphyInfo generated maybe nil if json is not correct
     */
    class func generateFromJSONOfRandomGiphy(jsonData: NSDictionary) -> GiphyInfo? {
        var giphyInfo: GiphyInfo!
        
        if let id = jsonData.toStringAtKey(kGiphyID),
            let sourceGiphyURL = jsonData.toStringAtKey(kGiphyURL)
        {
            // Init new giphy
            giphyInfo = GiphyInfo()
            giphyInfo.id = id
            giphyInfo.sourceGiphyURL = sourceGiphyURL
            giphyInfo.slug = (sourceGiphyURL.componentsSeparatedByString("/").last!).stringByReplacingOccurrencesOfString("-\(id)", withString: "")
            
            // Foreach option get info in jsonData
            for option in gifOptions {
                var urlKey = "\(option)_url"
                var heightKey = "\(option)_height"
                var widthKey = "\(option)_width"
                
                if option == kOriginalGiphy {
                    urlKey = "image_original_url"
                    heightKey = "image_height"
                    widthKey = "image_width"
                }
            
                // Foreach option get info in jsonData
                if  let url = jsonData.toStringAtKey(urlKey),
                    let height = jsonData.toStringAtKey(heightKey),
                    let width = jsonData.toStringAtKey(widthKey) {
                    
                    let value = GiphyRendition(url: url, fixedHeight: Float(height)!, fixedWidth: Float(width)!, size: kDefaultSize, option: GiphyRenditionOption(rawValue: option)!)
                    value.giphyInfo = giphyInfo
                    
                    giphyInfo.images[option] = value
                }
            }
        }
        
        return giphyInfo
    }
    
}






