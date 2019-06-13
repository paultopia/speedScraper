//
//  state.swift
//  speedScraper
//
//  Created by Paul Gowder on 6/10/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

import Foundation
import WebKit

final class State {
    var downloadedLinks: LinkList?
    var currentLinks: LinkList?
    var webView: WKWebView?
    init(){
        downloadedLinks = nil
        currentLinks = nil
        webView = nil
    }
    func loadUp(_ linkList: LinkList) {
        downloadedLinks = linkList
        currentLinks = linkList
    }
    
    func reset(){
        downloadedLinks = nil
        currentLinks = nil
        webView = nil
    }
    
    func printCurrentState(){
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(currentLinks!)
        let jsonString = String(data: jsonData, encoding: .utf8)
        print(jsonString)
    }
}
