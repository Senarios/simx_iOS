//
//  EditProfileVC.swift
//  CyberScope
//
//  Created by Saad Furqan on 09/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import AVKit
import Foundation
import Fusuma
import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit
import Toaster
import TwitterKit
import LinkedinSwift

public enum User_Skills: String
{
    case Broadcaster = "Recruiter"  // Client
    case Viewer = "OpenForWork" //"RemoteWorker"
}

class EditProfileVC: UIViewController, UITextFieldDelegate
{ //FusumaDelegate

    @IBOutlet weak var btnMyVideoCVs: UIButton!
    @IBOutlet weak var profileNameContainer: UIView!
    @IBOutlet weak var linkedinLinkContainer: UIView!
    @IBOutlet weak var lblUsername: UITextField!
    @IBOutlet weak var button_cancel: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var button_camera: UIButton!
    @IBOutlet weak var textfield_jobTitle: UITextField!
    @IBOutlet weak var textfield_hourlyRate: UITextField!
    @IBOutlet weak var textfield_ProfileUrl: UITextField!
    @IBOutlet weak var button_save: UIButton!
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var linkedInButton: UIButton!
    
    @IBOutlet weak var socialMediaAccountsTitleLabel: UILabel!
    @IBOutlet weak var socailMediaAccountsOptionsContainerView: UIView!
    @IBOutlet weak var currentBalanceLabel: UILabel!
    @IBOutlet weak var viewPayment: UIView!
    
 //   @IBOutlet weak var addPaymentLabel: UILabel!
    @IBOutlet weak var payPalOptionsContainer: UIView!
    @IBOutlet weak var paymentAddInfoButton: UIButton!
    
    @IBOutlet weak var broadcasterRateLabel: UILabel!
    @IBOutlet weak var broacasterRateContainer: UIView!
    
    @IBOutlet weak var withdrawAmountButton: UIButton!
    
    var imagePickerController : UIImagePickerController!
    
    //let newTwitterButton : TWTRLogInButton!
    
    var current_UserData = CurrentUser.getCurrentUser_From_UserDefaults()
    var isImageChanged = false
    var selectedImage = UIImage(named: Constants.imagesName.default_UserImage)
    fileprivate let dataAccess = DataAccess.sharedInstance
    
    var jobsTitle_List: [User_Skills] = [User_Skills.Broadcaster, User_Skills.Viewer]
    var selectedJobTitle_case: User_Skills = User_Skills.Viewer
    
    var popupListView:XMPopupListView?
    
    @IBAction func buttonProfileUrlInfo_Tapped(_ sender: Any) {
        if let url = URL(string: "https://www.linkedin.com/help/linkedin/answer/49315/finding-your-linkedin-public-profile-url") {
            UIApplication.shared.open(url)
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        if (CurrentUser.Current_UserObject.skills == Constants.userSkillsType.viewer) {
//            self.socialMediaAccountsTitleLabel.isHidden = true
//            self.socailMediaAccountsOptionsContainerView.isHidden = true
        //    self.addPaymentLabel.isHidden = true
            //self.payPalOptionsContainer.isHidden = true
//            self.paymentAddInfoButton.isHidden = false
            self.broadcasterRateLabel.isHidden = false
            self.broacasterRateContainer.isHidden = false
        }
        else {
//            self.socialMediaAccountsTitleLabel.isHidden = false
//            self.socailMediaAccountsOptionsContainerView.isHidden = false
         //   self.addPaymentLabel.isHidden = false
            //self.payPalOptionsContainer.isHidden = false
//            self.paymentAddInfoButton.isHidden = false
            self.broadcasterRateLabel.isHidden = false
            self.broacasterRateContainer.isHidden = false
            self.textfield_hourlyRate.isEnabled = true
          //  self.showCautionAlert()
        }
        //self.broadcasterRateLabel.isHidden = false
        //self.broacasterRateContainer.isHidden = false
        
        // Do any additional setup after loading the view.
        self.setUp_Controls()
        self.checkSocialMediaAvaialablility()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .black
    }

    func showCautionAlert() {
        let cannotCallAlert = UIAlertController(title: "", message: "Your hourly rate should include a 25% comfort fee levied by SimX which will apply to every video or voice chat conversation. \n\n i.e \n\n If your video or voice chat rate is £100 an hour you will receive a net fee of £75 an hour. \n\n Chat is charged  in seconds and can be terminated at any time by either party.", preferredStyle: .actionSheet)
        let okFunction = UIAlertAction(title: "Got It!", style: .default) { _ in
        }
        
        cannotCallAlert.addAction(okFunction)
        self.present(cannotCallAlert, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.UpdateBalance()
    }
    override func viewDidAppear(_ animated: Bool) {
        
        self.setUp_Controls()
        
//        if (CurrentUser.Current_UserObject.skills == Constants.userSkillsType.viewer) {
//            self.socialMediaAccountsTitleLabel.isHidden = true
//            self.socailMediaAccountsOptionsContainerView.isHidden = true
//            self.addPaymentLabel.isHidden = true
//            //self.payPalOptionsContainer.isHidden = true
//            self.paymentAddInfoButton.isHidden = true
//            self.broadcasterRateLabel.isHidden = true
//            self.broacasterRateContainer.isHidden = true
//        }
//        else {
//            self.socialMediaAccountsTitleLabel.isHidden = false
//            self.socailMediaAccountsOptionsContainerView.isHidden = false
//            self.addPaymentLabel.isHidden = false
//            //self.payPalOptionsContainer.isHidden = false
//            self.paymentAddInfoButton.isHidden = false
//            self.broadcasterRateLabel.isHidden = false
//            self.broacasterRateContainer.isHidden = false
//
//            self.showCautionAlert()
//        }
    }
    
    func addTwitterButton() {
        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            
            if (session != nil)
            {
                UserDefaults.standard.setValue("\((session?.userID)!)", forKey: Constants.Twitter.TWITTER_USER_ID)
                UserDefaults.standard.synchronize()
                
                //let messageToast = Toast(text: "Signed in as :\(session?.userName as! String).", duration: Delay.short)
                //messageToast.show()
                
                let client = TWTRAPIClient.withCurrentUser() // ?include_email=true
                let request = client.urlRequest(withMethod: "GET",
                                                urlString: "https://api.twitter.com/1.1/account/verify_credentials.json",
                                                parameters: ["include_email": "true", "skip_status": "true"],
                                                error: nil)
                client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                    
                    if (connectionError == nil) {
                        
                        do{
                            let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                            print("Json response: ", json)
                            
                            var Email = json["email"]
                            print("Email: ", Email)
                            
                            if(Email != nil) {
                                print("Email is not nil, We have Twitter email..")
                            }
                            else {
                                client.requestEmail { email, error in
                                    if (email != nil) {
                                        Email = email
                                        print("signed in as \(session?.userName) with email = \(email)");
                                    }
                                    else {
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
        
        logInButton.frame = self.twitterButton.frame
//        //logInButton.setCornerRadiusCircle()
//        self.newTwitterButton = logInButton
//        self.view.addSubview(self.newTwitterButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func findLinkedinUsernameClicked(_ sender: Any) {
        let videoURLString = "\(Constants.Stream_URLs.videoBaseLink)Other/link.mp4"
        self.playThisVideoInAVPlayer(videoFileURLString: videoURLString)
    }
    
    func playThisVideoInAVPlayer(videoFileURLString: String) {
            
            print("about to launch Player with : \(videoFileURLString)")
            let url = URL(string: videoFileURLString)
            let asset = AVURLAsset(url: url!)
            let playerItem = AVPlayerItem(asset: asset)
            let player = AVPlayer(playerItem: playerItem)

            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            player.play()
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
    //        // to overcome .stalled state
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
    //            playerViewController.player!.play()
    //        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func UpdateBalance()
    {
        self.current_UserData = CurrentUser.getCurrentUser_From_UserDefaults()
        self.currentBalanceLabel.text = "£\(self.current_UserData.credit)"
    }
    func setUp_Controls()
    {
        self.current_UserData = CurrentUser.getCurrentUser_From_UserDefaults()
        let url = Utilities.getUserImage_URL(username: CurrentUser.get_User_useremail_fromUserDefaults())
        //self.profileImage.
        self.profileImage.sd_setImage(with: url, placeholderImage: self.selectedImage?.circle)
        if (self.isImageChanged) {
            self.profileImage.image = self.selectedImage?.circle
        }
        else {
            self.profileImage.image = self.profileImage.image?.circle
        }
        
//        self.textfield_jobTitle.delegate = self
        self.textfield_hourlyRate.delegate = self
        
        self.selectedJobTitle_case = (self.current_UserData.skills == User_Skills.Broadcaster.rawValue) ? .Broadcaster: .Viewer
//        self.textfield_jobTitle.text = self.selectedJobTitle_case.rawValue
        
        self.textfield_hourlyRate.text = "£\(self.current_UserData.rate)"
        
        self.currentBalanceLabel.text = "£\(self.current_UserData.credit)"
        self.lblUsername.text = self.current_UserData.name
        let profileUrlString23 = self.current_UserData.link
        if !(profileUrlString23 == "" || profileUrlString23 == " " || profileUrlString23 == "NA") {
            self.textfield_ProfileUrl.text = Utilities.getLinkedinLink(linkedinLInk: profileUrlString23)
        }
        
        if (self.current_UserData.credit > 0.0) {
            self.withdrawAmountButton.isUserInteractionEnabled = true
            self.withdrawAmountButton.alpha = 1.0
        }
        else {
            self.withdrawAmountButton.isUserInteractionEnabled = false
            self.withdrawAmountButton.alpha = 0.4
        }
        self.withdrawAmountButton.isUserInteractionEnabled = true
        self.withdrawAmountButton.alpha = 1.0
    
        viewPayment.layer.shadowColor = UIColor.black.cgColor
        viewPayment.layer.shadowOpacity = 0.3
        viewPayment.layer.shadowOffset = .zero
        viewPayment.layer.shadowRadius = 3
        
        self.broacasterRateContainer.layer.cornerRadius = 5
        broacasterRateContainer.layer.shadowColor = UIColor.black.cgColor
        broacasterRateContainer.layer.shadowOpacity = 0.3
        broacasterRateContainer.layer.shadowOffset = .zero
        broacasterRateContainer.layer.shadowRadius = 3
        
        
        self.profileNameContainer.layer.cornerRadius = 5
        profileNameContainer.layer.shadowColor = UIColor.black.cgColor
        profileNameContainer.layer.shadowOpacity = 0.3
        profileNameContainer.layer.shadowOffset = .zero
        profileNameContainer.layer.shadowRadius = 3
        
        
        self.linkedinLinkContainer.layer.cornerRadius = 5
        linkedinLinkContainer.layer.shadowColor = UIColor.black.cgColor
        linkedinLinkContainer.layer.shadowOpacity = 0.3
        linkedinLinkContainer.layer.shadowOffset = .zero
        linkedinLinkContainer.layer.shadowRadius = 3
        
        
//        if self.current_UserData.skills == Constants.userSkillsType.freelancer {
            self.btnMyVideoCVs.layer.cornerRadius = 5
            self.btnMyVideoCVs.isHidden = false
////        }
////        else
////        {
//            self. .isHidden = true
//       // }
        
    }
    
    func checkSocialMediaAvaialablility() {
//        self.checkFacebookAvaialbility()
//        self.checkLinkedInAvailability()
//        self.checkTwitterAvailability()
    }
    
    // MARK: - Facebook Methods
    
    func checkFacebookAvaialbility() {
        if (FBSDKAccessToken.current() == nil) {
            self.facebookButton.alpha = 0.6
        }else if FBSDKAccessToken.current().hasGranted("publish_actions") {
            self.facebookButton.alpha = 1.0
        }else {
            self.facebookButton.alpha = 0.6
        }
    }
    
    func signinWithFacebook() {
        
        if (FBSDKAccessToken.current() != nil) {
            if FBSDKAccessToken.current().hasGranted("publish_actions") {
                Toast(text: "Facebook added successfully").show()
                return
            }
        }
        print("Request publish_actions permissions")
        let login: FBSDKLoginManager = FBSDKLoginManager()
        
        login.logIn(withPublishPermissions: ["publish_actions"], from: self) { (result, error) in
            if (error != nil) {
                print(error!)
            } else if (result?.isCancelled)! {
                print("Canceled")
            } else if (result?.grantedPermissions.contains("publish_actions"))! {
                print("permissions granted")
                self.facebookButton.alpha = 1.0
            }
        }
        return
    }
    
    @IBAction func myVideoCVsClicked(_ sender: Any) {
        self.performSegue(withIdentifier: Constants.Segues.MyProfile_to_MyVideoCvs, sender: self)
    }
    // MARK: - Sharing FTL Methods
    func ShareOnLinkedIn()
    {
        // if ( want to share from the app)
        if LISDKSessionManager.hasValidSession()
        {
            let url: String = "https://api.linkedin.com/v1/people/~/shares"
            let payloadStr: String = "{\"comment\":\"My Live Stream on CyberscopeTV\",\"content\":{\"title\":\"SimX Resources\",\"description\":\"Leverage LinkedIn's APIs to maximize engagement\",\"submitted-url\":\"https://www.cyberjobscope.com\",\"submitted-image-url\":\"https://web.scottishhealth.live/picture/Photos/1498045484.png\"},\"visibility\":{\"code\":\"anyone\"}}"
            
            //https://web.simx.tv/
            
            let payloadData = payloadStr.data(using: String.Encoding.utf8)
            
            LISDKAPIHelper.sharedInstance().postRequest(url, body: payloadData, success: { (response) in
                print(response!.data)
                
            }, error: { (error) in
                
                print(error as! Error)
                
                let alert = UIAlertController(title: "Alert!", message: "aomething went wrong", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    
    func shareOnFacebook() {
        let stringText = Utilities.getShareableLink(broadcastName: "101551811096497991498045484", imageLink: "1498045484")
        FBSDKGraphRequest(graphPath: "me/feed", parameters: ["message": "SimX", "link": URL(string: stringText)], httpMethod: "POST").start(completionHandler: {(_ connection: FBSDKGraphRequestConnection?, _ result: Any?, _ error: Error?) -> Void in
            if error == nil {
                print("Post id: ", result)
            }
        })
    }
    
    // MARK: - LinkedIn Methods
    func  checkLinkedInAvailability() {
        
        if UserDefaults.standard.object(forKey: "LIAccessToken") != nil {
            self.linkedInButton.alpha = 1.0
        }
        else {
            self.linkedInButton.alpha = 0.6
        }
//        if LISDKSessionManager.hasValidSession()
//        {
//            self.linkedInButton.alpha = 1.0
//        }
//        else {
//            self.linkedInButton.alpha = 0.6
//        }
    }
    
    func signinWithLinkedIn() {
        if UserDefaults.standard.object(forKey: "LIAccessToken") != nil {
            
            Toast(text: "LinkedIn added successfully").show()
            self.linkedInButton.alpha = 1.0
            return
        }
        else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            controller.accessDelegate = self
            self.present(controller, animated: true, completion: nil)
            return
        }
        
        // not to be executed after Linked APIs version 2
        if LISDKSessionManager.hasValidSession()
        {
            Toast(text: "LinkedIn added successfully").show()
            self.linkedInButton.alpha = 1.0
            return
        }

        if (SignInViewController.linkedinHelper == nil) {
            let config = LinkedinSwiftConfiguration(clientId: Constants.LinkedIn.clientId, clientSecret: Constants.LinkedIn.clientSecret, state: Constants.LinkedIn.state, permissions: Constants.LinkedIn.permissions, redirectUrl: Constants.LinkedIn.redirectUrl)
            
            SignInViewController.linkedinHelper = LinkedinSwiftHelper(configuration: config!, nativeAppChecker: nil, clients: nil, webOAuthPresent: self, persistedLSToken: nil)
        }
        
        SignInViewController.linkedinHelper?.authorizeSuccess({(lsToken) -> Void in
            
            print("\n Login success lsToken: \(lsToken) \n")
            Toast(text: "LinkedIn added successfully").show()
            self.linkedInButton.alpha = 1.0
            let session = LISDKSessionManager.sharedInstance().session
            print(session?.description)
            self.requestProfileSampleToTrySaveSession()
//            LISDKSessionManager.createSession(withAuth: [LISDK_FULL_PROFILE_PERMISSION,LISDK_W_SHARE_PERMISSION], state: nil, showGoToAppStoreDialog: true, successBlock: {(_ returnState: String?) -> Void in
//                print("\("success called!")")
//                let session = LISDKSessionManager.sharedInstance().session as? LISDKSession
//            }) { (error) -> Void in
//                print("Error: \(error)")
//            }
            exit(0)
            //UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
        }, error: {(error) -> Void in
            self.linkedInButton.alpha = 0.6
            print("\n Error: \(error.localizedDescription) \n")
            Alert.showAlertWithMessageAndTitle(message: error.localizedDescription, title: "ERROR")
        }, cancel: {() -> Void in
            self.linkedInButton.alpha = 0.6
            print("\n User Cancelled the process... \n")
            Alert.showAlertWithMessageAndTitle(message: "You cancelled the LinkedIn-login process.", title: "CANCELLED!")
        })
    }
    
    func requestProfileSampleToTrySaveSession()
    {
        // hitting this api to test does it helps saving session to likned in
        SignInViewController.linkedinHelper?.requestURL(Constants.LinkedIn.requestURL, requestType: LinkedinSwiftRequestGet, success: { (response) -> Void in
            print("\n Request success with response: \(response.jsonObject!) \n")
            let session = LISDKSessionManager.sharedInstance().session
            print(session?.description)
        }) {(error) -> Void in
            // Also called when user press done button
            print("\n Error: \(error.localizedDescription) \n")
        }
    }
    
    // MARK: - Twitter Methods
    func checkTwitterAvailability() {
        
        if (UserDefaults.standard.string(forKey: Constants.Twitter.TWITTER_Token) != nil) {
            let twitter_USERID = UserDefaults.standard.string(forKey: Constants.Twitter.TWITTER_Token)
            if (twitter_USERID == nil) {
                self.twitterButton.alpha = 0.6
                return
            }
            print("Twitter use:: ", twitter_USERID ?? "abc787")
            self.twitterButton.alpha = 1.0
        }
        else {
            self.twitterButton.alpha = 0.6
        }
    }
    
    func signinWithTwitter() {
        // Swift
        if (UserDefaults.standard.string(forKey: Constants.Twitter.TWITTER_Token) != nil) {
            let twitter_USERID = UserDefaults.standard.string(forKey: Constants.Twitter.TWITTER_Token)
            if (twitter_USERID == nil) {
                return
            }
            Toast(text: "Twitter added successfully").show()
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TWTRWebViewController") as! TWTRWebViewController
        controller.accessDelegate = self
        self.present(controller, animated: true, completion: nil)
        return
        
//        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
//            if (session != nil) {
//                let store = TWTRTwitter.sharedInstance().sessionStore
//                print("signed in as \(session?.userName)")
//                self.twitterButton.alpha = 1.0
//
//                UserDefaults.standard.setValue("\((session?.userID)!)", forKey: Constants.Twitter.TWITTER_USER_ID)
//                UserDefaults.standard.synchronize()
//            } else {
//                print("error: \(error?.localizedDescription)")
//                self.twitterButton.alpha = 0.6
//            }
//        })
    }
    
    func moveBack() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func button_cancelAction(_ sender: Any) {
        self.moveBack()
    }
    
    func isValidUrlString (myString: String) -> Bool {
        let urlRegEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: myString)
    }
    
    @IBAction func button_saveTapped(_ sender: Any)
    {
        
//        if (self.textfield_ProfileUrl.text! == "") {
//            Toast(text: "Please enter link for LinkedIn Profile!", duration: Delay.short).show()
//            return
//        }
//        if (self.textfield_hourlyRate.text! == "£") {
//            Toast(text: "Please enter hourly Rate", duration: Delay.short).show()
//            return
//        }
        
        
//        let array = textfield_hourlyRate.text!.components(separatedBy: "£")
//        print(array[1])
        
//        let hourlyRateValue  =  Int(array[1]) ?? 0
        
//        if ( hourlyRateValue  < 0 ){
//            Toast(text: "Hourly Rate Must be Greater then 0", duration: Delay.short).show()
//            return
//        }
        if (!self.isValidUrlString(myString: self.textfield_ProfileUrl.text!)) {
            Toast(text: "Not a valid link!", duration: Delay.short).show()
            return
        }
      /*  if (!self.textfield_ProfileUrl.text!.lowercased().contains(find: "linkedin.com/in/")) {
            Toast(text: "Link does not seems to be of a valid LinkedIn Profile!", duration: Delay.short).show()
            return
        }*/
//        if (!self.textfield_ProfileUrl.text!.contains(find: "https://linkedin.com/in/")) {
//            Toast(text: "Link does not seems to be of a valid LinkedIn Profile!", duration: Delay.short).show()
//            return
//        }
        
        if ((textfield_ProfileUrl.text?.contains(find: "https://linkedin.com/in/")) != nil){
            DispatchQueue.main.async {
                self.updateUserData()
            }
            
        }else{
            Toast(text: "Link does not seems to be of a valid LinkedIn Profile!", duration: Delay.short).show()
        }
        
       
    }
    
    @IBAction func button_cameraTapped(_ sender: Any)
    {
       // self.showImagePicker()
        self.showImagePickerView()
    }
    
    @IBAction func facebookAction(_ sender: UIButton) {
        // facebook Action
        self.signinWithFacebook()
    }
    
    @IBAction func twitterAction(_ sender: UIButton) {
        // twitter Action
        self.signinWithTwitter()
    }
    
    @IBAction func linkedInAction(_ sender: UIButton) {
        // LinkedIn Action
        self.signinWithLinkedIn()
    }
    
   /* func showImagePicker()
    {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.cropHeightRatio = 0.6 // Height-to-width ratio. The default value is 1, which means a squared-size photo.
        fusuma.allowMultipleSelection = false // You can select multiple photos from the camera roll. The default value is false.
        self.present(fusuma, animated: true, completion: nil)
    }*/
    
    func showImagePickerView()
    {
        
        let alertController = UIAlertController(title: "Upload Image", message: "Choose Image to Upload", preferredStyle: .actionSheet)
        
        let cameraButton = UIAlertAction(title: "Take a Photo", style: .default, handler: { (action) -> Void in
            print("take photo pressed")
            self.imagePickerController = UIImagePickerController()
            self.imagePickerController.delegate = self
            self.imagePickerController.sourceType = .camera
           self.imagePickerController.allowsEditing = true
            self.present(self.imagePickerController, animated: true, completion: nil)
        })
        
        let  galleryButton = UIAlertAction(title: "Choose from Gallery", style: .default, handler: { (action) -> Void in
            print("choose from gallery tapped")
            print("Choose picture pressed")
            self.imagePickerController = UIImagePickerController()
            self.imagePickerController.delegate = self
            self.imagePickerController.sourceType =  UIImagePickerController.SourceType.photoLibrary
           self.imagePickerController.allowsEditing = true
            self.present(self.imagePickerController, animated: true, completion: nil)
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        
        alertController.addAction(cameraButton)
        alertController.addAction(galleryButton)
        alertController.addAction(cancelButton)
        
        self.present(alertController,animated: true, completion: nil)
    }
    
    func updateUserData()
    {
        if(self.current_UserData.rate == self.textfield_hourlyRate.text) {
            print("Job Title and Hourly rate not changed... so, no need to update data")
            self.moveBack()
        }
        else
        {
           // self.current_UserData.skills = self.textfield_jobTitle.text!
            self.current_UserData.name = self.lblUsername.text!
            
            self.current_UserData.rate = self.textfield_hourlyRate.text!
            self.current_UserData.link = self.textfield_ProfileUrl.text!
            self.current_UserData.rate.removeFirst()
            
            let data = ["\(Constants.UserFields.username)": self.current_UserData.username as AnyObject, "\(Constants.UserFields.name)": self.current_UserData.name as AnyObject, "\(Constants.UserFields.rate)": self.current_UserData.rate as AnyObject,"\(Constants.UserFields.link)": current_UserData.link as AnyObject] as AnyObject
            
            Utilities.show_ProgressHud(view: self.view)
            self.dataAccess.Update_Data_in_UsersTable(data, delegate: self)
        }
    }
    
//    func showJobTitles_PopUp()
//    {
//        self.popupListView = XMPopupListView.init(boundView: self.textfield_jobTitle, dataSource: self, delegate: self)
//
//        self.popupListView?.backgroundColor = UIColor.clear
//        self.view.addSubview(self.popupListView!)
//        popupListView?.show()
//    }
    
    func upload_ProfileImage()
    {
        let image_data = self.compressImage(self.selectedImage!)
        let image : String = (image_data.base64EncodedString())
//        var name : String = CurrentUser.get_User_username_fromUserDefaults()
        //get_User_useremail_fromUserDefaults
        var name : String = CurrentUser.get_User_useremail_fromUserDefaults()
        name = name + ".png"
        self.isImageChanged = true
        uploadImage(url:Constants.API_URLs.uploadProfileImage_URL, withParams:["base64": image , "ImageName" : name ])
        {
            (succeeded: Bool, msg: String?) -> () in
            if succeeded == true
            {
                if msg == nil
                {
                    
                    DispatchQueue.main.async{
                        print("Uploading Failed")
                        //Alert.showAlertWithMessage(message: "Uploading Failed" , fromViewController: self)
                        
                        SDImageCache.shared().clearMemory()
                        SDImageCache.shared().clearDisk()
                    }
                    print("\n\nMessage is nil ::: \(String(describing: msg))")
                }
                else
                {
                    DispatchQueue.main.async{
                        //Alert.showAlertWithMessage(message: "Image Uploaded" , fromViewController: self)
                        
                        SDImageCache.shared().clearMemory()
                        SDImageCache.shared().clearDisk()
                        print("Image Uploaded")
                    }
                    print("\n\nMessage is ::: \(String(describing: msg))")
                }
            }
            else
            {
                print("Uploading Failed")
                print("\n\nError fetching Data !!! ")
            }
        }
    }
    
    func compressImage (_ image: UIImage) -> Data
    {
        let compressionQuality:CGFloat = 0.5
        
        let rect:CGRect = CGRect(x: 0, y: 0, width: 75, height: 75)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        let imageData:Data = UIImageJPEGRepresentation(img, compressionQuality)!//! as Data
        
        return imageData
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
                postCompleted(true, dataString! as String)
            }
            else
            {
                Alert.showAlertWithMessageAndTitle(message: "NO INTERNET CONNECTION", title: "Error")
                print("\n\nERROR !!! NO INTERNET CONNECTION...DATA IS NIL")
            }
        })
        task.resume()
    }
    
    /*
     
     |||||||||||||||||||||||||||||||||||||||||||||||||||||
     ||                                                 ||
     ||        *****    DELEGATE METHODS    *****       ||
     ||                                                 ||
     |||||||||||||||||||||||||||||||||||||||||||||||||||||
     
     */
    
    // UITextFieldDelegate methods
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
//        if(textField == self.textfield_jobTitle)
//        {
//            textField.resignFirstResponder()
//            self.showJobTitles_PopUp()
//        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if(textField == self.textfield_hourlyRate)
        {
            let range = (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length < 1
            
            if(range)
            {
                return false
            }
            else
            {
                return true
            }
        }
        else
        {
            return true
        }
    }
    
    // FusumaDelegate Methods
    // Return the image which is selected
/*    func fusumaImageSelected(_ image: UIImage, source: FusumaMode)
    {
        print("\n fusumaImageSelected called ... \n")
        switch source {
        case .camera:
            print("Image captured from Camera")
            break
        case .library:
            print("Image selected from Camera Roll")
            break
        default:
            print("Image selected")
            break
        }
        
        DispatchQueue.main.async
        {
            self.selectedImage = image
            self.profileImage.image = self.selectedImage?.circle
            
            self.upload_ProfileImage()
        }
    }
    
    // Return the image but called after is dismissed.
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {
        
        print("\n fusumaDismissedWithImage called ... \n")
        switch source
        {
        case .camera:
            print("Called just after dismissed FusumaViewController using Camera")
        case .library:
            print("Called just after dismissed FusumaViewController using Camera Roll")
        default:
            print("Called just after dismissed FusumaViewController")
        }
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
        print("\n fusumaVideoCompleted called ... \n")
        print("video completed and output to file: \(fileURL)")
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized()
    {
        print("\n fusumaCameraRollUnauthorized called ... \n")
        
        //  Alerts.CallTwoButtonPopUp(VC: self, title: "Access Requested", message: "Saving image needs to access your photo album", okButtonText: Constants.Strings.Settings, cancelButtonText: Constants.Strings.Cancel, delegate: self, tagID: 1, alert_type: .information)
        
        print("Camera roll unauthorized")
        
        let alert = UIAlertController(title: "Access Requested",
                                      message: "Saving image needs to access your photo album",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { (action) -> Void in
            
            if let url = URL(string:UIApplicationOpenSettingsURLString)
            {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            
        })
        
        guard let vc = UIApplication.shared.delegate?.window??.rootViewController,
            let presented = vc.presentedViewController else {
                return
        }
        
        presented.present(alert, animated: true, completion: nil)
    }
    
    // Return selected images when you allow to select multiple photos.
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        
        print("\n fusumaMultipleImageSelected called ... \n")
        print("Number of selection images: \(images.count)")
        
        var count: Double = 0
        
        for image in images {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (3.0 * count)) {
                
                print("w: \(image.size.width) - h: \(image.size.height)")
            }
            count += 1
        }
        
//        DispatchQueue.main.async
//            {
//                self.selectedImage = images[0]
//                self.profileImage.image = self.selectedImage?.circle
//
//                self.upload_ProfileImage()
//        }
    }
    
    func fusumaClosed()
    {
        print("\n fusumaClosed called ... \n")
    }*/
    
    //          ***************************
}

extension EditProfileVC: UpdateUser_Delegate
{
    // UpdateUser_Delegate methods
    func UpdateUser_ResponseSuccess(updated_user: User, status: Bool)
    {
        DispatchQueue.main.async {
            Utilities.hide_ProgressHud(view: self.view)
        }
        
        print("\n UpdateUser_ResponseSuccess called ... And updated_userName = \(self.current_UserData.username) \n")
        
        CurrentUser.setCurrentUser_UserDefaults(user: self.current_UserData)
        CurrentUser.Current_UserObject = CurrentUser.getCurrentUser_From_UserDefaults()
        
        self.moveBack()
    }
    
    func UpdateUser_ResponseError(_ error:NSError?)
    {
        Utilities.hide_ProgressHud(view: self.view)
        print("\n UpdateUser_ResponseError called... And Error = \(String(describing: error?.localizedDescription)) \n")
    }
}

extension EditProfileVC: XMPopupListViewDelegate, XMPopupListViewDataSource
{
    // XMPopupListViewDelegate Methods
    func clickedListViewAtIndexPath(indexPath: IndexPath)
    {
        let object = self.jobsTitle_List[indexPath.row]
        print("\n selected case = \(object.rawValue) \n")
        
        self.selectedJobTitle_case = object
//        self.textfield_jobTitle.text = self.selectedJobTitle_case.rawValue
//        self.textfield_jobTitle.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    // XMPopupListViewDataSource Methods
    
    internal func titleInSection(section: NSInteger) -> NSString
    {
        return "Select Job Title"
    }
    
    internal func numberOfSections() -> NSInteger {
        return 1
    }
    
    func numberOfRowsInSection(section: Int) -> Int
    {
        return self.jobsTitle_List.count
    }
    
    func itemCellHeight(indexPath: IndexPath) -> CGFloat
    {
        return 40
    }
    
    func itemCell(indexPath: IndexPath) -> UITableViewCell
    {
        if self.jobsTitle_List.count == 0 {
            return UITableViewCell()
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = self.jobsTitle_List[indexPath.row].rawValue
        return cell
    }
}

extension EditProfileVC: MyLITokenRequestDelegate {
    func success(accessToken: String) {
        print("\n Login success lsToken: \(accessToken) \n")
        Toast(text: "LinkedIn added successfully").show()
        self.linkedInButton.alpha = 1.0
        ////let session = LISDKSessionManager.sharedInstance().session
        ////print(session?.description)
        //////self.requestProfileSampleToTrySaveSession()
    }
    
    func error(message: String) {
        self.linkedInButton.alpha = 0.6
        print("\n Error: \(message) \n")
        Alert.showAlertWithMessageAndTitle(message: message, title: "ERROR")
    }
}

extension EditProfileVC: MyTWTRTokenRequestDelegate {
    
    func twtrSuccess(accessToken: String) {
//        print("\n Login success twitterToken: \(accessToken) \n")
//        Toast(text: "Twitter added successfully").show()
        self.twitterButton.alpha = 1.0
    }
    
    func twtrError(message: String) {
        self.twitterButton.alpha = 0.6
        print("\n Error Twitter: \(message) \n")
        Alert.showAlertWithMessageAndTitle(message: message, title: "ERROR")
    }
}
extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        var rawImage: UIImage

        if let possibleImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            rawImage = possibleImage
        } else if let possibleImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            rawImage = possibleImage
        } else {
            return
        }
        
        
        DispatchQueue.main.async
        {
            self.selectedImage = rawImage
            self.profileImage.image = self.selectedImage?.circle
            
            self.upload_ProfileImage()
        }
        
        print("image selected")
        self.dismiss(animated: true, completion: nil)
    }
}
