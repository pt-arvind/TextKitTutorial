//
//  HTMLParserTests.swift
//  TextKitTutorial
//
//  Created by Yuchen Nie on 5/12/16.
//  Copyright © 2016 WeddingWire. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Kingfisher
import Fuzi
@testable import TextKitTutorial

class HTMLParserTest: QuickSpec {
    override func spec() {
        let textView = WWHTMLTextView()
        
//        describe("Textview is not nil") {
//            it("shouldn't be nil") {
//                
//                HTMLParser(output: textView, source: HTMLDocument(), imageRetriever: KingfisherManager.sharedManager)
//                let parser = HTMLParser(textView: textView)
//                expect(parser.textView).notTo(equal(nil))
//            }
//        }

        describe("HTMLParser") {
            context("should parse HTML images") {
                it("should remove HTML image tags") {
                    guard let htmlString = self.getJSONValueFromFile("SampleJSONTest", key: "cooked") else {return}
//                    let document = try! HTMLDocument(string: htmlString)
//                    let parser = HTMLParser(output: textView, source: document, imageRetriever: KingfisherManager.sharedManager)

                    
//                    let parser = HTMLParser(textView: textView)
//                    let cookedString = parser.removeImageTags(htmlString)
                    
                    let prunedString = AttributedStringAssistant.HTMLStringPruner.prune(htmlString, of: HTMLParserConstants.HTMLTypes.image)
                    
                    expect(prunedString.rangeOfString("<img")).to(beNil())
                }
                
                it("should get a list of images from html") {
//                    let parser = HTMLParser(textView: textView)
//                    guard let htmlString = self.getJSONValueFromFile("SampleJSONTest", key: "cooked") else {return}
                    guard let htmlString = self.getJSONValueFromFile("SampleJSONTest", key: "cooked") else {return}
                    let document = try! HTMLDocument(string: htmlString)
                    let parser = HTMLParser(output: textView, source: document, imageRetriever: KingfisherManager.sharedManager)
                    
                    
//                    let imageTags = parser.getImageTags(htmlString).images
//                    let parsedHTMLString = parser.getImageTags(htmlString).htmlWithNoImages
                    
                    let results = try! parser.parse()
                    
                    expect(results.attributedString.string.rangeOfString("<img")).to(beNil())
                    expect(results.images.count).to(equal(8))
                }
                
                it("should have the proper information for images", closure: {
                    guard let htmlString = self.getJSONValueFromFile("SampleJSONTest", key: "cooked") else {return}
                    let document = try! HTMLDocument(string: htmlString)
                    let parser = HTMLParser(output: textView, source: document, imageRetriever: KingfisherManager.sharedManager)
                    
                    let results = try! parser.parse()
                    
                    let firstImage = results.images[0]
                    expect(firstImage.src).to(equal("http://lorempixel.com/96/96?random=1"))
                    expect(firstImage.key).to(equal("http://lorempixel.com/96/96?random=1"))
                    expect(firstImage.size.height).to(equal(96.0))
                })
//                it("shouldn't have any images") {
////                    let parser = HTMLParser(textView: textView)
////                    guard let htmlString = self.getJSONValueFromFile("Sample21", key: "cooked") else {return}
//                    guard let htmlString = self.getJSONValueFromFile("SampleJSONTest", key: "cooked") else {return}
//                    let document = try! HTMLDocument(string: htmlString)
//                    let parser = HTMLParser(output: textView, source: document, imageRetriever: KingfisherManager.sharedManager)
//                    
//                    let imageTags = parser.getImageTags(htmlString).images
//                    let parsedHTMLString = parser.getImageTags(htmlString).htmlWithNoImages
//                    expect(parsedHTMLString).to(equal(htmlString))
//                    expect(imageTags.count).to(equal(0))
//                }
            }
        }
        
        describe("Image struct tests") {
            var images:[ImageTypeStruct]!
            
            beforeEach({ 
                let parser = HTMLParser(textView: textView)
                guard let htmlString = self.getJSONValueFromFile("SampleJSONTest", key: "cooked") else {return}
                images = parser.getImageTags(htmlString).images
            })
            

        }
        
        describe("WWXMLElements Tests") { 
            var parser:HTMLParser!
            var htmlString:String!
            
            beforeEach({ 
                parser = HTMLParser(textView: textView)
                htmlString = self.getJSONValueFromFile("SampleJSONTest", key: "cooked")
            })
            
            it("should return the proper number of elements", closure: { 
                let elements = parser.getElementsFromString(htmlString)
                expect(elements.count).to(equal(51))
            })
            
            it("elements should have the correct values", closure: { 
                let elements = parser.getElementsFromString(htmlString)
                let firstElement = elements[1]
                expect(firstElement.attributes?.count).to(equal(0))
                expect(firstElement.raw!).to(equal("<blockquote>This is someone elses quote that I\'m showing here... oh do \n\n<br/>\n\n<a href=\"http://google.com\">links</a> work here?</blockquote>"))
                expect(firstElement.stringValue!).to(equal("This is someone elses quote that I\'m showing here... oh do \n\n\n\nlinks work here?"))
                expect(firstElement.tag!).to(equal("blockquote"))
                
            })
            
            it("should build attributed string", closure: { 
                let elements = parser.getElementsFromString(htmlString)
                let attributedString = parser.buildAttributedStringWithXMLElements(elements).attrString
                expect(attributedString.length>0).to(beTrue())
                expect(attributedString.containsAttachmentsInRange(NSMakeRange(0, attributedString.length))).to(beFalse())
            })
            
            it("should have the correct indexing for images", closure: {
                let elements = parser.getElementsFromString(htmlString)
                let images = parser.buildAttributedStringWithXMLElements(elements).images
                expect(images.count).to(equal(8))
                let image0 = images[0]
                expect(image0.index).to(equal(395))
                let image1 = images[1]
                expect(image1.index).to(equal(430))
                let image2 = images[2]
                expect(image2.index).to(equal(432))
                let image3 = images[3]
                expect(image3.index).to(equal(520))
            
            })
            
        }
    }
    
    func getJSONValueFromFile(fileName:String, key:String) -> String? {
        let bundle = NSBundle(forClass: self.dynamicType)
        guard let path = bundle.pathForResource(fileName, ofType: "json") else {return nil}
        guard let jsonData = try? NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe) else {return nil}
        guard let jsonResult = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments) else {return nil}
        guard let str = jsonResult.objectForKey(key) as? String else {return nil}
        return str
    }
}