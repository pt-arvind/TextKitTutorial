//
//  BaseCell.swift
//  TextKitTutorial
//
//  Created by Yuchen Nie on 4/18/16.
//  Copyright © 2016 WeddingWire. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class BaseCell: UITableViewCell {
    static let identifier = "BaseCellIdentifier"
    
    private lazy var textView:WWTextView = {
        let textView = WWTextView(frame: .zero)
        
        self.addSubview(textView)
        return textView
    }()
    
    func loadViewModel() {
        
    }
}