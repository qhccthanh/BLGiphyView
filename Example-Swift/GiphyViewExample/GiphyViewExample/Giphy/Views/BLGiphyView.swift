//
//  BLGiphyView.swift
//  EmojiKeyboard
//
//  Created by qhcthanh on 8/22/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import Foundation

let kNumberOfLoadMoreItem: UInt = 16

@objc public protocol BLGiphyViewDelegate: NSObjectProtocol {
    
    optional func didBeginEditingText(textField: UITextField)
    
    optional func didEndEditingText(textField: UITextField)
    
    optional func didNeedDismissGiphyView(giphyView: BLGiphyView)
}

public class BLGiphyView: UIView {
    
    // MARK: UI Properties
    public var topBar: BLGiphyTopBarView! = nil
    public var bottomBar: BLGiphyBottomBarView! = nil
    public var giphyCollectionView: BLGiphyCollectionView! = nil
    
    // MARK: Private properties
    private var currentOption: BLGiphyBottomOptionItem = .Home
    private var lasTimeLoadMore: NSTimeInterval = 0
    private var isFirstTimeInit = true
    private var isSetupView = false
    private var searchTimer: NSTimer!
    
    // MARK: Public properties
    public var giphyToastView: BLGiphyToastView! = nil
    public var currentKeyword: String = ""
    public weak var delegate: BLGiphyViewDelegate?
    public weak var bottomGiphyCollectionViewContraint: NSLayoutConstraint!
    public var limitLoadMoreGiphy = 3
    
    /// The minimum time wait to search autocomplete giphy. Default is 0.3 second
    public var minimumWaitTimeAutoCompleteSearch = 0.3
    
    // MARK: Initialize
    public override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        setupView()
    }
    
    override public func updateConstraints() {
        super.updateConstraints()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Setup subview in GiphyView. This will call setupContrainst
     */
    private func setupView() {
        
        if self.isSetupView {
            return
        }
        
        self.isSetupView = true
        
        // Self init
        self.backgroundColor = .blackColor()
        self.clipsToBounds = true
        
        // Top bar init
        self.topBar = BLGiphyTopBarView()
        self.topBar.searchView.delegate = self
        self.topBar.dismissButton.addTarget(self, action: #selector(onTouchUpDismissButton), forControlEvents: .TouchUpInside)
        self.addSubview(self.topBar)
    
        // Bottom bar init
        self.bottomBar = BLGiphyBottomBarView()
        self.bottomBar.delegate = self
        self.addSubview(self.bottomBar)

        
        // giphyCollectionView init
        self.giphyCollectionView = BLGiphyCollectionView()
        self.giphyCollectionView.giphyDelegate = self
        self.giphyCollectionView.backgroundColor = .clearColor()
        
        self.addSubview(self.giphyCollectionView)
        
        
        // ToastView
        self.giphyToastView = BLGiphyToastView()
        self.giphyToastView.toastLabel.text = "This gif has copied. Now paste to input text"
        //self.giphyToastView.toastBackgroundColor = UIColor.redColor().colorWithAlphaComponent(0.5)
        self.addSubview(self.giphyToastView)
        
        self.setupContraints()
        //self.loadMoreRandomGiphy()
    }
    
    /**
     Setup Contraint of subViews. Need to call when updateContraints
     */
    public func setupContraints() {
        
        // Top bar constrain
        self.topBar.constrain(.Top, to: .Top, of: self, offsetBy: 2)
        self.topBar.constrain(.Left, to: .Left, of: self)
        self.topBar.constrain(.Right, to: .Right, of: self)
        self.topBar.constrain(.Height,to : 23 )
        
        // Bottom bar constrain
        self.bottomBar.constrain(.Bottom, to: .Bottom, of: self)
        self.bottomBar.constrain(.Left, to: .Left, of: self)
        self.bottomBar.constrain(.Right, to: .Right, of: self)
        self.bottomBar.constrain(.Height, being: .Equal, to: .Height, of: self, multipliedBy: 0.1)
        
        // Giphy CollectionView bar constrain
        self.giphyCollectionView.constrain(.Top, to: .Bottom, of: self.topBar, offsetBy: 6)
        self.bottomGiphyCollectionViewContraint = self.giphyCollectionView.constrain(.Bottom, to: .Top, of: self.bottomBar, offsetBy: -6)
        self.giphyCollectionView.constrain(.Left, to: .Left, of: self)
        self.giphyCollectionView.constrain(.Right, to: .Right, of: self)
        
        // GiphyToastView bar constrain
        self.giphyToastView.constrain(.Height, to: 35)
        self.giphyToastView.constrain(.Bottom, to: .Top, of: self)
        self.giphyToastView.constrain(.Left, to: .Left, of: self)
        self.giphyToastView.constrain(.Right, to: .Right, of: self)
    }
    
    func onTouchUpDismissButton() {
        if let delegate = self.delegate,
            let didNeedDismissGiphyView = delegate.didNeedDismissGiphyView
        {
            didNeedDismissGiphyView(self)
        }
    }
    
}

// MARK: BLGiphyBottomBarViewDelegate
extension BLGiphyView: BLGiphyBottomBarViewDelegate {
    
    /**
     Delegate called when selectItem Option in bottom bar. When select other option func will load giphy in this option
     
     - parameter itemOption: The item Option in bottom bar is selected
     */
    public func didSelectItem(itemOption: BLGiphyBottomOptionItem) {
        
        self.currentOption = itemOption
        self.giphyCollectionView.hidden = false
        
        // It will load trend giphys from GiphyManager and when load success, it will reload data of giphy collectionView in main thread
        if itemOption == .Trend {
            BLGiphyManager.shareManager().getTrendGiphy(kNumberOfLoadMoreItem) { (giphy, error) in
                if let giphy = giphy where error == nil {
                    self.giphyCollectionView.setGiphyDataSource(giphy)
                }
            }
            
            self.topBar.searchView.text = ""
        } else if itemOption == .Home {
            self.giphyCollectionView.setGiphyDataSource(BLGiphyManager.shareManager().getRandomGiphy())
            
            self.topBar.searchView.text = ""
        } else if itemOption == .Recent {

            self.topBar.searchView.text = currentKeyword
            
            if !currentKeyword.isEmpty {
                BLGiphyManager.shareManager().getSearchGiphy(currentKeyword) { (keyword, giphy, error) in
                    if let giphy = giphy where error == nil && keyword == self.currentKeyword {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.giphyCollectionView.setGiphyDataSource(giphy)
                        })
                    }
                }
                
            } else {
                
                self.giphyCollectionView.setGiphyDataSource([])
            }
        }
        else {
            
            self.giphyCollectionView.hidden = true
            self.topBar.searchView.text = ""
        }
        
    }
    
    /**
     Load more giphy item with random giphy API. The json data of giphy will cache to BLGiphyManager in randomGiphys properties
     The load more should be called when use scroll to bottom contentView of random collectionView and delay 5s 
     */
    public func loadMoreRandomGiphy() {
        
        if NSDate.startCount() - self.lasTimeLoadMore > 5 {
            self.lasTimeLoadMore = NSDate.startCount()
            BLGiphyManager.shareManager().loadMoreRandomGiphy(kNumberOfLoadMoreItem, handler: { (giphy, error) in
                if let giphy = giphy where error == nil {
                    if self.currentOption == .Home {
                        self.giphyCollectionView.insertGiphyDataSource(giphy)
                    }
                }
            })
        }
    }
    
   
    
}

// MARK: UITextFieldDelegate
extension BLGiphyView: UITextFieldDelegate {
    
    /**
     This function will be called when user begin editing a search textField in top bar GiphyView
     
     - parameter textField: The textField is searching
     */
    public func textFieldDidBeginEditing(textField: UITextField) {
        
        self.bottomBar.selectItemOption(.Recent)
        
        if let delegate = self.delegate, let didBeginEditing = delegate.didBeginEditingText {
            didBeginEditing(textField)
        }
        
    }
    
    /**
     This function will be called when user end editing a search textField in top bar GiphyView
     
     - parameter textField: The textField is end searching
     */
    public func textFieldDidEndEditing(textField: UITextField) {
        
        if let delegate = self.delegate, let didEndEditingText = delegate.didEndEditingText {
            didEndEditingText(textField)
        }
    }
    
    /**
     This function will be called when user tap return
     
     - parameter textField: The textField return
     */
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if let delegate = self.delegate, let didEndEditingText = delegate.didEndEditingText {
            didEndEditingText(textField)
        }
        
        if let text = textField.text where !text.isEmpty {
            
            self.currentKeyword = text
            searchGiphy(text)
            
            return true
        }
        
        return false
    }
    
    /**
     Search Giphy with keyword. This function will move to option .Recent and setGiphyDataSource with result giphySearch
     When block call back. It will update giphy datasource If block result keyword is equal currentKeyword in this GiphyView and not error
     
     - parameter keyword: The keyword want to search giphy
     */
    public func searchGiphy(keyword: String) {
        
        BLGiphyManager.shareManager().getSearchGiphy(keyword,numberGiphy: 10 , handler: {
            (searchKeyword, giphy, error) in
            
            if let giphy = giphy where error == nil && searchKeyword == self.currentKeyword {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.giphyCollectionView.setGiphyDataSource(giphy)
                })
            }
        })
    }
    
    @objc func searchGiphyAutoComplete(timer: NSTimer!) {
        if let userInfo = timer.userInfo,
            let keyword = userInfo["keyword"] as? String {
            self.searchGiphy(keyword)
        }
    }
    
    /**
     Discussion: When the search text change searchTimer will invalidate and create new keyword search will time minimumWaitTimeAutoCompleteSearch second run.
     
     */
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if let timer = self.searchTimer {
            timer.invalidate()
        }
        
        YLSessionManager.sharedDefaultSessionManager().cancelAllDataTask()
    
        var newText = textField.text! as NSString
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        
        self.searchTimer = NSTimer.scheduledTimerWithTimeInterval(minimumWaitTimeAutoCompleteSearch, target: self, selector: #selector(searchGiphyAutoComplete), userInfo: ["keyword": newText], repeats: false)
        
        self.currentKeyword = newText as String
        
        return true
    }
    
}

// MARK: BLGiphyCollectionViewDelegate
extension BLGiphyView: BLGiphyCollectionViewDelegate {
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // Load more if need
        if self.currentOption == .Home {
            if scrollView.contentOffset.x + scrollView.frame.width > scrollView.contentSize.width {
                if scrollView.contentOffset.x + scrollView.frame.width - scrollView.contentSize.width > scrollView.frame.width/6 {
                    if !self.isFirstTimeInit {
                        self.loadMoreRandomGiphy()
                    } else {
                        self.isFirstTimeInit = false
                    }
                }
            }
        }
    }
}








	