//
//  jobCandidateCell.swift
//  SimX
//
//  Created by APPLE on 24/07/2020.
//  Copyright © 2020 Agilio. All rights reserved.
//

import UIKit

protocol jobCandidateCellDelegate: class {
    func selectJobOptions(jobId: Int)
}

class jobCandidateCell: UITableViewCell {
    var JobId: Int = -1

    @IBOutlet weak var viewBG: UIView!
    
    @IBOutlet weak var imgUser: UIImageView!
    
    @IBOutlet weak var lblUsername: UILabel!
    
    @IBOutlet weak var btnSelection: UIButton!
    
    @IBAction func selctionClicked(_ sender: Any) {
        cellDelegate!.selectJobOptions(jobId: self.JobId)
    }
    
    var cellDelegate: jobCandidateCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
