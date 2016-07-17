//
//  ForumCell.swift
//  ForumsWebView
//
//  Created by Arvind Subramanian on 7/14/16.
//  Copyright © 2016 WeddingWire. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SnapKit

struct HTMLStylingAssistant {
    static func style(html: String, withCSS css: String) -> String {
        /*
         blockquote { border-left: 5px solid #e9e9e9; background-color: #f8f8f8; clear: both; }
         */
        let styling = "<style> \(css) </style>"
        return "\(styling)\(html)"
    }
}

class ForumCell : UITableViewCell {
    
    struct Constants {
        static let reuseID = "com.weddingwire.ForumCell"
    }
    
    lazy var webView: WKWebView = {
        let view = WKWebView()
        
        view.backgroundColor = .redColor()
        
        self.contentView.addSubview(view)
        
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(UIScreen.mainScreen().bounds.size.width, 400)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//    }
    
    func configure(withHtml html: String, andCss css: String) {
//        NSURL *mainBundleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
//        [self.webView loadHTMLString:htmlString baseURL:nil];
//        let styledHTML = HTMLStylingAssistant.style(html, withCSS: css)
        webView.loadHTMLString(html, baseURL: nil)
        
        setNeedsLayout()
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
    }
    
    // hard set the 
    override func updateConstraints() {
        
        webView.snp_updateConstraints { (make) in
            make.edges.equalTo(contentView).inset(10)
        }
        
//        contentView.snp_updateConstraints { (make) in
//            make.edges.equalTo(self)
//        }
        
        super.updateConstraints()
    }
}