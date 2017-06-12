//
//  PatientTableViewCell.swift
//  AgressionMonitoring
//
//  Created by rahul rachamalla on 6/6/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit

class PatientRootTableViewCell: UITableViewCell {
    enum Status{
        case stable
        case aggressive
        case partiallyaggressive
        case unknown
    }
    
    @IBOutlet weak var patientName: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var view: PatientRootUIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func patientStatus(status: Status) {
        if (status == Status.stable) {
            self.view.activeStatusColor(viewColor: UIColor.green)
        } else if (status == Status.aggressive) {
            self.view.activeStatusColor(viewColor: UIColor.red)
        } else if (status == Status.partiallyaggressive ) {
            self.view.activeStatusColor(viewColor: UIColor.yellow)
        } else {
            self.view.activeStatusColor(viewColor: UIColor.gray)
        }
    }
    
    /*override func layoutSubviews() {
        super.layoutSubviews()
        
        let frame = contentView.frame
        let frameInset = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(10, 10, 10, 10))
        contentView.frame = frameInset
    }*/

}
