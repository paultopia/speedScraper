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

struct InLink: Codable {
    let text: String
    let href: String
}

struct Link {
    let text: String
    let href: String
    let filename: String?
}

extension Link {
    init(_ inLink: InLink){
        text = inLink.text
        href = inLink.href
        filename = nil
    }
}

struct LinkList {
    typealias LinksType = [Link]
    var links: LinksType
    init(_ links: [Link]) {
        self.links = links
    }
    init(_ inLinks: [InLink]){
        links = inLinks.map {Link($0)}
    }
}

func decodeLinks(_ inLinks: String) -> LinkList {
    let decoder = JSONDecoder()
    let outLinks = try! decoder.decode([InLink].self, from: inLinks.data(using: .utf8)!)
    return LinkList(outLinks)
}

extension LinkList: Collection {
    typealias Index = LinksType.Index
    typealias Element = LinksType.Element
    var startIndex: Index { return links.startIndex }
    var endIndex: Index { return links.endIndex }
    subscript(index: Index) -> Element {
        get { return links[index] }
    }
    func index(after i: Index) -> Index {
        return links.index(after: i)
    }
}

extension Link {
    func defrag() -> Link? {
        guard let url = URL(string: href) else {
            return nil
        }
        if let fragment = url.fragment {
            let output = url.absoluteString.replacingOccurrences(of: "#\(fragment)", with: "")
            return Link(text: text, href: output, filename: filename)
        } else {
            return Link(text: text, href: href, filename: filename)
        }
    }
}
