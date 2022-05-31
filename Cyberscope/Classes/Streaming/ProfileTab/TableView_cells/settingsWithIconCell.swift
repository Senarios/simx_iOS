//
//  settingsWithIconCell.swift
//  CyberScope
//
//  Created by Saad Furqan on 09/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit

class settingsWithIconCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var icon_imageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
