//
//  DeletePatientTableViewCell.swift
//  AggressionMonitoring
//
//  Created by admin on 8/11/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit

class DeletePatientTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var deleteView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
