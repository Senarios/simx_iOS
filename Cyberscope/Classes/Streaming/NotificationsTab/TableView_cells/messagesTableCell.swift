//
//  messagesTableCell.swift
//  CyberScope
//
//  Created by Saad Furqan on 03/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit

class messagesTableCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var unreadMessagesCount: UILabel!
    @IBOutlet weak var chatImage: UIImageView!
    var imageName: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func getImageNameForQBUser(qbid:UInt) {
        
        //make image circular
        chatImage.layer.cornerRadius = chatImage.frame.height / 2
        chatImage.clipsToBounds = true
        
        QBRequest.user(withID: qbid, successBlock: { response, users in
            // Successful response with page information and users array
            print(response.debugDescription)
            print(users)
            self.imageName = users.login as! String
            print(Utilities.getUserImage_URL(username: self.imageName))
            self.chatImage.sd_setImage(with: Utilities.getUserImage_URL(username: self.imageName), placeholderImage: UIImage(named: Constants.imagesName.broadcaster_image))
        }, errorBlock: { response in
            // Handle error here
            print(response.error.debugDescription)
        })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
