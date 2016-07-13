//
//  TextStorage.swift
//  PrettyTextView
//
//  Created by Wesley Cope on 4/13/16.
//  Copyright © 2016 Wess Cope. All rights reserved.
//

import Foundation
import UIKit

class TextStorage : NSTextStorage {
    var textStyles:[String : AnyObject]?
    
    var backing:NSMutableAttributedString   = NSMutableAttributedString()
    var emails:[NSRange]                    = []
    var urls:[NSRange]                      = []
    var custom:[NSRange]                    = []
    var tapInset                            = UIEdgeInsets(top: -5, left: -5, bottom: -5, right: -5)
    
    private let linkPattern     = "[a-zA-Z]+://[0-9a-zA-Z_.?&/=]+"
    private let emailPattern    = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]+"
    override var string: String {
        return backing.string
    }
    
    override func attributesAtIndex(location: Int, effectiveRange range: NSRangePointer) -> [String : AnyObject] {
        return backing.attributesAtIndex(location, effectiveRange: range)
    }
    
    override func replaceCharactersInRange(range: NSRange, withString str: String) {
        beginEditing()
        
        backing.replaceCharactersInRange(range, withString: str)
        edited([.EditedAttributes, .EditedCharacters,], range: range, changeInLength: (str.characters.count - range.length))
        endEditing()
    }
    
    override func setAttributes(attrs: [String : AnyObject]?, range: NSRange) {
        beginEditing()
        
        backing.setAttributes(attrs, range: range)
        edited([.EditedAttributes,], range: range, changeInLength: 0)
        
        endEditing()
    }
    
    override func addAttributes(attrs: [String : AnyObject], range: NSRange) {
        beginEditing()
        
        backing.addAttributes(attrs, range: range)
        edited([.EditedAttributes,], range: range, changeInLength: 0)
        
        endEditing()
    }
    
    override func processEditing() {
        
        let paragraphRange = (self.string as NSString).paragraphRangeForRange(self.editedRange)
        
        self.removeAttribute(NSForegroundColorAttributeName, range: paragraphRange)
        //self.removeAttribute(NSLinkAttributeName, range: paragraphRange)
        self.removeAttribute(DetectedDataHandlerAttributeName, range: paragraphRange)
        
        if let textStyles = textStyles {
            addAttributes(textStyles, range: paragraphRange)
        }
        
        emails  = [NSRange]()
        urls    = [NSRange]()

        let linkExpression    = try? NSRegularExpression(pattern: linkPattern, options: NSRegularExpressionOptions())
        if let linkExpression = linkExpression {
            linkExpression.enumerateMatchesInString(self.string, options: NSMatchingOptions(), range: paragraphRange) { (result, flags, stop) in
                
                if let result = result {
                    let textValue                               = (self.string as NSString).substringWithRange(result.range)
                    let textAttributes: [String : AnyObject]!   = [NSForegroundColorAttributeName: UIColor.blueColor(), NSLinkAttributeName: textValue, DetectedDataHandlerAttributeName: DetectedType.URL.rawValue]
                    
                    self.addAttributes(textAttributes, range: result.range )
                    self.urls.append(result.range)
                }
            }
        }
        
        let emailExpression    = try? NSRegularExpression(pattern: emailPattern, options: NSRegularExpressionOptions())
        if let emailExpression = emailExpression {
            emailExpression.enumerateMatchesInString(self.string, options: NSMatchingOptions(), range: paragraphRange) { (result, flags, stop) in
                
                if let result = result {
                    let textValue                               = (self.string as NSString).substringWithRange(result.range)
                    let textAttributes: [String : AnyObject]!   = [NSForegroundColorAttributeName: UIColor.blueColor(), NSLinkAttributeName: textValue, DetectedDataHandlerAttributeName: DetectedType.Email.rawValue]
                    
                    self.addAttributes(textAttributes, range: result.range )
                    self.emails.append(result.range)
                }
                
            }
        }
        
        for range in custom {
            let textAttributes: [String : AnyObject]! = [NSForegroundColorAttributeName: UIColor.blueColor(), NSLinkAttributeName: "CustomRange", DetectedDataHandlerAttributeName: DetectedType.Custom.rawValue]
            
            self.addAttributes(textAttributes, range: range )
        }
        
        super.processEditing()
    }
}

