//
//  BLGiphyCollectionView.swift
//  EmojiKeyboard
//
//  Created by Quach Ha Chan Thanh on 8/23/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import UIKit
import MobileCoreServices

private let kGiphyViewCell = "kGiphyViewCell"
private let kReviewViewTag = 101

@objc public protocol BLGiphyCollectionViewDelegate: UICollectionViewDelegate {
    
}

public class BLGiphyCollectionView: UICollectionView {
    
    // MARK: UI Properties
    
    public var giphyCollectionViewLayout: BLCollectionViewFlowLayout!
    
    // MARK: Public Properties
    
    public var isRemoveSelf = false
    public var giphyRenditionOption: GiphyRenditionOption = .FixedHeightSmall
    public weak var giphyDelegate: BLGiphyCollectionViewDelegate?
    
    // MARK: Public Properties
    
    private var giphyDataSource: [GiphyInfo] = [GiphyInfo]()
    private var isLoadGif: Bool = true
    private var internalSerialQueue = dispatch_queue_create("com.fresher2016.ReloadDatdGiphyCollectionView", DISPATCH_QUEUE_SERIAL)
    
    // MARK: Initialize
    
    public convenience init() {
        
        // Setup CollectionView layout
        let giphyCollectionViewLayout = BLCollectionViewFlowLayout()
        giphyCollectionViewLayout.minimumInteritemSpacing = 2
        giphyCollectionViewLayout.minimumLineSpacing = 2
        giphyCollectionViewLayout.scrollDirection = .Horizontal
        
        self.init(frame: CGRectZero,collectionViewLayout: giphyCollectionViewLayout)
        
        // Asign to self
        self.giphyCollectionViewLayout = giphyCollectionViewLayout
        self.giphyCollectionViewLayout.delegate = self
        
        // Setup view
        self.contentInset = UIEdgeInsetsMake(2, 5, 2, 5)
        self.showsHorizontalScrollIndicator = false
        
        self.dataSource = self
        self.delegate = self
        
        self.registerClass(BLGiphyCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: kGiphyViewCell)
    }
    
    // MARK: Public Method's
    
    /**
     Set giphy source to display in this collectionView. When set giphy source
     This will excuse in internalSerialQueue
     
     - parameter giphys: The giphy array binding to collectionView
     */
    public func setGiphyDataSource(giphys: [GiphyInfo]) {
        
        dispatch_async(internalSerialQueue, {
            YLImageDownloader.sharedDefaultImageDownloader().cancelAllDataTask()
            BLDisplayGifManager.defaultManager.deleteAllImageView()
            
            dispatch_sync(dispatch_get_main_queue(), {
                self.giphyDataSource = giphys
                self.reloadData()
                self.setContentOffset(CGPointZero, animated: false)
                self.collectionViewLayout.invalidateLayout()
            })
            
        })
    }
    
    /**
     Remove all Giphy item to collectionView this will excuse in internalSerialQueue
     */
    public func removeCollectionView() {
        
        dispatch_async(internalSerialQueue, {
            
            dispatch_sync(dispatch_get_main_queue(), {
                self.giphyDataSource.removeAll()
                self.reloadData()
            })
        })
    }
    
    /**
     Insert Giphy item to collectionView this will excuse in internalSerialQueue
     
     - parameter giphys: The giphy array to insert
     */
    public func insertGiphyDataSource(giphys: [GiphyInfo]) {

        dispatch_async(internalSerialQueue, {
            
            // Insert giphy to collectionView UI
            dispatch_sync(dispatch_get_main_queue(), {
                var indexPathInsert = [NSIndexPath]()
                
                for giphy in giphys {
                    indexPathInsert.append(NSIndexPath(forItem: self.giphyDataSource.count, inSection: 0))
                    self.giphyDataSource.append(giphy)
                }
                
                
                self.insertItemsAtIndexPaths(indexPathInsert)
            })
        })
    }

    
}

// MARK: BLFlowLayoutDelegate
extension BLGiphyCollectionView: BLFlowLayoutDelegate {
    
    func collectionView(collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: NSIndexPath, withHeight: CGFloat) -> CGFloat {
        
        if let giphyRendition = self.giphyDataSource[indexPath.row].getGiphyRendtion(giphyRenditionOption) {
            return CGFloat(giphyRendition.fixedWidth)
        }
        
        return 0
    }
    
}

// MARK: UICollectionViewDelegate + UICollectionViewDataSource
extension BLGiphyCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
         return giphyDataSource.count
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    /**
     Binding GiphyRendition in GiphyDatasource with indexPath. 
     When binding will set delegate to it
     The BLGiphyCollectionViewCell will not display gif immediately. It's will download or display gif in delegate willDisplayCell
     CellForItemAtIndexPath just binding data display to this cell at indexPath
     */
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // Get Cell reuse and set delegate
        let giphyCell = collectionView.dequeueReusableCellWithReuseIdentifier(kGiphyViewCell, forIndexPath: indexPath) as! BLGiphyCollectionViewCell
        giphyCell.delegate = self
        
        // Binding UI
        let giphyRendition = self.giphyDataSource[indexPath.row].getGiphyRendtion(giphyRenditionOption)
        giphyCell.bindingUI(giphyRendition!)
        
        return giphyCell
    }
    
    /**
     When cell will display. We will check isLoadGif
     isLoadGif is TRUE if collectionView is static (not scroll). WillDisplayCell will display gif in this cell, if GIF existed just startAnimate Gif, else download gif and display
     isLoadGif is FALSE if collectionView is dynamic (scrolling). WillDisplayCell will loadThumbGIF in this cell if existed
     
     @discussion: We should load cell when collectionView static. Because displayGif will create download task foreach cell when scrolling, it use so much CPU to create many download thread when scrolling. (> 70% CPU).
     */
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if let giphyCell = cell as? BLGiphyCollectionViewCell {
            if isLoadGif  {
                giphyCell.displayGif()
            } else {
                giphyCell.loadThumbGIF()
            }
        }
    }
    
    /**
     When cell EndDisplaying. 
     This function will clean current gif and cancel current task in gifView. 
     This maybe load thumb if it exitsed
     */
    public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if let giphyCell = cell as? BLGiphyCollectionViewCell {
            giphyCell.endDisplayGif()
        }
    }

}

// MARK: UIScrollViewDelegate
extension BLGiphyCollectionView {
    
    /**
    When collectionView didScroll, this will pass action to giphyDelegate.
     
     @Notes: This action in this scrollViewDidScroll is load more random Giphy in BLGiphyView
     */
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if let gDelgate = self.giphyDelegate,
            let scrollViewDidScroll = gDelgate.scrollViewDidScroll
        {
            scrollViewDidScroll(scrollView)
        }
    }
    
    /**
     scrollViewDidEndDecelerating will be called when user stop scroll in collectionView.
     
     @discussion: We will display gif in visable cells when collectionView is static (not scrolling)
    */
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        for visableCell in self.visibleCells() {
            if let giphyCell = visableCell as? BLGiphyCollectionViewCell {
                giphyCell.displayGif()
            }
        }
        
         self.isLoadGif = true
    }
    
    /**
     @discussion: We will stop display gif in collectionView via isLoadGif flag. 
                  When isLoadGif is false, the cell display will not load gif immediately
    */
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.isLoadGif = false
    }

}

// MARK: BLGiphyCollectionViewCellDelegate
extension BLGiphyCollectionView: BLGiphyCollectionViewCellDelegate {
    
    public func didSelectViewCell(viewCell: BLGiphyCollectionViewCell) {
        
        // Get giphyRendition source ID
        let giphyID = viewCell.giphyRendition?.getID()
        
        // Check giphyID not nil and cacheGif, cacheData exits
        if let giphyID = giphyID,
            let cacheGIF = BLGIFCache.shareManager().gifForKey(giphyID),
            let gifData = cacheGIF.imageData
        {
            // Copy to clipboard
            UIPasteboard.generalPasteboard().setData(gifData, forPasteboardType: kUTTypeGIF as String)
            
            // Show animation or something when copy success
            if let superView = self.superview as? BLGiphyView, let toastView = superView.giphyToastView {
                toastView.animateShowToast(1.5)
            }
        }
        
    }
    
    public func didReviewViewCell(viewCell: BLGiphyCollectionViewCell) {
        
        // Set current review gif is FixedHeightSmall (current in binding collectionCell)
        if let reviewGifImage = viewCell.gifView.gifImage {
            let reviewView = BLGifView(gifImage: reviewGifImage)
            
            // Get GiphyReview is option FixedHeightDownsampled in orignal giphyInfo
            if let giphyFixedHeightReview = viewCell.giphyRendition?.giphyInfo?.getGiphyRendtion(GiphyRenditionOption.FixedHeight) {
                
                let giphyFixedHeightReviewID: String = giphyFixedHeightReview.getID()
                
                // Download Large gif option FixedHeightDownsampled and display it when download success
                reviewView.setGifImage(NSURL(string: giphyFixedHeightReview.url)!, gifIdentifier: giphyFixedHeightReviewID, success: {
                    identifier, gif in
                    
                    if identifier == giphyFixedHeightReviewID {
                        dispatch_async(dispatch_get_main_queue(), {
                            if let gif = gif {
                                reviewView.setGifImage(gif, contentMode: .ScaleAspectFit)
                                reviewView.startAnimatingGif()
                            }
                        })
                    }
                })
                
            }
            
            // Show BLToastView
            reviewView.tag = kReviewViewTag
            reviewView.contentMode = .ScaleAspectFit
            self.superview!.addSubview(reviewView)
            
            reviewView.constrain(toEdgesOf: self)
        }
    }
    
    public func didEndReviewViewCell(viewCell: BLGiphyCollectionViewCell) {
        
        // Remove BLToastView if existsed
        if let review = self.superview!.viewWithTag(kReviewViewTag) {
            review.removeFromSuperview()
        }
    }
    
}









