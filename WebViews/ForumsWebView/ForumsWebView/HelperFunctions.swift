//
//  HelperFunctions.swift
//  TextKitTutorial
//
//  Created by Yuchen Nie on 4/19/16.
//  Copyright © 2016 WeddingWire. All rights reserved.
//

import Foundation
import UIKit
import Fuzi

struct HelperFunctions {
    static func getHTMLFromFile(fileName:String) -> String{
        let url = NSBundle.mainBundle().URLForResource(fileName, withExtension:"html")
        guard let fileContent = try? NSString(contentsOfURL: url!, encoding: NSNonLossyASCIIStringEncoding) else {return ""}
        return fileContent as String
    }
    
    static func showHTMLString(unformattedString: String) -> NSAttributedString{
        
        return try! NSAttributedString(data: unformattedString.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
    }
    
    static func stringFrom(fileName:String, `extension`: String) -> String? {
        let url = NSBundle.mainBundle().URLForResource(fileName, withExtension:`extension`)
        guard let fileContent = try? NSString(contentsOfURL: url!, encoding: NSUTF8StringEncoding) else { return nil }
        return fileContent as String
    }
    
    static func getJSONValueFromFile(fileName:String, key:String) -> [String]? {
        guard let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "json") else {return nil}
        guard let jsonData = try? NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe) else {return nil}
        guard let jsonResult = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments) else {return nil}
        guard let stream = jsonResult["post_stream"] as? NSDictionary else {return nil}
        guard let posts = stream["posts"] as! NSArray? else {return nil}
//        let firstPost = posts[0] as! NSDictionary
        
//        guard let str = firstPost[key] as? String else {return nil}
        
        let postXMLs = posts.map { (post) -> String in
            return post[key] as! String
        }
        
        return postXMLs
    }
    
    static func convertSizeForImage(originalSize:CGSize, containerSize:CGSize) -> CGSize {
        if originalSize.width > containerSize.width {
            let ratio = containerSize.width/originalSize.width
            return CGSizeMake(originalSize.width * ratio, originalSize.height * ratio)
        } else {
            return originalSize
        }
    }
}

extension NSData {
    var attributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options:[NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF16StringEncoding], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}

extension String {
    var utf8Data: NSData? {
        return dataUsingEncoding(NSUTF16StringEncoding)
    }
}
