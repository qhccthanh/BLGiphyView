//
//  BLGiphyButtonControl.swift
//  EmojiKeyboard
//
//  Created by Quach Ha Chan Thanh on 8/23/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import UIKit

public class BLGiphyButtonControl: UIControl {
    
    // MARK: Private UI Properties
    private var imageView: UIImageView!
    private var widthImageViewConstraint: NSLayoutConstraint!
    private var heightImageViewConstraint: NSLayoutConstraint!
    
    // MARK: Public UI Properties
    public var image: UIImage?
    public var selectedImage: UIImage?
    public var imageSizeSelectedScale: CGFloat = 1.25
    
    // MARK: Initialize
    public convenience init(image: UIImage?, selectedImage: UIImage? = nil, select: Bool = false) {
        
        self.init()
        
        self.image = image
        self.selectedImage = selectedImage
        self.selected = select
        
        self.setupView()
    }
    
    /**
     Setup subview in GiphyView. This will call setupContrainst
     */
    public func setupView() {
        
        self.imageView = UIImageView()
        self.addSubview(self.imageView)
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.image = self.image
        
        self.imageView.constrain(toCenterOf: self)
        
        self.widthImageViewConstraint = self.imageView.constrain(.Width, being: .Equal, to: .Width, of: self, multipliedBy: 1/2)
        self.heightImageViewConstraint = self.imageView.constrain(.Height, being: .Equal, to: .Height, of: self, multipliedBy: 1/2)
     
        
    }
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        
        if selected {
            self.imageView.image = self.selectedImage
            self.widthImageViewConstraint.constant = self.imageView.bounds.width * imageSizeSelectedScale/2
            self.heightImageViewConstraint.constant = self.imageView.bounds.height * imageSizeSelectedScale/2
        }
    }
    
    /**
     Call when button is touch up inside. This function will update image and size, state to button select
     */
    public func onSelected() {
        
        if self.selected == false {
            self.selected = true
            self.imageView.image = self.selectedImage
            
            self.widthImageViewConstraint.constant = self.imageView.bounds.width * imageSizeSelectedScale/2
            self.heightImageViewConstraint.constant = self.imageView.bounds.height * imageSizeSelectedScale/2
            UIView.animateWithDuration(0.3, animations: {
                self.layoutIfNeeded()
            })
        }
    }
    
    /**
     Call when button is touch up inside other button. This function will update image and size, state to button deSelected
     */
    func onDeselect() {

        if self.selected == true {
            self.selected = false
            self.imageView.image = self.image
            
            self.widthImageViewConstraint.constant = 0
            self.heightImageViewConstraint.constant = 0
            UIView.animateWithDuration(0.3, animations: {
                self.layoutIfNeeded()
            })
            
        }
        
    }
    
    
}
