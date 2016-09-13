//
//  BLGiphyCollectionViewCell.swift
//  EmojiKeyboard
//
//  Created by Quach Ha Chan Thanh on 8/23/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import UIKit

@objc public protocol BLGiphyCollectionViewCellDelegate {
    
    func didSelectViewCell(viewCell: BLGiphyCollectionViewCell)
    
    func didReviewViewCell(viewCell: BLGiphyCollectionViewCell)
    
    func didEndReviewViewCell(viewCell: BLGiphyCollectionViewCell)
}

public class BLGiphyCollectionViewCell: UICollectionViewCell {
    
    // MARK: UI Properties
    public var gifView: BLGifView!
    public var indicatorView: UIActivityIndicatorView!
    
    // MARK: Public Properties
    public var showAnimated: Bool = true
    public var isDisplay: Bool = true
    public weak var giphyRendition: GiphyRendition?
    public weak var delegate: BLGiphyCollectionViewCellDelegate?
    
    /// The minimum time when user press in cell to select this gif if the gif exitsed. Default is 0.1 seconds
    public var minimumTimeToPressSelect: Double = 0.1
    
    /// The minimum time when user press in cell to select this gif if the gif exitsed. Default is 1 seconds
    public var minimumTimeToPressReview: Double = 1
    
    // MARK: Initialize
    public convenience init() {
        self.init()
        
        self.setupView()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupView()
    }
    
    /**
     Clean BLGifView and set current Image to nil
     */
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        if gifView != nil {
            self.gifView.cancelImageDownloadTask()
            self.gifView.cleanGIF()
            self.gifView.image = nil
        }
    }
    
    // MARK: Setup view method's
    
    /**
     Setup subview in BLGiphyCollectionViewCell
     */
    private func setupView() {
        
        // GifView
        self.gifView = BLGifView(frame: CGRectZero)
        self.gifView.hidden = true
        self.gifView.userInteractionEnabled = true
        
        self.contentView.addSubview(self.gifView)
        
        // Setup Gesture
        self.setupGestureGifView()
        
        // Initial indicatorView
        self.indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
//        self.indicatorView.hidesWhenStopped = true
        
        self.contentView.addSubview(self.indicatorView)
        
        // Setup Constraint
        self.gifView.constrain(toEdgesOf: self.contentView)
        self.indicatorView.constrain(toEdgesOf: self.contentView)
        
        // SetupView
        self.clipsToBounds = true
    }
    
    /**
     Setup Gesture to gifView. The gesture will catch the select Gif and review-endreview Gif
     */
    private func setupGestureGifView() {
        
        let selectGesture = UILongPressGestureRecognizer(target:self , action:  #selector(self.onTapGiphyGesture(_:)))
        selectGesture.minimumPressDuration = self.minimumTimeToPressSelect
        self.gifView.addGestureRecognizer(selectGesture)
        
        let reviewGesture = UILongPressGestureRecognizer(target:self , action:  #selector(self.onLongTapGiphyGestrue(_:)))
        reviewGesture.minimumPressDuration = self.minimumTimeToPressReview
        self.gifView.addGestureRecognizer(reviewGesture)
        
        // The selectGesture will be received when reviewGesture fail 
        selectGesture.requireGestureRecognizerToFail(reviewGesture)
    }
    
    // MARK: Public Method's
    
    /**
     Binding UI with GifRendition
     
     - parameter giphyRendition: The GiphyRendition to binding with imageGif
     */
    public func bindingUI(giphyRendition: GiphyRendition) {
        
        if gifView == nil {
            self.setupView()
        }
        
        self.giphyRendition = giphyRendition

        self.indicatorView.startAnimating()
        
        self.loadThumbGIF()
       
    }
    
    /**
     Load thumb UIImage via current BLGif in BLGifView. If thumbGif is nil, the BLGifView will empty and The Indicator is activing
     */
    public func loadThumbGIF() {
        
        if let giphyRendition = self.giphyRendition {
            let image = BLGIFCache.shareManager().thumbForKey(giphyRendition.getID())
            self.gifView.image = image
            
            if image != nil {
                self.indicatorView.stopAnimating()
            }
        }
    }
    
    /**
     Call when need display Gif. This function when stop current GifView and loadThumb if exists
     This will load BLGif via current giphyRendition URL if BLGif has exitsted in cache with id will load this else This GifView will dowload gif with URL in current giphyRendition.
     When download success this will cache BLGif to BLGIFCache and stop indicatorView, reloadUI if need
     */
    public func displayGif() {
        
        if let giphyRendition = self.giphyRendition {
            
            self.gifView.stopDisplay()
            self.loadThumbGIF()
            
            self.gifView.setGifImage(NSURL(string:giphyRendition.url)!, gifIdentifier: giphyRendition.getID(), gifPlaceholder: nil, manager: BLDisplayGifManager.defaultManager, loopCount: -1, success: {
                identifier, gif in
                
                if identifier == self.giphyRendition?.getID() {
                    dispatch_async(dispatch_get_main_queue(), {
                        if let gif = gif {
                            self.gifView.hidden = false
                            self.indicatorView.stopAnimating()
                            self.indicatorView.hidden = true
                            
                            self.gifView.setGifImage(gif)
                        }
                    })
                }
            })
        }
    }
    
    /**
     Call when cell invisableCell and end display gif.
     This function will clean current gif and cancel current task in gifView.
     This maybe load thumb if it exitsed
     */
    func endDisplayGif() {
        if gifView != nil {
            self.gifView.cancelImageDownloadTask()
            self.gifView.cleanGIF()
            
            self.loadThumbGIF()
        }
        
    }
    
    /**
     Call when user short press in cell. This will call didSelectViewCell from BLGiphyCollectionViewCellDelegate
     
     - parameter gesture: The gesture has received
     */
    func onTapGiphyGesture(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .Began {
            if let delegate = self.delegate {
                delegate.didSelectViewCell(self)
                
            }
        }
        
    }
    
    /**
     Call when user long press in cell. 
     This will call didReviewViewCell from BLGiphyCollectionViewCellDelegate if began gesture (when user hold enough time to review minimumTimeToPressReview)
     This will call didEndReviewViewCell from BLGiphyCollectionViewCellDelegate if ended gesture
     
     - parameter gesture: The gesture has received
     */
    func onLongTapGiphyGestrue(gesture: UILongPressGestureRecognizer) {
        
        if let delegate = self.delegate {
            if gesture.state == .Began {
                
                delegate.didReviewViewCell(self)
            } else if gesture.state == .Ended {
                
                delegate.didEndReviewViewCell(self)
            }
        }
    }
    
    /**
     Clean Gif when deinit
     */
    deinit {
        if self.gifView != nil {
            self.gifView.cleanGIF()
        }
    }
}
