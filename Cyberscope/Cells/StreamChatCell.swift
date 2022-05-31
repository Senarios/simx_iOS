//
//  StreamChatCell.swift
//  SimX
//
//  Created by Zain Ahmed on 10/11/2021.
//  Copyright © 2021 Agilio. All rights reserved.
//

import UIKit

class StreamChatCell: UITableViewCell {

    @IBOutlet weak var img : UIImageView!
    @IBOutlet weak var name : UILabel!
    @IBOutlet weak var comment : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func getNib() -> UINib{
        return UINib(nibName: "\(StreamChatCell.self)", bundle: nil)
    }

}
