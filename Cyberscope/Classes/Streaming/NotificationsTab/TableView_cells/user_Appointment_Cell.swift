//
//  user_Appointment_Cell.swift
//  CyberScope
//
//  Created by Saad Furqan on 12/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate {
    func hasPerformedSwipe(passedInfo: String, cell: user_Appointment_Cell)
}

class user_Appointment_Cell: UITableViewCell
{
    var delegate: TableViewCellDelegate?
    var originalCenter = CGPoint()
    var isSwipeSuccessful = false
    var isSwipeLeft = false
    var buttonViewOriginalCenter = CGPoint()
    var leftSwipeCount = 0
    
    @IBOutlet weak var lblSwipeToRespond: UILabel!
    @IBOutlet weak var topViewutlet: UIView!
    
    @IBOutlet weak var image_broadcaster: UIImageView!
    @IBOutlet weak var broadcaster_name: UILabel!
    
    @IBOutlet weak var label_appointmentTime: UILabel!
    @IBOutlet weak var label_appointmentDate: UILabel!
    @IBOutlet weak var label_appointmentStatus: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        topViewutlet.layer.shadowColor = UIColor.black.cgColor
        topViewutlet.layer.shadowOpacity = 0.3
        topViewutlet.layer.shadowOffset = .zero
        topViewutlet.layer.shadowRadius = 3
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    func initialize()
    {
//        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
//        recognizer.delegate = self
//        topViewutlet.addGestureRecognizer(recognizer)
//        trailingConstraintActionViewOutlet.constant = -120
    }
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            originalCenter = topViewutlet.center
        }
        
        if recognizer.state == .changed {
            checkIfSwiped(recognizer: recognizer)
        }
        
        if recognizer.state == .ended {
            let originalFrame = CGRect(x: 0, y: topViewutlet.frame.origin.y, width: topViewutlet.bounds.size.width, height: topViewutlet.bounds.size.height)
            if isSwipeSuccessful, let delegate = self.delegate {
                if leftSwipeCount == 0 {
                    leftSwipeCount += 1
                    delegate.hasPerformedSwipe(passedInfo: "I performed a swipe", cell: self)
                    //moveViewBackIntoPlace(originalFrame: originalFrame)
                   
                    UIView.animate(withDuration: 0.3, animations: {
                        self.layoutIfNeeded()
                    })
                }
            } else {
                leftSwipeCount = 0
                moveViewBackIntoPlace(originalFrame: originalFrame)
                UIView.animate(withDuration: 0.5, animations: {
                    self.layoutIfNeeded()
                })
            }
        }
        
    }
    func checkIfSwiped(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.topViewutlet)
        isSwipeSuccessful = recognizer.isLeft(theViewYouArePassing: self.topViewutlet)
        if isSwipeSuccessful {
            if leftSwipeCount == 0 {
                self.topViewutlet.center = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y)
            }
        }
        print(isSwipeSuccessful)
    }
    func moveViewBackIntoPlace(originalFrame: CGRect) {
        UIView.animate(withDuration: 0.2, animations: {self.topViewutlet.frame = originalFrame})
    }
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
        }
        return false
    }
}

extension UIPanGestureRecognizer {
    func isLeft(theViewYouArePassing: UIView) -> Bool {
        let viewVelocity : CGPoint = velocity(in: theViewYouArePassing)
        if viewVelocity.x > 0 {
            print("Gesture went right")
            return false
        } else {
            print("Gesture went left")
            return true
        }
    }
}
