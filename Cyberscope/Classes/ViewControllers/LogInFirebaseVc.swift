//
//  LogInFirebaseVc.swift
//  SimX
//
//  Created by Hashmi on 17/03/2022.
//  Copyright © 2022 Agilio. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAuth
import Alamofire
import SwiftyJSON
import CoreLocation
import MBProgressHUD

class LogInFirebaseVc: UIViewController, get_Users_Delegate, get_UserData_Delegate, Add_Or_Update_User_Delegate, UserDetailDelegate, UpdateUser_FCM_Protocol, UserStatusDelegate {
    func Add_Or_Update_User_ResponseSuccess(userName: String) {
        Utilities.hide_ProgressHud(view: self.view)
        print("\n Add_Or_Update_User_ResponseSuccess called ... \n")
        
        CurrentUser.setCurrentUser_UserDefaults(user: self.user_toCreate!)
        CurrentUser.setCurrentUserStatus_as_Login()
        
        CurrentUser.set_CurrentDevice_Arn()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute: {
            AppDelegate.shared_instance.setStreamBoardInitialViewControllerToRoot()
        })
    }
    
    func Add_Or_Update_User_ResponseError(error: NSError) {
        Utilities.hide_ProgressHud(view: self.view)
        print("\n Add_Or_Update_User_ResponseError called ... AND Error = \(error.localizedDescription) \n")
    }
    
   
    
   
    
 
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var termMainView: UIView!
    @IBOutlet weak var termTextView: UITextView!
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    
    @IBOutlet weak var termLbl: UILabel!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    //MARK: Buttons
    
    
    @IBOutlet weak var btnShowPassword: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBAction func loginBtn(_ sender: Any) {
        if emailTf.text?.isEmpty == true{
            Toast(text: "Enter your email").show()
        }else if passwordTf.text?.isEmpty == true{
            Toast(text: "Enter your password").show()
        }else{
            if emailTf.text?.isValidateEmail() == true{
                fireBaseEmailCheck(email: emailTf.text!, password: passwordTf.text!)
            }else{
                Toast(text: "Invalid Email").show()
            }
        }
    }
    @IBOutlet weak var forgetPassBtn: UIButton!
    @IBAction func forgetPassBtn(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ForgetPassVcN") as? ForgetPassVcN
        vc!.modalPresentationStyle = .fullScreen
        present(vc!, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var signUpBtn: UIButton!
    @IBAction func signUpBtn(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SignUpFirebaseVc") as? SignUpFirebaseVc
        vc!.user_DataObj.name = "riz"
        vc!.modalPresentationStyle = .fullScreen
        present(vc!, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var agreeBtn: UIButton!
    @IBAction func agreeBtn(_ sender: Any) {
        termMainView.isHidden = true
    }
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBAction func cancelBtn(_ sender: Any) {
        termMainView.isHidden = true
    }
    
    @IBAction func showPassBtn(_ sender: Any) {
        isChecked = !isChecked
        if isChecked {
            passwordTf.isSecureTextEntry = true
            if let image = UIImage(systemName: "eye.slash.fill") {
                btnShowPassword.setImage(image, for: .normal)
            }
        } else {
            passwordTf.isSecureTextEntry = false
            if let image = UIImage(systemName: "eye.fill") {
                btnShowPassword.setImage(image, for: .normal)
            }
        }
        
    }
    
    let user_DataObj = User()
    let currentUser = User()
    var isChecked = true
    var user_toCreate: User?
    var locationManager: CLLocationManager?
    //
    var topView_toShow_loader = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
                case .default:
                print("default")
                
                case .cancel:
                print("cancel")
                
                case .destructive:
                print("destructive")
                
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
        
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
        
        
        passwordTf.isSecureTextEntry = true
        myScrollView.bounces = false
        passwordTf.isSecureTextEntry = true
        termMainView.isHidden = true
        //MARK: Gestures
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        termLbl.isUserInteractionEnabled = true
        termLbl.addGestureRecognizer(tap)
        // removing link din screen
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.setUp_controls()
            if(CurrentUser.isUserLogedIn())
            {
                self.topView_toShow_loader.isHidden = false
                Utilities.show_ProgressHud(view: self.topView_toShow_loader)
                DataAccess.sharedInstance.get_UserData_using_UserName(userName: CurrentUser.get_User_username_fromUserDefaults(), resultDelegate: self)
                
            }
            else
            {
                self.topView_toShow_loader.isHidden = true
            }
        })
        if let image = UIImage(systemName: "eye.slash.fill") {
            btnShowPassword.setImage(image, for: .normal)
        }
        
        
    }
    

    func setUp_controls()
    {
        self.topView_toShow_loader.frame = self.view.bounds
        self.topView_toShow_loader.backgroundColor = UIColor.white
        
        self.view.addSubview(self.topView_toShow_loader)
        self.topView_toShow_loader.isHidden = true
        
        let config = LinkedinSwiftConfiguration(clientId: Constants.LinkedIn.clientId, clientSecret: Constants.LinkedIn.clientSecret, state: Constants.LinkedIn.state, permissions: Constants.LinkedIn.permissions, redirectUrl: Constants.LinkedIn.redirectUrl)
        SignInViewController.linkedinHelper = LinkedinSwiftHelper(configuration: config!, nativeAppChecker: nil, clients: nil, webOAuthPresent: self, persistedLSToken: nil)
    }
   
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loginBtn.layer.cornerRadius = 10
        loginBtn.layer.borderWidth =  2.0
        loginBtn.layer.borderColor =  UIColor(red: 61/255, green: 71/255, blue: 133/255, alpha: 1).cgColor
        emailView.layer.cornerRadius = 10
        emailView.layer.borderColor = UIColor.lightGray.cgColor
        emailView.layer.borderWidth = 0.5
        passwordView.layer.cornerRadius = 10
        passwordView.layer.borderColor = UIColor.lightGray.cgColor
        passwordView.layer.borderWidth = 0.5
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        BoardingViewController.isRequestFor_newLinkedIn_User = false
    }
    
    @objc func tapFunction(sender: UITapGestureRecognizer) {
        termMainView.isHidden = false
    }
    
    //MARK: Firebase Email Exist
    func fireBaseEmailCheck(email: String, password: String){
        Utilities.show_ProgressHud(view: self.view)
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { authResult, error in
            let id = authResult?.user.uid
            if id == nil{
                Utilities.hide_ProgressHud(view: self.view)
                Toast(text: "User Not Registered").show()
            }else{
                let authUser = Auth.auth().currentUser
                if(authUser!.isEmailVerified){
                    print("Email Verified ....")
                    DataAccess.sharedInstance.get_UserData_using_UserName(userName: id ?? "", resultDelegate: self)
                }
                else{
                    Utilities.hide_ProgressHud(view: self.view)
                    print("Email not Verified ....")
                    Toast(text: "Email not Verified! Kindly go to your Email Inbox and verify email before login ...").show()
                }
            }
            
        })
    }
    
//
//    }
    
    func userIsSignedInSuccess(_ bSignedIn: Bool, message: String?) {
        Utilities.hide_ProgressHud(view: self.view)
        print(bSignedIn, message)
    }
    
    func userIsSignedOut() {
        print("nothing")
    }
    
    func setRecievedUserStatus(_ status: Bool, statusString: String, userData: User) {
        print(status, statusString, userData)
        
        
        UserDefaults.standard.set(userData.skills, forKey: "type")
        
        let vc = UIStoryboard(name: "StreamBoard", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainTabBarVC") as? MainTabBarVC
        vc?.modalPresentationStyle = .fullScreen
        present(vc!, animated: true, completion: nil)
    }
    
    func dataAccessError(_ error: NSError?) {
        print(error)
    }
    func getUsers_Data_ResponseSuccess(users: [User]) {
        print(users)
    }
    
    func getUsers_Data_ResponseError(_ error: NSError?) {
        print(error)
    }
    func get_Users_Success(_ users: [User]) {
      
        //self.User(json: users)
        print(users)
//        UserDefaults.standard.set(users, forKey: "resource")
        Utilities.hide_ProgressHud(view: self.view)

    }

    
    func get_Users_Error(_ error: NSError?) {
        print(error)
    }
   
    func login_to_QB(userLogin: String, password: String)
    {
        QBRequest.logIn(withUserLogin: userLogin, password: password, successBlock:{ r, user in
            
            QBChat.instance.connect(withUserID: user.id, password: user.password!, completion: { (error) in
                
                if error != nil {
                    print("\n Got an error while connecting with QB chat && error = \(String(describing: error?.localizedDescription)) \n")
                }
                
                print("\n Successfully LogIn to QB chat ... \n")
                Utilities.hide_ProgressHud(view: self.topView_toShow_loader)
                CurrentUser.setCurrentUserStatus_as_Login()
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute: {
                    self.topView_toShow_loader.isHidden = true
                    AppDelegate.shared_instance.setStreamBoardInitialViewControllerToRoot()
                })
                
            })
            
        }, errorBlock: { (error) -> Void in
            
            Utilities.hide_ProgressHud(view: self.topView_toShow_loader)
            self.topView_toShow_loader.isHidden = true
            print("\n Login to QB failed with error = \(String(describing: error))\n")
            
            let e = Utilities.getQB_ErrorMessage_andTitle_fromErrorCode(error_StatusCode: error.status.rawValue)
            Alert.showAlertWithMessageAndTitle(message: e.message, title: e.title)
        })
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
    
    func updated_FCM_Response(isSuccess: Bool , error: String, id: Int)
    {
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
    
    
    func get_UserData_ResponseSuccess(isExist: Bool, requiredUser: User){
        print("\n get_UserData_ResponseSuccess called ... \n")
        
        
        print(requiredUser.username)        
        UserDefaults.standard.set(requiredUser.username, forKey: Constants.CurrentUser_UserDefaults.CurrentUser_username)
        UserDefaults.standard.set(requiredUser.username, forKey: "NONE")
        UserDefaults.standard.set(requiredUser.link, forKey: "NOLINK")
        UserDefaults.standard.set(requiredUser.broadcasts, forKey: "NOBROAD")
        
        
        if(isExist)
        {
            CurrentUser.setCurrentUser_UserDefaults(user: requiredUser)
            CurrentUser.Current_UserObject = requiredUser
            print(requiredUser.email, Constants.QuickBlox.QB_User_Default_Password)
            self.login_to_QB(userLogin: requiredUser.email, password: Constants.QuickBlox.QB_User_Default_Password)
        }
        else
        {
            self.topView_toShow_loader.isHidden = true
        }
    }
    func get_UserData_ResponseError(_ error: NSError?) {
        print(error)
        self.topView_toShow_loader.isHidden = true
    }
    
    
}

extension String {
    
    func isValidateEmail() -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
}

extension LogInFirebaseVc: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                }
            }
        }
    }
}
