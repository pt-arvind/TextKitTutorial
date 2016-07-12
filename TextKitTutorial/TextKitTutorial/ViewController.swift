//
//  ViewController.swift
//  TextKitTutorial
//
//  Created by Yuchen Nie on 4/15/16.
//  Copyright © 2016 WeddingWire. All rights reserved.
//

import UIKit
import SnapKit
import Appendix
import Fuzi
import Kingfisher


class ViewController: UIViewController, UITextViewDelegate {
    private lazy var label:UILabel = {
        let label = UILabel()
        label.text = "test"
        label.textAlignment = .Center
        self.view.addSubview(label)
        return label
    }()
    
    var elements:[XMLElement] = [XMLElement]()
    
    private let textViewDelegate:Handler = Handler()
    
    private lazy var textView:WWHTMLTextView = {_textView in
        _textView.delegate                      = self.textViewDelegate
        _textView.textContainer.lineBreakMode   = .ByWordWrapping
//        _textView.delaysContentTouches          = false
        _textView.textContainerInset            = UIEdgeInsetsZero
        _textView.editable                      = false
//        _textView.selectable                    = true
        _textView.userInteractionEnabled        = true
        
        self.view.addSubview(_textView)
        return _textView
    }(WWHTMLTextView())
    
//    private lazy var htmlParser:HTMLParser2 = {
//        
//        let htmlParser = HTMLParser2(textView: self.textView)
//        return htmlParser
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        view.setNeedsUpdateConstraints()
        view.updateConstraintsIfNeeded()
        loadHTMLFromFile()
        
        //loadHTML()
    }

    override func updateViewConstraints() {
        label.snp_updateConstraints { (make) in
            make.leading.trailing.equalTo(self.view).inset(10)
            make.top.equalTo(self.view).offset(10)
        }
        
        textView.snp_updateConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(label.snp_bottom).offset(10)
            make.bottom.equalTo(self.view)
        }
        super.updateViewConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var parser: HTMLParser!
    func loadHTMLFromFile() {
        if let htmlString = HelperFunctions.getJSONValueFromFile("SampleHTMLParsingPost", key: "cooked") {
            //print("htmlStirng = \(htmlString)")
            do {
//                let string = "<aside class=\"quote\" data-post=\"2\" data-topic=\"367\" data-full=\"true\"><div class=\"title\">\n<div class=\"quote-controls\"></div>\n<img alt=\"\" width=\"20\" height=\"20\" src=\"//mantis.pod.weddingwire.com/letter_avatar_proxy/v2/letter/s/c57346/40.png\" class=\"avatar\">Settings5:</div>\n<blockquote style=\"border-left: 5px solid #e9e9e9; background-color: #f8f8f8; clear: both;\"><p>Here is my post - i'm a normal user</p></blockquote></aside>\n\n<p>I'm quoting you on that</p>"
                
                
//                NSAttributedString *attributedString = [[NSAttributedString alloc]
//                    initWithData: [htmlString dataUsingEncoding:NSUnicodeStringEncoding]
//                    options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
//                documentAttributes: nil
//                error: nil
//                ];
                
                let document = try HTMLDocument(string: htmlString)
                
                parser = HTMLParser(output: textView, source: document, imageRetriever: KingfisherManager.sharedManager)
                    
                let tuple = try parser.parse()
                
                textView.attributedText = tuple.attributedString//try NSAttributedString(data: string.dataUsingEncoding(NSUnicodeStringEncoding)!, options: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType], documentAttributes: nil)
                    
                    //
                parser.insertImages(tuple.images)
                
            } catch {
                print("FUCK")
            }
//            
//            let attrStr = htmlParser.getAttributedStringAndImagesFromHTML(htmlString)
//
//            
//            
//            textView.attributedText = attrStr.attrString
//            htmlParser.insertImages(attrStr.images)
        }
    }
}

