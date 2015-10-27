//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by Raphael Neuenschwander on 17.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    var imageUrl: NSURL? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var activityIndcator: UIActivityIndicatorView!
    
    func updateUI() {
        
        // Reset any pre-existing tweet information
        mediaImageView.image = nil
        
        if let imageUrl = imageUrl {
            
            activityIndcator.startAnimating()
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            
            //fetch the data off the main queue
            dispatch_async(dispatch_get_global_queue(qos, 0)) {
                if let data = NSData(contentsOfURL: imageUrl) {
                    
                    //update the UI on the main queue
                    dispatch_async(dispatch_get_main_queue()) {
                        self.mediaImageView?.image = UIImage(data: data)
                        self.activityIndcator.stopAnimating()
                    }
                } else {
                    self.activityIndcator.stopAnimating()
                }
            }
        }
    }
}
