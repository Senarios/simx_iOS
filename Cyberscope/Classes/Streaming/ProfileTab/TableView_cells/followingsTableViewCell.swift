//
//  followingsTableViewCell.swift
//  CyberScope
//
//  Created by Saad Furqan on 09/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit

class followingsTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobTitle_Label: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileImage.setMyCornerRadiusCircle()
    }

    func checkIfYouFollowing(userId: String) {
        if (Utilities.check_isCurrentUser_AlreadyFollowing_Broadcaster(broadcaster_username: userId)) {
            self.setFollowButtonToFollowing()
        }
        else {
            self.setFollowButtonToFollow()
        }
    }
    
    func setFollowButtonToFollow() {
        self.followButton.setTitle("Follow", for: .normal)
        self.followButton.backgroundColor = UIColor.lightGray
    }
    func setFollowButtonToFollowing() {
        self.followButton.setTitle("Following", for: .normal)
        self.followButton.backgroundColor = UIColor(red: 0.0, green: 0.6745, blue: 0.4000, alpha: 1.0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
