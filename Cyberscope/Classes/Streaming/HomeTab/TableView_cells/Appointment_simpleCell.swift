//
//  Appointment_simpleCell.swift
//  CyberScope
//
//  Created by Saad Furqan on 12/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit

class Appointment_simpleCell: UITableViewCell {

    @IBOutlet weak var label_key: UILabel!
    @IBOutlet weak var label_value: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
