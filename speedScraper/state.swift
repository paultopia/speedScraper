//
//  state.swift
//  speedScraper
//
//  Created by Paul Gowder on 6/10/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

import Foundation

final class State {
    var downloadedLinks: LinkList?
    var currentLinks: LinkList?
    init(){
        downloadedLinks = nil
        currentLinks = nil
    }
    func loadUp(_ linkList: LinkList) {
        downloadedLinks = linkList
        currentLinks = linkList
    }
    
    func printCurrentState(){
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(currentLinks!)
        let jsonString = String(data: jsonData, encoding: .utf8)
        print(jsonString)
    }
}
