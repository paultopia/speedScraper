//
//  ViewController.swift
//  speedScraper
//
//  Created by Paul Gowder on 6/6/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {

    @IBOutlet var webView: WKWebView!
    
    @IBAction func loadButtonPressed(_ sender: Any) {
        webView.load("https://www.apple.com/")
        print("trying to load from remote")
    }
    
    @IBAction func linkButtonPressed(_ sender: Any) {
        webView.test()
        print("trying to load local string")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

