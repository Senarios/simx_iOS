//
//  UIbuttonExt.swift
//  CyberScope
//
//  Created by Salman on 28/03/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit

extension UIButton {
    
    func sayHello() {
        print("Hello I am UIButton")
    }
    
    func setBGColorAndText(sText: String ,sColor: UIColor) {
        
        self.titleLabel?.text = sText
        self.backgroundColor = sColor
    }
    
    func setTextToMyButton(sText: String) {
        
        self.titleLabel?.text = sText
        self.titleLabel!.textAlignment = .center
    }
    
    func setCornerRadiusCircle() {
        
        self.layer.cornerRadius = self.frame.size.height/2.0
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.clear.cgColor
    }
    
    func setCornerRadisConst(with value:Int) {
        
        self.layer.cornerRadius = CGFloat(value)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.clear.cgColor
    }
    
//    override open func layoutSubviews() {
//        print("\n\n * * layoutSubviews called on me -> I am UIButton \n")
//    }
}

extension UILabel {
    func setCornerRadisConst(with value:Int) {
        
        self.layer.cornerRadius = CGFloat(value)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
    }
}
@IBDesignable extension UIButton {

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
