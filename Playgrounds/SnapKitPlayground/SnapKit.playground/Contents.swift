//: Please build the scheme 'SnapKitPlayground' first
import XCPlayground
//XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
import UIKit
import SnapKit


class LiveView : UIView {
    lazy var textView: WWHTMLTextView = {
        let view = WWHTMLTextView()
        view.backgroundColor = .whiteColor()
        
        self.addSubview(view)
        return view
    }()
    
    override func updateConstraints() {
        textView.snp_updateConstraints { (make) in
            make.edges.equalTo(self).inset(10)
        }
        
        super.updateConstraints()
    }
}

struct HTMLStylingAssistant {
    static func style(html: String) -> String {
        
        let style2 = "blockquote { border-left: 5px solid #e9e9e9; background-color: #f8f8f8; clear: both; }"

        let style = "blockquote { background-color: #f8f8f8; border-left: 5px solid #e9e9e9; margin-left: 0; margin-right: 0; padding: 12px; }"
        
        let styling = "<meta charset=\"UTF-8\" /><style> \(style) </style>"
        let cookedHtml =  "\(styling)\(html)"
        
        
        return cookedHtml
    }
}

struct AttributedStringAssistant {
    static func attributedString(from html: String) throws -> NSAttributedString {
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF16StringEncoding
        ]
        
        let styledHtml = HTMLStylingAssistant.style(html)
        
        let encodedData = styledHtml.dataUsingEncoding(NSUTF16StringEncoding)!
        let attributedString = try NSMutableAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
        
        return attributedString
    }
}

let frame = CGRectMake(0, 0, 400, 400)
let view = LiveView(frame: frame)
view.backgroundColor = .grayColor()



let string = "<aside class=\"quote\" data-post=\"2\" data-topic=\"367\" data-full=\"true\"><div class=\"title\">\n<div class=\"quote-controls\"></div>\nSettings5:</div>\n<blockquote><p>Here is my post - i'm a normal user</p></blockquote></aside>\n\n<p>I'm quoting you on that</p>"

let attrString = try! AttributedStringAssistant.attributedString(from: string)

view.textView.attributedText = attrString

view.setNeedsUpdateConstraints()
XCPlaygroundPage.currentPage.liveView = view



