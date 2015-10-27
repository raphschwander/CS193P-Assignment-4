//
//  ImageCollectionViewCell.swift
//  Smashtag
//
//  Created by Raphael Neuenschwander on 23.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit

@objc protocol ImageCollectionViewDelegate {
    optional func didFinishDownloadingImage(image: UIImage, sender: ImageCollectionViewCell)
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    var imageUrl: NSURL? {
        didSet {
            updateUI()
        }
    }
    
    var delegate: ImageCollectionViewDelegate?
    
    @IBOutlet weak var tweetImage: UIImageView!

    private func updateUI() {
        
        //Reset any pre-existing image
        tweetImage.image = nil
        
        // Put the placeHolder image while downloading
        if let placeholder = UIImage(named: "PlaceHolder") {
            tweetImage.image = placeholder
        }
        
        if let imageUrl = imageUrl {
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            // Fetch the data off the main queue
            dispatch_async(dispatch_get_global_queue(qos, 0)) {
                if let fetchedData = NSData(contentsOfURL: imageUrl) {
                    if let image = UIImage(data: fetchedData) {
                        
                        // Update the UI on the main queue
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tweetImage.image = image
                        }
                        
                        // Inform the delegate that we finished downloading the image
                        self.delegate?.didFinishDownloadingImage!(image, sender: self)
                    }
                }
            }
        }
    }

}
