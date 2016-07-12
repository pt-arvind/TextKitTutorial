//
//  HTMLParser.swift
//  TextKitTutorial
//
//  Created by Yuchen Nie on 4/28/16.
//  Copyright © 2016 WeddingWire. All rights reserved.
//

import Foundation
import Fuzi
import Kingfisher


protocol HTMLParserOutput: class {
    func insertImage(name:String, image:UIImage, size:CGSize)
    func insertImage(name:String, image:UIImage, size:CGSize, at index:Int) -> NSRange
    func removeImage(range:NSRange)
}

// FIXME: this protocol should not be so tightly tied to Kingfisher
protocol ImageRetriever: class {
    func retrieveImageWithURL(URL: NSURL,
                              optionsInfo: KingfisherOptionsInfo?,
                              progressBlock: DownloadProgressBlock?,
                              completionHandler: CompletionHandler?) -> RetrieveImageTask
}

extension WWHTMLTextView : HTMLParserOutput {}
extension KingfisherManager : ImageRetriever {}

struct AttributedStringAssistant {
    // abstract // FIXME: protocol with impl?
    class Element {
        let XMLelement: WWXMLElement
        init (XMLelement: WWXMLElement) {
            self.XMLelement = XMLelement
        }
        
        func attributedStrings() -> [NSAttributedString] {
            return []
        }
        
        func imageTags() -> [ImageTypeStruct] {
            return []
        }
    }
    
    class Raw : Element {
        private var document: HTMLDocument!
        private var images = [ImageTypeStruct]()
        private var strings = [NSAttributedString]()
        
        init(XMLelement: WWXMLElement, document: HTMLDocument) throws {
            self.document = document
            super.init(XMLelement: XMLelement)
            try buildAttributesAndImages()
        }
        
        private func buildAttributesAndImages() throws {
            guard let HTMLString = XMLelement.raw else { throw Exception.InvalidHTML }
            
            var resultHTMLString = HTMLString
            
            for XMLElement in document.css(HTMLParserConstants.HTMLTypes.image) {
                let attributes = XMLElement.attributes
                if let imageType = ImageTypeStructFactory.make(attributes) {
                    images.append(imageType)
                }
            }
            
            if images.count > 0 {
                let imageTag = HTMLParserConstants.HTMLTypes.image
                resultHTMLString = HTMLStringPruner.prune(HTMLString, of: imageTag)
            }
            
            let attributedOptions : [String: AnyObject] = [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                NSCharacterEncodingDocumentAttribute: NSUTF16StringEncoding
            ]
            
            let encodedData = resultHTMLString.dataUsingEncoding(NSUTF16StringEncoding)
            let attributedString = try NSMutableAttributedString(data: encodedData!, options: attributedOptions, documentAttributes: nil)
            strings = [attributedString]
        }
        
        override func attributedStrings() -> [NSAttributedString] {
            return strings
        }
        
        override func imageTags() -> [ImageTypeStruct] {
            return images
        }
    }
    
    class Image : Element {
        override func imageTags() -> [ImageTypeStruct] {
            let attributes = XMLelement.element.attributes
            let image = ImageTypeStructFactory.make(attributes)
            return image != nil ? [image!] : []
        }
    }
    
    class Link : Element {
        
    }
    
    class HREF : Link {
        var href:String
        
        init(XMLelement: WWXMLElement, href: String) {
            self.href = href
            super.init(XMLelement: XMLelement)
        }
        
        override func attributedStrings() -> [NSAttributedString] {
            if let linkClass = XMLelement.element.attributes[HTMLParserConstants.ClassTypes.kClass]{
                href = linkClass + HTMLParserConstants.HTMLConstants.separator + href
            }
            
            let attributedString = NSMutableAttributedString(string: XMLelement.element.stringValue)
            attributedString.addAttribute(NSLinkAttributeName, value: href, range: NSMakeRange(0, XMLelement.element.stringValue.length))
            
            return []
        }
    }
    
    class Mention : Link {
        override func attributedStrings() -> [NSAttributedString] {
            let value = HTMLParserConstants.ClassTypes.mention
            
            let attributedString = NSMutableAttributedString(string: XMLelement.element.stringValue)
            attributedString.addAttribute(NSLinkAttributeName, value: value, range: NSMakeRange(0, XMLelement.element.stringValue.length))
            
            return [attributedString]
        }
    }
    
    enum Exception : ErrorType {
        case InvalidHTML
    }
    
    struct HTMLStringPruner {
        private static func indexOf(substring: String, `in` string: String) -> String.CharacterView.Index {
            return string.rangeOfString(substring, options: .LiteralSearch, range: nil, locale: nil)?.startIndex ?? string.startIndex
        }
        
        private static func indexOf(substring: String, `in` string: String, within range: Range<String.Index>) -> String.CharacterView.Index {
            return string.rangeOfString(substring, options: .LiteralSearch, range: range, locale: nil)?.endIndex ?? string.startIndex
        }
        
        static func prune(HTMLString: String, of tag: String) -> String{
            let tagPrefix = HTMLParserConstants.HTMLConstants.openBracket + tag
            let startIndex = indexOf(tagPrefix, in: HTMLString)
            
            let range = startIndex..<HTMLString.endIndex
            let endIndex = indexOf(HTMLParserConstants.HTMLConstants.closeBracket, in: HTMLString, within: range)
            
            let newRange = startIndex..<endIndex
            
            let newString = HTMLString.stringByReplacingCharactersInRange(newRange, withString: "")
            let checkIndex = indexOf(tagPrefix, in: newString)
            
            if checkIndex != HTMLString.startIndex {
                return prune(newString, of: tag)
            } else {
                return newString
            }
        }
    }
    
    struct ElementFactory {
        static func make(tag: String, element: WWXMLElement) throws -> Element {
            var result: Element
            switch tag {
            case HTMLParserConstants.HTMLTypes.image:
                result = Image(XMLelement: element)
            case HTMLParserConstants.HTMLTypes.link where element.element.attributes[HTMLParserConstants.ClassTypes.href] != nil:
                let href = element.element.attributes[HTMLParserConstants.ClassTypes.href]!
                result = HREF(XMLelement: element, href: href)
            case HTMLParserConstants.HTMLTypes.link: // all things that aren't HREF's are being considered mentions...
                result = Mention(XMLelement: element)
            default:
                guard let HTMLString = element.raw else { throw Exception.InvalidHTML }
                
                result = try Raw(XMLelement: element, document: HTMLDocument(string: HTMLString))
            }
            
            return result
        }
    }
    
    struct ImageTypeStructFactory {
        static func make(attributes:[String:String]) -> ImageTypeStruct? {
            guard let src = attributes[HTMLParserConstants.ClassTypes.source],
                width = attributes[HTMLParserConstants.ClassTypes.width],
                height = attributes[HTMLParserConstants.ClassTypes.height],
                widthFlt = Float(width),
                heightFlt = Float(height) else {
                    return nil
            }
            
            let widthCG = CGFloat(widthFlt)
            let heightCG = CGFloat(heightFlt)
            
            return ImageTypeStruct(src: src, key: src, size: CGSizeMake(widthCG, heightCG) , index: 0)
        }
    }
}

class HTMLParser {
    enum ParsingException : ErrorType {
        case RootHasNoChildren
    }
    
    let output: HTMLParserOutput
    let sourceDocument: HTMLDocument
    let imageRetriever: ImageRetriever
    let css: String
    
    init(output: HTMLParserOutput, source: HTMLDocument, imageRetriever: ImageRetriever, css: String) {
        self.output = output
        self.sourceDocument = source
        self.imageRetriever = imageRetriever
        self.css = css
    }
    
    func parse() throws -> (attributedString:NSAttributedString, images:[ImageTypeStruct]) {
        let elements = try XMLElements()
        return try buildAttributedStringWithXMLElements(elements)
    }
    
    func insertImages(images:[ImageTypeStruct], placeholderImage: UIImage! = UIImage(named: "gray")) {
        for var imageType in images {
            imageType.imageRange = output.insertImage("placeholderImage", image: placeholderImage, size: imageType.size, at: imageType.index)
            
            imageRetriever.retrieveImageWithURL(NSURL(string: imageType.src)!, optionsInfo: nil, progressBlock: nil, completionHandler: { [weak self] (image, error, cacheType, imageURL) in
                dispatch_async(dispatch_get_main_queue(), {
                    guard let _self = self, image = image, range = imageType.imageRange else {
                        print("bail me out, berniiiieeee!")
                        return
                    }
                    _self.output.removeImage(range)
                    _self.output.insertImage("Image", image: image, size: imageType.size, at: imageType.index)
                })
            })
        }
    }
    
    private func XMLElements() throws -> [WWXMLElement] {
        guard let root = sourceDocument.root, first = root.children.first else {
            throw ParsingException.RootHasNoChildren
        }
        var elements = [WWXMLElement]()
        
        elements = first.children.map({ (element) -> WWXMLElement in
            let WWElement = WWXMLElement(element: element)
            return WWElement
        })
        return elements
        
    }
    
    private func buildAttributedStringWithXMLElements(wwElements:[WWXMLElement]) throws -> (attributedString: NSAttributedString, images:[ImageTypeStruct]) {
        
        let attrStr = NSMutableAttributedString()
        var imageTags:[ImageTypeStruct] = [ImageTypeStruct]()
        
        for wwelement in wwElements {
            let element = wwelement.element
            guard let tag = element.tag else {
                continue
            }
            
            let elementStringRepresentable = try AttributedStringAssistant.ElementFactory.make(tag, element: wwelement)
            
            for string in elementStringRepresentable.attributedStrings() {
                attrStr.appendAttributedString(string)
            }
            
            let length = attrStr.length
            
            // resolve indices
            let images = elementStringRepresentable.imageTags().enumerate().map({ (index, image) -> ImageTypeStruct in
                var newImage = image
                newImage.index = length + index
                return newImage
            })
            
            imageTags += images
        }
        
        return (attrStr, imageTags)
    }
}

struct HTMLParserConstants {
    struct HTMLTypes {
        static let image    = "img"
        static let link     = "a"
    }
    
    struct ClassTypes {
        static let width    = "width"
        static let height   = "height"
        static let source   = "src"
        static let mention  = "mention"
        static let href     = "href"
        static let kClass   = "class"
    }
    
    struct HTMLConstants {
        static let openBracket  = "<"
        static let closeBracket = ">"
        static let separator    = ":/"
    }
}

struct ImageTypeStruct {
    let src:String!
    let key:String!
    let size:CGSize!
    var index:Int!
    var imageRange:NSRange?
    
    init(src:String, key:String, size:CGSize, index:Int){
        self.src = src
        self.key = key
        self.size = size
        self.index = index
    }
}
