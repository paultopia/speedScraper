//
//  webViewTools.swift
//  speedScraper
//
//  Created by Paul Gowder on 6/6/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

import Foundation
import WebKit

extension WKWebView {
    func load(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("can't make url")
            return
        }
        let request = URLRequest(url: url)
        load(request)
    }
}

let testHtml =  "<html><body><h1>Hello World</h1></body></html>"

extension WKWebView {
    func test(){
        loadHTMLString(testHtml, baseURL: nil)
        }
}
