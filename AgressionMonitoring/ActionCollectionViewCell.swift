//
//  ActionCollectionViewCell.swift
//  AggressionMonitoring
//
//  Created by admin on 7/7/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit

class ActionCollectionViewCell: UICollectionViewCell {
   
    enum STATUS {
        case SELECTED
        case DESELECTED
        case UNKNOWN
    }
    
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var actionName: UILabel!

    func applyViewStatusColor(status: STATUS) {
        if (status == STATUS.SELECTED) {
            actionView.backgroundColor = UIColor.green
        } else if (status == STATUS.DESELECTED) {
            actionView.backgroundColor = UIColor.blue
        } else {
            actionView.backgroundColor = UIColor.darkGray
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        //fatalError("init(coder:) has not been implemented")
        //self.contentView.setNeedsLayout()
    }
    
}
