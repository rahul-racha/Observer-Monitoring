//
//  PatientRootUIView.swift
//  AgressionMonitoring
//
//  Created by rahul rachamalla on 6/6/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit

class PatientRootUIView: UIView {

    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }
    
    // MARK: Helper methods
    func activeStatusColor(viewColor: UIColor)
    {
        self.backgroundColor = viewColor
    }

}
