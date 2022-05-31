//
//  StreamCell.swift
//  CyberScope
//
//  Created by Salman on 08/03/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit

class StreamCell: UITableViewCell {

    @IBOutlet weak var streamThumbnailImage: UIImageView!
    @IBOutlet weak var streamTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
