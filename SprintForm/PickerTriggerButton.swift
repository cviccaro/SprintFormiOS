//
//  PickerTriggerButton.swift
//  Trade Show
//
//  Created by Chris Viccaro on 6/3/15.
//  Copyright (c) 2015 JP Enterprises, Inc. All rights reserved.
//

import UIKit

class PickerTriggerButton: UIButton {
    var targetTextfield:UITextField?
    var pickerOptions:Array<String>?
    var fieldName:String?    
    var selectedOption:Int = 0
    
    convenience init(frame:CGRect, pickerOptions: Array<String>, targetTextfield: UITextField) {
        self.init(frame: frame)
        self.targetTextfield = targetTextfield
        self.pickerOptions = pickerOptions
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.backgroundColor = UIColor.clear
        self.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin]
    }


}
