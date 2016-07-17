//
//  ViewController.swift
//  ForumsWebView
//
//  Created by Arvind Subramanian on 7/14/16.
//  Copyright © 2016 WeddingWire. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var data: [String] = [String]()
    var heights: [CGFloat] = [CGFloat]()
    var css: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        guard let htmlStrings = HelperFunctions.getJSONValueFromFile("SampleHTMLParsingPost", key: "cooked"),
        css = HelperFunctions.stringFrom("custom", extension: "css") else {
            fatalError("nurrrrrrr")
        }
        
        data = htmlStrings
        self.css = css
        
        
        
        
        
        
        cacheHeights()
        
        
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 400
        tableView.registerClass(ForumCell.self, forCellReuseIdentifier: ForumCell.Constants.reuseID)
    }
    
    func cacheHeights() {
        let cachedCell = ForumCell(style: .Default, reuseIdentifier: ForumCell.Constants.reuseID)
        let context = UIGraphicsGetCurrentContext();
        var layer: CGLayer?
        heights = data.map { (html) -> CGFloat in
            cachedCell.webView.scrollView.scrollEnabled = false
            cachedCell.configure(withHtml: html, andCss: css)
            layer = CGLayerCreateWithContext(context, cachedCell.webView.bounds.size, nil);
            let layerCtx = CGLayerGetContext(layer);
            CGContextBeginPath(layerCtx);
            CGContextMoveToPoint(layerCtx, -10, 10);
            CGContextAddLineToPoint(layerCtx, 100, 10);
            CGContextAddLineToPoint(layerCtx, 100, 100);
            CGContextClosePath(layerCtx);
            
            
            
            return cachedCell.webView.bounds.height
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 400
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier(ForumCell.Constants.reuseID) as? ForumCell else {
            fatalError("the fuck homie")
        }
        
//        cell.backgroundColor = .greenColor()
        let html = data[indexPath.row]
        
        cell.configure(withHtml: html, andCss: css)
        
        return cell
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    

    
}

