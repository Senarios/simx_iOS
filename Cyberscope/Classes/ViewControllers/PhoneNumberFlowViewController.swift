//
//  PhoneNumberFlowViewController.swift
//  CyberScope
//
//  Created by Salman on 09/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD

class PhoneNumberFlowViewController: UIViewController {

    // MARK: - Outlets
    
    //view Containers
    
    @IBOutlet weak var PhoneNumberView: UIView!
    @IBOutlet weak var otpView: UIView!
    
    // PhoneNumber View
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func selectCountryButtonTapped(_ sender: UIButton) {
        self.selectCountryAction()
    }
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        self.continueAction()
    }
    
    // OTP View
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    @IBAction func resendCode(_ sender: UIButton) {
        self.resendOTP()
    }
    
    @IBAction func confirmCode(_ sender: UIButton) {
        self.confirmOTP()
    }
    // Close View
    @IBAction func closeOrDismiss(_ sender: UIButton) {
        
        self.dismiss(animated: false, completion: nil)
    }
    
    
    // MARK: - Class Variables
    var otpSent = ""
    
    var isComingFrom_SignUpVC: Bool = false
    var isComingFrom_SignInVC: Bool = false
    
    var user_toCheck: User = User()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.otpView.isHidden = true
        self.loginButton.setCornerRadiusCircle()
        self.continueButton.setCornerRadiusCircle()
    }
    
    // MARK: - Otp Sending Mechanism
    func sendOTPApiHit() {
        
        let codeMessage = self.randomNumberWith(digits:6)
        let phoneNumber = "\(countryCodeTextField.text!)\(mobileNumberTextField.text!)"
        self.otpSent = "\(codeMessage)" // -> otpSent is saved locally in string format
        let urlString = "https://web.scottishhealth.live/picture/sms.php?number=\(phoneNumber)&message=\(codeMessage)"
        //"https://web.simx.tv/picture/sms.php?number=\(phoneNumber)&message=\(codeMessage)"
        print("\n", urlString)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        //request.httpBody = 
        // insert json data to the request
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        { data, response, error in
            
            if error != nil {
                print("Error -> \(error)")
                return
            }
            do {
                let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                print("Response data \(result)")
                
//                let msg = result["message"] as! String
                let statusVal = result["status"] as! Bool
//                print("Printing Response message = \(msg)", "and Status = \(statusVal)")
                
                if (!statusVal) // || msg == "file not found")
                {
                    return
                }
                else {
                    
                }
            } catch {
                print("Error -> \(error)")
            }
        }
        task.resume()
    }
    
    // MARK: - Genrate Random Code
    
    func randomNumberWith(digits:Int) -> Int {
        let min = Int(pow(Double(10), Double(digits-1))) - 1
        let max = Int(pow(Double(10), Double(digits))) - 1
        return Int(Range(uncheckedBounds: (min, max)))
    }
    
    // MARK: - Button Actions
    func selectCountryAction() {
        
    }
    
    func continueAction() {
        
        if (self.mobileNumberTextField.text! == "") {
            let messageToast = Toast(text: "Please enter mobile number" + "!", duration: Delay.short)
            messageToast.show()
        }
        else if ((self.mobileNumberTextField.text?.characters.count)! < 10) {
            let messageToast = Toast(text: "Invalid mobile number" + "!", duration: Delay.short)
            messageToast.show()
        }
        else {
            self.sendOTPApiHit()
            self.instructionsLabel.text = "Enter 6-digit Code you just recieved on you number \(countryCodeTextField.text!)\(mobileNumberTextField.text!)"
        
            self.otpView.isHidden = false
            print("\n OTP is : \(self.otpSent) \n")
            let messageToast = Toast(text: "OTP is : \(self.otpSent)", duration: Delay.short)
            messageToast.show()
        }
    }
    
    // MARK: - Confirm Code
    
    func resendOTP() {
        self.sendOTPApiHit()
    }
    
    func confirmOTP()
    {
        if(self.otpTextField.text! == self.otpSent)
        {
            // show Shimmer loader Here
            self.checkNumberAvailability()
        }
        else {
            let messageToast = Toast(text: "Incorrect code, please try again" + "!", duration: Delay.short)
            messageToast.show()
        }
    }

    
    // MARK: - Check Number Avilability
    
    func checkNumberAvailability()
    {
        let str = "\(self.countryCodeTextField.text!)\(self.mobileNumberTextField.text!)"
        let phoneNumber = String(str.dropFirst())
        print("\n 00\(phoneNumber)")
        
        self.user_toCheck.username = "00\(phoneNumber)"
        Utilities.show_ProgressHud(view: self.view)
        
        let sessionObject = DataAccess.sharedInstance
        sessionObject.getUserWithPhoneNumber(self.user_toCheck.username, resultDelegate: self as UserStatusDelegate)
    }
    
    // MARK: - Memory Warnings
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == Constants.Segues.PhoneNumberVC_to_MoreUserDetails1VC)
        {
            let nextVC = segue.destination as! MoreUserDetails1ViewController
           // nextVC.user_toCreate = self.user_toCheck
            //MARK: Riz Change
            nextVC.newObj = self.user_toCheck
        }
    }
    
}

extension PhoneNumberFlowViewController: UserStatusDelegate {
    
    // MARK: - UserStatusDelegate Methods
    
    func recievedUserStatus(_ status: Bool, statusString: String, requiredUser: User)
    {
        Utilities.hide_ProgressHud(view: self.view)
        print("\n recievedUserStatus called ... \n")
        
        if (status)
        {
            self.user_toCheck = requiredUser
            CurrentUser.setCurrentUser_UserDefaults(user: requiredUser)
            CurrentUser.setCurrentUserStatus_as_Login()
            
            CurrentUser.set_CurrentDevice_Arn()
            
            AppDelegate.shared_instance.setStreamBoardInitialViewControllerToRoot()
        }
        else
        {
//            let viewController2 = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "MoreUserDetails1ViewController") as! MoreUserDetails1ViewController
//            self.present(viewController2, animated: false, completion: nil)
            
            self.performSegue(withIdentifier: Constants.Segues.PhoneNumberVC_to_MoreUserDetails1VC, sender: self)
        }
    }
    
    func dataAccessError(_ error:NSError?)
    {
        Utilities.hide_ProgressHud(view: self.view)
        print("\n dataAccessError called ... \n")
    }
}

extension Int {
    
    init(_ range: Range<Int> ) {
        let delta = range.lowerBound < 0 ? abs(range.lowerBound) : 0
        let min = UInt32(range.lowerBound + delta)
        let max = UInt32(range.upperBound   + delta)
        self.init(Int(min + arc4random_uniform(max - min)) - delta)
    }
}
