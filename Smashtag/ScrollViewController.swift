//
//  ScrollViewController.swift
//  Smashtag
//
//  Created by Raphael Neuenschwander on 19.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit

class ScrollViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.contentSize = imageView.frame.size
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
        }
    }
    
    private var imageView = UIImageView()
    
    var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            
            // When the image first appears, display it zoomed to show as much of the image as possible but with no "whitespace" around it
            if let imageWidth = newValue?.size.width, imageHeight = newValue?.size.height, frameWidth = scrollView?.frame.width, frameHeight = scrollView?.frame.height {
                let zoomScale = max(frameWidth / imageWidth, frameHeight / imageHeight)
                scrollView?.minimumZoomScale = zoomScale / 10
                scrollView?.maximumZoomScale = zoomScale * 10
                scrollView?.setZoomScale(zoomScale, animated: true)
            }
        }
    }
    
    var imageUrl: NSURL? {
        didSet {
            // clear the pre-existing image
            image = nil
            
            // Check if the view window is active, if it is, fetch and load the image
            if view.window != nil {
                loadImage()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
        
        let unwindToRootButton =  UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "unwind")
        navigationItem.rightBarButtonItem = unwindToRootButton
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if image == nil {
            loadImage()
        }
    }
    
    private struct Storyboard {
        static let UnwindSegueIdentifier = "Unwind To Main Menu"
    }
    
    func unwind() {
        performSegueWithIdentifier(Storyboard.UnwindSegueIdentifier, sender: self)
    }
    
    //Load the image and display it in the scroll view
    private func loadImage() {
        if let url = imageUrl {
            let qos = Int(QOS_CLASS_USER_INTERACTIVE.rawValue)
            // Fetch the data off the main queue
            dispatch_async(dispatch_get_global_queue(qos, 0)) {
                if let fetchedData = NSData(contentsOfURL: url) {
                    // Update the UI on the main queue
                    dispatch_async(dispatch_get_main_queue()) {
                        if let image = UIImage(data: fetchedData) {
                            self.image = image
                        } else {
                            self.image = nil
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
