//
//  ForgetPassVcN.swift
//  SimX
//
//  Created by Hashmi on 22/03/2022.
//  Copyright © 2022 Agilio. All rights reserved.
//

import UIKit
import FirebaseAuth
import Toaster

class ForgetPassVcN: UIViewController {

    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var emailView: UIView!
    
    @IBOutlet weak var emailTf: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myScrollView.bounces = false
    }
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        emailView.layer.borderColor = UIColor.lightGray.cgColor
        emailView.layer.borderWidth = 1.0
        emailView.layer.cornerRadius = 10.0
        
        submitBtn.layer.borderColor = UIColor.purple.cgColor
        submitBtn.layer.borderWidth = 1.0
        submitBtn.layer.cornerRadius = 10.0
    }
    
    
    @IBAction func submitBtn(_ sender: Any) {
        
        if emailTf.text?.isEmpty == true{
            Toast(text: " Enter email ").show()
        }else{
            
            Utilities.show_ProgressHud(view: self.view)
            
            Auth.auth().sendPasswordReset(withEmail: emailTf.text!) { error in
                if error != nil{
                    Utilities.hide_ProgressHud(view: self.view)
                    let resetFailedAlert = UIAlertController(title: "Reset Failed", message: "Error: \(String(describing: error?.localizedDescription))", preferredStyle: .alert)
                    resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetFailedAlert, animated: true, completion: nil)
                }else {
                    Utilities.hide_ProgressHud(view: self.view)
                    let resetEmailSentAlert = UIAlertController(title: "Reset email sent successfully", message: "Check your email", preferredStyle: .alert)
                    resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetEmailSentAlert, animated: true, completion: nil)
                }
                
            }
        }
        
    }
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}
