//
//  SignInViewController.swift
//  CyberScope
//
//  Created by Salman on 23/02/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toaster
import FBSDKCoreKit
import FBSDKLoginKit
import TwitterKit
import LinkedinSwift
import Quickblox




class SignInViewController: UIViewController, UserDetailDelegate, UserStatusDelegate, FBSDKLoginButtonDelegate, UpdateUser_FCM_Protocol, IsTwitter_Facebook_IdAlready_Exist_Delegate
{
    static var userFacebookData : [String:Any] = [:]
    static var userTwitterData : [String:Any] = [:]
    static var userLinkedInData : [String:Any] = [:]
    
    static var facebook_userData = User()
    static var twitter_userData = User()
    
    static var isRequestFor_newFacebook_User = false
    static var isRequestFor_newTwitter_User = false
    static var isRequestFor_newLinkedIn_User = false
    
    var isUsingTwitter = false
    var isUsing_LinkedIn = false
    
    @IBOutlet weak var buttonsContainerView: UIView!
    @IBOutlet var selfLoginWithFBButton: UIButton!
    @IBOutlet var selfLoginWithTWTRButton: UIButton!
    @IBOutlet weak var selfLoginLinkedInButton: UIButton!
    @IBOutlet weak var selfLoginPhoneNumberButton: UIButton!
    
    @IBOutlet weak var termsAndConditionsContainer: UIView!
    @IBOutlet weak var tAndCTextView: UITextView!
    
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func agreeConditionsAction(_ sender: UIButton) {
        self.termsAndConditionsContainer.isHidden = true
        self.performSegue(withIdentifier: Constants.Segues.SignInVC_to_MoreUserDetails1VC, sender: self)
    }
    
    @IBAction func cancelConditionsAction(_ sender: UIButton) {
        self.termsAndConditionsContainer.isHidden = true
        self.closeOrDismiss(sender)
    }
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBAction func facebookLoginButtonTapped(_ sender: UIButton) {
        
    }
    
    static var linkedinHelper: LinkedinSwiftHelper?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.agreeButton.setCornerRadisConst(with: 5)
        self.cancelButton.setCornerRadisConst(with: 5)
        
        // Do any additional setup after loading the view.
        self.setup_controls()
    }
    
    func setup_controls()
    {
        self.isUsingTwitter = false
        self.isUsing_LinkedIn = false
        
        //////self.addFaceBookButton()
        //////self.addTwitterButton()
        
        self.buttonsContainerView.setMyCornerRadisConst(with: 5)
        self.selfLoginLinkedInButton.setCornerRadisConst(with: 3)
        ////self.selfLoginPhoneNumberButton.setCornerRadisConst(with: 3)
        
        // set linkedIn herlper object
        let config = LinkedinSwiftConfiguration(clientId: Constants.LinkedIn.clientId, clientSecret: Constants.LinkedIn.clientSecret, state: Constants.LinkedIn.state, permissions: Constants.LinkedIn.permissions, redirectUrl: Constants.LinkedIn.redirectUrl)
        SignInViewController.linkedinHelper = LinkedinSwiftHelper(configuration: config!, nativeAppChecker: nil, clients: nil, webOAuthPresent: self, persistedLSToken: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // PhoneNumberVerification_ViewController.isForgotPasswordCase = false
        SignInViewController.isRequestFor_newTwitter_User = false
        SignInViewController.isRequestFor_newFacebook_User = false
        SignInViewController.isRequestFor_newLinkedIn_User = false
    }
    
    func addFaceBookButton() {
        
        let loginView : FBSDKLoginButton = FBSDKLoginButton()
        self.buttonsContainerView.addSubview(loginView)
        
        loginView.frame = selfLoginWithFBButton.frame
        loginView.readPermissions = ["public_profile", "email"]
        loginView.delegate = self as FBSDKLoginButtonDelegate
        
        // If we have an access token, then let's display some info
        
        if (FBSDKAccessToken.current() != nil)
        {
            // Display current FB premissions
            print (FBSDKAccessToken.current().permissions)
            
            if((FBSDKAccessToken.current()) != nil)
            {
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email"]).start(completionHandler:
                    { (connection, result, error) -> Void in
                        
                        if (error == nil)
                        {
                            print(result ?? "NO RESULT")
                            if let data = result as? [String:Any]
                            {
                                SignInViewController.userFacebookData = data
                            }
                        }
                        else
                        {
                            print(error?.localizedDescription)
                        }
                })
            }
        }
        
        //loginView.setCornerRadiusCircle()
    }
    
    func addTwitterButton()
    {
        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            
            if (session != nil)
            {
                self.isUsingTwitter = true
                self.isUsing_LinkedIn = false
                
//                UserDefaults.standard.setValue("\((session?.userID)!)", forKey: Constants.Twitter.TWITTER_USER_ID)
//                UserDefaults.standard.synchronize()
                
                //let messageToast = Toast(text: "Signed in as :\(session?.userName as! String).", duration: Delay.short)
                //messageToast.show()
                
                MBProgressHUD.showAdded(to: self.view, animated: true)
                let client = TWTRAPIClient.withCurrentUser() // ?include_email=true
                let request = client.urlRequest(withMethod: "GET",
                                                urlString: "https://api.twitter.com/1.1/account/verify_credentials.json",
                                                parameters: ["include_email": "true", "skip_status": "true"],
                                                error: nil)
                client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                    if (connectionError == nil) {
                        
                        do{
                            let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                            print("Json response: ", json)
                            
                            var Email = json["email"]
                            print("Email: ", Email)
                            
                            if(Email != nil)
                            {
                                print("Email is not nil, We have Twitter email..")
                            }
                            else
                            {
                                client.requestEmail { email, error in
                                    
                                    if (email != nil)
                                    {
                                        Email = email
                                        print("signed in as \(session?.userName) with email = \(email)");
                                    }
                                    else
                                    {
                                        print("error while getting email: \(error?.localizedDescription)");
                                    }
                                }
                            }
                            
                            print("Email => ",Email)
                            let name = json["name"]
                            print("name: ",name)
                            let description = json["description"]
                            print("description: ",description)
                            
                            SignInViewController.userTwitterData = json
                        }
                        catch
                        {}
                        
                        if SignInViewController.userTwitterData["email"] != nil
                        {
                            if SignInViewController.userTwitterData["email"] as! String == ""
                            {
                                let messageToast = Toast(text: "Email is not availabe or empty against your account.", duration: Delay.short)
                                messageToast.show()
                                
                                SignInViewController.userTwitterData["email"] = ""
                                //return
                            }
                            else
                            {
                                //self.checkUpEmailAvailability_for_Twitter()
                            }
                        }
                        else
                        {
                            //let messageToast = Toast(text: "Email is Nil against your account.", duration: Delay.short)
                            //messageToast.show()
                            
                            SignInViewController.userTwitterData["email"] = ""
                        }
                        
                        MBProgressHUD.hide(for: self.view, animated: true)
                        //self.checkUpEmailAvailability_for_Twitter()
                        self.check_isTwitter_Account_IdAlreadyExist()
                        
                    }
                    else
                    {
                        print("Error: \(connectionError.debugDescription.debugDescription)")
                        let messageToast = Toast(text: "Error: \(connectionError.debugDescription)", duration: Delay.short)
                        messageToast.show()
                    }
                }
            }
            else
            {
                print("error: \(error?.localizedDescription)");
                let messageToast = Toast(text: "error: \(error?.localizedDescription)", duration: Delay.short)
                messageToast.show()
            }
        })
        
        logInButton.frame = self.selfLoginWithTWTRButton.frame
        //logInButton.setCornerRadiusCircle()
        self.buttonsContainerView.addSubview(logInButton)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton)
    {
        FBSDKLoginManager().logOut()
        
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton)
    {
        if allDataEntered()
        {
            // Get Data
            self.getUserStatus()
        }
    }
    
    @IBAction func forgotPassword_Tapped(_ sender: Any)
    {
        //PhoneNumberVerification_ViewController.isForgotPasswordCase = true
        self.performSegue(withIdentifier: Constants.Segues.signIn_to_EnterPhoneNumber_VC, sender: self)
    }
    
    @IBAction func button_LinkedIn_Tapped(_ sender: Any)
    {
//        let vc = UIStoryboard(name: Constants.StoryBoards.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.ViewControllers.LoginWith_LinkedIn_VC) as! LoginWith_LinkedIn_VC
//
//        self.present(vc, animated: true, completion: nil)
        
        self.LinkedIn_LogIn_Tapped()
    }
    
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
//        SignInViewController.linkedinHelper?.authorizeSuccess({(lsToken) -> Void in
//
//            print("\n Login success lsToken: \(lsToken) \n")
//            //Toast(text: "Login successfull. Getting user profile data..").show()
//
//            self.isUsingTwitter = false
//            self.isUsing_LinkedIn = true
//
//            self.requestProfile()
//            let session = LISDKSessionManager.sharedInstance().session as? LISDKSession
//        }, error: {(error) -> Void in
//
//            print("\n Error: \(error.localizedDescription) \n")
//            Alert.showAlertWithMessageAndTitle(message: error.localizedDescription, title: "ERROR")
//
//        }, cancel: {() -> Void in
//
//            print("\n User Cancelled the process... \n")
//            Alert.showAlertWithMessageAndTitle(message: "You cancelled the LinkedIn-login process.", title: "CANCELLED!")
//        })
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
                        
                       
                    }
                    catch {
                        print("Could not convert JSON data into a dictionary.")
                    }
                }
            }
            
            task.resume()
        }
        return
//        SignInViewController.linkedinHelper?.requestURL(Constants.LinkedIn.requestURL, requestType: LinkedinSwiftRequestGet, success: { (response) -> Void in
//
//            print("\n Request success with response: \(response.jsonObject!) \n")
//            SignInViewController.userLinkedInData = response.jsonObject as! [String : Any]
//
//            SignInViewController.userLinkedInData["id"] = String(describing: SignInViewController.userLinkedInData["id"]!)
//            SignInViewController.userLinkedInData["email"] = String(describing: SignInViewController.userLinkedInData["emailAddress"]!)
//            SignInViewController.userLinkedInData["name"] = String(describing: SignInViewController.userLinkedInData["firstName"]!) + " " + String(describing: SignInViewController.userLinkedInData["lastName"]!)
//
//            //Toast(text: "User profile data fetched successfully!").show()
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
//
//                Utilities.hide_ProgressHud(view: self.view)
//                self.check_isLinkedIn_Account_IdAlreadyExist()
//            })
//
//        }) {(error) -> Void in
//
//            // Also called when user press done button
//            print("\n Error: \(error.localizedDescription) \n")
//            Utilities.hide_ProgressHud(view: self.view)
//            Alert.showAlertWithMessageAndTitle(message: error.localizedDescription, title: "ERROR")
//        }
    }
    
    func getProfileEmail() {
        if let accessToken = UserDefaults.standard.object(forKey: "LIAccessToken") {
            let targetURLString = "https://api.linkedin.com/v2/emailAddress?q=members&projection=(elements*(handle~))"
            let request = NSMutableURLRequest(url: NSURL(string: targetURLString)! as URL)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
                
                print(response)
                
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
    
    @IBAction func button_PhoneNumber_Tapped(_ sender: Any)
    {
        self.performSegue(withIdentifier: Constants.Segues.signIn_to_EnterPhoneNumber_VC, sender: self)
    }
    
    func getUserStatus()
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let sessionObject = DataAccess.sharedInstance
        sessionObject.getUserForSignIn(emailTextField.text!, passwordTextField.text!, resultDelegate: self as UserDetailDelegate)
    }
    
    func setRecievedUserStatus(_ status: Bool, statusString: String, userData: User)
    {
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
    
    func dataAccessError(_ error:NSError?) {
        
        MBProgressHUD.hide(for: self.view, animated: true)
        self.presentAlertWithMessage(msg: (error?.description)!, field: 1, title: "Error")
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func allDataEntered() -> Bool {
        
        if (self.emailTextField.text?.characters.count)! == 0 {
            
            self.presentAlertWithMessage(msg: "Enter Email", field: 1)
            //            self.emailTextField.becomeFirstResponder()
            return false
        }
        else if !self.isValidEmail(testStr: self.emailTextField.text!) {
            
            self.presentAlertWithMessage(msg: "Enter valid Email", field: 1)
            //            self.presentAlertWithMessage(msg: "Mobile Number Length should atleast be 8", field: 1)
            //            self.emailTextField.becomeFirstResponder()
            return false
        }
        else if (self.passwordTextField.text?.characters.count)! == 0 {
            self.presentAlertWithMessage(msg: "Enter Password", field: 2)
            //            self.passwordTextField.becomeFirstResponder()
            return false
        }
            //        else if (self.passwordTextField.text?.characters.count )! < 4 {
            //            self.presentAlertWithMessage(msg: "Password should atleast be of lenght 4",field: 2)
            //            //            self.passwordTextField.becomeFirstResponder()
            //            return false
            //        }
        else {
            return true
        }
    }
    
    func presentAlertWithMessage(msg:String, field:Int, title: String = "Login")
    {
        let actionSheetController: UIAlertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) { action -> Void in
            if field == 1 {
                self.emailTextField.becomeFirstResponder()
            }
            else {
                self.passwordTextField.becomeFirstResponder()
            }
            //dismiss the action sheet
        }
        
        actionSheetController.addAction(cancelAction)
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    
    private var _orientations = UIInterfaceOrientationMask.portrait
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        //print("supportedInterfaceOrientations Method call \n", self._orientations)
        return self._orientations
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit
    {
        
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?)
     {
        if(segue.identifier == Constants.Segues.signIn_to_EnterPhoneNumber_VC)
        {
            let nextVC = segue.destination as! PhoneNumberFlowViewController
            nextVC.isComingFrom_SignInVC = true
            nextVC.isComingFrom_SignUpVC = false
        }
        
        if(segue.identifier == Constants.Segues.SignInVC_to_MoreUserDetails1VC)
        {
            let nextVC = segue.destination as! MoreUserDetails1ViewController
            
            let user = User()
            
            if(SignInViewController.isRequestFor_newFacebook_User)
            {
                user.username = "\(SignInViewController.userFacebookData["id"] ?? "")"
                user.email = "\(SignInViewController.userFacebookData["email"] ?? "")"
                user.name = "\(SignInViewController.userFacebookData["name"] ?? "")"
                user.link = "\(SignInViewController.userFacebookData["link"] ?? "NA")"//publicProfileUrl
            }
            else if(SignInViewController.isRequestFor_newTwitter_User)
            {
                user.username = "\(SignInViewController.userTwitterData["id"] ?? "")"
                user.email = "\(SignInViewController.userTwitterData["email"] ?? "")"
                user.name = "\(SignInViewController.userTwitterData["name"] ?? "")"
                let screenName = "\(SignInViewController.userTwitterData["screen_name"] ?? "NA")"
                if (screenName == "NA") { user.link = screenName }
                else { user.link = "https://twitter.com/" + screenName }
            }
            else if(SignInViewController.isRequestFor_newLinkedIn_User)
            {
                user.username   = "\(SignInViewController.userLinkedInData["id"] ?? "")"
                user.email      = "\(SignInViewController.userLinkedInData["email"] ?? "")"
                user.name       = "\(SignInViewController.userLinkedInData["name"] ?? "")"
                user.link       = "\(SignInViewController.userLinkedInData["publicProfileUrl"] ?? "NA")"//publicProfileUrl
            }
            
            //nextVC.user_toCreate = user
                //MARK: Riz Change
            nextVC.newObj = user
        }
     }
    
    
    /**
     Sent to the delegate when the button was used to login.
     - Parameter loginButton: the sender
     - Parameter result: The results of the login
     - Parameter error: The error (if any) from the login
     */
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!)
    {
        if error != nil
        {
            print(error.localizedDescription)
            let messageToast = Toast(text: "Error! Please retry in a moment.", duration: Delay.short)
            messageToast.show()
        }
        else
        {
            print(result.token)
            if((FBSDKAccessToken.current()) != nil)
            {
                self.isUsingTwitter = false
                self.isUsing_LinkedIn = false
                
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, link"]).start(completionHandler:
                    { (connection, result, error) -> Void in
                        
                        if (error == nil)
                        {
                            print(result ?? "NO RESULT")
                            if let data = result as? [String:Any]
                            {
                                SignInViewController.userFacebookData = data
                                let messageToast = Toast(text: "Please Wait...", duration: Delay.short)
                                messageToast.show()
                                
                                if SignInViewController.userFacebookData["email"] != nil
                                {
                                    if SignInViewController.userFacebookData["email"] as! String == ""
                                    {
                                        let messageToast = Toast(text: "Email is not availabe or Empty against your account.", duration: Delay.short)
                                        messageToast.show()
                                        
                                        SignInViewController.userFacebookData["email"] = ""
                                        
                                        //return
                                    }
                                    else {
                                        //self.checkUpEmailAvailability_For_Facebook()
                                    }
                                }
                                else
                                {
                                    SignInViewController.userFacebookData["email"] = ""
                                }
                                
                                //self.checkUpEmailAvailability_For_Facebook()
                                self.check_isFB_Account_IdAlreadyExist()
                            }
                            else
                            {
                                let messageToast = Toast(text: "No data retrieved from your account.", duration: Delay.short)
                                messageToast.show()
                            }
                        }
                        else
                        {
                            print(error?.localizedDescription)
                        }
                })
            }
            else
            {
                let messageToast = Toast(text: "You quit the process.", duration: Delay.short)
                messageToast.show()
            }
        }
    }
    
    /**
     Sent to the delegate when the button was used to logout.
     - Parameter loginButton: The button that was clicked.
     */
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func checkUpEmailAvailability_For_Facebook()
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let sessionObject = DataAccess.sharedInstance
        sessionObject.get_Facebook_Twitter_UserWithEmail(SignInViewController.userFacebookData["email"] as! String, "", resultDelegate: self as UserStatusDelegate)
    }
    
    func checkUpEmailAvailability_for_Twitter() {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let sessionObject = DataAccess.sharedInstance
        sessionObject.get_Facebook_Twitter_UserWithEmail(SignInViewController.userTwitterData["email"] as! String, "", resultDelegate: self as UserStatusDelegate)
    }
    
    func check_isFB_Account_IdAlreadyExist()
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let sessionObject = DataAccess.sharedInstance
        
        if(SignInViewController.userFacebookData["id"] != nil)
        {
            sessionObject.get_Facebook_Twitter_UserWith_accountID("\(SignInViewController.userFacebookData["id"]!)", resultDelegate: self as IsTwitter_Facebook_IdAlready_Exist_Delegate)
        }
        else
        {
            sessionObject.get_Facebook_Twitter_UserWith_accountID("0", resultDelegate: self as IsTwitter_Facebook_IdAlready_Exist_Delegate)
        }
    }
    
    func check_isTwitter_Account_IdAlreadyExist()
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let sessionObject = DataAccess.sharedInstance
        
        if(SignInViewController.userTwitterData["id"] != nil)
        {
            sessionObject.get_Facebook_Twitter_UserWith_accountID("\(SignInViewController.userTwitterData["id"]!)", resultDelegate: self as IsTwitter_Facebook_IdAlready_Exist_Delegate)
        }
        else
        {
            sessionObject.get_Facebook_Twitter_UserWith_accountID("0", resultDelegate: self as IsTwitter_Facebook_IdAlready_Exist_Delegate)
        }
    }
    
    func check_isLinkedIn_Account_IdAlreadyExist()
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let sessionObject = DataAccess.sharedInstance
        
        if(SignInViewController.userLinkedInData["id"] != nil) {
            sessionObject.get_Facebook_Twitter_UserWith_accountID("\(SignInViewController.userLinkedInData["id"]!)", resultDelegate: self)
        }
    }
    
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
            if isUsingTwitter
            {
                self.check_isTwitter_Account_IdAlreadyExist()
            }
            else if(self.isUsing_LinkedIn)
            {
                self.check_isLinkedIn_Account_IdAlreadyExist()
            }
            else
            {
                self.check_isFB_Account_IdAlreadyExist()
            }
        }
    }
    
    func requestFor_newFacebook_User()
    {
        SignInViewController.isRequestFor_newFacebook_User = true
        SignInViewController.isRequestFor_newTwitter_User = false
        SignInViewController.isRequestFor_newLinkedIn_User = false
        
        self.termsAndConditionsContainer.isHidden = false
        self.tAndCTextView.setContentOffset(CGPoint.zero, animated: false)
        
        //self.performSegue(withIdentifier: Constants.Segues.SignInVC_to_MoreUserDetails1VC, sender: self)
    }
    
    func requestFor_newTwitter_User()
    {
        SignInViewController.isRequestFor_newTwitter_User = true
        SignInViewController.isRequestFor_newFacebook_User = false
        SignInViewController.isRequestFor_newLinkedIn_User = false
        
        self.termsAndConditionsContainer.isHidden = false
        self.tAndCTextView.setContentOffset(CGPoint.zero, animated: false)
        
        //self.performSegue(withIdentifier: Constants.Segues.SignInVC_to_MoreUserDetails1VC, sender: self)
    }
    
    func requestFor_newLinkedIn_User()
    {
        SignInViewController.isRequestFor_newLinkedIn_User = true
        SignInViewController.isRequestFor_newTwitter_User = false
        SignInViewController.isRequestFor_newFacebook_User = false
        
        self.termsAndConditionsContainer.isHidden = false
        self.tAndCTextView.setContentOffset(CGPoint.zero, animated: false)
        
        //self.performSegue(withIdentifier: Constants.Segues.SignInVC_to_MoreUserDetails1VC, sender: self)
    }
    
    static func LogOut_from_Facebook()
    {
        print("Notification Received to Logout from FaceBook ...")
        FBSDKAccessToken.setCurrent(nil)
        FBSDKProfile.setCurrent(nil)
        FBSDKLoginManager().logOut()
        
        let deletepermission = FBSDKGraphRequest(graphPath: "me/permissions/", parameters: nil, httpMethod: "DELETE")
        deletepermission?.start(completionHandler: {(connection,result,error)-> Void in
            print("the delete permission is \(String(describing: result))")
        })
    }
    
    static func LogOut_from_Twitter()
    {
        print("Notification Received to Logout from Twitter ...")
        if let id = TWTRAPIClient.withCurrentUser().userID
        {
            print("Notification Received to Logout from Twitter... Twitter userId = \(id)")
            TWTRTwitter.sharedInstance().sessionStore.logOutUserID(id)
        }
    }
    
    static func LogOut_from_LinkedIn()
    {
        
        print(linkedinHelper?.lsAccessToken)
        UserDefaults.standard.removeObject(forKey: "LIAccessToken")
        if (SignInViewController.linkedinHelper == nil) {
            let config = LinkedinSwiftConfiguration(clientId: Constants.LinkedIn.clientId, clientSecret: Constants.LinkedIn.clientSecret, state: Constants.LinkedIn.state, permissions: Constants.LinkedIn.permissions, redirectUrl: Constants.LinkedIn.redirectUrl)

            SignInViewController.linkedinHelper = LinkedinSwiftHelper(configuration: config!, nativeAppChecker: nil, clients: nil, webOAuthPresent: UIViewController(), persistedLSToken: nil)
        }
        
        let cookie = HTTPCookie.self
        let cookieJar = HTTPCookieStorage.shared

            for cookie in cookieJar.cookies! {
               // print(cookie.name+"="+cookie.value)
                cookieJar.deleteCookie(cookie)
            }
        
        SignInViewController.linkedinHelper?.logout()
        SignUpViewController.linkedinHelper?.logout()
        print(linkedinHelper?.lsAccessToken)
        print(linkedinHelper)
        print("LogOut_from_LinkedIn signinViewController")
    }
    
    static func Logout_fromQB()
    {
        QBChat.instance.disconnect { (err) in
            
            QBRequest.logOut(successBlock: { (r) in
                
            })
        }
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
    
    //////////////////////////////////////////
    //                                     //
    ////        Delegate Methods          //
    //                                   //
    //////////////////////////////////////
    
    // IsTwitter_Facebook_IdAlready_Exist_Delegate Methods
    func IsTwitter_Facebook_IdAlready_Exist_Respnse(_ isExist: Bool, statusString: String, requiredUser: User)
    {
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
                else if(SignInViewController.isRequestFor_newLinkedIn_User || self.isUsing_LinkedIn)
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
            if isUsingTwitter
            {
                self.requestFor_newTwitter_User()
            }
            else if(self.isUsing_LinkedIn)
            {
                self.requestFor_newLinkedIn_User()
            }
            else
            {
                self.requestFor_newFacebook_User()
            }
        }
    }
    
    func Twitter_Facebook_Account_AccessError(_ error: String)
    {
        MBProgressHUD.hide(for: self.view, animated: true)
        self.presentAlertWithMessage(msg: error, field: 0)
    }
    
    func showAlert(_ title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func closeOrDismiss(_ sender: UIButton) {
        
        self.dismiss(animated: false, completion: nil)
    }
    
}

extension SignInViewController: MyLITokenRequestDelegate {
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
