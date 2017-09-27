//
//  ViewController.swift
//  SprintForm
//
//  Created by Chris Viccaro on 9/26/17.
//  Copyright © 2017 JP Enterprises. All rights reserved.
//

import UIKit

class FormViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet var yellowBanner:UIView?
    @IBOutlet var requiredLabels:[UILabel]!;
    @IBOutlet var fieldLabels:[UILabel]!;
    @IBOutlet var textFields:[UITextField]!;
    @IBOutlet var dropdownFields: [UITextField]!;
    @IBOutlet var helpText:UILabel!;
    
    var activePickerTrigger:PickerTriggerButton?
    var pickerView:UIPickerView?
    var popOver:UIViewController?
    //var popOverController:UIPopoverController?
    
    var stateOptions: [String] = [];

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize state options
        let statesPlist = Bundle.main.resourceURL?.appendingPathComponent("States.plist")
        
        let statesDict = NSDictionary(contentsOf: statesPlist!)
        self.stateOptions = []
        if let statesDictCopy = statesDict {
            for (stateName, stateCode) in statesDictCopy {
                self.stateOptions.append(stateName as! String)
            }
        }
        self.stateOptions.sort()
        print(self.stateOptions)

        // Create picker view controller
        if (self.pickerView == nil) {
            self.pickerView = UIPickerView(frame: CGRect(x: 0,y: 0,width: self.view.frame.size.width, height: 216.0))
            self.pickerView?.showsSelectionIndicator = true
            self.pickerView?.delegate = self
            self.pickerView?.dataSource = self
        }
        
        // Create popover view controller
        if (self.popOver == nil) {
            self.popOver = UIViewController()
            self.popOver!.view = self.pickerView
            //self.popOver!.preferredContentSize = CGSize(width: self.view.frame.size.width / 1.5, height: 216.0)
            self.popOver?.modalPresentationStyle = UIModalPresentationStyle.popover;
        }
        
        // Adjust fonts for textfields
        if (self.textFields.count > 0) {
            for textfield in self.textFields {
                textfield.font = UIFont(name: "SprintSansWeb-Regular", size: 15.0)
            }
        }
        
        // Adjust fonts for labels
        self.helpText.font = UIFont(name: "SprintSansWeb-RegularItalic", size: 15.0)
        
        if (self.fieldLabels.count > 0) {
            for label in self.fieldLabels {
                label.font = UIFont(name: "SprintSansWeb-Medium", size: 17.0)
                label.sizeToFit()
            }
        }
        
        var i = 0;
        for view in self.yellowBanner!.subviews {
            let label = view as! UILabel;

            if (i == 2) {
                label.font = UIFont(name: "SprintSansWeb-Medium", size: 17.0)
                label.frame.origin.x = label.frame.origin.x + 3;
            } else {
                label.font = UIFont(name: "SprintSansWeb-Regular", size: 17.0)
            }
            
            label.sizeToFit()
            
            i = i + 1;
        }
        if (self.requiredLabels.count > 0) {
            for label in self.requiredLabels {
                let requiredLabel = UILabel()
                requiredLabel.frame = CGRect(x: label.frame.origin.x + label.frame.size.width + 3,y: CGFloat(label.frame.origin.y), width: 10.0, height: 10.0)
                requiredLabel.text = "*"
                requiredLabel.font = UIFont(name: "SprintSansWeb-Medium", size: 16.0)
                requiredLabel.textColor = UIColor(red: (248.0 / 256.0), green: (9.0/256.0), blue: (71.0/256.0), alpha: 1.0)
                requiredLabel.sizeToFit()
                self.view.addSubview(requiredLabel);
            }
        }
        
        // Create dropdown fields
        if (self.dropdownFields!.count > 0) {
            for textfield in self.dropdownFields {
                var options:[String] = [];
                if (textfield.tag == 100) {
                    options = ["Sprint", "AT&T", "Verizon", "T-Mobile", "Cricket"];
                } else if (textfield.tag == 105) {
                    options = self.stateOptions;
                } else {
                    options = ["Yes", "No"];
                }
                self.createDropdown(textField: textfield, opts: options);
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     * Create Dropdown Field
     **/
    func createDropdown(textField: UITextField, opts: Array<String>) {
        // add blank option
        let options = ["Please select one..."] + opts
        // Build textfield
        textField.delegate = self
        var defaultValueOption = 0
        // Inject default value
//        if ((defaultValue) != nil && !defaultValue!.isKind(of: NSNull)) {
//            if (isBoolField) {
//                if (defaultValue as! String == "1") {
//                    textField.text = "Yes"
//                    defaultValueOption = 1
//                }
//                else {
//                    textField.text = "No"
//                    defaultValueOption = 2
//                }
//            }
//            else {
//                var defaultValueString = defaultValue as! String
//                var i = 0
//                //self.logger.log(String(format:"Scanning options %@ for value: %@", options, defaultValueString))
//                for val in options {
//                    if (val == defaultValueString) {
//                        defaultValueOption = i
//                        textField.text = val
//                        //self.logger.log(String(format:"Found text %@ in options as index %ld", defaultValueString, i))
//                    }
//                    i += 1
//                }
//            }
//        }
//
        
        // Create trigger
        
        let trigger = PickerTriggerButton(frame: textField.frame, pickerOptions: options, targetTextfield: textField)
        //trigger.fieldName = field_name
        trigger.selectedOption = defaultValueOption
        trigger.addTarget(self, action: #selector(FormViewController.displayPicker(_:)), for: UIControlEvents.touchUpInside)
        
        // Add trigger to subviews
        self.view!.addSubview(trigger)
    }
    
    /**
     * Submit Form
     **/
    @IBAction func submitForm(_ sender: UIButton) {
        print("Submit form from button", sender)
    }
    
    
    // MARK: Picker
    @objc func displayPicker(_ sender: PickerTriggerButton?) {
        self.activePickerTrigger = sender
        print(String(format:"display picker from %@.  Our target textfield is %@.  Default value is %ld", sender!, sender!.targetTextfield!, self.activePickerTrigger!.selectedOption))
        self.pickerView?.reloadAllComponents()
        self.pickerView?.selectRow(self.activePickerTrigger!.selectedOption, inComponent: 0, animated: false)
        self.popOver!.preferredContentSize = CGSize(width: self.activePickerTrigger!.frame.size.width, height: self.activePickerTrigger!.frame.size.height * 5)
        self.present(self.popOver!, animated: true, completion: nil);
        
        let popoverPresentationController = self.popOver!.popoverPresentationController
        popoverPresentationController?.sourceView = sender
        popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: self.activePickerTrigger!.frame.size.width, height: self.activePickerTrigger!.frame.size.height)

    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.activePickerTrigger!.pickerOptions!.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.activePickerTrigger!.pickerOptions![row] as String
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (row > 0) {
            self.activePickerTrigger!.selectedOption = row
            var title = self.activePickerTrigger!.pickerOptions![row] as String
            self.activePickerTrigger!.targetTextfield!.text = title
//            if let defaultValues:Dictionary<String,AnyObject> = self.defaultValues {
//                var _defaults = defaultValues
//                var fieldname = self.activePickerTrigger!.fieldName!
//                _defaults[fieldname] = title as AnyObject
//                self.defaultValues = _defaults
//            }
            print(String(format: "selected row %d in picker.  returns value %@", row, title))
            print(String(format: "Setting %@ as value of textfield %@", title, self.activePickerTrigger!.targetTextfield!))
        }
    }

}

