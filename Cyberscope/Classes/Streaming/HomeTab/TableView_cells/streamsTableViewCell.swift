//
//  streamsTableViewCell.swift
//  CyberScope
//
//  Created by Saad Furqan on 05/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit

class streamsTableViewCell: UITableViewCell
{
    
//    @IBOutlet weak var imgJob: UIImageView!
//    @IBOutlet weak var redContainer: UIView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var image_thumbnail: UIImageView!
//    @IBOutlet weak var image_broadcaster: UIImageView!
    @IBOutlet weak var broadcast_name: UILabel!
    @IBOutlet weak var broadcaster_name: UILabel!
//    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var label_viewers: UILabel!
    @IBOutlet weak var broadcaster_name2: UILabel!
    //    @IBOutlet weak var deleteButton: UIButton!
//    @IBOutlet weak var shareButton: UIButton!
//    @IBOutlet weak var lblClients: UILabel!
//    @IBOutlet weak var viewTags: UIView!
    
    @IBOutlet weak var lblJobDescriptionUrl: UILabel!
    
    @IBOutlet weak var btnDeleteRequest: UIButton!
    var thisBroadcast: COVideo?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        viewMain.layer.shadowColor = UIColor.black.cgColor
        viewMain.layer.shadowOpacity = 0.3
        viewMain.layer.shadowOffset = .zero
        viewMain.layer.shadowRadius = 3

        
        
        setupLabelTap()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    fileprivate func setupLabelTap() {
        
        guard let _ = lblJobDescriptionUrl else { return }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openLinkInWeb))
        self.lblJobDescriptionUrl.isUserInteractionEnabled = true
        self.lblJobDescriptionUrl.addGestureRecognizer(tapGesture)
    }
    
    @objc func openLinkInWeb() {
        if let url = URL(string: lblJobDescriptionUrl.text ?? "") {
            if var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                if comps.scheme == nil {
                    comps.scheme = "http"
                }
                if let validUrl = comps.url {
                    UIApplication.shared.open(validUrl)
                }
            }
        }
    }
}
