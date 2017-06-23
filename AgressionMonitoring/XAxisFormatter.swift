//
//  XAxisFormatter.swift
//  AggressionMonitoring
//
//  Created by admin on 6/21/17.
//  Copyright © 2017 handson. All rights reserved.
//

import Foundation
import Charts

public class BarChartFormatter: NSObject, IAxisValueFormatter
{
    var agCategory: [String]?
    
    public func setWeek(fields: [String]) {
        self.agCategory = fields
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String
    {
        let val = Int(floor(value))
        print(val)
        if (self.agCategory != nil) {
            if val>=0 && val<self.agCategory!.count {
                return self.agCategory![val]
            }
        }
        return ""
    }
}
