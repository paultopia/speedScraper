//
//  downloads.swift
//  speedScraper
//
//  Created by Paul Gowder on 6/6/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

import Foundation

struct Downloader {
    let dirPath: URL
    
    init(){
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss_O"
        let subdirectory = "ScrapeResults_\(dateFormatter.string(from:now))"
        let downloadsURL = try!
            FileManager.default.url(for: .downloadsDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        dirPath = downloadsURL.appendingPathComponent(subdirectory)
        
        do {
            try FileManager.default.createDirectory(at: dirPath, withIntermediateDirectories: true, attributes: nil)
            print("successfully created directory")
        } catch let error as NSError {
            print(error.localizedDescription);
            print("failed to create directory")
        }
        
    }
    func download(inURL: String, filename: String){
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
            
            guard let fileURL = urlOrNil else { return }
            do {

                let savedURL = self.dirPath.appendingPathComponent(
                    filename)
                try FileManager.default.moveItem(at: fileURL, to: savedURL)
            } catch {
                print ("file error: \(error)")
            }
        }
        downloadTask.resume()
    }
    func download(inURL: String) {
        let url = URL(string: inURL)!
        let filename = url.lastPathComponent
        download(inURL: inURL, filename: filename)
    }
    // assumes I just want to download stuff with defined filenames.
    func download(link: Link){
            guard let filename = link.extractFilename()?.filename else {return}
            download(inURL: link.href, filename: filename)
    }
    
    func download(linkList: LinkList){
        linkList.links.forEach {download(link: $0)}
    }
}


