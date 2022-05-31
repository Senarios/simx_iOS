//
//  user_RejectedAppointment_Cell.swift
//  CyberScope
//
//  Created by Saad Furqan on 12/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit

class user_RejectedAppointment_Cell: UITableViewCell {

    @IBOutlet weak var topViewutlet: UIView!
    @IBOutlet weak var image_broadcaster: UIImageView!
    @IBOutlet weak var broadcaster_name: UILabel!
    
    @IBOutlet weak var label_appointmentTime: UILabel!
    @IBOutlet weak var label_appointmentDate: UILabel!
    @IBOutlet weak var label_appointmentStatus: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        topViewutlet.layer.shadowColor = UIColor.black.cgColor
        topViewutlet.layer.shadowOpacity = 0.3
        topViewutlet.layer.shadowOffset = .zero
        topViewutlet.layer.shadowRadius = 3
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
