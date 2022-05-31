//
//  BoardingViewController.swift
//  CyberScope
//
//  Created by Salman on 28/03/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import Foundation
import Quickblox
import QuickbloxWebRTC
import LinkedinSwift
import MBProgressHUD
import Toaster
import FirebaseCore
import FirebaseAuth

class BoardingViewController: UIViewController, get_UserData_Delegate
{
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    var isUsingTwitter = false
    var isUsing_LinkedIn = false
    static var isRequestFor_newLinkedIn_User = false
    
    var topView_toShow_loader = UIView()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
            
        print("flow111Boardind view controller run")
        // Do any additional setup after loading the view.
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
    }
    
    func setUp_controls()
    {
        self.topView_toShow_loader.frame = self.view.bounds
        self.topView_toShow_loader.backgroundColor = UIColor.white
        
//        let img = UIImageView()
//        img.frame.size.width = 250
//        img.frame.size.height = 300
//        img.image = self.image_logo.image
//        img.center = self.topView_toShow_loader.center
        
//        self.topView_toShow_loader.addSubview(img)
        self.view.addSubview(self.topView_toShow_loader)
        self.topView_toShow_loader.isHidden = true
        
        let config = LinkedinSwiftConfiguration(clientId: Constants.LinkedIn.clientId, clientSecret: Constants.LinkedIn.clientSecret, state: Constants.LinkedIn.state, permissions: Constants.LinkedIn.permissions, redirectUrl: Constants.LinkedIn.redirectUrl)
        SignInViewController.linkedinHelper = LinkedinSwiftHelper(configuration: config!, nativeAppChecker: nil, clients: nil, webOAuthPresent: self, persistedLSToken: nil)
    }
    @IBAction func btnTermsAndConditionsClicked(_ sender: Any) {
//        if let url = URL(string: "https://www.h2startup.com/termsAndConditions.html") {
//            UIApplication.shared.open(url)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        BoardingViewController.isRequestFor_newLinkedIn_User = false
    }
    
    override func viewWillLayoutSubviews() {
        
//        self.loginButton.setCornerRadiusCircle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gotoStreamingStoryboard()
    {
        
        AppDelegate.shared_instance.setStreamBoardInitialViewControllerToRoot()
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
    
    // get_UserData_Delegate methods
    func get_UserData_ResponseSuccess(isExist: Bool, requiredUser: User)
    {
        print("\n get_UserData_ResponseSuccess called ... \n")
        
        if(isExist)
        {
            CurrentUser.setCurrentUser_UserDefaults(user: requiredUser)
            
            self.login_to_QB(userLogin: requiredUser.username, password: Constants.QuickBlox.QB_User_Default_Password)
        }
        else
        {
            self.topView_toShow_loader.isHidden = true
        }
    }
    
    func get_UserData_ResponseError(_ error: NSError?)
    {
        Utilities.hide_ProgressHud(view: self.topView_toShow_loader)
        self.topView_toShow_loader.isHidden = true
        print("\n get_UserData_ResponseError called ... AND Error = \(String(describing: error?.localizedDescription)) \n")
    }
    
    @IBAction func btnLoginWithLinkedIn_pressed(_ sender: Any) {
        //self.LinkedIn_LogIn_Tapped()
        let vc = storyboard?.instantiateViewController(withIdentifier: "LogInFirebaseVc") as? LogInFirebaseVc
        vc!.modalPresentationStyle = .fullScreen
        vc!.modalTransitionStyle = .crossDissolve
        present(vc!, animated: true, completion: nil)
    }
    
    //MARK:- Login Using LinkedIn
    
    func LinkedIn_LogIn_Tapped()
    {
        //SignInViewController.linkedinHelper?.
        
        if UserDefaults.standard.object(forKey: "LIAccessToken") != nil {
            print("\n Login success lsToken: \(UserDefaults.standard.value(forKey: "LIAccessToken") as! String) \n")
            self.isUsingTwitter = false
            self.isUsing_LinkedIn = true
            
            self.requestProfile()
            //let session = LISDKSessionManager.sharedInstance().session as? LISDKSession
        }
        else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            controller.accessDelegate = self
//            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        }
        return
    }
    
    func requestProfile()
    {
        Utilities.show_ProgressHud(view: self.view)
        
        if let accessToken = UserDefaults.standard.object(forKey: "LIAccessToken") {
            let targetURLString = "https://api.linkedin.com/v2/me"
            let request = NSMutableURLRequest(url: NSURL(string: targetURLString)! as URL)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            let session = URLSession(configuration: URLSessionConfiguration.default)
            
            // Make the request.
            let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
                // Get the HTTP status code of the request.
                if error != nil {
                    print("\n Error: \(error!.localizedDescription) \n")
                    Utilities.hide_ProgressHud(view: self.view)
                    Alert.showAlertWithMessageAndTitle(message: error!.localizedDescription, title: "ERROR")
                    return
                }
                let statusCode = (response as! HTTPURLResponse).statusCode
                
                if statusCode == 200 {
                    // Convert the received JSON data into a dictionary.
                    do {
                        let responseData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                        let dataDictionary = responseData as! Dictionary <String, Any>
                        SignInViewController.userLinkedInData = dataDictionary
                        
                        SignInViewController.userLinkedInData["id"] = String(describing: dataDictionary["id"]!)
                        SignInViewController.userLinkedInData["name"] = String(describing: dataDictionary["localizedFirstName"]!) + " " + String(describing: dataDictionary["localizedLastName"]!)
                        
                        //Toast(text: "User profile data fetched successfully!").show()
                        
                        self.getProfileEmail()
                    }
                    catch {
                        print("Could not convert JSON data into a dictionary.")
                    }
                }
            }
            
            task.resume()
        }
        return
    }
    
    func getProfileEmail() {
        if let accessToken = UserDefaults.standard.object(forKey: "LIAccessToken") {
            let targetURLString = "https://api.linkedin.com/v2/emailAddress?q=members&projection=(elements*(handle~))"
            let request = NSMutableURLRequest(url: NSURL(string: targetURLString)! as URL)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
                let statusCode = (response as! HTTPURLResponse).statusCode
                if (error != nil) {
                    print("\n Error: \(error!.localizedDescription) \n")
                    Utilities.hide_ProgressHud(view: self.view)
                    Alert.showAlertWithMessageAndTitle(message: error!.localizedDescription, title: "ERROR")
                    return
                }
                if statusCode == 200 {
                    do {
                        let responseData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                        let dataDictionary = responseData as! Dictionary <String, Any>
                        let emailResponse = (((dataDictionary["elements"] as! NSArray).firstObject as! [String: Any])["handle~"] as! [String: Any])["emailAddress"] as? String
                        if (emailResponse == nil || emailResponse == "") {
                            print("\n Error: \(error!.localizedDescription) \n")
                            Utilities.hide_ProgressHud(view: self.view)
                            Alert.showAlertWithMessageAndTitle(message: "email not found", title: "ERROR")
                            return
                        }
                        SignInViewController.userLinkedInData["email"] = emailResponse ?? "notfound"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                            Utilities.hide_ProgressHud(view: self.view)
                            self.check_isLinkedIn_Account_IdAlreadyExist()
                        })
                    }
                    catch {
                        print("Could not convert JSON data into a dictionary.")
                    }
                }
            }
            
            task.resume()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
       if(segue.identifier == Constants.Segues.SignInVC_to_MoreUserDetails1VC)
       {
           let nextVC = segue.destination as! MoreUserDetails1ViewController
           
           let user = User()
           
          if(BoardingViewController.isRequestFor_newLinkedIn_User)
           {
               user.username = "\(SignInViewController.userLinkedInData["id"] ?? "")"
               user.email = "\(SignInViewController.userLinkedInData["email"] ?? "")"
               user.name = "\(SignInViewController.userLinkedInData["name"] ?? "")"
           }
           //MARK: Riz Change
           //nextVC.user_toCreate = user
           nextVC.newObj = user
       }
    }
}

extension BoardingViewController: UserDetailDelegate, UserStatusDelegate, UpdateUser_FCM_Protocol, IsTwitter_Facebook_IdAlready_Exist_Delegate
{
    func setRecievedUserStatus(_ status: Bool, statusString: String, userData: User) {
        print("Login statusString = \(statusString)")
        
        MBProgressHUD.hide(for: self.view, animated: true)
        if status {
            if statusString == "verified"
            {
                self.LogedIn_User_successfully(userData: userData)
            }
            else
            {
                let messageToast = Toast(text: "Please wait for Your account to be verfied by Admin.", duration: Delay.short)
                messageToast.show()
                
                SignInViewController.LogOut_from_Twitter()
                SignInViewController.LogOut_from_Facebook()
                SignInViewController.LogOut_from_LinkedIn()
            }
        }
        else
        {
            self.presentAlertWithMessage(msg: "In-correct Email or password", field: 1)
        }
    }
    
    func dataAccessError(_ error: NSError?) {
        MBProgressHUD.hide(for: self.view, animated: true)
        self.presentAlertWithMessage(msg: (error?.description)!, field: 1, title: "Error")
    }
    
    func recievedUserStatus(_ status: Bool, statusString: String, requiredUser: User) {
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
            if(self.isUsing_LinkedIn)
            {
                self.check_isLinkedIn_Account_IdAlreadyExist()
            }
        }
    }
    
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
    
    func IsTwitter_Facebook_IdAlready_Exist_Respnse(_ isExist: Bool, statusString: String, requiredUser: User) {
        MBProgressHUD.hide(for: self.view, animated: true)
        
        if isExist
        {
//            if requiredUser.username == FBSDKAccessToken.current().userID {
//
//            }
//            if statusString == Constants.accountStatus.verified
//            {
//                self.LogedIn_User_successfully(userData: requiredUser)
//            }
//            else if statusString == Constants.accountStatus.unverified
//            {
//                self.showAlert("Message", message: "Please wait for Your account to be verfied by Admin.")
//
//                SignInViewController.LogOut_from_Twitter()
//                SignInViewController.LogOut_from_Facebook()
//                SignInViewController.LogOut_from_LinkedIn()
//            }
//            else
//            {
//                self.showAlert("Message", message: "No status received against this account. Try again!")
//
//                SignInViewController.LogOut_from_Twitter()
//                SignInViewController.LogOut_from_Facebook()
//                SignInViewController.LogOut_from_LinkedIn()
//            }
            if (requiredUser.link == nil || requiredUser.link == "" || requiredUser.link == "NA" || requiredUser.link == "No") {
                
                if(SignInViewController.isRequestFor_newTwitter_User || self.isUsingTwitter)
                {
                    let screenName = "\(SignInViewController.userTwitterData["screen_name"] ?? "NA")"
                    if (screenName == "NA") { requiredUser.link = screenName }
                    else { requiredUser.link = "https://twitter.com/" + screenName }
                }
                else if(BoardingViewController.isRequestFor_newLinkedIn_User || self.isUsing_LinkedIn)
                {
                    requiredUser.link = "\(SignInViewController.userLinkedInData["publicProfileUrl"] ?? "NA")"//publicProfileUrl
                }
                else
                {
                    requiredUser.link = "\(SignInViewController.userFacebookData["link"] ?? "NA")"//publicProfileUrl
                }
            }
            //
            CurrentUser.setCurrentUserStatus_as_Login()
            CurrentUser.printCurrentUser_Details(user: requiredUser)
            CurrentUser.Current_UserObject = requiredUser
            CurrentUser.setCurrentUser_UserDefaults(user: CurrentUser.Current_UserObject)
            CurrentUser.updated_FCM = "\(CurrentUser.getCurrentUser_FCM())"
            CurrentUser.set_CurrentDevice_Arn()
            self.updateUserFCM(targetUser: requiredUser, newFCM: CurrentUser.updated_FCM)
            CurrentUser.printCurrentUser_Details(user: CurrentUser.Current_UserObject)
            //
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute: {
                AppDelegate.shared_instance.setStreamBoardInitialViewControllerToRoot()
            })
        }
        else
        {
            if(self.isUsing_LinkedIn)
            {
                self.requestFor_newLinkedIn_User()
            }
        }
    }
    
    func Twitter_Facebook_Account_AccessError(_ error: String) {
        MBProgressHUD.hide(for: self.view, animated: true)
        self.presentAlertWithMessage(msg: error, field: 0)
    }
    
    func requestFor_newLinkedIn_User()
    {
        BoardingViewController.isRequestFor_newLinkedIn_User = true
        
        self.performSegue(withIdentifier: Constants.Segues.SignInVC_to_MoreUserDetails1VC, sender: self)
    }
    func presentAlertWithMessage(msg:String, field:Int)
    {
        let alertController: UIAlertController = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) { action -> Void in
            if field == 1 {
                //                self.emailTextField.becomeFirstResponder()
            }
            else {
                //                self.passwordTextField.becomeFirstResponder()
            }
        }
        
        alertController.addAction(cancelAction)
        //Present the AlertController
        self.present(alertController, animated: true, completion: nil)
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
    func check_isLinkedIn_Account_IdAlreadyExist()
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let sessionObject = DataAccess.sharedInstance
        
        if(SignInViewController.userLinkedInData["id"] != nil) {
            sessionObject.get_Facebook_Twitter_UserWith_accountID("\(SignInViewController.userLinkedInData["id"]!)", resultDelegate: self)
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
    
    func moveToNextView()
    {
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
    func presentAlertWithMessage(msg:String, field:Int, title: String = "Login")
    {
        let actionSheetController: UIAlertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) { action -> Void in
            if field == 1 {
//                self.emailTextField.becomeFirstResponder()
            }
            else {
//                self.passwordTextField.becomeFirstResponder()
            }
            //dismiss the action sheet
        }
        
        actionSheetController.addAction(cancelAction)
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
    }
}

extension BoardingViewController: MyLITokenRequestDelegate
{
    func success(accessToken: String) {
       
        print("\n Login success lsToken: \(UserDefaults.standard.value(forKey: "LIAccessToken") as! String) \n")
        self.isUsingTwitter = false
        self.isUsing_LinkedIn = true
        
        self.requestProfile()
    }
    
    func error(message: String) {
        print("\n User Cancelled the process... \n")
        Alert.showAlertWithMessageAndTitle(message: "You cancelled the LinkedIn-login process.", title: "CANCELLED!")
    }
}
