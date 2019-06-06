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

let extractContentJS = """
document.body.style.backgroundColor = "red";
var links = JSON.stringify(Array.prototype.slice.call(document.getElementsByTagName('a')).map(x => ({text: x.text, href: x.href})));
window.webkit.messageHandlers.jsHandler.postMessage(links);
"""
struct Links: Codable {
    let text: String
    let href: String
}

func decodeLinks(_ inLinks: String) -> [Links] {
    let decoder = JSONDecoder()
    let outLinks = try! decoder.decode([Links].self, from: inLinks.data(using: .utf8)!)
    return outLinks
}
