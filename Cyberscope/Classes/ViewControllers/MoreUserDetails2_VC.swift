//
//  MoreUserDetails2_VC.swift
//  CyberScope
//
//  Created by Saad Furqan on 17/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD
import FirebaseAuth
import Firebase

class MoreUserDetails2_VC: UIViewController, Add_Or_Update_User_Delegate, SignUpUser_Delegate
{
    func SignUpUser_Delegate_Response(isSuccess: Bool, error: String, id: Int) {
        print(isSuccess, error, id)
        Utilities.hide_ProgressHud(view: self.view)
    }
    
    @IBOutlet weak var button_completeProfile: UIButton!
    @IBOutlet weak var textfield_hourlyRate: UITextField!
    @IBOutlet weak var hourlyRateLabel: UILabel!
    @IBOutlet weak var perhourRateLabel: UILabel!
    @IBOutlet weak var textView_whatYouDo: UITextView!
    @IBOutlet weak var button_checkBox: UIButton!
    @IBOutlet weak var textfield_referalCode: UITextField!
    @IBOutlet weak var profileUrlInfoButton: UIButton!
    @IBOutlet weak var textfield_ProfileUrl: UITextField!
    
    fileprivate let dataAccess = DataAccess.sharedInstance
    var user_toCreate: User?
    var newObj = User()
    var ref = DatabaseReference.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        print(user_toCreate)

        if (self.user_toCreate?.skills == Constants.userSkillsType.viewer) {
            
            //Utilities.show_ProgressHud(view: self.view) // show progress hud
            
            // Set defaults value to rate for a viewer
            self.user_toCreate?.rate = "0"
            self.user_toCreate?.password = Constants.DreamFactory.DF_User_Default_Password
            self.user_toCreate?.isNew_object = true
            
            //self.SignUp_QB_User()
            self.hourlyRateLabel.isHidden = true
            self.perhourRateLabel.isHidden = true
            self.textfield_hourlyRate.isHidden = true
        }
        self.button_completeProfile.setCornerRadiusCircle()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (self.user_toCreate?.skills == Constants.userSkillsType.broadcaster) {
            //self.showCautionAlert()
            self.hourlyRateLabel.isHidden = false
            self.perhourRateLabel.isHidden = false
            self.textfield_hourlyRate.isHidden = false
        }
        self.button_completeProfile.setCornerRadiusCircle()
    }

    func showCautionAlert() {
        let cannotCallAlert = UIAlertController(title: "", message: "Your hourly rate should include a 25% comfort fee levied by SimX which will apply to every video or voice chat conversation. \n\n i.e \n\n If your video or voice chat rate is £100 an hour you will receive a net fee of £75 an hour. \n\n Chat is charged  in seconds and can be terminated at any time by either party.", preferredStyle: .actionSheet)
        let okFunction = UIAlertAction(title: "Got It!", style: .default) { _ in
        }
        cannotCallAlert.addAction(okFunction)
        self.present(cannotCallAlert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func button_checkBox_Tapped(_ sender: Any) {
    }
    
    func isValidUrlString (myString: String) -> Bool {
        let urlRegEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: myString)
    }
    
    @IBAction func buttonProfileUrlInfo_Tapped(_ sender: Any) {
        if let url = URL(string: "https://www.linkedin.com/help/linkedin/answer/49315/finding-your-linkedin-public-profile-url") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func button_completeProfile_Tapped(_ sender: Any)
    {
        if (self.textfield_ProfileUrl.text! == "") {
            Toast(text: "Please enter link for LinkedIn Profile!", duration: Delay.short).show()
            return
        }
        if (!self.isValidUrlString(myString: self.textfield_ProfileUrl.text!)) {
            Toast(text: "Not a valid link!", duration: Delay.short).show()
            return
        }
     /*   if (!self.textfield_ProfileUrl.text!.lowercased().contains(find: "linkedin.com/in")) {
            Toast(text: "Link does not seems to be of a valid LinkedIn Profile!", duration: Delay.short).show()
            return
        }*/
        //MARK: Riz Change
//        if (!self.textfield_ProfileUrl.text!.isValidLinkedinLink) {
//            Toast(text: "Link does not seems to be of a valid LinkedIn Profile!", duration: Delay.short).show()
//            print("Link \(user_toCreate?.link)")
//            print("Linkedin\(user_toCreate?.linkedin)")
//            return
//        }
        if (self.user_toCreate?.skills == Constants.userSkillsType.broadcaster) {
           
            if (self.textfield_hourlyRate.text! == "0" || self.textfield_hourlyRate.text! == "0.0") {
                Toast(text: "A broadcaster rate can not be zero!", duration: Delay.short).show()
                return
            }
//            if (Int(self.textfield_hourlyRate.text!) ?? 0 < 19 ) {
//                Toast(text: "A broadcaster rate can not be Less then 20", duration: Delay.short).show()
//                return
//            }
        }
        if(self.user_toCreate != nil)
        {
            Utilities.show_ProgressHud(view: self.view)
            
            self.user_toCreate?.rate = self.textfield_hourlyRate.text!
            self.user_toCreate?.link = self.textfield_ProfileUrl.text!
            self.user_toCreate?.password = Constants.DreamFactory.DF_User_Default_Password
            self.user_toCreate?.isNew_object = true
            print("Link \(user_toCreate?.link)")
            print("Linkedin\(user_toCreate?.linkedin)")
            
            //MARK: Save data in Firebase real time DB
            let email = UserDefaults.standard.string(forKey: "sEmail")
            let password = UserDefaults.standard.string(forKey: "sPass")
            print(email, password)
            self.fireBaseEmailCheck(email: email ?? "", password: password ?? "")
            
            //self.SignUp_QB_User()
        }
        else {
            Toast(text: "User data not found, go back and try again!", duration: Delay.short).show()
            return
        }
    }
    
    //MARK: Upload imgae
    func upload_ProfileImage()
    {
        Utilities.show_ProgressHud(view: self.view)
        let imgData = UserDefaults.standard.string(forKey: "imageData")

        
        let image : String = imgData!
        //MARK: Change 2022
        //var name : String = (self.user_toCreate?.username)!

        var name : String = user_toCreate!.email
        self.newObj.picture = name //self.newObj.username
        
        name = name + ".png"
        print(name)
        
        print(Constants.API_URLs.uploadProfileImage_URL)
        uploadImage(url:Constants.API_URLs.uploadProfileImage_URL, withParams:["base64": image , "ImageName" : name ])
        {
            (succeeded: Bool, msg: String?) -> () in
            if succeeded == true
            {
                if msg == nil
                {
                    DispatchQueue.main.async {
                        print("Uploading Failed")
                    }
                    print("\n\nMessage is nil ::: \(String(describing: msg))")
                }
                else
                {
                    DispatchQueue.main.async {
                        print("Image Uploaded")
                        
                        
                    }
                    print("\n\nMessage is ::: \(String(describing: msg))")
                }
            }
            else
            {
                print("Uploading Failed")
                print("\n\nError fetching Data !!!")
            }
        }
    }
    
    func uploadImage(url:String, withParams params: [String : String?] , postCompleted : @escaping (_ succeeded: Bool, _ msg: String?) -> ())
    {
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        let session = URLSession.shared
        request.httpMethod = "POST"
        var bodyData = ""
        for (key,value) in params
        {
            if (value == nil){ continue }
            let scapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let scapedValue = value?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            bodyData += "\(scapedKey!)=\(scapedValue!)&"
        }
        request.httpBody = bodyData.data(using: String.Encoding.utf8, allowLossyConversion: true)
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            if data != nil
            {
                print("\n\ndata is ::: \(String(describing: data)).\n\nresponse is \(response)")
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print(dataString)
                
                let newV = dataString!.substring(from: 1)
                //substring(1,dataString.length())
                print(newV)
                
                postCompleted(true, newV as String)
            }
            else
            {
                print("\n\nERROR !!! NO INTERNET CONNECTION...DATA IS NIL")
            }
        })
        task.resume()
    }
    
    
    func fireBaseEmailCheck(email: String, password: String){
        Utilities.show_ProgressHud(view: self.view)
        Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in

            if let x = error {
                let err = x as NSError
                switch err.code {
                case AuthErrorCode.wrongPassword.rawValue:
                    
                    Toast(text: "wrong password").show()
                case AuthErrorCode.invalidEmail.rawValue:
                    Toast(text: "invalid email").show()
                case AuthErrorCode.accountExistsWithDifferentCredential.rawValue:
                    Toast(text: "accountExistsWithDifferentCredential").show()
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    //Toast(text: "email already in use").show()
                    let x = authResult?.user.uid
                    
                    
                    
                    
                    self.user_toCreate?.username = x ?? ""
                    self.user_toCreate?.picture = self.user_toCreate?.email ?? ""
                    self.newObj.username = x ?? ""
                default:
                    print("unknown error: \(err.localizedDescription)")
                }
            }

            let x = authResult?.user.uid
            self.user_toCreate?.username = x ?? ""
            self.user_toCreate?.picture = self.user_toCreate?.email ?? ""
            self.saveFireBaseData(value: x ?? "")
            self.newObj.username = x ?? ""
            //Mark Upload Image
            self.upload_ProfileImage()
            self.SignUp_QB_User()
            self.sendVerificationMail()
            
            Auth.auth().currentUser!.sendEmailVerification { error in
               if let error = error {
                  print("Error of Verification email: \(String(describing: error.localizedDescription))")
               }
               print("Email sent")
            }
            //Toast(text: "successfully created user:  \(x ?? "")").show()
            
        })
    }
    

    public func sendVerificationMail() {
        let authUser = Auth.auth().currentUser
        if authUser != nil && authUser!.isEmailVerified {
            authUser!.sendEmailVerification(completion: { (error) in
                // Notify the user that the mail has sent or couldn't because of an error.
                print("Email verification error ....")
                print(error)
            })
        }
        else {
            // Either the user is not available, or the user is already verified.
        }
    }
    
    //MARK: Save firebase real time data
    func saveFireBaseData(value: String){
        print(value)
        let email = UserDefaults.standard.string(forKey: "sEmail")
        let name =   UserDefaults.standard.string(forKey: "sName")
        let dict = ["email": email, "name": name]
        self.ref.child("UserNames").child(value).setValue(dict)
    }
    
    func SignUp_QB_User()
    {
       
        let user = QBUUser()
        user.fullName = self.user_toCreate?.name
        user.login = self.user_toCreate?.email
        user.password = Constants.QuickBlox.QB_User_Default_Password
        user.tags = [Constants.OS.ios]
        
       // MARK: Riz Comment
        QBRequest.signUp(user, successBlock: { (response, user) in

            print("\n => QB SIGNUP SUCCESSFULL ... \n New User Details are: ")
            print("\n \(user.id) \n \((user.fullName)!) \n \((user.login)!) \n")

            self.user_toCreate?.qbid = String(describing: user.id)
            if (UserDefaults.standard.object(forKey: "endpointArnForSNSCyberScope787") != nil) {
                self.user_toCreate?.arn = UserDefaults.standard.object(forKey: "endpointArnForSNSCyberScope787") as! String
            }

            self.dataAccess.add_OR_update_User(user: self.user_toCreate!, delegate: self)

        }, errorBlock: { (error) in

            print("\n => QB SIGNUP FAILED ... \n error = \(error)")

            Utilities.hide_ProgressHud(view: self.view)
            let e = Utilities.getQB_ErrorMessage_andTitle_fromErrorCode(error_StatusCode: error.status.rawValue)
            Alert.showAlertWithMessageAndTitle(message: e.message, title: e.title)
        })
    }
    
    // Add_Or_Update_User_Delegate methods
    func Add_Or_Update_User_ResponseSuccess(userName: String)
    {
        Toast(text: "Signup successfully! Please verify your email").show()
        Utilities.hide_ProgressHud(view: self.view)
        print("\n Add_Or_Update_User_ResponseSuccess called ... \n")
        
        CurrentUser.setCurrentUser_UserDefaults(user: self.user_toCreate!)
        CurrentUser.setCurrentUserStatus_as_Login()
        
        CurrentUser.set_CurrentDevice_Arn()
        
        self.GoToLogin()
//        DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute: {
//            AppDelegate.shared_instance.setStreamBoardInitialViewControllerToRoot()
//        })
    }
    
    func GoToLogin(){
        CurrentUser.deSetCurrentUser_UserDefaults()
        CurrentUser.setCurrentUserStatus_as_LogOut()
        self.unsubscribeQuickblox()
//        SignInViewController.LogOut_from_Facebook()
//        SignInViewController.LogOut_from_Twitter()
//        SignInViewController.LogOut_from_LinkedIn()
        SignInViewController.Logout_fromQB()
        UserDefaults.standard.removeObject(forKey: Constants.Twitter.TWITTER_Token)
        UserDefaults.standard.removeObject(forKey: Constants.Twitter.TWITTER_TokenSecret)
        
        do {
            try Auth.auth().signOut()
        }catch {
            print("already logged out")
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0, execute: {
            
            Utilities.hide_ProgressHud(view: self.view)
            AppDelegate.shared_instance.goTo_Main_StoryBoard_afterLogout()
        })
    }
    
    func unsubscribeQuickblox()
    {
        var subdIdsSet : Set<UInt> = []
        if let subsIds = UserDefaults.standard.object(forKey: "apns_subsciptionarray_simx_786") as? [UInt] {
            for subsId in subsIds {
                subdIdsSet.insert(subsId)
            }
        }
        if let subsIds2 = UserDefaults.standard.object(forKey: "apnsVoip_subsciptionarray_simx_786") as? [UInt] {
            for subsId in subsIds2 {
                subdIdsSet.insert(subsId)
            }
        }
        print("subscription Ids: ", subdIdsSet)
        subdIdsSet.forEach {(number) in
            QBRequest.deleteSubscription(withID: number, successBlock: nil, errorBlock: nil)
        }
    }
    
    func Add_Or_Update_User_ResponseError(error: NSError)
    {
        Utilities.hide_ProgressHud(view: self.view)
        print("\n Add_Or_Update_User_ResponseError called ... AND Error = \(error.localizedDescription) \n")
    }

        
}



