//
//  downloads.swift
//  speedScraper
//
//  Created by Paul Gowder on 6/6/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

import Foundation

func download(inURL: String){
    let url = URL(string: inURL)!
    let downloadTask = URLSession.shared.downloadTask(with: url) {
        urlOrNil, responseOrNil, errorOrNil in
        
        if errorOrNil != nil  {
            print("Client error!")
            return
        }
        
        let resp = responseOrNil as! HTTPURLResponse
        guard (200...299).contains(resp.statusCode) else {
            print("Server error: \(resp.statusCode)")
            return
        }
        // check for and handle errors:
        // * errorOrNil should be nil
        // * responseOrNil should be an HTTPURLResponse with statusCode in 200..<299
        
        guard let fileURL = urlOrNil else { return }
        do {
            let documentsURL = try
                FileManager.default.url(for: .downloadsDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: false)
            let savedURL = documentsURL.appendingPathComponent(
                fileURL.lastPathComponent)
            try FileManager.default.moveItem(at: fileURL, to: savedURL)
        } catch {
            print ("file error: \(error)")
        }
    }
    downloadTask.resume()
}
