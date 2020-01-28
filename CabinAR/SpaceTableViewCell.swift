//
//  SpaceTableViewCell.swift
//  CabinAR
//
//  Created by Pascal Rettig on 6/2/19.
//  Copyright © 2019 Pascal Rettig. All rights reserved.
//

import UIKit

class SpaceTableViewCell: UITableViewCell {

    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
