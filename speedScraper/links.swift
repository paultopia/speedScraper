//
//  links.swift
//  speedScraper
//
//  Created by Paul Gowder on 6/7/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//


// Need to:
// 1.  remove fragments
// 2.  remove dupes
// 3.  permit filtering

import Foundation

struct Links: Codable {
    let text: String
    let href: String
    
    func defrag() -> Links? {
        guard let url = URL(string: href) else {
            return nil
        }
        if let fragment = url.fragment {
            let output = url.absoluteString.replacingOccurrences(of: "#\(fragment)", with: "")
            return Links(text: text, href: output)
        } else {
            return Links(text: text, href: href)
        }
    }

}

struct LinkList {
    var links: [Links]
    init(_ inLinks: [Links]) {
        links = inLinks
    }
}

func decodeLinks(_ inLinks: String) -> [Links] {
    let decoder = JSONDecoder()
    let outLinks = try! decoder.decode([Links].self, from: inLinks.data(using: .utf8)!)
    return outLinks
}

