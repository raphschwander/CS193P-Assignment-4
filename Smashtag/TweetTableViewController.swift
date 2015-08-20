//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Raphael Neuenschwander on 14.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    var tweets = [[Tweet]]()
    
    private let userDefaults = UserDefaults()
    
    // Keep track of the searches perfomed by the user by persisting the search terms
    private var searchTerms: [String] {
        get { return userDefaults.fetchSearchTerms() }
        set { userDefaults.storeSearchTerms(newValue) }
    }
    
    @IBOutlet weak var refreshIndicator: UIRefreshControl!
    

    @IBOutlet weak var twitterSearchField: UITextField! {
        didSet {
            twitterSearchField.delegate = self
            twitterSearchField.text = searchText
        }
    }
    
    //Set the unwind action
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue) {
    }
    
    var searchText: String? {
        didSet {
            lastSuccessfulRequest = nil
            twitterSearchField?.text = searchText
            tweets.removeAll()
            tableView.reloadData()
            fetchTweets()
            
            if let searchText = searchText  {
                searchTerms.insert(searchText, atIndex: 0)
            }
        }
    }
    
    private struct Storyboard {
        static let TableViewReusableCellIdentifier = "Tweet"
        static let SegueIdentifier = "Show Mentions"
    }
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        fetchTweets()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    var lastSuccessfulRequest: TwitterRequest?
    
    var nextRequestToAttempt: TwitterRequest? {
        if lastSuccessfulRequest == nil  {
            if searchText != nil {
                return TwitterRequest(search: searchText!, count: 100)
            } else {
              return nil
            }
        } else {
            return lastSuccessfulRequest!.requestForNewer
        }
    }
    
    private func fetchTweets() {
        if refreshIndicator != nil {
            refreshIndicator?.beginRefreshing()
        }
        refresh(refreshIndicator)
    }
    

    @IBAction func refresh(sender: UIRefreshControl?) {
        if searchText != nil {
            title = searchText
            if let request = nextRequestToAttempt {
                request.fetchTweets { (tweets) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        if tweets.count > 0 {
                            self.lastSuccessfulRequest = request
                            self.tweets.insert(tweets, atIndex: 0)
                            self.tableView.reloadData()
                        }
                        sender?.endRefreshing()
                    }
                }
            }
        } else {
            sender?.endRefreshing()
        }
    }
    
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == twitterSearchField {
            searchText = textField.text
            
        }
        //Remove the Keyboard
        textField.resignFirstResponder()
        return true
    }


    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TableViewReusableCellIdentifier, forIndexPath: indexPath) as! TweetTableViewCell
        let tweet = tweets[indexPath.section][indexPath.row]
        cell.tweet = tweet
        

        return cell
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
        
        if let tmvc = segue.destinationViewController as? TweetMentionsTableViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case Storyboard.SegueIdentifier:
                    let cell = sender as! TweetTableViewCell
                    if let indexPath = tableView.indexPathForCell(cell) {
                        tmvc.tweet = self.tweets[indexPath.section][indexPath.row]
                    }
                default: break
                }
            }
        }
    }
}
