//
//  BLGiphyRequestManager.swift
//  EmojiKeyboard
//
//  Created by qhcthanh on 8/18/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import Foundation
import UIKit

var limitDefault: UInt = 30
let kGiphyAPIKeyTrial = "dc6zaTOxFJmzC"
let kHostGiphyLink = "http://api.giphy.com/v1/gifs"

private typealias RequestCompletionHandler = (data: NSData?, respone: NSURLResponse?, error: NSError?) -> Void
public typealias GiphyCompletionHandler = (giphy: [GiphyInfo]?, error: NSError?) -> Void

private var giphyRequestToken: dispatch_once_t = 0

public class BLGiphyRequestManager: NSObject {
    
    // The instance singleton BLGiphyRequestManager
    private static var instance: BLGiphyRequestManager!
   
    // The dataTask request a giphy in server. Just request one time 1 session task in giphy server
    private var dataTasks: [NSURLSessionTask]
    
    private override init() {
        
        self.dataTasks = [NSURLSessionTask]()
        
        super.init()
    }
    
    /**
     Get the singleton BLGiphyRequestManager
     
     - returns: The singleton GiphyManager
     */
    public class func shareManager() -> BLGiphyRequestManager {

        dispatch_once(&giphyRequestToken, {
            BLGiphyRequestManager.instance = BLGiphyRequestManager()
        })
        
        return BLGiphyRequestManager.instance
    }
    
    private func generateURLRequestGiphy(type: String, param: NSDictionary?) -> NSURL {
        
        var link: String
        if type != "" {
            link = "\(kHostGiphyLink)/\(type)?api_key=\(kGiphyAPIKeyTrial)"
        } else {
            link = "\(kHostGiphyLink)?api_key=\(kGiphyAPIKeyTrial)"
        }
        if let param = param {
            for key in param.allKeys {
                if let value = param.valueForKey(key as! String) {
                    var valueKey = value
                    if let value = value as? NSArray {
                        valueKey = value.componentsJoinedByString(",")
                    }
                    link += "&\(key)=\(valueKey)"
                }
            }
        }
        
        return NSURL(string: link.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
    }
    
    public func searchKeywordGiphy(searchKeyword: String, limit: UInt = limitDefault, completion: GiphyCompletionHandler) {
        //        Example
        //        http://api.giphy.com/v1/gifs/search?q=funny+cat&api_key=dc6zaTOxFJmzC&limit=1
        
        let requestURL = self.generateURLRequestGiphy("search", param: ["q": searchKeyword.stringByReplacingOccurrencesOfString(" ", withString: "+").lowercaseString,"limit":limit])
        self.requestGiphy(requestURL) { (data, respone, error) in
            if let error = error {
                completion(giphy: nil,error: error)
            } else {
                // parse json
                completion(giphy: self.parseGiphyFromJsonData(data), error: error)
            }
        }
    }
    
    public func searchIDsGiphy(id: [String], limit: UInt = limitDefault, completion: GiphyCompletionHandler) {
        //        Example
        //        http://api.giphy.com/v1/gifs?api_key=dc6zaTOxFJmzC&ids=[feqkVgjJpYtjy,7rzbxdu0ZEXLy]
        let requestURL = self.generateURLRequestGiphy("", param: ["ids":id])
        
        self.requestGiphy(requestURL) { (data, respone, error) in
            if let error = error {
                completion(giphy: nil,error: error)
            } else {
                // parse json
                completion(giphy: self.parseGiphyFromJsonData(data), error: error)
            }
        }
    }
    
    public func getTrendGiphy(limit: UInt = limitDefault, completion: GiphyCompletionHandler) {
        //        Example
        //        http://api.giphy.com/v1/gifs/trending?api_key=dc6zaTOxFJmzC&limit=5
        let requestURL = self.generateURLRequestGiphy("trending", param: ["limit":limit])
        self.requestGiphy(requestURL) { (data, respone, error) in
            if let error = error {
                completion(giphy: nil,error: error)
            } else {
                // parse json
                completion(giphy: self.parseGiphyFromJsonData(data), error: error)
            }
        }
    }
    
    /**
     Get random giphy just once request once time
     */
    public func getRandomGiphy(tag: String? = nil, limit: UInt = limitDefault, completion: GiphyCompletionHandler) {
        //        Example
        //        http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC
        //        Tag: http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=\(tag)
        let param = NSMutableDictionary()
        param["limit"] = limit
        
        if let tag = tag {
            param["tag"] = tag
        }
        
        let requestURL = self.generateURLRequestGiphy("random", param: param)
        self.requestGiphy(requestURL) { (data, respone, error) in
            if let error = error {
                completion(giphy: nil,error: error)
            } else {
                // parse json
                completion(giphy: self.parseGiphyFromJsonData(data, random: true), error: error)
            }
        }
    }
    
    private func requestGiphy(url: NSURL, completion: RequestCompletionHandler ) {
        
        YLSessionManager.sharedDefaultSessionManager().startDataTaskWithURL(url, completionHandler: {
            (data, respone, error) in
            completion(data: data, respone: respone, error: error)
        })

//        let newDataTask = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, respone, error) in
//            completion(data: data, respone: respone, error: error)
//        }
//        newDataTask.resume()
        
        //self.dataTasks.append(newDataTask)
    }
    
    private func parseGiphyFromJsonData(jsonData: NSData?, random: Bool = false) -> [GiphyInfo] {
        var giphyArray = [GiphyInfo]()
        
        if let jsonData = jsonData,
            let json = NSDictionary.fromJSON(jsonData)
        {
            if !random {
                if let giphyDatas = json.toArrayAtKey("data") {
                    // Get array data giphy
                    for giphyData in giphyDatas {
                        if let jsonData = giphyData as? NSDictionary,
                            let giphy = GiphyInfo.generateFormJSON(jsonData)
                        {
                            giphyArray.append(giphy)
                        }
                    }
                }
            } else {
                if  let giphyDatas = json.toDictionaryAtKey("data"), let giphy = GiphyInfo.generateFromJSONOfRandomGiphy(giphyDatas) {
                    giphyArray.append(giphy)
                }
            }
        }
        
        return giphyArray
    }
    
    public func cancelAllTask() {
        NSURLSession.sharedSession().invalidateAndCancel()
    }
    
}





