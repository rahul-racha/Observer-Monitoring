//
//  Global.swift
//  AgressionMonitoring
//
//  Created by rahul rachamalla on 6/6/17.
//  Copyright © 2017 handson. All rights reserved.
//

import Foundation

struct Manager {
    static var controlData: Bool?
    static var patientDetails: [Dictionary<String,Any>]?
    static var reloadAllCells: Bool = true
    static var addControlHold: Bool = false
}
