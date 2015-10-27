//
//  TweetCollectionViewController.swift
//  Smashtag
//
//  Created by Raphael Neuenschwander on 22.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit


class TweetCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ImageCollectionViewDelegate {
    
    var tweets: [[Tweet]] = [[]] {
        didSet {
            // filter the array, to keep only the Tweets that contain image url
            for tweetArray in tweets {
                
                let filteredArray = tweetArray.filter() {
                    if $0.media.first?.url != nil {
                        return true
                    } else {
                        return false }
                }
                tweetsWithImages += [filteredArray]
            }
        }
    }
    
    private let cache = NSCache()
    
    private var tweetsWithImages: [[Tweet]] = [[]]
    
    @IBOutlet var tweetCollectionView: UICollectionView! {
        didSet{
            tweetCollectionView.delegate = self
            tweetCollectionView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: Gestures.PinchAction))
        }
    }
    
    private struct Storyboard {
        static let CollectionViewReusableCellIdentifier = "ImageCell"
        static let SegueIdentifier = "Show Tweet"
    }
    
    private struct Gestures {
        static let PinchAction: Selector = "scale:"
    }
    
    private var scale: CGFloat = 1 {
        didSet{
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    private struct Constants {
        static let LayoutSectionInset = 0
        static let LayoutMinimumLineSpacing: CGFloat = 1
        static let LayoutMinimumInteritemSpacing: CGFloat = 1
        static let LayoutNumberOfCellPerRow: CGFloat = 3
    }
    
    func scale(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .Changed:
            scale *= gesture.scale
            gesture.scale = 1
        default: break
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.reloadData()
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let collectionViewWidth = self.collectionView!.frame.size.width
        let width = floor(self.collectionView!.frame.size.width/(Constants.LayoutNumberOfCellPerRow * scale)) - Constants.LayoutMinimumLineSpacing
        
        if width > collectionViewWidth {
            scale = 1 / Constants.LayoutNumberOfCellPerRow
            return CGSize(width: collectionViewWidth, height: collectionViewWidth)
        } else {
            return CGSize(width: width, height: width)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.LayoutMinimumLineSpacing
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.LayoutMinimumInteritemSpacing
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifer = segue.identifier {
            switch identifer {
            case Storyboard.SegueIdentifier:
            if let tvc = segue.destinationViewController as? TweetTableViewController {
                if let cell = sender as? ImageCollectionViewCell {
                    if let indexPath = collectionView?.indexPathForCell(cell) {
                        tvc.tweetToShow = tweetsWithImages[indexPath.section][indexPath.row]
                        tvc.title = title
                    }
                }
                }
            default: break
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return tweetsWithImages.count
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return tweetsWithImages[section].count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Storyboard.CollectionViewReusableCellIdentifier, forIndexPath: indexPath) as! ImageCollectionViewCell
        
        cell.delegate = self
        
        let tweet = tweetsWithImages[indexPath.section][indexPath.row]
        let url = tweet.media.first!.url
        
        if let image = restoreImage(urlOfImage: url) {
            cell.tweetImage.image = image
        } else {
            cell.imageUrl = url
        }
        
        return cell
    }

    //MARK: - ImageCollectionViewDelegate
    func didFinishDownloadingImage(image: UIImage, sender: ImageCollectionViewCell) {
        storeImage(urlOfImage: sender.imageUrl!, image: image)
    }
    
    //MARK: - NSCache
    
    private func storeImage(urlOfImage url: NSURL ,image: UIImage) {
        if restoreImage(urlOfImage: url) == nil {
            cache.setObject(image, forKey: "\(url)", cost: UIImageJPEGRepresentation(image, 1)!.length)
        }
    }
    
    private func restoreImage(urlOfImage url: NSURL) -> UIImage? {
        if let image = cache.objectForKey("\(url)") as? UIImage {
            return image
        }
        else {
            return nil
        }
    }
    
    

}
