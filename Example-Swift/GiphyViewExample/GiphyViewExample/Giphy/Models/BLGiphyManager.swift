//
//  GiphyManager.swift
//  EmojiKeyboard
//
//  Created by Quach Ha Chan Thanh on 8/23/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import Foundation

private var giphyManagerToken: dispatch_once_t = 0

public class BLGiphyManager: NSObject {
    
    // MARK: Private Properties
    private static var giphyManager: BLGiphyManager!
    
    private var trendGiphys: [GiphyInfo]?
    private var randomGiphys: [GiphyInfo] = []
    private var mySearchGiphys: Dictionary<String, [GiphyInfo]> =  Dictionary<String, [GiphyInfo]>()
    
    // MARK: Pulbic method's
    
    /**
     Share the singleton GiphyManager
     
     - returns: The instance singleton object
     */
    public class func shareManager() -> BLGiphyManager {
        
        dispatch_once(&giphyManagerToken, {
            giphyManager = BLGiphyManager()
        })
        
        return giphyManager
    }
    
    /**
     Private init object
     
     - returns: The GiphyManager Instance
     */
    private override init() {
        
    }
    
    
    /**
     Get Trend Giphy via BLGiphyRequestManager. The Giphy when load success will cache to this manager
     
     - parameter numberGiphy: Number giphy trend want to get
     - parameter handler:     The completion handler when get Giphy has parse to GiphyInfo array
     */
    public func getTrendGiphy(numberGiphy: UInt = 26, handler: GiphyCompletionHandler) {
        
        if self.trendGiphys == nil || self.trendGiphys!.count == 0 {
            BLGiphyRequestManager.shareManager().getTrendGiphy(numberGiphy) { (giphys, error) in
                self.trendGiphys = giphys
                
                handler(giphy: self.trendGiphys, error: error)
            }
        } else {
            handler(giphy: self.trendGiphys, error: nil)
        }
    }
    
    /**
     Load more random giphy with numberGiphy random. The Giphy when load success will cache to this manager
     
     - parameter numberGiphy: The max numberGiphy want to load
     - parameter handler: The completion handler when get Giphy has parse to GiphyInfo array
     */
    public func loadMoreRandomGiphy(numberGiphy: UInt,handler: GiphyCompletionHandler) {
        
        var numberGiphy = numberGiphy
        for _ in 1...numberGiphy {
            BLGiphyRequestManager.shareManager().getRandomGiphy { (giphy, error) in
                
                if let giphy = giphy {
                    var giphyArray = [GiphyInfo]()
                    
                    for giphyElement in giphy {
                        
                        let itemsDuplicate = self.randomGiphys.filter({
                            if $0.id == giphyElement.id {
                                return true
                            }
                            return false
                        })
                        
                        if itemsDuplicate.count == 0 {
                            self.randomGiphys.append(giphyElement)
                            giphyArray.append(giphyElement)
                        } else {
                            numberGiphy += 1
                        }
                    }
                    
                    handler(giphy: giphyArray, error: nil)
                    
                } else {
                    handler(giphy: nil, error: error)
                }
            }
        }
    }
    
    /**
     Get Search Giphy with Keyword. The Giphy when load success will cache to this manager in mySearchGiphy to get it call get mySearchGiphy with key
     
     - parameter keyword:     The keyword giphy to search
     - parameter numberGiphy: The max number giphy return when search
     - parameter handler:     The completion handler when get Giphy has parse to GiphyInfo array
     */
    public func getSearchGiphy(keyword: String, numberGiphy: UInt = 26,handler: (searchKeyword: String, giphy: [GiphyInfo]?, error: NSError?) -> Void) {
        
        YLSessionManager.sharedDefaultSessionManager().cancelAllDataTask()
        
        if let giphySearch = self.mySearchGiphys[keyword.lowercaseString] {
            handler(searchKeyword: keyword, giphy: giphySearch, error: nil)
        } else {
            BLGiphyRequestManager.shareManager().searchKeywordGiphy(keyword, limit: numberGiphy) { (giphys, error) in
                self.mySearchGiphys[keyword.lowercaseString] = giphys
                handler(searchKeyword: keyword, giphy: giphys, error: error)
            }
        }
    }
    
    public func searchGiphyLocal(id: String) {
    
    }
    
    /**
     Get the random giphy in this manager
     
     - returns: The random giphy array in this manager
     */
    public func getRandomGiphy() -> [GiphyInfo] {
        return self.randomGiphys
    }
    
    public func removeAllDataCache() {
        self.trendGiphys?.removeAll()
        self.mySearchGiphys.removeAll()
        self.randomGiphys.removeAll()
        self.mySearchGiphys.removeAll()
    }
    
}



