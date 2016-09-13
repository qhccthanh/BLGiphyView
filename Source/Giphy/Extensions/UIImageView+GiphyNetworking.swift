//
//  UIImageView+GiphyNetworking.swift
//  EmojiKeyboard
//
//  Created by qhcthanh on 8/22/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import Foundation
import UIKit

private let _activeImageDownloadIdentifier = malloc(4)

extension BLGifView {
    
    // MARK: SetImage

    /**
     Set a gif image and a manager to an existing UIImageView.
     WARNING : this overwrite any previous gif.
     
     - parameter gifURL:         The gifURL to download gif data
     - parameter gifPlaceholder: The UIImage Gif to display when downloading gifURL
     - parameter manager:        The manager to handle the gif display
     - parameter loopCount:      The number of loops we want for this gif. -1 means infinite. Default: -1 (infinite)
     */
    public func setGifImage(gifURL: NSURL,gifIdentifier: String, gifPlaceholder: UIImage? = nil, manager: BLDisplayGifManager = BLDisplayGifManager.defaultManager, loopCount:Int = -1, success: ((identifier: String, gif: BLGif?) -> Void)? = nil, failure: ((error: NSError) -> Void)? = nil ) {
        
        // Check Current ImageView with URL Task. If CurrentURL = url param will return
        if self.isActiveTaskURLEqualToURL(gifURL) {
            return
        }
        
        // Cancel task in this ImageView if exists
        
        self.cancelImageDownloadTask()
        
        // Get Gif in cache
        
        let cacheGif: BLGif? = BLGIFCache.shareManager().gifForKey(gifIdentifier)

//        var cacheGif: UIImage?
//        let cacheGIFData: NSData? = BLGIFCache.shareManager().gifDataForKey(gifIdentifier)
//        
//        if let cacheGIFData = cacheGIFData {
//            cacheGif = UIImage(gifData: cacheGIFData)
//        }
        
        
        // Check Image in Cache Exists
        if let cacheGif = cacheGif {
            if let success = success {
                success(identifier: gifIdentifier,gif: cacheGif)
            } else {
                self.image = nil
                self.setGifImage(cacheGif,contentMode: .ScaleAspectFit, manager: manager)
            }
        } else {
            // Set Placeholder
            if gifPlaceholder != nil {
                self.image = nil
//                self.setGifImage(gifPlaceholder,contentMode: .ScaleAspectFit , manager: manager, loopCount: loopCount)
            }
            
            self.activeImageURL = gifURL.absoluteString
            
            let gifDownloader =  UIImageView.sharedImageDownloader()
            
            let dataTaskID: INTEGER_T = gifDownloader.generateTaskIdentifier()
            self.activeImageDownloadIdentifier = dataTaskID
            
            gifDownloader.downloadGIFWithURL(gifURL,taskIdentifier: dataTaskID, identifier: gifIdentifier, completionHandler: {
                 [weak self]  (taskIdentifier, identifier, image, respone, error) in
                if let strongSelf = self {
                    if strongSelf.activeImageDownloadIdentifier == taskIdentifier && gifIdentifier == identifier {
                        if let error = error, let failure = failure {
                            failure(error: error)
                        } else {
                            if let success = success {
                                success(identifier: gifIdentifier,gif: image)
                            } else if let image = image {
                                if !NSThread.isMainThread() {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        strongSelf.cleanGIF()
                                        strongSelf.setGifImage(image, manager: manager)
                                    })
                                } else {
                                    strongSelf.cleanGIF()
                                    strongSelf.setGifImage(image, manager: manager)
                                }
                                
                            }
                            strongSelf.activeImageURL = ""
                        }
                    } else {
                        
                    }
                }
            })
        }
        
    }
    
}