//
//  InstallViewController.swift
//  SprintForm
//
//  Created by Chris Viccaro on 10/12/17.
//  Copyright © 2017 JP Enterprises. All rights reserved.
//

import UIKit

class InstallViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView?
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var saveButton: UIButton?
    
    var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var selectedSource: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.sizeToFit()

        self.titleLabel?.font = UIFont(name: "SprintSansWeb-Regular", size: 24.0)
        self.titleLabel?.sizeToFit()
        self.titleLabel?.frame.origin.x += 20
        
        self.saveButton?.titleLabel?.font = UIFont(name: "SprintSansWeb-Regular", size: 24.0)

        self.tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView?.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
        let sourceKey = self.appDelegate.sourceMap[indexPath.row]
        let source = self.appDelegate.sources[sourceKey]
        cell.textLabel?.text = source
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var i = 0
        for _ in self.appDelegate.sourceMap {
            if (i != indexPath.row) {
                if let cell = self.tableView?.cellForRow(at: IndexPath(row: i, section: 0)) {
                    cell.accessoryType = .none
                }
            }
            i = i + 1
        }
        if let cell = self.tableView?.cellForRow(at: indexPath) {
            if (cell.accessoryType == .checkmark) {
                cell.accessoryType = .none
                self.selectedSource = nil
            } else {
                cell.accessoryType = .checkmark
                self.selectedSource = self.appDelegate.sourceMap[indexPath.row]
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appDelegate.sources.count
    }
    
    @IBAction func save(_ sender: UIButton) {
        if let source = self.selectedSource {
            UserDefaults.standard.setValue(source, forKey: "sprint_form_tracking_id")
            self.appDelegate.trackingID = source
            self.dismiss(animated: true, completion: nil)
        }
    }
}
