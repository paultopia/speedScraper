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
    let textOfLink: String
    let href: String
}

struct Link: Codable {
    let textOfLink: String
    let href: String
    let filename: String?
}

extension Link {
    init(_ inLink: InLink){
        textOfLink = inLink.textOfLink
        href = inLink.href
        filename = nil
    }
}

// what do I do about basename problems in scraped URLS?  I don't have anything to resolve relative urls right at the moment.  (Can I do it in the javascript?!)
// maybe JS already does this?!  Need to test. https://stackoverflow.com/a/14781678/4386239 


struct LinkList: Codable {
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
            return Link(textOfLink: textOfLink, href: output, filename: filename)
        } else {
            return Link(textOfLink: textOfLink, href: href, filename: filename)
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


extension Link {
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
            return Link(textOfLink: textOfLink, href: href, filename: fn)
        } else {
        return nil
        }
    }
}

extension LinkList {
    func withFilenames() -> LinkList {
        return LinkList(links.compactMap {$0.extractFilename()})
    }
}


// EXPERIMENTAL/UNTESTED:

// swiped from https://www.hackingwithswift.com/articles/108/how-to-use-regular-expressions-in-swift
extension NSRegularExpression {
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}

extension LinkList {

    enum RegexTarget: String, CaseIterable {
        case text = "text of link"
        case href = "link address"
        case filename = "filename"
    }
    
    // this one works:
    func filterByFileExtensions(extensions: [String]) -> LinkList {
        let onlyFiles = withFilenames()
        let filtered = onlyFiles.filter {extensions.contains(URL(string: $0.href)!.pathExtension)}
        // I really should just work with URLS rather than keep converting back and forth to strings...
        return LinkList(filtered) 
        // I also should really take map/filter/reduce and return LinkList from them?    
    }
    
    func filterByRegex(pattern: String, target: RegexTarget) -> LinkList {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return self // just ignore if passed a regular expression that doesn't work.
        }
        var filtered: [Link]
        switch target {
            case .text:
                filtered = links.filter {regex.matches($0.textOfLink)}
            case .href:
                filtered = links.filter {regex.matches($0.href)}
            case .filename:
                filtered = withFilenames().filter {regex.matches($0.filename!)}
        }
        
        return LinkList(filtered) 
    }
}

