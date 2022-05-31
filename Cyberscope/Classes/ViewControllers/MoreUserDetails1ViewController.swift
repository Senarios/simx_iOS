//
//  MoreUserDetails1ViewController.swift
//  CyberScope
//
//  Created by Salman on 10/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import Toaster
import Fusuma
import FirebaseAuth
import DropDown

class MoreUserDetails1ViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userJobTitleTextField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var viewerButton: UIButton!
    @IBOutlet weak var broadcasterButton: UIButton!
    
    @IBOutlet weak var viewerViewContainer: UIView!
    @IBOutlet weak var viewerLabel: UILabel!
    @IBOutlet weak var viewerImage: UIImageView!
    
    @IBOutlet weak var broadcasterViewContainer: UIView!
    @IBOutlet weak var broadcasterLabel: UILabel!
    @IBOutlet weak var broadcasterImage: UIImageView!
    
    @IBOutlet weak var viewerOrBroadcasterDetailsLabel: UILabel! {
        didSet {
            viewerOrBroadcasterDetailsLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var takePictureMotivationalImage: UIImageView!
    @IBOutlet weak var userPictureImageView: UIImageView!
    
    var imagePickerController : UIImagePickerController!
    
    // MARK: - OutletsActions
    @IBAction func doneButtonAction(_ sender: UIButton) {
        self.doneAction()
    }
    @IBAction func viewerButtonAction(_ sender: UIButton) {
        self.viewerTappedAction()
    }
    @IBAction func broadcasterButtonAction(_ sender: UIButton) {
        self.broadcasterTappedAction()
    }
    @IBAction func pickImageButtonAction(_ sender: UIButton)
    {
       // self.showImagePicker()
        self.showImagePickerView()
    }
    
    @IBOutlet weak var dismissView: UIView!
    
    // Close View
    @IBAction func closeOrDismiss(_ sender: UIButton) {
        
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBOutlet weak var jobhunterLbl: UILabel!
    @IBOutlet weak var recruiterLbl: UILabel!
    
    
    @IBOutlet weak var recruiterBtn: UIButton!
    @IBAction func recruiterBtn(_ sender: Any) {
        colorChangeBtn(btn: recruiterBtn)
       
//            recruiterBtn.setTitleColor(UIColor.green, for: UIControlState.normal)
//            jobHunterBtn.setTitleColor(UIColor.blue, for: UIControlState.normal)
            userTypeString = "Recruiter"
            UserDefaults.standard.set("Recruiter", forKey: "type")
            UserDefaults.standard.set("Recruiter", forKey: Constants.CurrentUser_UserDefaults.skills)
        
    }
    
    
    @IBOutlet weak var jobHunterBtn: UIButton!
    @IBAction func jobHunterBtn(_ sender: Any) {
        
        colorChangeBtn(btn: jobHunterBtn)
//            recruiterBtn.setTitleColor(UIColor.blue, for: UIControlState.normal)
//            jobHunterBtn.setTitleColor(UIColor.green, for: UIControlState.normal)
            userTypeString = "Job hunter"
            UserDefaults.standard.set("Job hunter", forKey: "type")
      
    }
    /*
    func showImagePicker()
    {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.cropHeightRatio = 0.6 // Height-to-width ratio. The default value is 1, which means a squared-size photo.
        fusuma.allowMultipleSelection = false // You can select multiple photos from the camera roll. The default value is false.
        
        fusumaCameraRollTitle = "Library"
        fusumaCameraTitle = "Camera"
        fusumaTintColor = Constants.appColors.colorBlue
        
        self.present(fusuma, animated: true, completion: nil)
    }*/
    
    // MARK: -
    var userTypeString = ""
    var isImageTaken = false
    
    //var user_toCreate: User?
    var nObj = UserInfoObj()
    var newObj = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.newObj.name)
        let name = UserDefaults.standard.string(forKey: "name")
        print(name)

        let cloaseTap = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        dismissView.addGestureRecognizer(cloaseTap)
        
        UserDefaults.standard.string(forKey: "email")
        //fireBaseEmailCheck(email: newObj.email, password: newObj.password)
        
        // Do any additional setup after loading the view.
        self.setup_controls()
    }
    
    @objc func dismissViewController(){
        dismiss(animated: true, completion: nil)
    }
    func colorChangeBtn(btn: UIButton){
        print(btn.titleLabel?.text)
        
        if btn.titleLabel?.text == "Recruiter"{
            recruiterLbl.textColor = .green
            jobhunterLbl.textColor = .blue
            
          
            
            
        }else if btn.titleLabel?.text == "Job hunter"{
            recruiterLbl.textColor = .blue
            jobhunterLbl.textColor = .green
            
        }
        
    }
    
    // MARK: Riz Change
    func setup_controls()
    {
        
        self.doneButton.setCornerRadiusCircle()
        self.setInitialStagesForViewContainers()
        self.setViewInitials()
        self.userTypeString = ""
        
        if(self.newObj != nil) {
            if(self.newObj.name != "") {
                self.userNameTextField.text = self.newObj.name
            }
            if(self.newObj.skills == Constants.userSkillsType.viewer) {
                self.viewerTappedAction()
                self.userJobTitleTextField.text = Constants.userSkillsType.viewer
            }
            else if(self.newObj.skills == Constants.userSkillsType.broadcaster) {
                self.broadcasterTappedAction()
                self.userJobTitleTextField.text = Constants.userSkillsType.broadcaster
            }
        }
        
    }
    
//    func setup_controls()
//    {
//        self.doneButton.setCornerRadiusCircle()
//        self.setInitialStagesForViewContainers()
//        self.setViewInitials()
//        self.userTypeString = ""
//
//        if(self.user_toCreate != nil) {
//            if(self.user_toCreate?.name != "") {
//                self.userNameTextField.text = self.user_toCreate?.name
//            }
//            if(self.user_toCreate?.skills == Constants.userSkillsType.viewer) {
//                self.viewerTappedAction()
//                self.userJobTitleTextField.text = Constants.userSkillsType.viewer
//            }
//            else if(self.user_toCreate?.skills == Constants.userSkillsType.broadcaster) {
//                self.broadcasterTappedAction()
//                self.userJobTitleTextField.text = Constants.userSkillsType.broadcaster
//            }
//        }
//    }
    
    // MARK: - Button Actions
    // MARK: Riz Change
    func doneAction() {
       
        if (self.userNameTextField.text! == "") {
            let messageToast = Toast(text: "Please provide your Name" + "!", duration: Delay.short)
            messageToast.show()
        }
        else if ((self.userNameTextField.text?.characters.count)! < 3) {
            let messageToast = Toast(text: "Name is too short, please make sure you entered your name correctly" + "!", duration: Delay.short)
            messageToast.show()
        }
//        else if (self.userJobTitleTextField.text! == "") {
//            let messageToast = Toast(text: "Please provide your job title" + "!", duration: Delay.short)
//            messageToast.show()
//        }
//        else if (userTypeString == "") {
//            let messageToast = Toast(text: "Choose your user mode " + Constants.userSkillsType.viewer + " or Client!", duration: Delay.short)
//            messageToast.show()
//        }
        else if (!self.isImageTaken) {
            let messageToast = Toast(text: "Please add your picture!", duration: Delay.short)
            messageToast.show()
        }
        else {
            // Set Data and then move to nextVC
            if(newObj != nil)
            {
                self.newObj.name = self.userNameTextField.text!
                self.newObj.skills = self.userTypeString
                
                if userTypeString.isEmpty == true{
                    Toast(text: "Select Type of User").show()
                }else{
                    self.performSegue(withIdentifier: Constants.Segues.SignupDetail_to_SignUPDetail2, sender: self)
                }
                
            }
        }
    }
    
//    func doneAction() {
//
//        if (self.userNameTextField.text! == "") {
//            let messageToast = Toast(text: "Please provide your Name" + "!", duration: Delay.short)
//            messageToast.show()
//        }
//        else if ((self.userNameTextField.text?.characters.count)! < 3) {
//            let messageToast = Toast(text: "Name is too short, please make sure you entered your name correctly" + "!", duration: Delay.short)
//            messageToast.show()
//        }
////        else if (self.userJobTitleTextField.text! == "") {
////            let messageToast = Toast(text: "Please provide your job title" + "!", duration: Delay.short)
////            messageToast.show()
////        }
////        else if (userTypeString == "") {
////            let messageToast = Toast(text: "Choose your user mode " + Constants.userSkillsType.viewer + " or Client!", duration: Delay.short)
////            messageToast.show()
////        }
//        else if (!self.isImageTaken) {
//            let messageToast = Toast(text: "Please add your picture!", duration: Delay.short)
//            messageToast.show()
//        }
//        else {
//            // Set Data and then move to nextVC
//            if(self.user_toCreate != nil)
//            {
//                self.user_toCreate?.name = self.userNameTextField.text!
//                self.user_toCreate?.skills = self.userTypeString
//
//                self.performSegue(withIdentifier: Constants.Segues.MoreUserDetails1VC_to_EnableLocationVC, sender: self)
//            }
//        }
//    }
    
    func viewerTappedAction() {
        self.viewerViewContainer.setMyCornerRadisConstColorBlue(with: 5)
        self.viewerLabel.textColor = Constants.appColors.colorBlue
        self.viewerImage.image = UIImage(named:"viewerImageBlue")
        
        self.broadcasterViewContainer.setMyCornerRadisConstColorGrey(with: 5)
        self.broadcasterLabel.textColor = Constants.appColors.colorGreyText
        self.broadcasterImage.image = UIImage(named:"broadcasterImageGrey")
        
        self.viewerOrBroadcasterDetailsLabel.text = Constants.strings.ViewerDetailString
        viewerOrBroadcasterDetailsLabel.isHidden = false
        
        //
        self.userTypeString = Constants.userSkillsType.viewer
    }
    
    func broadcasterTappedAction() {
        self.viewerViewContainer.setMyCornerRadisConstColorGrey(with: 5)
        self.viewerLabel.textColor = Constants.appColors.colorGreyText
        self.viewerImage.image = UIImage(named:"viewerImageGrey")
        
        self.broadcasterViewContainer.setMyCornerRadisConstColorBlue(with: 5)
        self.broadcasterLabel.textColor = Constants.appColors.colorBlue
        self.broadcasterImage.image = UIImage(named:"broadcasterImageBlue")
        
        self.viewerOrBroadcasterDetailsLabel.text = Constants.strings.BroadcasterDetailString
        viewerOrBroadcasterDetailsLabel.isHidden = false
        
        //
        self.userTypeString = Constants.userSkillsType.broadcaster
    }
    
    func setInitialStagesForViewContainers() {
        
        self.viewerViewContainer.setMyCornerRadisConstColorGrey(with: 5)
        self.viewerLabel.textColor = Constants.appColors.colorGreyText
        
        self.broadcasterViewContainer.setMyCornerRadisConstColorGrey(with: 5)
        self.broadcasterLabel.textColor = Constants.appColors.colorGreyText
    }
    
    func setViewInitials() {
        self.userPictureImageView.setMyCornerRadiusCircle()
    }
    
    func pickImageTappedAction() {
        
        
    }
    
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == Constants.Segues.SignupDetail_to_SignUPDetail2)
        {
//            let nextVC = segue.destination as! EnableLocationVC
//            nextVC.user_toCreate = self.newObj
            let nextVC = segue.destination as! MoreUserDetails2_VC
            nextVC.user_toCreate = self.newObj
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
    
    func upload_ProfileImage()
    {
        let image2344 = self.userPictureImageView.image!
        let image_data = self.compressImage(self.userPictureImageView.image!)
        
        
        let image : String = (image_data.base64EncodedString())
        UserDefaults.standard.set(image, forKey: "imageData")
        //MARK: Change 2022
      
    }
    
//    func uploadImage(url:String, withParams params: [String : String?] , postCompleted : @escaping (_ succeeded: Bool, _ msg: String?) -> ())
//    {
//        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
//        let session = URLSession.shared
//        request.httpMethod = "POST"
//        var bodyData = ""
//        for (key,value) in params
//        {
//            if (value == nil){ continue }
//            let scapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//            let scapedValue = value?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//            bodyData += "\(scapedKey!)=\(scapedValue!)&"
//        }
//        request.httpBody = bodyData.data(using: String.Encoding.utf8, allowLossyConversion: true)
//        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
//
//            if data != nil
//            {
//                print("\n\ndata is ::: \(String(describing: data)).\n\nresponse is \(response)")
//                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//                print(dataString)
//
//                let newV = dataString!.substring(from: 1)
//                //substring(1,dataString.length())
//                print(newV)
//
//                postCompleted(true, newV as String)
//            }
//            else
//            {
//                print("\n\nERROR !!! NO INTERNET CONNECTION...DATA IS NIL")
//            }
//        })
//        task.resume()
//    }
//    //MARK: Firebase Email Exist
//    func fireBaseEmailCheck(email: String, password: String){
//        Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
//
//            if let x = error {
//                let err = x as NSError
//                switch err.code {
//                case AuthErrorCode.wrongPassword.rawValue:
//                    Utilities.hide_ProgressHud(view: self.view)
//                    Toast(text: "wrong password").show()
//                case AuthErrorCode.invalidEmail.rawValue:
//                    Toast(text: "invalid email").show()
//                    Utilities.hide_ProgressHud(view: self.view)
//                case AuthErrorCode.accountExistsWithDifferentCredential.rawValue:
//                    Toast(text: "accountExistsWithDifferentCredential").show()
//                    Utilities.hide_ProgressHud(view: self.view)
//                case AuthErrorCode.emailAlreadyInUse.rawValue:
//                    //Toast(text: "email already in use").show()
//                    let x = authResult?.user.uid
//                    self.newObj.username = x ?? ""
//                    self.newObj.picture = x ?? ""
//                default:
//                    print("unknown error: \(err.localizedDescription)")
//                }
//            }
//
//            let x = authResult?.user.uid
//            self.newObj.username = x ?? ""
//
//            //Toast(text: "successfully created user:  \(x ?? "")").show()
//            Utilities.hide_ProgressHud(view: self.view)
//        })
//    }
}
/*
extension MoreUserDetails1ViewController: FusumaDelegate {
    
    // MARK: - ImagePickerDelegate
    // Return the image which is selected from camera roll or is taken via the camera.
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        
        print("Image selected")
        
        self.isImageTaken = true
        self.userPictureImageView.image = image.circle
        self.upload_ProfileImage()
    }
    
    // Return the image but called after is dismissed.
    func fusumaDismissedWithImage(image: UIImage, source: FusumaMode) {
        print("Called just after FusumaViewController is dismissed.")
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
        print("Called just after a video has been selected.")
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
    }
    
    // Return selected images when you allow to select multiple photos.
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        
    }
    
    // Return an image and the detailed information.
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode, metaData: ImageMetadata) {
        
    }
}*/
extension MoreUserDetails1ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            self.isImageTaken = true
            self.userPictureImageView.image = rawImage.circle
            self.upload_ProfileImage()
        }
        
        print("image selected")
        self.dismiss(animated: true, completion: nil)
    }
}
