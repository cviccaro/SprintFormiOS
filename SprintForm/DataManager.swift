//
//  DataManager.swift
//  SprintForm
//
//  Created by Chris Viccaro on 9/28/17.
//  Copyright © 2017 JP Enterprises. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class DataManager {
    var uploadUrl = "http://sprint-form.jpedev.com/submit"
    var timer: Timer?
    
    func startTimer() {
        guard self.timer == nil else { return }
        self.timer = Timer.scheduledTimer(timeInterval: 600, target: self, selector: #selector(uploadSubmissions), userInfo: nil, repeats: true)
        self.timer?.fire()
    }
    
    func stopTimer() {
        guard timer != nil else { return }
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func getContext() -> NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    func getSubmissions() -> [Submission] {
        let context = self.getContext()
        do {
            return try context.fetch(Submission.fetchRequest())
        } catch {
            return [];
        }
    }
    
    func push() {
        self.uploadSubmissions(timer:nil)
    }
    
    @objc func uploadSubmissions(timer: Timer?) {
        let context = self.getContext()
        let submissions = self.getSubmissions()
        for submission in submissions {
            if (!submission.uploaded) {
                let parameters: Parameters = [
                    "first_name": submission.first_name!,
                    "last_name": submission.last_name!,
                    "e_mail_address": submission.e_mail_address!,
                    "current_carrier": submission.current_carrier!,
                    "mobile_number": submission.mobile_number!,
                    "street_address": submission.street_address!,
                    "city": submission.city!,
                    "state": submission.state!,
                    "zip_code": submission.zip_code!,
                    "how_many_lines_on_account": submission.how_many_lines_on_account!,
                    "how_many_tablets_on_account": submission.how_many_tablets_on_account!,
                    "opt_out": submission.opt_out,
                    "udid": submission.udid!,
                    "tracking_id": submission.tracking_id!,
                    "created_at": submission.created_at!
                ]
                print("Uploading submission with data: ", parameters)
                Alamofire.request(self.uploadUrl, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
                    .responseJSON { response in
                        print("Response from server: ", response)
                        if let json = response.result.value as? [String:AnyObject] {
                            let success = json["success"] as! Int == 1
                            if (success) {
                                submission.uploaded = true
                                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                            }
                        }
                    }
            } else {
                //print(String(format:"Skipping upload of submission created_at %@ because it has already been uploaded.", submission.created_at!.debugDescription))
            }
        }
    }
}
