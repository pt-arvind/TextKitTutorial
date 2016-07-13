//
//  TextView.swift
//  PrettyTextView
//
//  Created by Wesley Cope on 4/13/16.
//  Copyright © 2016 Wess Cope. All rights reserved.
//

import Foundation
import UIKit

public class WWHTMLTextView : UITextView {
    var onClick:((string:String, type:DetectedType, range:NSRange) -> Void)?
    var detected:((string:String, type:DetectedType, range:NSRange) -> Void)?
    var tapGestureRecognizer:UITapGestureRecognizer?
    var shouldUpdate        = true
    var highlightColor      = UIColor.blueColor().colorWithAlphaComponent(0.2)
    var placeholderLabel    = UILabel(frame: .zero)
    let tapInset            = UIEdgeInsets(top: -2, left: -2, bottom: -2, right: -2)
    
    private var prettyStorage       = NSTextStorage()
    private var prettyLayoutManager = NSLayoutManager()
    private var prettyContainer     = NSTextContainer()

    var placeholder: String? {
        didSet {
            var attributes = [String: AnyObject]()
            
            if typingAttributes.count > 0 && isFirstResponder() {
                attributes = typingAttributes
            } else {
                if let font = font {
                    attributes[NSFontAttributeName] = font
                }
                
                attributes[NSForegroundColorAttributeName] = UIColor(white: 0.7, alpha: 1.0)
                
                if textAlignment != NSTextAlignment.Left {
                    let paragraph                               = NSMutableParagraphStyle()
                    paragraph.alignment                         = textAlignment
                    attributes[NSParagraphStyleAttributeName]   = paragraph
                }
            }
            
            self.attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: attributes)
        }
    }
    
    var attributedPlaceholder: NSAttributedString? {
        didSet {
            placeholderLabel.attributedText = attributedPlaceholder
            placeholderLabel.sizeToFit()
            
            placeholderLabel.frame = placeholderFrame(placeholderLabel.bounds)
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    init(frame: CGRect) {
        prettyStorage.addLayoutManager(prettyLayoutManager)
        prettyLayoutManager.addTextContainer(prettyContainer)
        
        super.init(frame: frame, textContainer: prettyContainer)
        
        initialize()
    }
    
    func initialize() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textChanged), name: UITextViewTextDidChangeNotification, object: self)

        placeholderLabel.hidden = false
        
        addSubview(placeholderLabel)
    }

    func textChanged() {
        if let _ = attributedPlaceholder {
            placeholderLabel.hidden = text.characters.count == 0 ? false : true
        }
        
        setNeedsDisplay()
    }
    
    func newline() {
        if let attrString = attributedText.mutableCopy() as? NSMutableAttributedString {
            let lineEnd = NSMutableAttributedString(string: "\n")
            
            lineEnd.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle(0), range: NSRange(location: 0, length: lineEnd.length))
            
            attrString.appendAttributedString(lineEnd)
            
            attributedText = attrString
        }
    }
    
    func paragraphStyle(spacing:CGFloat) -> NSParagraphStyle {
        let style                       = NSMutableParagraphStyle()
        style.paragraphSpacing          = spacing
        style.paragraphSpacingBefore    = spacing
        
        return style
    }
}

extension WWHTMLTextView /* Actions */ {
    func clickedDetected(string:String, type:DetectedType, range:NSRange) {
        onClick?(string:string, type:type, range:range)
    }
}

extension WWHTMLTextView /* Detection */ {
    func urlsAt(location:CGPoint, complete:(NSRange) -> ()) {
        var found = false
        
        attributedText.enumerateAttribute(DetectedDataHandlerAttributeName, inRange: NSMakeRange(0, attributedText.length), options: []) { (value, range, stop) in
            if value != nil {
                self.frames([NSValue(range: range),]) { (frame, range, stop) in
                    if !found && CGRectContainsPoint(frame, location) {
                        
                        self.drawHighlight(frame, range: range)
                        
                        found = true
                        
                        complete(range)
                    }
                }
            }
        }
        
        if !found {
            attributedText.enumerateAttribute(ImageAttributeName, inRange: NSMakeRange(0, attributedText.length), options: []) { (value, range, stop) in
                if value != nil {
                    self.frames([NSValue(range: range),]) { (frame, range, stop) in
                        if !found && CGRectContainsPoint(frame, location) {
                            
                            self.drawHighlight(frame, range: range)
                            
                            found = true
                            
                            complete(range)
                        }
                    }
                }
            }
        }
    }
    
    func frames(ranges:[NSValue], complete:(frame: CGRect, range:NSRange, stop:Bool) -> Void) {
        for value in ranges {
            let range   = value.rangeValue
            let glyphs  = layoutManager.glyphRangeForCharacterRange(range, actualCharacterRange: nil)
            
            layoutManager.enumerateEnclosingRectsForGlyphRange(glyphs, withinSelectedGlyphRange: NSMakeRange(NSNotFound, 0), inTextContainer: textContainer) { (rect, stop) in
                var rect        = rect
                rect.origin.x  += self.textContainerInset.left
                rect.origin.y  += self.textContainerInset.top
                rect            = UIEdgeInsetsInsetRect(rect, self.tapInset)
                
                complete(frame: rect, range: range, stop: true)
            }
        }
    }
    
    func currentlydetected(string:String, type:DetectedType, range:NSRange) {
        detected?(string:string, type:type, range:range)
    }
}

extension WWHTMLTextView /* Imaging */ {
    func imageRanges() -> [[String : NSRange]] {
        var ranges = [[String : NSRange]]()
        attributedText.enumerateAttribute(ImageAttributeName, inRange: NSRange(location: 0, length: attributedText.length), options: []) { (value, range, stop) in
            guard let value = value as? String else { return }
            
            ranges.append([value : range])
        }
        
        return ranges
    }
    
    func range(of imageHash:String) -> NSRange? {
        var imageRange:NSRange? = nil
        
        attributedText.enumerateAttribute(ImageAttributeName, inRange: NSRange(location: 0, length: attributedText.length), options: []) { (value, range, stop) in
            guard let value = value as? String where value == imageHash else { return }
            imageRange = range
        }
        
        return imageRange
    }
    
    func insertImage(name:String, image:UIImage, width:CGFloat) {
        if let attrText = attributedText.mutableCopy() as? NSMutableAttributedString {
            attrText.appendAttributedString(NSAttributedString(string: "\n"))
            
            let _ = text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            
            attributedText = attrText
            
            let ratio   = CGFloat(width / image.size.width)
            let width   = image.size.width * ratio
            let height  = image.size.height * ratio
            let size    = CGSize(width: width, height: height)
            
            insertImage(name, image: image, size: size)
            newline()
        }
    }
    
    func insertImage(name:String, image:UIImage, size:CGSize) {
        let attachment      = NSTextAttachment(data: nil, ofType: nil)
        attachment.image    = image
        attachment.bounds   = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        if let attachedAttributedString = NSAttributedString(attachment: attachment) as? NSMutableAttributedString {
            attachedAttributedString.addAttributes([NSParagraphStyleAttributeName: paragraphStyle(0), DetectedDataHandlerAttributeName: DetectedType.Image.rawValue, NSLinkAttributeName : "img://name"], range: NSRange(location: 0, length: attachedAttributedString.length))
            
            if let attrString = attributedText.mutableCopy() as? NSMutableAttributedString {
                attrString.appendAttributedString(attachedAttributedString)
                
                attributedText = attrString
            }
        }
    }
    
    func insertImage(name:String, image:UIImage, size:CGSize, at index:Int) -> NSRange {
        let attachment      = NSTextAttachment(data: nil, ofType: nil)
        attachment.image    = image
        attachment.bounds   = CGRectMake(0, 0, size.width, size.height)
        
        if let attachmentAttributedString = NSAttributedString(attachment: attachment) as? NSMutableAttributedString {
            let paragraphStyle                      = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacing         = 10
            paragraphStyle.paragraphSpacingBefore   = 10
            //, NSParagraphStyleAttributeName: paragraphStyle
            let attr: [String: AnyObject]           = [ImageAttributeName: name, DetectedDataHandlerAttributeName: DetectedType.Image.rawValue, NSLinkAttributeName : "img://name"]
            
            if let attrString = self.attributedText.mutableCopy() as? NSMutableAttributedString {
                attrString.insertAttributedString(attachmentAttributedString, atIndex: index)
                
                
                let range = NSMakeRange(index, attachmentAttributedString.length)
                self.attributedText = attrString
                
                attrString.addAttributes(attr, range: range)
                return range
            }
        }
        return NSMakeRange(0, 0)
    }
    
    func removeImage(range:NSRange){
        if let attrString = self.attributedText.mutableCopy() as? NSMutableAttributedString {
            attrString.replaceCharactersInRange(range, withString: "")
            self.attributedText = attrString
        }
    }
}

extension WWHTMLTextView /* Drawing */ {
    func placeholderFrame(frame:CGRect) -> CGRect {
        var bounds       = frame
        bounds.origin.x += textContainer.lineFragmentPadding
        bounds.origin.y += textContainer.lineFragmentPadding
        
        return bounds
    }
    
    func drawHighlight(frame:CGRect, range: NSRange) {
        let layer               = CALayer()
        layer.frame             = frame
        layer.backgroundColor   = highlightColor.CGColor
        layer.cornerRadius      = 4.0
        layer.masksToBounds     = true
        
        self.layer.addSublayer(layer)
        
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.4 * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
            layer.removeFromSuperlayer()
        }
    }
}

extension WWHTMLTextView : UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}




