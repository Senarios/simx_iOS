//
//  UIViewExt.swift
//  CyberScope
//
//  Created by Salman on 28/03/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import Foundation

import UIKit

extension UIView {
    
    func sayHelloV() {
        print("Hello I am UIView")
    }
    
    func setMyCornerRadiusCircle() {
        
        self.layer.cornerRadius = self.frame.size.height/2.0
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.clear.cgColor
    }
    
    func setMyCornerRadisConst(with value:Int) {
        
        self.layer.cornerRadius = CGFloat(value)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.clear.cgColor
    }
    
    func setMyCornerRadisConstColorGrey(with value:Int) {
        
        self.layer.cornerRadius = CGFloat(value)
        self.layer.borderWidth = 1
        self.layer.borderColor = Constants.appColors.colorGrey.cgColor
    }
    
    func setMyCornerRadisConstColorBlue(with value:Int) {
        
        self.layer.cornerRadius = CGFloat(value)
        self.layer.borderWidth = 1
        self.layer.borderColor = Constants.appColors.colorBlue.cgColor
    }
   
    func applyShadow(radius: CGFloat)
    {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = radius
        
    }
}
