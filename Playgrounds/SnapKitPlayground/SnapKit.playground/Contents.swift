//: Please build the scheme 'SnapKitPlayground' first
import XCPlayground
XCPlaygroundPage.currentPage.needsIndefiniteExecution = false
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



//class ArvindsMagnificentTextView : UITextView {
//    var imageLocations =
//    var quoteLocations = Set<CGPoint>()
//    
//    var
//}

class ArvindsMagnificentContainerView : UIView {
    lazy var textView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .whiteColor()
        
        self.addSubview(view)
        
        return view
    }()
    
    var images: [UIImageView] = [UIImageView]()
    var quotes: [AnyObject] = [AnyObject]()
    var exclusionPaths: [UIBezierPath] = [UIBezierPath]()
    
    func updateExclusionPaths() {
        textView.textContainer.exclusionPaths = exclusionPaths
    }
    
    override func updateConstraints() {
        textView.snp_updateConstraints { (make) in
            make.edges.equalTo(self).inset(10)
        }
        
        super.updateConstraints()
    }
    
    
    
}



struct HTMLStylingAssistant {
    static func style(html: String) -> String {
        /*
         blockquote { border-left: 5px solid #e9e9e9; background-color: #f8f8f8; clear: both; }
        */
        let styling = "<meta charset=\"UTF-8\"><style> blockquote { border-left: 5px solid #e9e9e9; background-color: #f8f8f8; clear: both; }</style>"
        return "\(styling)\(html)"
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

let frame = CGRectMake(0, 0, 600, 800)
let view = ArvindsMagnificentContainerView(frame: frame)
view.backgroundColor = .grayColor()



let string = "I will be very <b>bold</b> here and show you a <big>big</big> blockquote:\n\n<br>\n\n<blockquote>This is someone elses quote that I'm showing here... oh do \n\n<br>\n\n<a href=\"http://google.com\">links</a> work here?</blockquote><p>Anyway in case the link didn't work above, E00\n\n<br>\n\n<p>This is some test text <br> with a line break in a paragraph</p><h5>and this is gonna be a header 5 oh yea!</h5><h6>Header 6 time!</h6>\n\n<p>And let's add a <sub>subscript</sub> and a <sup>superscript</sup>!<br><tt>Teletype font anyone?</tt> <u>I just wanted some underlines</u> anndddd image!<br><div class=\"lightbox-wrapper\"><a href=\"http://loremflickr.com/800/800?random=4\" $IMAGE$ class=\"lightbox\" title=\"800?random=4\"><img src=\"http://loremflickr.com/800/800?random=4\" width=\"500\" height=\"500\"><img src=\"http://loremflickr.com/800/800?random=4\" width=\"500\" height=\"500\"><img src=\"http://loremflickr.com/800/800?random=4\" width=\"500\" height=\"500\"><img src=\"http://loremflickr.com/800/800?random=4\" width=\"500\" height=\"500\"><div class=\"meta\">\n<span class=\"filename\">800?random=4</span><span class=\"informations\">800x800</span><span class=\"expand\"></span>\n</div></a></div></p><p>Some end text"

//let attrString = try! AttributedStringAssistant.attributedString(from: string)

let image = UIImage(named: "800.jpeg")!
//let imageView = UIImageView(image: image)

//view.textView.text = string

// find the location of a glyph in the string so we can put the images and stuff in there
let textFont = [NSFontAttributeName: UIFont(name: "GillSansMT", size: 30.0) ?? UIFont.systemFontOfSize(18.0)]
let attrString1 = NSMutableAttributedString(string: string, attributes: textFont)

// range of substring to search
let str1 = attrString1.string as NSString
let range = str1.rangeOfString("$IMAGE$", options: NSStringCompareOptions.LiteralSearch, range: NSMakeRange(0, str1.length))

// prepare the textview
//let textView = UITextView(frame:CGRectMake(0,0,200,200))
view.textView.attributedText = attrString1

// you should ensure layout
view.textView.layoutManager.ensureLayoutForTextContainer(view.textView.textContainer)

// text position of the range.location
let start = view.textView.positionFromPosition(view.textView.beginningOfDocument, offset: range.location)!
// text position of the end of the range
let end = view.textView.positionFromPosition(start, offset: range.length)!

// text range of the range
let tRange = view.textView.textRangeFromPosition(start, toPosition: end)

// here it is!
let rect = view.textView.firstRectForRange(tRange!)

let rectInMagViewSpace = view.convertRect(rect, fromView: view.textView)

let imageFrame = CGRectMake(0, rectInMagViewSpace.origin.y, view.bounds.width, 200)
let imageView = UIImageView(frame: imageFrame)
imageView.contentMode = .ScaleAspectFit
imageView.image = image
view.addSubview(imageView)

var imageViewFrame = view.convertRect(imageView.bounds, fromView: imageView)
imageViewFrame.origin.x -= view.textView.textContainerInset.left
imageViewFrame.origin.y -= view.textView.textContainerInset.top

let imageViewPath = UIBezierPath(rect: imageViewFrame)
view.textView.textContainer.exclusionPaths.append(imageViewPath)


// find expected height for view and resize the whole view to be this
view.textView.scrollEnabled = false
//view.textView.sizeToFit()
let contentSize = view.textView.contentSize

view.textView.scrollEnabled = true

//view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, contentSize.height)
//view.textView.attributedText = attrString

let webView = UIWebView(frame: frame)
let dupString = "<aside class=\"quote\" data-post=\"2\" data-topic=\"367\" data-full=\"true\"><div class=\"title\">\n<div class=\"quote-controls\"></div>\nSettings5:</div>\n<blockquote><p>Here is my post - i'm a normal user</p></blockquote></aside>\n\n<p>I'm quoting you on that</p>"


//webView.

let html = HTMLStylingAssistant.style(dupString)
let cssURL = NSBundle.mainBundle().URLForResource("custom", withExtension: "css")!
webView.loadHTMLString(html, baseURL: cssURL)

view.setNeedsUpdateConstraints()
XCPlaygroundPage.currentPage.liveView = webView



