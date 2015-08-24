//
//  TweetCollectionViewController.swift
//  Smashtag
//
//  Created by Raphael Neuenschwander on 22.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit


class TweetCollectionViewController: UICollectionViewController, ImageCollectionViewDelegate {
    
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
    
    private struct Storyboard {
        static let CollectionViewReusableCellIdentifier = "ImageCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

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

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

    //MARK: - ImageCollectionViewDelegate
    func didFinishDownloadingImage(image: UIImage, sender: ImageCollectionViewCell) {
        storeImage(urlOfImage: sender.imageUrl!, image: image)
    }
    
    //MARK: - NSCache
    
    private func storeImage(urlOfImage url: NSURL ,image: UIImage) {
        if restoreImage(urlOfImage: url) == nil {
            cache.setObject(image, forKey: "\(url)", cost: UIImageJPEGRepresentation(image, 1).length)
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
