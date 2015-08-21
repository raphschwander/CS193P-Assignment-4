//
//  UserDefaults.swift
//  Smashtag
//
//  Created by Raphael Neuenschwander on 20.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import Foundation


class UserDefaults {
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    private struct Key {
        static let RecentSearchTerms = "UserDefaults.Key.RecentSearchTerms"
    }
    
    private struct Constant {
        static let MaxNumberOfSearchToKeepTrackOf = 3
    }
    
    func storeSearchTerms(recentSearchTerms:[String]) {
        
        var searchTerms = recentSearchTerms
        
        // Remove the search terms exceeding the defined amount of maximum number of search terms to keep track of
        let exceedMax = searchTerms.count - Constant.MaxNumberOfSearchToKeepTrackOf
        if exceedMax > 0 {
            for _ in 1...exceedMax {
                searchTerms.removeLast()
            }
        }
        userDefaults.setObject(searchTerms, forKey: Key.RecentSearchTerms)
    }
    
    func fetchSearchTerms() -> [String] {
        return userDefaults.objectForKey(Key.RecentSearchTerms) as? [String] ?? []
    }
    
    func deleteSearchTerm(removeAtIndexPath indexPath: NSIndexPath) {
        if var searchTerms = userDefaults.objectForKey(Key.RecentSearchTerms) as? [String] {
            searchTerms.removeAtIndex(indexPath.row)
            storeSearchTerms(searchTerms)
        }
    }
}