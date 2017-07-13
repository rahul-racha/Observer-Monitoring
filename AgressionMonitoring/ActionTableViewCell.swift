//
//  ActionTableViewCell.swift
//  AggressionMonitoring
//
//  Created by admin on 7/10/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit

class ActionTableViewCell: UITableViewCell {

    @IBOutlet weak var actionCollectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        //fatalError("init(coder:) has not been implemented")
        //let flow = self.actionCollectionView.collectionViewLayout//UICollectionViewFlowLayout
        
        //self.contentView.layoutIfNeeded()
    }

    var collectionViewOffset: CGFloat {
        get {
            return actionCollectionView.contentOffset.x
        }
        
        set {
            actionCollectionView.contentOffset.x = newValue
        }
    }
    
    /*override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                 withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                 verticalFittingPriority: UILayoutPriority) -> CGSize {
        self.actionCollectionView.frame = CGRect(x: 0, y: 0, width: targetSize.width, height: CGFloat(MAXFLOAT))
        self.actionCollectionView.layoutIfNeeded()
        return actionCollectionView.collectionViewLayout.collectionViewContentSize
    }*/
    

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCollectionViewDataSourceDelegate
        <D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>
        (dataSourceDelegate: D, forRow row: Int, forSection sec: Int)
    {
        actionCollectionView.delegate = dataSourceDelegate
        actionCollectionView.dataSource = dataSourceDelegate
        let indexPath = IndexPath(row: row, section: sec)
        //actionCollectionView.tag = row
        actionCollectionView.layer.setValue(indexPath, forKey: "indexLoc")
        //print("xyzychxh loc:\(actionCollectionView.layer.value(forKey: "indexLoc"))")
        actionCollectionView.reloadData()
    }

}
