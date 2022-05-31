//
//  RatingView.swift
//  SimX
//
//  Created by Senarios on 23/06/2021.
//  Copyright © 2021 Agilio. All rights reserved.
//

import UIKit

class RatingView: UIView {

    @IBOutlet var viewMain: UIView!
    @IBOutlet weak var viewInner: UIView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var viewRating: StarRatingView!
    @IBOutlet weak var txtReview: UITextView!
    @IBOutlet weak var btnPostReview: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            commonInit()
        }
        
        func commonInit() {
            Bundle.main.loadNibNamed("RatingView", owner: self, options: nil)
            viewMain.frame = self.bounds
            viewMain.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            self.addSubview(viewMain)
            
            txtReview.delegate = self
            txtReview.text = "Type your review here..."
            txtReview.textColor = UIColor.gray
            
            btnPostReview.layer.cornerRadius = 5
            btnPostReview.clipsToBounds = true
            
            txtReview.layer.shadowColor = UIColor.black.cgColor
            txtReview.layer.shadowOpacity = 0.3
            txtReview.layer.shadowOffset = .zero
            txtReview.layer.shadowRadius = 3
            
            txtReview.layer.cornerRadius = 5
            txtReview.clipsToBounds = true
        }
}

extension RatingView: UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(textView == txtReview)
        {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
}
