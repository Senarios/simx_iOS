//
//  SignUpFirebaseVc.swift
//  SimX
//
//  Created by Hashmi on 17/03/2022.
//  Copyright © 2022 Agilio. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAuth
import Firebase
import FirebaseDatabase
import CloudKit
import MBProgressHUD

class SignUpFirebaseVc: UIViewController, UITextFieldDelegate, RegistrationDelegate, SignUpUser_Delegate, UserDetailDelegate, SignInDelegate, UpdateUser_FCM_Protocol, UserStatusDelegate {
    func updated_FCM_Response(isSuccess: Bool, error: String, id: Int) {
        MBProgressHUD.hide(for: self.view, animated: true)
        
        if isSuccess
        {
            if id != 0 {
                print("Updated FCM User id = \(id)")
                CurrentUser.Current_UserObject.arn = CurrentUser.updated_FCM
                print("\n\t\tNew LogIn User Details")
                CurrentUser.printCurrentUser_Details(user: CurrentUser.Current_UserObject)
                CurrentUser.setCurrentUser_UserDefaults(user: CurrentUser.Current_UserObject)
            }
            else {
                print("Failed to Update FCM")
            }
        }
        else
        {
            let messageToast = Toast(text: error, duration: Delay.short)
            messageToast.show()
        }
    }
    
   
    
    @IBOutlet weak var myScrollView: UIScrollView!
    
    @IBOutlet weak var termLbl: UILabel!
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var confirmPassTf: UITextField!
    //MARK: Views
    
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var cPasswordView: UIView!
    
    @IBOutlet weak var termMainView: UIView!
    @IBOutlet weak var termTextView: UITextView!
    
    @IBOutlet weak var btnShowConfirmPassword: UIButton!
    @IBOutlet weak var btnShowEnterPassword: UIButton!
    @IBAction func passwordShowBtn(_ sender: Any) {
        isChecked = !isChecked
        if isChecked {
            passwordTf.isSecureTextEntry = true
            if let image = UIImage(systemName: "eye.slash.fill") {
                btnShowEnterPassword.setImage(image, for: .normal)
            }
            
        } else {
            passwordTf.isSecureTextEntry = false
            if let image = UIImage(systemName: "eye.fill") {
                btnShowEnterPassword.setImage(image, for: .normal)
            }
        }
        
    }
    @IBAction func cPasswordShowBtn(_ sender: Any) {
        isChecked = !isChecked
        if isChecked {
            confirmPassTf.isSecureTextEntry = true
            if let image = UIImage(systemName: "eye.slash.fill") {
                btnShowConfirmPassword.setImage(image, for: .normal)
            }
        } else {
            confirmPassTf.isSecureTextEntry = false
            if let image = UIImage(systemName: "eye.fill") {
                btnShowConfirmPassword.setImage(image, for: .normal)
            }
        }
        
    }
    @IBOutlet weak var checkBoxBtn: UIButton!
    @IBAction func checkBoxBtn(_ sender: Any) {
//        if checkBx{
//            checkBoxImgView.image = UIImage(named: "checkbox")
//            checkBoxBtn.titleLabel?.text = ""
//            checkBx = false
//        }else{
//            checkBoxImgView.image = UIImage(named: "checkbox_empty")
//            checkBoxBtn.titleLabel?.text = ""
//            checkBx = true
//        }
        if checkBx {
            checkBoxImgView.image = UIImage(named: "checkbox")
            checkBx = false
            checkString = "n"
        } else {
            checkBoxImgView.image = UIImage(named: "checkbox_empty")
            checkBx = true
            checkString = "y"
        }
        
        
    }
    
    
    @IBOutlet weak var nextBtn: UIButton!
    @IBAction func nextBtn(_ sender: Any) {
        
        
        let password = passwordTf.text!
        let confirmPassword = confirmPassTf.text!
        
        if nameTf.text?.isEmpty == true{
            Toast(text: "Enter your name").show()
        }else if emailTf.text?.isEmpty == true{
            Toast(text: "Enter your email").show()
        }
//        else if passwordTf.text?.isEmpty == true{
//            Toast(text: "Enter your password").show()
//        }
        else if !password.isValidPassword(){
            Toast(text: "Password must have minimum 8 characters at least 1 Uppercase Alphabet, 1 Lowercase Alphabet and 1 Number").show()
        }
        else if confirmPassTf.text?.isEmpty == true{
            Toast(text: "Enter your password again should not empty").show()
        }else if confirmPassword != password {
            Toast(text: "Password and Re-enter password should be same ").show()
        }
        else if checkString == "y"{
            Toast(text: "Accept Terms and Conditions to continue").show()
        }else{
            
            //isValidateEmail
            if emailTf.text?.isValidateEmail() == true{
                if passwordTf.text == confirmPassTf.text{
                    emailCheck(email: emailTf.text!, password: passwordTf.text!)
                }else{
                    Toast(text: "Password don't match").show()
                    return
                }
            }else{
                Toast(text: "Invalid Email").show()
                return
            }
        }
    }

    @IBOutlet weak var loginBtn: UIButton!
    @IBAction func loginBtn(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    
    @IBOutlet weak var agreeBtn: UIButton!
    @IBAction func agreeBtn(_ sender: Any) {
        termMainView.isHidden = true
    }
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBAction func cancelBtn(_ sender: Any) {
        termMainView.isHidden = true
    }
    
    @IBOutlet weak var checkBoxImgView: UIImageView!
    
    var newValue = ""
    let user_DataObj = User()
    var checkBx = false
    var checkString = "y"
    var isChecked = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        passwordTf.isSecureTextEntry = true
        confirmPassTf.isSecureTextEntry = true
        myScrollView.bounces = false
        termMainView.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        termLbl.isUserInteractionEnabled = true
        termLbl.addGestureRecognizer(tap)
        
        if let image = UIImage(systemName: "eye.slash.fill") {
            btnShowEnterPassword.setImage(image, for: .normal)
        }
        if let image = UIImage(systemName: "eye.slash.fill") {
            btnShowConfirmPassword.setImage(image, for: .normal)
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nextBtn.layer.cornerRadius = 10
        nextBtn.layer.borderWidth =  2.0
        nextBtn.layer.borderColor =  UIColor(red: 61/255, green: 71/255, blue: 133/255, alpha: 1).cgColor
        checkBoxBtn.titleLabel?.textColor = .clear
        nameView.layer.cornerRadius = 10.0
        nameView.layer.borderWidth = 0.5
        nameView.layer.borderColor = UIColor.lightGray.cgColor
        emailView.layer.cornerRadius = 10.0
        emailView.layer.borderWidth = 0.5
        emailView.layer.borderColor = UIColor.lightGray.cgColor
        passwordView.layer.cornerRadius = 10.0
        passwordView.layer.borderWidth = 0.5
        passwordView.layer.borderColor = UIColor.lightGray.cgColor
        cPasswordView.layer.cornerRadius = 10.0
        cPasswordView.layer.borderWidth = 0.5
        cPasswordView.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    
    //FCM
    func recievedUserStatus(_ status: Bool, statusString: String, requiredUser: User)
    {
        MBProgressHUD.hide(for: self.view, animated: true)
        if status
        {
            if statusString == Constants.accountStatus.verified
            {
                self.LogedIn_User_successfully(userData: requiredUser)
            }
            else if statusString == Constants.accountStatus.unverified
            {
                let messageToast = Toast(text: "Please wait for Your account to be verfied by Admin.", duration: Delay.short)
                messageToast.show()
                
                SignInViewController.LogOut_from_Twitter()
                SignInViewController.LogOut_from_Facebook()
                SignInViewController.LogOut_from_LinkedIn()
            }
            else
            {
                let messageToast = Toast(text: "No status received against this account. Try again!", duration: Delay.short)
                messageToast.show()
                
                SignInViewController.LogOut_from_Twitter()
                SignInViewController.LogOut_from_Facebook()
                SignInViewController.LogOut_from_LinkedIn()
            }
        }
        else
        {
           
        }
    }
    
    func LogedIn_User_successfully(userData: User)
    {
        CurrentUser.setCurrentUserStatus_as_Login()
        CurrentUser.printCurrentUser_Details(user: userData)
        CurrentUser.Current_UserObject = userData
        CurrentUser.setCurrentUser_UserDefaults(user: CurrentUser.Current_UserObject)
        CurrentUser.updated_FCM = "\(CurrentUser.getCurrentUser_FCM())"
        CurrentUser.set_CurrentDevice_Arn()
        
        
        
        
        print("At the time of Login,Updated FCM = \(CurrentUser.updated_FCM)")
        self.updateUserFCM(targetUser: userData, newFCM: CurrentUser.updated_FCM)
        
//        let messageToast = Toast(text: " Login Successfully ", duration: Delay.short)
//        messageToast.show()
        
        print("Before Move to next View ... printing current user object")
        CurrentUser.printCurrentUser_Details(user: CurrentUser.Current_UserObject)
        
        self.moveToNextView()
    }
    
   func moveToNextView() {
        if(StreamsListViewController.isComingFrom_PlayList_ViewController)
        {
            if StreamsListViewController.videoStreamingController == nil
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let streamingViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                StreamsListViewController.videoStreamingController = streamingViewController
            }
            self.present(StreamsListViewController.videoStreamingController, animated: true, completion: nil)
        }
        else
        {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
//            let secondViewController = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllers.containerView) as! containerViewViewController
//            self.present(secondViewController, animated: true, completion: nil)
        }
    }
    
    
    func updateUserFCM(targetUser: User, newFCM: String)
    {
        print("new FCM = \(newFCM)")
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let user = targetUser
        user.arn = newFCM
        let sessionObject = DataAccess.sharedInstance
        
        sessionObject.UpdateUser_FCM(user, delegate: self as UpdateUser_FCM_Protocol)
    }
    
    
    
    @objc func tapFunction(sender: UITapGestureRecognizer) {
        termMainView.isHidden = false
    }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        checkBx = !checkBx
        
        if checkBx{
            checkBoxImgView.image = UIImage(named: "checkbox")
            checkBx = false
        }else{
            checkBoxImgView.image = UIImage(named: "checkbox_empty")
            checkBx = true
        }
        
    }
//    
//    //MARK: Save firebase real time data
//    func saveFireBaseData(){
//        self.ref.child("UserNames").childByAutoId().setValue("riz")
//    }
    
    //MARK: Firebase Email Exist
    
    func emailCheck(email: String, password: String) {

        Auth.auth().fetchSignInMethods(forEmail: email) { res, error in
            print(res, error)
            if res != nil{
                Toast(text: "email is alreay in use").show()
            }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MoreUserDetails1ViewController") as? MoreUserDetails1ViewController
                
                self.user_DataObj.name = self.user_DataObj.name.appending(self.nameTf.text ?? "")
                
                self.user_DataObj.email = self.user_DataObj.name.appending(self.emailTf.text ?? "")
                self.user_DataObj.email = self.user_DataObj.password.appending(self.passwordTf.text ?? "")
                self.user_DataObj.setUserDefaults()
                
                UserDefaults.standard.set(self.emailTf.text ?? "", forKey: "sEmail")
                UserDefaults.standard.set(self.passwordTf.text ?? "", forKey: "sPass")
                UserDefaults.standard.set(self.nameTf.text ?? "", forKey: "sName")
                
                vc!.newObj.name = self.nameTf.text ?? ""
                vc!.newObj.email = self.emailTf.text ?? ""
                vc!.newObj.password = self.passwordTf.text ?? ""
                
                vc!.modalPresentationStyle = .fullScreen
                self.present(vc!, animated: true, completion: nil)
            }
        }
        
//
//        Auth.auth().createUser(withEmail: email, password: password ) { user, error in
//            if let x = error {
//                let err = x as NSError
//                switch err.code {
//                case AuthErrorCode.wrongPassword.rawValue:
//                    print("wrong password")
//                case AuthErrorCode.invalidEmail.rawValue:
//                    print("invalid email")
//                case AuthErrorCode.accountExistsWithDifferentCredential.rawValue:
//                    print("accountExistsWithDifferentCredential")
//                case AuthErrorCode.emailAlreadyInUse.rawValue: //<- Your Error
//                    print("email is alreay in use")
//                default:
//                    print("unknown error: \(err.localizedDescription)")
//                }
//                //return
//            } else {
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MoreUserDetails1ViewController") as? MoreUserDetails1ViewController
//
//                UserDefaults.standard.set(self.emailTf.text ?? "", forKey: "email")
//                UserDefaults.standard.set(self.passwordTf.text ?? "", forKey: "password")
//
//
//                self.user_DataObj.name = self.nameTf.text ?? ""
//                self.user_DataObj.email = self.emailTf.text ?? ""
//                self.user_DataObj.password = self.passwordTf.text ?? ""
//
////                vc!.newObj.name = self.nameTf.text ?? ""
////                vc!.newObj.email = self.emailTf.text ?? ""
////                vc!.newObj.password = self.passwordTf.text ?? ""
//
//                vc!.modalPresentationStyle = .fullScreen
//                self.present(vc!, animated: true, completion: nil)
//            }
//
//
//        }
    }
    func userIsRegisteredSuccess(_ bSignedIn: Bool, message: String?) {
        print(bSignedIn, message)
    }
    func SignUpUser_Delegate_Response(isSuccess: Bool, error: String, id: Int) {
        print(isSuccess, error, id)
    }
    func setRecievedUserStatus(_ status: Bool, statusString: String, userData: User) {
        print(status, statusString, userData)
    }
    
    func dataAccessError(_ error: NSError?) {
        print(error)
    }
    
    func userIsSignedInSuccess(_ bSignedIn: Bool, message: String?) {
        print(message)
    }
    
    func userIsSignedOut() {
        print("nothing")
    }
}

