//
//  BLGiphyBottomBarView.swift
//  EmojiKeyboard
//
//  Created by Quach Ha Chan Thanh on 8/23/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import UIKit

@objc public enum BLGiphyBottomOptionItem: Int {
    case Home
    case MyFavorite
    case Recent
    case Trend
}

@objc public protocol BLGiphyBottomBarViewDelegate: NSObjectProtocol {
    optional func didSelectItem(itemOption: BLGiphyBottomOptionItem)
}

public class BLGiphyBottomBarView: UIView {
    
    // MARK: UI Properties
    public var homeButtonView: BLGiphyButtonControl!
    public var myButtonView: BLGiphyButtonControl!
    public var recentButtonView: BLGiphyButtonControl!
    public var trendButtonView: BLGiphyButtonControl!
    
    // MARK: Public properties
    public var currentSelectedControl: BLGiphyButtonControl?
    public weak var delegate: BLGiphyBottomBarViewDelegate?
    
    // MARK: Initialize
    public convenience init() {
        self.init(frame: CGRectZero)
        
        setupView()
    }
    
    /**
     Inititialize subview's
     */
    public func setupView() {
        
        self.createPageButton()
        self.updateConstraint()
        
    }
    
    /**
     Update contrainsts subView's need to call when reload UI
     */
    func updateConstraint() {

        self.homeButtonView.constrain(.Top, to: . Top, of: self)
        self.homeButtonView.constrain(.Bottom, to: .Bottom, of: self, offsetBy: -3)
        self.homeButtonView.constrain(.Left, to: . Left, of: self, offsetBy: 10)
        self.homeButtonView.constrain(.Width, being: .Equal, to: .Width, of: self, multipliedBy: 0.25, offsetBy: -2.5)
        
        self.myButtonView.constrain(.Top, to: . Top, of: self.homeButtonView)
        self.myButtonView.constrain(.Bottom, to: .Bottom, of: self.homeButtonView)
        self.myButtonView.constrain(.Left, to: . Right, of: self.homeButtonView)
        self.myButtonView.constrain(.Width, to: .Width, of: self.homeButtonView)
        
        self.recentButtonView.constrain(.Top, to: . Top, of: self.homeButtonView)
        self.recentButtonView.constrain(.Bottom, to: .Bottom, of: self.homeButtonView)
        self.recentButtonView.constrain(.Left, to: . Right, of: self.myButtonView)
        self.recentButtonView.constrain(.Width, to: .Width, of: self.homeButtonView)
        
        self.trendButtonView.constrain(.Top, to: . Top, of: self.homeButtonView)
        self.trendButtonView.constrain(.Bottom, to: .Bottom, of: self.homeButtonView)
        self.trendButtonView.constrain(.Left, to: . Right, of: self.recentButtonView)
        self.trendButtonView.constrain(.Width, to: .Width, of: self.homeButtonView)
        
    }
    
    /**
     Create option button's
     */
    private func createPageButton() {
        
        // self.homeButtonView
        self.homeButtonView = BLGiphyButtonControl(
            image: UIImage(named: "Home_dark"),
            selectedImage: UIImage(named: "Home Filled_dark"), select: true)
        self.addSubview(self.homeButtonView)

        
        self.homeButtonView.onSelected()
        self.currentSelectedControl = self.homeButtonView
        self.homeButtonView.addTarget(self, action: #selector(onTouchUpInsideActiveControl), forControlEvents: .TouchUpInside)
        
        // self.myButtonView
        self.myButtonView = BLGiphyButtonControl(
            image: UIImage(named: "Happy_dark"),
            selectedImage: UIImage(named: "Happy Filled_dark"))
        self.addSubview(self.myButtonView)
        
        self.myButtonView.addTarget(self, action: #selector(onTouchUpInsideActiveControl), forControlEvents: .TouchUpInside)
        
        // self.recentButtonView
        self.recentButtonView = BLGiphyButtonControl(
            image: UIImage(named: "Time_dark"),
            selectedImage: UIImage(named: "Time Filled_dark"))
        self.addSubview(self.recentButtonView)
        
       
        
        self.recentButtonView.addTarget(self, action: #selector(onTouchUpInsideActiveControl), forControlEvents: .TouchUpInside)
        
        // self.trendButtonView
        self.trendButtonView = BLGiphyButtonControl(
            image: UIImage(named: "Line Chart_dark"),
            selectedImage: UIImage(named: "Line Chart Filled_dark"))
        self.addSubview(self.trendButtonView)
        
        self.trendButtonView.addTarget(self, action: #selector(onTouchUpInsideActiveControl), forControlEvents: .TouchUpInside)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        self.self.homeButtonView.updateConstraints()
    }
    
    /**
     When touch up inside action in each bottom control. 
     This will update state in bottom bar and call onSelected in sender to animation update display select control
     This function will call the delegate with corresponding action
     
     - parameter sender: The control button touch up inside
     */
    @objc func onTouchUpInsideActiveControl(sender: BLGiphyButtonControl!) {

        if self.currentSelectedControl != sender {
            if let currentSelectedControl = self.currentSelectedControl {
                currentSelectedControl.onDeselect()
            }
            
            self.currentSelectedControl = sender
            sender.onSelected()
            
            if let delegate = self.delegate, let selectSelector = delegate.didSelectItem {
                switch sender {
                case self.homeButtonView:
                    selectSelector(.Home)
                    break
                case self.myButtonView:
                    selectSelector(.MyFavorite)
                    break
                case self.recentButtonView:
                    selectSelector(.Recent)
                    break
                case self.trendButtonView:
                    selectSelector(.Trend)
                    break
                default:
                    break
                }
            }
           
        }
    }
    
    /**
     Call when user select option button manually. This function will call touchUpInside target in this option button
     
     - parameter option: The option to select
     */
    public func selectItemOption(option: BLGiphyBottomOptionItem) {
        
        var buttonSelect: BLGiphyButtonControl?
        
        switch option {
            case .Home:
                buttonSelect = homeButtonView
            case .MyFavorite:
                buttonSelect = myButtonView
            case .Trend:
                buttonSelect = trendButtonView
            case .Recent:
                buttonSelect = recentButtonView
        }
        
        if let buttonSelect = buttonSelect {
            self.onTouchUpInsideActiveControl(buttonSelect)
        }
    }
}

