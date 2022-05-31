//
//  VideoCVsCell.swift
//  SimX
//
//  Created by APPLE on 01/07/2020.
//  Copyright © 2020 Agilio. All rights reserved.
//

import UIKit

protocol VideoCVCellDelegate: class {
    func playCVVideo(videoCV: String)
    func applyCVideo(indexPath : IndexPath)
}

class VideoCVsCell: UITableViewCell {

    @IBOutlet weak var lblVideoTitle: UILabel!
    @IBOutlet weak var imgVideoThumb: UIImageView!
    @IBOutlet weak var playVideoImg : UIImageView!
    @IBOutlet weak var applyButton : UIButton!
    var videoCV: String = ""
    
    var cellDelegate: VideoCVCellDelegate?
    var index : IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playVideoImg.isUserInteractionEnabled = true
        applyButton.layer.cornerRadius = 6
        playVideoImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPlay)))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @objc func didTapPlay(){
        self.cellDelegate?.playCVVideo(videoCV: self.videoCV)
    }

    @IBAction func playVideoClicked(_ sender: UIButton) {
        

        self.cellDelegate?.applyCVideo(indexPath: index)
        
        
        
    }
}
