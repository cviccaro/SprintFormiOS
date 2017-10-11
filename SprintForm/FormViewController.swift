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
    @IBOutlet var scrollView:UIScrollView!;
    
    var activePickerTrigger:PickerTriggerButton?
    var activeField:UITextField?
    var pickerView:UIPickerView?
    var popOver:UIViewController?
    //var popOverController:UIPopoverController?
    
    var stateOptions: [String] = [];
    var dropdownFieldMap: [String: PickerTriggerButton] = [:];

    var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Initialize state options
        let statesPlist = Bundle.main.resourceURL?.appendingPathComponent("States.plist")
        
        let statesDict = NSDictionary(contentsOf: statesPlist!)
        self.stateOptions = []
        if let statesDictCopy = statesDict {
            for (stateName, _) in statesDictCopy {
                self.stateOptions.append(stateName as! String)
            }
        }
        self.stateOptions.sort()

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
                textfield.delegate = self
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
        
        // Created asteriks for required labels
        if (self.requiredLabels.count > 0) {
            for label in self.requiredLabels {
                let requiredLabel = UILabel()
                requiredLabel.frame = CGRect(x: label.frame.origin.x + label.frame.size.width + 3,y: CGFloat(label.frame.origin.y), width: 10.0, height: 10.0)
                requiredLabel.text = "*"
                requiredLabel.font = UIFont(name: "SprintSansWeb-Medium", size: 16.0)
                requiredLabel.textColor = UIColor(red: (248.0 / 256.0), green: (9.0/256.0), blue: (71.0/256.0), alpha: 1.0)
                requiredLabel.sizeToFit()
                self.scrollView!.addSubview(requiredLabel);
            }
        }
        
        // Create dropdown fields
        if (self.dropdownFields!.count > 0) {
            for textfield in self.dropdownFields {
                var options:[String] = [];
                if (textfield.tag == 120) {
                    options = ["AT&T", "Cricket", "PCS Mobile", "Sprint", "T-Mobile", "Verizon"];
                } else if (textfield.tag == 50) {
                    options = self.stateOptions;
                } else if (textfield.tag == 90 || textfield.tag == 100) {
                    options = ["0","1","2","3","4","5","6","7","8","9","10"];
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.scrollView.contentSize = self.view.frame.size
        
        // Adjust fonts for textfields
        if (self.textFields.count > 0) {
            for textfield in self.textFields {
                textfield.layer.borderColor = UIColor.darkGray.cgColor
                textfield.text = nil
            }
        }
        // Reset dropdown fields values
        if (self.dropdownFieldMap.count > 0) {
            for (_, trigger) in self.dropdownFieldMap {
                trigger.selectedOption = 0
            }
        }
    }
    
    
    
    @objc func keyboardWillShow(notification:NSNotification){
        var userInfo = notification.userInfo!
        let kbSize:CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height + 10, 0.0);
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        var viewFrame = self.view.frame
        viewFrame.size.height = viewFrame.size.height - kbSize.height - 10

        if (self.activeField !== nil && !viewFrame.contains(self.activeField!.frame.origin)) {
            self.scrollView.scrollRectToVisible(self.activeField!.frame, animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTage=textField.tag+10;

        // Try to find next responder
        let nextResponder=textField.superview?.viewWithTag(nextTage) as UIResponder!

        if (nextResponder != nil){
            if self.activePickerTrigger != nil {
                self.popOver!.dismiss(animated: false)
            }
            if (self.dropdownFields.contains(nextResponder as! UITextField)) {
                let fieldName = self.fieldNameForTextField(textField: nextResponder as! UITextField)
                let picker = self.dropdownFieldMap[fieldName]
                if (picker != nil) {
                    let welf = self
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25,execute: {
                        welf.displayPicker(picker)
                    })
                    textField.resignFirstResponder()
                }
            }
            nextResponder?.becomeFirstResponder()
        }
        else
        {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }
        return false // We do not want UITextField to insert line-breaks.
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeField = nil
    }
    
    /**
     * Create Dropdown Field
     **/
    func createDropdown(textField: UITextField, opts: Array<String>) {
        textField.delegate = self
       // textField.isUserInteractionEnabled = false
        
        // Create trigger
        let options = ["Please select one..."] + opts
        let trigger = PickerTriggerButton(frame: textField.frame, pickerOptions: options, targetTextfield: textField)
        trigger.selectedOption = 0
        trigger.addTarget(self, action: #selector(FormViewController.displayPicker(_:)), for: UIControlEvents.touchUpInside)
        
        let fieldName = self.fieldNameForTextField(textField: textField)
        self.dropdownFieldMap[fieldName] = trigger;
        
        // Add trigger to subviews
        self.scrollView!.addSubview(trigger)
    }
    
    func fieldNameForTextField(textField: UITextField) -> String {
        let label: UILabel? = self.view.viewWithTag(textField.tag - 1) as? UILabel
        return (label?.text?
            .lowercased()
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .joined(separator: "_"))!
    }
    
    /**
     * Submit Form
     **/
    @IBAction func submitForm(_ sender: UIButton) {
        var data: [String: Any] = [:]
        var errors: [String: String] = [:]
        for textfield in self.textFields {
            let label: UILabel? = self.view.viewWithTag(textfield.tag - 1) as? UILabel
            let fieldName = self.fieldNameForTextField(textField: textfield)
            let required = self.requiredLabels.contains(label!)

            if (required && (textfield.text == "" || textfield.text == nil)) {
                errors[fieldName] = "required"
                self.markFieldError(textfield: textfield)
            } else {
                data[fieldName] = textfield.text
                self.clearFieldError(textfield: textfield)
            }
            
            // validate zip
            if (textfield.tag == 60) {
                if (!self.isValidZip(testStr: textfield.text!)) {
                    errors[fieldName] = "zip"
                    self.markFieldError(textfield: textfield)
                } else {
                    self.clearFieldError(textfield: textfield)
                }
            }
            
            // validate email
            if (textfield.tag == 70) {
                if (!self.isValidEmail(testStr: textfield.text!)) {
                    errors[fieldName] = "email"
                    self.markFieldError(textfield: textfield)
                } else {
                    self.clearFieldError(textfield: textfield)
                }
            }
            
            // validate phone
            if (textfield.tag == 80) {
                if (!self.isValidPhone(testStr: textfield.text!)) {
                    errors[fieldName] = "phone"
                    self.markFieldError(textfield: textfield)
                } else {
                    self.clearFieldError(textfield: textfield)
                }
            }
        }
        if (errors.count > 0) {
            var errorMessage = ""
            if (errors.values.contains("required")) {
                errorMessage += "Please fill out all the required fields."
            }
            if (errors.values.contains("zip")) {
                errorMessage += "\r\nPlease enter a valid zip code."
            }
            if (errors.values.contains("email")) {
                errorMessage += "\r\nPlease enter a valid email."
            }
            if (errors.values.contains("phone")) {
                errorMessage += "\r\nPlease enter a valid mobile phone number."
            }
            let alert = UIAlertController(title: "Form invalid", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            // Submit the data.
            self.createSubmission(data: data)
        }
    }
    
    func markFieldError(textfield: UITextField) {
        textfield.layer.borderColor = UIColor.red.cgColor
        textfield.layer.borderWidth = 1.0
    }
    
    func clearFieldError(textfield: UITextField) {
        textfield.layer.borderColor = UIColor.darkGray.cgColor
        textfield.layer.borderWidth = 1.0
    }
    
    func isValidZip(testStr:String) -> Bool {
        let ZIP_REGEX = "(^[0-9]{5}(-[0-9]{4})?$)"
        
        let zipTest = NSPredicate(format:"SELF MATCHES %@", ZIP_REGEX)
        return zipTest.evaluate(with: testStr)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let EMAIL_REGEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", EMAIL_REGEX)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidPhone(testStr:String) -> Bool {
        let PHONE_REGEX = "^\\d?-?\\d{3}-?\\d{3}-?\\d{4}$"
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", PHONE_REGEX)
        return phoneTest.evaluate(with: testStr)
    }
    
    func createSubmission(data: [String:Any]) {
        // Create Core Data model
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let submission = Submission(context: context)
        submission.first_name = data["first_name"] as? String
        submission.last_name = data["last_name"] as? String
        submission.street_address = data["street_address"] as? String
        submission.mobile_number = data["mobile_number"] as? String
        submission.e_mail_address = data["e_mail_address"] as? String
        submission.how_many_lines_on_account = data["how_many_lines_on_account"] as? String
        submission.how_many_tablets_on_account = data["how_many_tablets_on_account"] as? String
        submission.zip_code = data["zip_code"] as? String
        submission.city = data["city"] as? String
        submission.current_carrier = data["current_carrier"] as? String
        submission.state = data["state"] as? String
        submission.opt_out = ((data["opt_out"] as? String) == "Yes")
        submission.udid = UIDevice.current.identifierForVendor!.uuidString
        submission.tracking_id = self.appDelegate.trackingID
        submission.created_at = Date()
        submission.uploaded = false
        
        // Save
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        let thankYouController = self.storyboard?.instantiateViewController(withIdentifier: "ThankYouViewController") as? ThankYouViewController
        self.navigationController?.pushViewController(thankYouController!, animated: true)
    }
    
    // MARK: Picker
    @objc func displayPicker(_ sender: PickerTriggerButton?) {
        self.activePickerTrigger = sender
//        print(String(format:"display picker from %@.  Our target textfield is %@.  Default value is %ld", sender!, sender!.targetTextfield!, self.activePickerTrigger!.selectedOption))
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
            let title = self.activePickerTrigger!.pickerOptions![row] as String
            self.activePickerTrigger!.targetTextfield!.text = title
        }
    }

}

