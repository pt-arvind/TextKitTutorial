//
//  DataType.swift
//  PrettyTextView
//
//  Created by Wesley Cope on 4/13/16.
//  Copyright © 2016 Wess Cope. All rights reserved.
//

import Foundation

let DetectedDataHandlerAttributeName    = "DetectedDataHandlerAttributeName"
let ImageAttributeName                  = "ImageAttributeName"
let CustomDataAttributeName             = "CustomDataAttributeName"

enum DetectedType : Int, CustomStringConvertible {
    case Mention
    case HashTag
    case URL
    case Email
    case Image
    case Custom
    
    var description: String {
        switch self {
        case .Mention:
            return "Mention"
        case .HashTag:
            return "HashTag"
        case .URL:
            return "URL"
        case .Email:
            return "Email"
        case .Image:
            return "Image"
        case .Custom:
            return "Custom"
        }
    }
}







