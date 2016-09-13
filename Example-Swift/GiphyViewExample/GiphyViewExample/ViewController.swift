//
//  ViewController.swift
//  GiphyViewExample
//
//  Created by Quach Ha Chan Thanh on 9/13/16.
//  Copyright © 2016 Quach Ha Chan Thanh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let giphyView = BLGiphyView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        self.view.addSubview(giphyView)
        
        giphyView.constrain(.Left, to: .Left, of: self.view)
        giphyView.constrain(.Right, to: .Right, of: self.view)
        giphyView.constrain(.Top, to: .Top, of: self.view, offsetBy: 50)
        giphyView.constrain(.Height, to: 216)
        
        BLGIFCache.shareManager().cacheMode = .LimitLength
        BLGIFCache.shareManager().maxOfNubmerCacheItem = 20
        BLGIFCache.shareManager().maxOfNumberGIFThumbCache = 40
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        giphyView.loadMoreRandomGiphy()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

