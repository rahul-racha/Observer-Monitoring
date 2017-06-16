//
//  Global.swift
//  AgressionMonitoring
//
//  Created by rahul rachamalla on 6/6/17.
//  Copyright © 2017 handson. All rights reserved.
//

import Foundation
import UIKit

struct Manager {
    static var userData: [String: Any]?
    static var controlData: Bool?
    static var patientDetails: [Dictionary<String,Any>]?
    static var reloadAllCells: Bool = true
    static var addControlHold: Bool = false
    static var deviceId: String?
    static var triggerNotifications: Bool = false
}

class Manage: UIViewController {
    
    func displayAlertMessage(message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }

}
