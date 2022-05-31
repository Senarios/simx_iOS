//
//  RatingTableViewCell.swift
//  SimX
//
//  Created by Senarios on 22/06/2021.
//  Copyright © 2021 Agilio. All rights reserved.
//

import UIKit

class RatingTableViewCell: UITableViewCell {

    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var imgReviewer: UIImageView!
    @IBOutlet weak var lblNameReviewer: UILabel!
    @IBOutlet weak var txtReview: UITextView!
    @IBOutlet weak var viewRating: StarRatingView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell()
    {
        viewMain.layer.shadowColor = UIColor.black.cgColor
        viewMain.layer.shadowOpacity = 0.3
        viewMain.layer.shadowOffset = .zero
        viewMain.layer.shadowRadius = 3
        
        viewMain.layer.cornerRadius = 5
        viewMain.clipsToBounds = true
        
        imgReviewer.layer.cornerRadius = imgReviewer.frame.height / 2
        imgReviewer.clipsToBounds = true
        
        txtReview.isEditable = false
        txtReview.isSelectable = false
    }
    
    func populateCell(name: String,rate: Int,review: String,picture: String)
    {
        self.lblNameReviewer.text = name
        self.viewRating.rating = Float(rate)
        if(review == "null")
        {
            self.txtReview.text = ""
        }
        else
        {
            self.txtReview.text = review
        }
        let url = Utilities.getUserImage_URL(username: picture)
        self.imgReviewer.sd_setImage(with: url, placeholderImage: UIImage(named: Constants.imagesName.broadcaster_image), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })
    }
}
