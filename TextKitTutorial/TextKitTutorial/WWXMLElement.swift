//
//  WWXMLElement.swift
//  TextKitTutorial
//
//  Created by Yuchen Nie on 4/28/16.
//  Copyright © 2016 WeddingWire. All rights reserved.
//

import Foundation
import Fuzi

//FIXME: why does this exist?
class WWXMLElement {
    let element:XMLElement!
    let raw:String?
    let attributes:[String:String]?
    let tag:String?
    let stringValue:String?
    
    init(element:XMLElement){
        self.element        = element
        self.raw            = element.rawXML
        self.attributes     = element.attributes
        self.tag            = element.tag
        self.stringValue    = element.stringValue
    }
}