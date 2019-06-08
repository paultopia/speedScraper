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

extension Link: Equatable, Hashable {
    static func ==(lhs: Link, rhs: Link) -> Bool {
        return lhs.href == rhs.href
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(href)
    }
}

extension LinkList {
    func defrag() -> LinkList {
        let cleanLinks: [Link] = links.compactMap {$0.defrag()}
        return LinkList(cleanLinks)
    }
    init(_ links: Set<Link>){
        self.links = Array(links)
    }
    func dedupe() -> LinkList {
        return LinkList(Set(links))
    }
}

// these next two extensions will go away when I devise a cleaner way to cook up an enum or something with filtration options attached.

extension Link {
    func isPDF() -> Bool {
        guard let exten = URL(string: href)?.pathExtension else {
            return false
        }
        return exten == "pdf"
    }
    // this assumes that links without files will just return html pages that aren't for download.
    // this assumption is bullshit, but it'll do for a start to test basic functionality.
    func isFile() -> Bool {
        guard let pathExtension = URL(string: href)?.pathExtension else {
            return false
        }
        return pathExtension != ""
    }
    
    func extractFilename() -> Link? {
        if filename != nil {
            return self
        }
        if isFile() {
            let fn = URL(string: href)!.lastPathComponent
            return Link(text: text, href: href, filename: fn)
        } else {
        return nil
        }
    }
}

extension LinkList {
    func onlyPDFs() -> LinkList {
        return LinkList(links.filter({$0.isPDF()}))
    }
    func withFilenames() -> LinkList {
        return LinkList(links.compactMap {$0.extractFilename()})
    }
}
