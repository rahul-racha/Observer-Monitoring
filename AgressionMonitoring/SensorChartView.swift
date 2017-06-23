//
//  SensorChartView.swift
//  AggressionMonitoring
//
//  Created by admin on 6/21/17.
//  Copyright © 2017 handson. All rights reserved.
//

import Foundation
import Charts

class SensorChartView: BarChartView {
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        constructFrame()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        constructFrame()
    }

    func constructFrame()
    {
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = self.frame.size.width / 14
    }

}
