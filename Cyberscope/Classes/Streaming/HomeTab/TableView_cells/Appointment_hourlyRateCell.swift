//
//  Appointment_hourlyRateCell.swift
//  CyberScope
//
//  Created by Saad Furqan on 12/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit

class Appointment_hourlyRateCell: UITableViewCell {

    @IBOutlet weak var label_key: UILabel!
    @IBOutlet weak var parentView_value: UIView!
    @IBOutlet weak var buttonHourlyRate: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
