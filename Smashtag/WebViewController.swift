//
//  WebViewController.swift
//  Smashtag
//
//  Created by Raphael Neuenschwander on 18.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    var url: NSURL? {
        didSet {
            if view.window != nil {
                webView?.stopLoading()
                loadUrl()
            }
        }
    }

    @IBOutlet weak var webView: UIWebView! {
        didSet {
            webView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUrl()
    }
    
    private func loadUrl() {
        if url != nil {
            let request = NSURLRequest(URL: url!)
            webView?.loadRequest(request)
        }
    }
    @IBAction func goBack(sender: AnyObject) {
        if (webView?.canGoBack != nil) {
            webView?.goBack()
        }
    }
    @IBAction func goForward(sender: AnyObject) {
        if (webView?.canGoForward != nil) {
            webView?.goForward()
        }
    }
    @IBAction func refresh(sender: AnyObject) {
        webView?.stopLoading()
        webView?.reload()
        
    }
    
}
