//
//  ThankYouViewController.swift
//  SprintForm
//
//  Created by Chris Viccaro on 9/28/17.
//  Copyright © 2017 JP Enterprises. All rights reserved.
//

import UIKit

class ThankYouViewController: UIViewController {
    @IBOutlet var thankYouLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adjust fonts for labels
        self.thankYouLabel?.font = UIFont(name: "SprintSansWeb-Bold", size: 24.0)
        self.thankYouLabel?.sizeToFit()
        self.thankYouLabel?.frame.origin.x = (self.view.frame.size.width / 2) - ((self.thankYouLabel?.frame.size.width)! / 2)
    }
    
    @IBAction func goBack() {
     self.navigationController?.popViewController(animated: true)
    }
}
