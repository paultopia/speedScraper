//
//  ViewController.swift
//  speedScraper
//
//  Created by Paul Gowder on 6/6/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

import Cocoa
import WebKit

let state = State()

class ViewController: NSViewController {

    @IBOutlet var webView: WKWebView!
    
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var urlToScrape: NSTextField!
    
    @IBAction func loadButtonPressed(_ sender: Any) {
        print("trying to load from remote")
        let toLoad = urlToScrape.stringValue
        //webView.load("http://gowder.io/#pubs")
        webView.load(toLoad)
        print("waiting...")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            print("now trying to print links")
            self.webView.evaluateJavaScript(extractContentJS, completionHandler: nil)
            // Put your code which should be executed with a delay here
        })
        
    }
    
    @IBAction func testDownloadButtonPressed(_ sender: Any) {
        //let testDL = "http://paul-gowder.com/iv-paper.pdf"
        let downloader = Downloader()
        if let targets =  state.currentLinks {
            downloader.download(linkList: targets.dedupe().onlyPDFs())
        }
        //print(downloader.dirPath.absoluteString)
        //print(downloader.dirPath)
        //downloader.download(inURL: testDL)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.configuration.userContentController.add(self, name: "jsHandler")
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "jsHandler" {
            let incoming = message.body
            //print(incoming)
            let links = decodeLinks(incoming as! String)
            state.loadUp(links.defrag().withFilenames())
            tableView.reloadData()
            //let cleanLinks = links.dedupe().onlyPDFs()
            //print(cleanLinks.map {$0.href})
            //print("here comes the great experiment!")
            //let downloader = Downloader()
            //downloader.download(linkList: cleanLinks)
            
        }
    }
}

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return state.currentLinks?.count ?? 0
    }
}

extension ViewController: NSTableViewDelegate {
    
    enum CellIDs: String {
        case PathCellID
        case DescriptionCellID
        case FilenameCellID
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        
        guard let item = state.currentLinks?[row] else {
            return nil
        }
        
        if tableColumn == tableView.tableColumns[0] {
            if item.textOfLink == "" {
                text = "none"
            } else {
                text = item.textOfLink
            }
            cellIdentifier = CellIDs.DescriptionCellID.rawValue
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.href
            cellIdentifier = CellIDs.PathCellID.rawValue
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.filename!
            cellIdentifier = CellIDs.FilenameCellID.rawValue
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
}
