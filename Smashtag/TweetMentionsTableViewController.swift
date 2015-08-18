//
//  TweetMentionsTableViewController.swift
//  Smashtag
//
//  Created by Raphael Neuenschwander on 16.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit

class TweetMentionsTableViewController: UITableViewController {
    
    var tweet: Tweet? {
        didSet{
            mentions.removeAll()
            
            if let user = tweet?.user {
                title = "\(user)"
            }
            
            if let imageMention = tweet?.media {
                if imageMention.count > 0 {
                    let imageMentionArray = Mentions(title: Constants.ImageMentionTitle, data: imageMention.map { (MentionItem.Image($0.url, $0.aspectRatio)) })
                    mentions.append(imageMentionArray)
                }
            }
            if let urlMention = tweet?.urls {
                if urlMention.count > 0 {
                    let urlMentionArray = Mentions(title: Constants.UrlMentionTitle, data: urlMention.map {(MentionItem.Keyword($0.keyword))})
                    mentions.append(urlMentionArray)
                }
            }
            if let userMention = tweet?.userMentions {
                if userMention.count > 0 {
                    let userMentionArray = Mentions(title: Constants.UserMentionTitle, data: userMention.map {(MentionItem.Keyword($0.keyword))})
                    mentions.append(userMentionArray)
                }
            }
            if let hashTagMention = tweet?.hashtags {
                if hashTagMention.count > 0 {
                    let hashTagArray = Mentions(title: Constants.HashtagMentionTitle, data: hashTagMention.map {(MentionItem.Keyword($0.keyword))})
                    mentions.append(hashTagArray)
                }
            }
        tableView?.reloadData()
        }
    }
    
    private var mentions = [Mentions]()
    
    private struct Mentions {
        var title: String
        var data: [MentionItem] = []
    }
    
    private enum MentionItem {
        case Image(NSURL, Double)
        case Keyword(String)
    }
    
    private struct Constants {
        static let ImageMentionTitle = "Image"
        static let UrlMentionTitle = "Url"
        static let UserMentionTitle = "User"
        static let HashtagMentionTitle = "HashTag"
        static let ImageBaseHeight:CGFloat = 200
        
    }
    
    private struct Storyboard {
        static let TableViewReusableImageCellIdentifier = "ImageMention"
        static let TableViewReusableTextCellIdentifier = "TextMention"
        static let UnwindToMainMenuIdentifier = "Unwind To Main Menu"
        static let WebviewSegueIdentifier = "Show Webview"
    }

    override func viewDidLoad() {
        super.viewDidLoad()


        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return mentions.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentions[section].data.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let mention = mentions[indexPath.section].data[indexPath.row]
        
        switch mention {
        case .Image(let url, let aspectRatio):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TableViewReusableImageCellIdentifier, forIndexPath: indexPath) as! ImageTableViewCell
            cell.imageUrl = url
            return cell
        
        case .Keyword(let keyword):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TableViewReusableTextCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.text = "\(keyword)"
            return cell
        }
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentions[section].title
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let mention = mentions[indexPath.section].data[indexPath.row]
        
        switch mention {
        case .Image(_, let aspectRatio):
            return tableView.bounds.size.width / CGFloat(aspectRatio)
            
        default: return UITableViewAutomaticDimension
        }
        
    }
    
    //Perfom appriopriate Segue depending of the type of cell that was selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let mention = mentions[indexPath.section].data[indexPath.row]
        
        switch mention {
        case .Keyword(let keyword):
            let mentionTitle = mentions[indexPath.section].title
            if mentionTitle == Constants.UrlMentionTitle {
                //for url, segue to a new MVC
                
            } else {
                // for Hashtags and Users, unwind to main menu
                performSegueWithIdentifier(Storyboard.UnwindToMainMenuIdentifier, sender: tableView.cellForRowAtIndexPath(indexPath))
            }
        default:
            break
        }
        
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.UnwindToMainMenuIdentifier:
                let cell = sender as! UITableViewCell
                if let indexPath = tableView.indexPathForCell(cell) {
                    if let tvc = segue.destinationViewController as? TweetTableViewController {
                        // set the new search text
                        tvc.searchText = cell.textLabel?.text
                    }
                }
            default: break
            }
        }
    }
}


