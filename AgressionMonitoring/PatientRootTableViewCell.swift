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
        case select
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
        } else if (status == Status.unknown ) {
            self.view.activeStatusColor(viewColor: UIColor.clear)
        } else {
            self.view.activeStatusColor(viewColor: UIColor.blue)
            //self.patientName.textColor = UIColor.white
            //self.location.textColor = UIColor.white
            //self.status.textColor = UIColor.white
        }
    }
    
    /*override func layoutSubviews() {
        super.layoutSubviews()
        
        let frame = contentView.frame
        let frameInset = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(10, 10, 10, 10))
        contentView.frame = frameInset
    }*/

}
