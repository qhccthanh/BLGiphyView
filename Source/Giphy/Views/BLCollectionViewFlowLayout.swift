//
//  BLCollectionViewFlowLayout.swift
//  EmojiKeyboard
//
//  Created by qhcthanh on 8/24/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import UIKit

@objc protocol BLFlowLayoutDelegate {
    
    optional func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:NSIndexPath,
                        withWidth:CGFloat) -> CGFloat
    
    optional func collectionView(collectionView: UICollectionView,
                        heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
    
    optional func collectionView(collectionView:UICollectionView, widthForPhotoAtIndexPath indexPath:NSIndexPath,
                        withHeight:CGFloat) -> CGFloat
    
    optional func collectionView(collectionView: UICollectionView,
                        widthForAnnotationAtIndexPath indexPath: NSIndexPath, withHeight: CGFloat) -> CGFloat
}

public class BLCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    weak var delegate: BLFlowLayoutDelegate?
    
    var numberOfRows = 2
    var cellPadding: CGFloat = 2.0
    
    // 3
    private var cache = [UICollectionViewLayoutAttributes]()
    
    private var contentWidth: CGFloat  = 0.0
    private var contentHeight: CGFloat {
        let insets = collectionView!.contentInset
        return CGRectGetHeight(collectionView!.bounds) - (insets.top + insets.bottom)
    }
    
    override public func prepareLayout() {
      
        cache.removeAll()
        self.contentWidth  = 0.0
        // 2
        let rowHeight = contentHeight / CGFloat(numberOfRows)
        var yOffset = [CGFloat]()
        for row in 0 ..< numberOfRows {
            yOffset.append(CGFloat(row) * rowHeight )
        }
        var row = 0
        var xOffset = [CGFloat](count: numberOfRows, repeatedValue: 0)
        
        // 3
        let numberOfItemInSection = collectionView!.numberOfItemsInSection(0)
        for item in 0 ..<  numberOfItemInSection {
            row = xOffset.indexOf(xOffset.minElement()!)!
            let indexPath = NSIndexPath(forItem: item, inSection: 0)
            
            // 4
            let height = rowHeight - cellPadding * 2
            let photoWidth = delegate!.collectionView!(collectionView!, widthForPhotoAtIndexPath: indexPath,
                                                       withHeight:height)
            let width = cellPadding +  photoWidth  + cellPadding
            let frame = CGRect(x: xOffset[row], y: yOffset[row], width: width, height: height)
            let insetFrame = CGRectInset(frame, cellPadding, cellPadding)
            
            // 5
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            // 6
            contentWidth = max(contentWidth, CGRectGetMaxX(frame))
            xOffset[row] = xOffset[row] + width
            
            //row = row >= (numberOfRows - 1) ? 0 : ++row
        }
        
    }
   
    
    public override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        
        if newBounds.width < contentWidth {
            return false
        }
        return true
    }
    
    override public func collectionViewContentSize() -> CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if CGRectIntersectsRect(attributes.frame, rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    
    
}
