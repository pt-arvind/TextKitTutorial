//
//  ViewController.swift
//  TextKitTutorial
//
//  Created by Yuchen Nie on 4/15/16.
//  Copyright © 2016 WeddingWire. All rights reserved.
//

import UIKit
import SnapKit
import Kanna
import Appendix

class ViewController: UIViewController {
    private lazy var label:UILabel = {label in
        label.text = "test"
        label.textAlignment = .Center
        self.view.addSubview(label)
        return label
    }(UILabel())
    private let textViewDelegate:Handler = Handler()
    
    private lazy var textView:WWTextView = {_textView in
        _textView.delegate                      = self.textViewDelegate
        _textView.textContainer.lineBreakMode   = .ByWordWrapping
        _textView.delaysContentTouches          = false
        _textView.textContainerInset            = UIEdgeInsetsZero
        _textView.editable                      = false
        _textView.selectable                    = true
        
        _textView.onClick = { (string, type, range) in
            print("CLICKED: \(type.description) :: \(string) :: \(range)")
        }
        
        _textView.detected = { (string, type, range) in
            print("DETECTED: \(type.description) :: \(string) :: \(range)")
        }
        
        self.view.addSubview(_textView)
        return _textView
    }(WWTextView())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.whiteColor()
        view.setNeedsUpdateConstraints()
        view.updateConstraintsIfNeeded()
        //textView.insertImage("grayCat", image: UIImage(named: "grayCat")!, size: CGSizeMake(192, 120), at: 30)
        
        loadHTML()
    }

    override func updateViewConstraints() {
        label.snp_updateConstraints { (make) in
            make.leading.trailing.equalTo(self.view).inset(10)
            make.top.equalTo(self.view).offset(10)
        }
        
        textView.snp_updateConstraints { (make) in
            make.center.equalTo(self.view)
            make.width.equalTo(300)
            make.height.equalTo(200)
        }
        super.updateViewConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadHTML() {
        let str = HelperFunctions.getHTMLFromFile("DiscourseOne")
        
        textView.attributedText = str.html2String
        textView.insertImage("grayCat", image: UIImage(named: "grayCat")!, width: 130)
        defer{
            let ranges = textView.imageRanges()
            print(ranges)
        }

        if let doc = Kanna.HTML(html: str, encoding: NSUTF8StringEncoding) {
            for img in doc.css("img") {
                print(img["width"])
            }
        }
    }
}
