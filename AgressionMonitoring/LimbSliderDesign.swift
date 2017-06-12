//
//  LimbSliderDesign.swift
//  AgressionMonitoring
//
//  Created by rahul rachamalla on 6/5/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit

class LimbSliderDesign: UISlider {
    enum thumbStatus {
        case stable
        case aggressive
        case partial
        case unknown
    }
    
    func colorSlider(status: thumbStatus) {
        if (status == thumbStatus.stable) {
            self.thumbTintColor = UIColor.green
        } else if (status == thumbStatus.aggressive) {
            self.thumbTintColor = UIColor.red
        } else if (status == thumbStatus.partial) {
            self.thumbTintColor = UIColor.yellow
        } else {
            self.thumbTintColor = UIColor.gray
        }
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
