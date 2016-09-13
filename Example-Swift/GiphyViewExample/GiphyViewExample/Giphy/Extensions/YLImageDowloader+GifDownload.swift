//
//  YLImageDowloader+GifDownload.swift
//  EmojiKeyboard
//
//  Created by qhcthanh on 8/22/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import Foundation


public extension YLImageDownloader {
    
    typealias DownloadGIFWithURLCompletionHandler = (taskID: INTEGER_T, imageIdentifier: String, gif: BLGif?, response: NSURLResponse?, error: NSError?) -> Void
    
    public func downloadGIFWithURL(url: NSURL,taskIdentifier: INTEGER_T, identifier: String, completionHandler: DownloadGIFWithURLCompletionHandler)  {
        
        self.sessionManager.startDataTaskWithURL(url, taskIdentifier: taskIdentifier) { (data, response, error) in
            
            if let error = error {
                completionHandler(taskID: taskIdentifier, imageIdentifier: identifier, gif: nil, response: response, error: error)
            } else {
                let downloadedGif = BLGif(gifData: data)
//                YLImageCache.sharedCachedImage().cacheImage(downloadedGif, forKey: identifier)
                BLGIFCache.shareManager().cacheGIF(downloadedGif, forKey: identifier)
                completionHandler(taskID: taskIdentifier, imageIdentifier: identifier, gif: downloadedGif, response: response, error: error)
            } 
        }
        
    }
}
