//
//  BLGiphyTopBarView.swift
//  EmojiKeyboard
//
//  Created by Quach Ha Chan Thanh on 8/23/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import UIKit

public class BLGiphyTopBarView: UIView {
    
    // MARK: UI Properties
    var searchView: UITextField!
    var keyboardButton: UIButton!
    var dismissButton: UIButton!
    
    // MARK: Public properties
    var currentSearchText: String?
    
    // MARK: Initialize
    public convenience init() {
        self.init(frame: CGRectZero)
        
        setupView()
    }
    
    func setupView() {
        
        // Setup Search Text Field
        self.searchView = UITextField()
        self.addSubview(searchView)
        
        self.searchView.layer.cornerRadius = 5
        self.searchView.layer.borderColor = UIColor.whiteColor().CGColor
        self.searchView.layer.borderWidth = 1.5
        
        self.searchView.textColor = UIColor.whiteColor()
        self.searchView.attributedPlaceholder = NSAttributedString(string: "Search text in here", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        self.searchView.textAlignment = .Center
        
        // Setup change KeyboardButton
        self.keyboardButton = UIButton.init(type: .System)
        self.addSubview(keyboardButton)
        self.keyboardButton.setTitle("Aa", forState: .Normal)
        self.keyboardButton.tintColor = .whiteColor()
        self.keyboardButton.titleLabel?.adjustsFontSizeToFitWidth
        self.keyboardButton.addTarget(self, action: #selector(endEditingSearchText), forControlEvents: .TouchUpInside)
        
        self.dismissButton = UIButton.init(type: .System)
        self.addSubview(dismissButton)
        self.dismissButton.setImage(
            UIImage(named: "Delete Filled_dark"), forState: .Normal)
        self.dismissButton.tintColor = .whiteColor()
        
        self.setupConstraints()
    }
    
    func setupConstraints() {
        
        // self.searchView constraint
        self.searchView.constrain(.Left, to: .Left, of: self, offsetBy: 5)
        self.searchView.constrain(.Top, to: . Top, of: self, offsetBy: 2)
        self.searchView.constrain(.Bottom, to: . Bottom, of: self, offsetBy: 2)
        
        // self.keyboard constraint
        self.dismissButton.constrain(.Top, to: . Top, of: self.searchView, offsetBy: 3)
        self.dismissButton.constrain(.Bottom, to: . Bottom, of: self.searchView, offsetBy: -3)
        self.dismissButton.constrain(.Right, to: .Right, of: self, offsetBy: -5)
        self.dismissButton.constrain(.Width, to: .Height, of: self.dismissButton)
        
        // self.keyboard constraint
        self.keyboardButton.constrain(.Top, to: . Top, of: self.dismissButton)
        self.keyboardButton.constrain(.Bottom, to: . Bottom, of: self.dismissButton)
        self.keyboardButton.constrain(.Right, to: .Left, of: self.dismissButton, offsetBy: -5)
        self.keyboardButton.constrain(.Width, to: .Width, of: self.dismissButton)
        
        // Relationship view
        self.searchView.constrain(.Right, to: . Left, of: self.keyboardButton, offsetBy: -5)
    }
    
    // MARK: Public method's
    
    /**
     Call when use tap in keyboard button. 
     This will forcus in search text field when editing is false and endEditing when it editing is true
     */
    func endEditingSearchText() {
        if self.searchView.editing {
            self.endEditing(true)
        } else {
            self.searchView.becomeFirstResponder()
        }
    }
    
    
    
}
