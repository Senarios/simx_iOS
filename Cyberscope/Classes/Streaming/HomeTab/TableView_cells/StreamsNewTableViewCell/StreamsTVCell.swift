//
//  StreamsTVCell.swift
//  SimX
//
//  Created by Salman on 05/10/2020.
//  Copyright © 2020 Agilio. All rights reserved.
//

import UIKit

class StreamsTVCell: UITableViewCell {
    
    //MARK: - IBOutlets Image views
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var imgJob: UIImageView!
    @IBOutlet weak var image_thumbnail: UIImageView!
    
    @IBOutlet weak var label_viewers: UILabel!
    @IBOutlet weak var broadcast_name: UILabel!
    @IBOutlet weak var broadcaster_name: UILabel!
    @IBOutlet weak var lblJobDescriptionUrl: UILabel!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var lblSwipeToApply: UILabel!
    @IBOutlet weak var viewRate: UIView!
    @IBOutlet weak var viewName: UIView!
    
    //MARK: - IBOutlets UIViews
    @IBOutlet weak var redContainer: UIView!
    @IBOutlet weak var viewTags: UIView!
    
    @IBOutlet weak var tagsViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
      
        viewMain.layer.shadowColor = UIColor.black.cgColor
        viewMain.layer.shadowOpacity = 0.3
        viewMain.layer.shadowOffset = .zero
        viewMain.layer.shadowRadius = 3

        viewRate.layer.cornerRadius = viewRate.frame.height / 2
        viewRate.layer.shadowColor = UIColor.black.cgColor
        viewRate.layer.shadowOpacity = 0.3
        viewRate.layer.shadowOffset = .zero
        viewRate.layer.shadowRadius = 2
        
        viewName.layer.cornerRadius = viewName.frame.height / 2
        viewName.layer.shadowColor = UIColor.black.cgColor
        viewName.layer.shadowOpacity = 0.3
        viewName.layer.shadowOffset = .zero
        viewName.layer.shadowRadius = 2
        
        setupLabelTap()
    }

}

//MARK: - Class Methods
extension StreamsTVCell {
    
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
