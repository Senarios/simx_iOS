//
//  CreateStreamVC.swift
//  CyberScope
//
//  Created by Saad Furqan on 05/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Toaster

class CreateStreamVC: UIViewController
{
    
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var imgCheckbox: UIImageView!
    @IBOutlet weak var btnIsJob: UIButton!
    @IBOutlet weak var lblIsJob: UILabel!
    
    //Apply job check
    
    @IBOutlet weak var applyVideoImg: UIImageView!
    @IBOutlet weak var applyJobImg: UIImageView!
    @IBOutlet weak var messageOnlyImg: UIImageView!
    @IBOutlet weak var callOnlyImg: UIImageView!
    @IBOutlet weak var bothImg: UIImageView!
    @IBOutlet weak var btnAddTags: UIButton!
    @IBOutlet weak var viewTagsOuter: UIView!
    @IBOutlet weak var tfTags: UITextField!
    @IBOutlet weak var viewAddTags: UIView!
    @IBOutlet weak var btnShowTagsView: UIButton!
    @IBOutlet weak var viewTags: UIView!
    
    @IBOutlet weak var addresslbl: UILabel!
    
    @IBOutlet weak var tfJobURL: UITextField!
//    @IBOutlet weak var viewJobURL: UIView! {
//        didSet {
//            viewJobURL.isHidden = true
//        }
//    }
    var urlCheck : Bool = false
    
    @IBOutlet weak var showUrlPopup: UIButton!
    @IBAction func showUrlPopup(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "YouTubeURLPopup") as? YouTubeURLPopup
        vc!.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc!.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        vc!.url = tfJobURL.text ?? ""
        vc!.checkYouTube = "YES"
      
        vc!.callback = { message in
            print(message)
            if message.isEmpty == true{
                print(message)
               
            }else{
                print(message)
                var urlStr = message
                if(!message.contains("http")){
                    urlStr = "https://" + message
                }
                self.tfJobURL.text = urlStr
            }
        }
        present(vc!, animated: true, completion: nil)
    }
    
    @IBOutlet weak var button_cancel: UIButton!
    @IBOutlet weak var goLiveButton: UIButton!
    @IBOutlet weak var rearCameraRadioButton: DLRadioButton!
    
//    @IBOutlet weak var facebookTickImage: UIImageView!
//    @IBOutlet weak var twitterTickImage: UIImageView!
//    @IBOutlet weak var linkedInTickImage: UIImageView!
    
    @IBOutlet weak var viewPitchTitle: UIView!
    //@IBOutlet weak var titleTextContainer: UIView!
    @IBOutlet weak var broadcastTitleField: UITextField!
    
//    @IBOutlet weak var facebookButton: UIButton!
//    @IBOutlet weak var twitterButton: UIButton!
//    @IBOutlet weak var linkedInButton: UIButton!
    
    
    var preferredCamera = "Rear"
    
    var isJobSelected: Bool = false
    var tagsCollection: [String] = []
    var videoObject = COVideo()
    
    @IBOutlet weak var applyVideoBtn: UIButton!
    @IBAction func applyVideoBtn(_ sender: Any) {
        applyBtnCheck(btn: applyVideoBtn)
        showUrlPopup.isUserInteractionEnabled = false
    }
    
    @IBOutlet weak var applyJobBtn: UIButton!
    @IBAction func applyJobBtn(_ sender: Any) {
        applyBtnCheck(btn: applyJobBtn)
        showUrlPopup.isUserInteractionEnabled = true

        
    }
    @IBOutlet weak var messageOnlyBtn: UIButton!
    @IBAction func messaheOnlyBtn(_ sender: Any) {
        contactTypeCheck(btn: messageOnlyBtn)
        self.videoObject.messageonly = msgString
        self.videoObject.callonly = callString
        self.videoObject.bothmsgcall = bothString
    }
    @IBOutlet weak var callOnlyBtn: UIButton!
    @IBAction func callOnlyBtn(_ sender: Any) {
        contactTypeCheck(btn: callOnlyBtn)
        self.videoObject.messageonly = msgString
        self.videoObject.callonly = callString
        self.videoObject.bothmsgcall = bothString
    }
    @IBOutlet weak var bothBtn: UIButton!
    @IBAction func bothBtn(_ sender: Any) {
        contactTypeCheck(btn: bothBtn)
        self.videoObject.messageonly = msgString
        self.videoObject.callonly = callString
        self.videoObject.bothmsgcall = bothString
    }
    
    @IBOutlet weak var locationBtn: UIButton!
    @IBAction func locationBtn(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MyMapVC") as? MyMapVC
        
        vc!.callback = { lat, long, address in
            print(lat, long, address)
            if address.isEmpty == true{
                print(lat, long, address)
            }else{
               print(lat, long, address)
                self.addString = address
                self.addresslbl.text = address
                self.latti = lat
                self.longi = long
//                self.videoObject.location = address
//                self.videoObject.latti = lat
//                self.videoObject.longi = long
            }
        }
        
        vc!.modalPresentationStyle = .fullScreen
        present(vc!, animated: true, completion: nil)
    }
    @IBOutlet weak var enableCommentsIconButton: UIButton!
    @IBAction func enableCommentsButtonAction(_ sender: UIButton) {
        
        if (self.enableCommentsIconButton.isSelected) {
            //Toast(text:"You hae disabled comments!", delay: Delay.short).show()
            self.enableCommentsIconButton.isSelected = false
            return
        }
        // this is else case
        self.enableCommentsIconButton.isSelected = true
    }
    
    @IBAction private func cameraSelectedButton(radioButton : DLRadioButton)
    {
        preferredCamera = radioButton.selected()!.titleLabel!.text!
        print(preferredCamera);
    }
    
    var applyVideoString : Bool!
    var applyJobSiteString : Bool!
    var msgString: Bool!
    var callString : Bool!
    var bothString : Bool!
    var addString = ""
    var latti = ""
    var longi = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        msgString = true
        callString = false
        bothString = false
        applyVideoString = true
        applyJobSiteString = false
        tfJobURL.isUserInteractionEnabled = false
        showUrlPopup.isUserInteractionEnabled = false
        myScrollView.bounces = false
        
        print("###come in create stream vc")
        //        self.checkFacebookAvailability()
        //        self.checkTwitterAvailability()
        //        self.checkLinkedInAvailability()
        
        rearCameraRadioButton.setSelected(true)
        self.setUpControls()
    }
    
    func setUpControls()
    {
        self.viewPitchTitle.layer.cornerRadius = 10
        self.viewPitchTitle.layer.borderWidth = 1
        self.viewPitchTitle.layer.borderColor = UIColor.lightGray.cgColor
        self.viewPitchTitle.backgroundColor = .white
        
        locationBtn.layer.cornerRadius = 10.0
        locationBtn.clipsToBounds = true
        
        self.viewTagsOuter.layer.cornerRadius = 10
        self.viewTagsOuter.layer.borderWidth = 1
        self.viewTagsOuter.layer.borderColor = UIColor.lightGray.cgColor
        self.viewTagsOuter.backgroundColor = .white
        
        self.btnAddTags.layer.cornerRadius = 15
        self.btnShowTagsView.layer.cornerRadius = 14
        
        self.viewAddTags.backgroundColor = UIColor(red: CGFloat(0.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(0.0/255.0), alpha: CGFloat(0.5))
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.CloseTagsView))
        gesture.delegate = self
        self.viewAddTags.addGestureRecognizer(gesture)
            
        self.viewAddTags.isHidden = true
        self.viewTags.backgroundColor = .clear
        
        self.tfTags.delegate = self
        self.broadcastTitleField.delegate = self
        
        if (CurrentUser.Current_UserObject.skills == Constants.userSkillsType.freelancer) {
            self.imgCheckbox.isHidden = true
            self.btnIsJob.isHidden = true
            self.lblIsJob.isHidden = true
        }
    }
    
    @objc func CloseTagsView(sender : UITapGestureRecognizer) {
        // Do what you want
        
        self.viewAddTags.isHidden = true
    }
    
    @IBAction func jobCheckboxClicked(_ sender: Any) {
        self.isJobSelected = !self.isJobSelected
        self.imgCheckbox.image = self.isJobSelected ? UIImage(named: "checkbox") : UIImage(named: "checkbox_empty")
        //self.viewJobURL.isHidden = !self.isJobSelected
    }
    
//  //  MARK: Check boxes for
    func applyBtnCheck(btn: UIButton){
        if btn == applyVideoBtn{
            applyVideoImg.image = UIImage(named: "radioCheck")
            applyJobImg.image = UIImage(named: "circleIcone")
            applyVideoString = true
            applyJobSiteString = false
            self.videoObject.Applyonvideo = true
            self.videoObject.Applyonjobsite = false
            self.urlCheck = false
            tfJobURL.text = ""
        }else if btn == applyJobBtn{
            
            applyVideoImg.image = UIImage(named: "circleIcone")
            applyJobImg.image = UIImage(named: "radioCheck")
            applyVideoString = false
            applyJobSiteString = true
            self.videoObject.Applyonvideo = false
            self.videoObject.Applyonjobsite = true
            self.urlCheck = true

        }

    }
    
    
    func contactTypeCheck(btn: UIButton){
        if btn == messageOnlyBtn{
            messageOnlyImg.image = UIImage(named: "radioCheck")
            callOnlyImg.image = UIImage(named: "circleIcone")
            bothImg.image = UIImage(named: "circleIcone")
            msgString = true
            callString = false
            bothString = false
        }else if btn == callOnlyBtn{
            messageOnlyImg.image = UIImage(named: "circleIcone")
            callOnlyImg.image = UIImage(named: "radioCheck")
            bothImg.image = UIImage(named: "circleIcone")
            msgString = false
            callString = true
            bothString = false
        }else if btn == bothBtn{
            messageOnlyImg.image = UIImage(named: "circleIcone")
            callOnlyImg.image = UIImage(named: "circleIcone")
            bothImg.image = UIImage(named: "radioCheck")
            msgString = false
            callString = false
            bothString = true
        }
        
    }
    
//    func checkFacebookAvailability() {
//        if (FBSDKAccessToken.current() == nil) {
//            self.facebookButton.alpha = 0.6
//            self.facebookButton.isUserInteractionEnabled = false
//            return
//        }
//        else if FBSDKAccessToken.current().hasGranted("publish_actions") {
//            self.facebookButton.alpha = 1.0
//            self.facebookButton.isUserInteractionEnabled = true
//        }
//        else {
//            self.facebookButton.alpha = 0.6
//            self.facebookButton.isUserInteractionEnabled = false
//        }
//    }
    
    @IBAction func addTagClicked(_ sender: Any) {
        
        if self.tfTags.text!.count > 0 && self.tfTags.text!.count < 12 {

            // Checking if user adding the same tag then return from here
            if tagsCollection.contains(self.tfTags.text!) {
                return
            }

            // remove all subviews first if user added tags before
            self.viewTags.subviews.forEach({$0.removeFromSuperview()})
            print(self.tfTags.text!)

            self.tagsCollection.append(self.tfTags.text!)
            self.viewAddTags.isHidden = true
            self.tfTags.text = ""

            var lTags = [String]()
            for tag in self.tagsCollection {
                let ltagExist = lTags.filter { $0 == tag }
                if ltagExist.count == 0 {
                    lTags.append(tag)
                }
            }


            let tags = lTags.map { button(with: $0) }
            tags.forEach({$0.addTarget(self, action: #selector(removeTag(_:)), for: .touchUpInside)})
            let frame = CGRect(x: 0, y: 0, width: self.viewTags.frame.width, height: self.viewTags.frame.height)
            let tagsView = TagsView(frame: frame)
            tagsView.backgroundColor = .none
            tagsView.create(cloud: tags)
            self.viewTags.addSubview(tagsView)

        }
        else
        {
            self.showAlert("Alert", message: "Tag length must be less than 12")
        }
    }
    
    @objc func removeTag(_ sender: UIButton) {
        
        print(sender.titleLabel?.text ?? "", "Tapped")
        self.tagsCollection.removeAll(where: {$0 == sender.titleLabel?.text})
        sender.removeFromSuperview()
        
        self.viewTags.subviews.forEach({$0.removeFromSuperview()})
        var lTags = [String]()
        for tag in self.tagsCollection {
            let ltagExist = lTags.filter { $0 == tag }
            if ltagExist.count == 0 {
                lTags.append(tag)
            }
        }
        let tags = lTags.map { button(with: $0) }
        tags.forEach({$0.addTarget(self, action: #selector(removeTag(_:)), for: .touchUpInside)})
        let frame = CGRect(x: 0, y: 0, width: self.viewTags.frame.width, height: self.viewTags.frame.height)
        let tagsView = TagsView(frame: frame)
        tagsView.backgroundColor = .none
        tagsView.create(cloud: tags)
        self.viewTags.addSubview(tagsView)
    }
    
    @IBAction func showTagsViewClicked(_ sender: Any) {
        
        if self.tagsCollection.count > 4 {
            return
        }
        
        self.tfTags.becomeFirstResponder()
        self.viewAddTags.isHidden = false
    }
    
//    func checkTwitterAvailability() {
//        if (UserDefaults.standard.string(forKey: Constants.Twitter.TWITTER_Token) != nil) {
//            let twitter_USERID = UserDefaults.standard.string(forKey: Constants.Twitter.TWITTER_Token)
//            if (twitter_USERID == nil) {
//                self.twitterButton.alpha = 0.6
//                self.twitterButton.isUserInteractionEnabled = false
//                return
//            }
//            print("Twitter use:: ", twitter_USERID ?? "abc787")
//            self.twitterButton.alpha = 1.0
//            self.twitterButton.isUserInteractionEnabled = true
//        }
//        else {
//            self.twitterButton.alpha = 0.6
//            self.twitterButton.isUserInteractionEnabled = false
//        }
//    }
    
//    func checkLinkedInAvailability() {
//        if let accessToken = UserDefaults.standard.value(forKey: "LIAccessToken") {
//            self.linkedInButton.alpha = 1.0
//            self.linkedInButton.isUserInteractionEnabled = true
//            print(accessToken)
//        }
//        else {
//            self.linkedInButton.alpha = 0.6
//            self.linkedInButton.isUserInteractionEnabled = false
//        }
//    }

    override func viewWillAppear(_ animated: Bool) {
        self.goLiveButton.setCornerRadiusCircle()
        //self.broadcastTitleField.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkTitleValidity() -> Bool {
        
        if(self.isJobSelected)
        {
            if(!self.isValidUrl(url: self.tfJobURL.text!))
            {
                self.showAlert("URL", message: "Entered url is invalid")
                return false
            }
        }
        
        if (self.broadcastTitleField.text == nil || self.broadcastTitleField.text == "") {
            
            self.showAlert("Alert", message: "Please put a title for new broadcast.")
            return false
        }
        else if ((self.broadcastTitleField.text?.count)! < 3) {
            self.showAlert("Title Strength", message: "Too short.")
            return false
        }
        else if (tagsCollection.count == 0) {
            self.showAlert("Tags missing", message: "Please add some tags")
            return false
        }else if self.urlCheck == true{
            
            if self.tfJobURL.text?.isEmpty == true{
                self.showAlert("Link missing", message: "Video Link is missing")
                return false
            }else{
                if addString.isEmpty == true{
                    self.showAlert("Location", message: "Select Location First")
                    return false
                }else {
                    if (!self.isValidUrl(url: self.tfJobURL.text!)){
                        self.showAlert("URL", message: "Entered url is invalid")
                        return false
                    }else{
                        self.start_Stream()
                        return true
                    }
                    
                }
            }
            
        }else{
            if addString.isEmpty == true{
                self.showAlert("Location", message: "Select Location First")
                return false
            }else{
                self.start_Stream()
                return true
            }
        }
        return true
    }
    
    func isValidUrl(url: String) -> Bool {
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: url)
        return result
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func moveTo_RootVC()
    {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func moveBack()
    {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func button_cancelAction(_ sender: Any)
    {
        self.moveBack()
    }
    
    @IBAction func goLiveButtonClicked(_ sender: UIButton) {
        
        if (!self.checkTitleValidity()) {
            return
        }
//        if addString.isEmpty == true{
//            Toast(text: "Select Location").show()
//        }else if applyVideoString.isEmpty == true || applyJobSiteString.isEmpty == true{
//
//            Toast(text: "Select Type to Apply").show()
//
//        }else if msgString.isEmpty == true || callString.isEmpty == true || bothString.isEmpty == true{
//            Toast(text: "Select Contact Type").show()
//        }else{
//            self.start_Stream()
//        }
        
        //performSegue(withIdentifier: "moveToLiveStreamVC", sender: self)
    }
    
    func start_Stream()
    {
        
        print("###come in start stream")
        let alert = UIAlertController.init(title: "Choose Broadcast Type", message: "", preferredStyle: .actionSheet)
        
        let accept = UIAlertAction.init(title: "Elevator Pitch (Max. 30 Sec)", style: .default) { action in
            //moveToLiveStreamVC
            let liveSVController = UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil).instantiateViewController(withIdentifier: "LiveStreamingViewController") as! LiveStreamingViewController
            LiveStreamingViewController.kStreamaxiaStreamName = self.broadcastTitleField.text!
            liveSVController.broadcastTitle = self.broadcastTitleField.text!
            liveSVController.lat = self.latti
            liveSVController.long = self.longi
            liveSVController.address = self.addString
            self.videoObject.latti = self.latti
            self.videoObject.longi = self.longi
            self.videoObject.location = self.addString
            self.videoObject.messageonly = self.msgString
            self.videoObject.callonly = self.callString
            self.videoObject.bothmsgcall = self.bothString
            //  applyVideoString = true
            //applyJobSiteString = false
            liveSVController.myLatitued = Double(self.latti) ?? 0.0
            liveSVController.myLongitude = Double(self.longi) ?? 0.0
            liveSVController.address = self.addString
            liveSVController.callStr = self.callString
            liveSVController.msgStr = self.msgString
            liveSVController.bothStr = self.bothString
            liveSVController.applyOnVide = self.applyVideoString
            liveSVController.applyOnJob = self.applyJobSiteString
//            liveSVController.isFacebookChoosen  = !self.facebookTickImage.isHidden
//            liveSVController.isTwitterChoosen   = !self.twitterTickImage.isHidden
//            liveSVController.isLinkedInChoosen  = !self.linkedInTickImage.isHidden
            liveSVController.jobDescriptionURL = self.tfJobURL.text ?? ""
            
            liveSVController.maxStreamLenght  = 30
            liveSVController.delegate = self
            liveSVController.isJobSelected  = self.isJobSelected
            liveSVController.tagsCollection  = self.tagsCollection
            if (self.preferredCamera == "Rear") {
                liveSVController.isFrontChoosen = false
                print ("rear 255")
            }
            else {
                liveSVController.isFrontChoosen = true
                print ("front 255")
            }
            liveSVController.modalPresentationStyle = .fullScreen
            liveSVController.isCommentsOptionChoosen = false //!self.enableCommentsIconButton.isSelected
            self.present(liveSVController, animated: true, completion: nil)
           // self.navigationController?.pushViewController(liveSVController, animated: true)
            
        }
        
        let reject = UIAlertAction.init(title: "Information Broadcast (Max. 15 Min)", style: .default) { action in
            //moveToLiveStreamVC
            let liveSVController = UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil).instantiateViewController(withIdentifier: "LiveStreamingViewController") as! LiveStreamingViewController
            LiveStreamingViewController.kStreamaxiaStreamName = self.broadcastTitleField.text!
            self.videoObject.latti = self.latti
            self.videoObject.longi = self.longi
            self.videoObject.location = self.addString
            liveSVController.lat = self.latti
            liveSVController.long = self.longi
            liveSVController.address = self.addString
//            liveSVController.isFacebookChoosen  = !self.facebookTickImage.isHidden
//            liveSVController.isTwitterChoosen   = !self.twitterTickImage.isHidden
//            liveSVController.isLinkedInChoosen  = !self.linkedInTickImage.isHidden
            
            liveSVController.maxStreamLenght  = 900
            liveSVController.jobDescriptionURL = self.tfJobURL.text ?? ""
            liveSVController.delegate = self
            liveSVController.isJobSelected  = self.isJobSelected
            liveSVController.tagsCollection  = self.tagsCollection
            
            if (self.preferredCamera == "Rear") {
                liveSVController.isFrontChoosen = false
                print ("rear 255")
            }
            else {
                liveSVController.isFrontChoosen = true
                print ("front 255")
            }
            liveSVController.isCommentsOptionChoosen = false //!self.enableCommentsIconButton.isSelected
            liveSVController.modalPresentationStyle = .fullScreen
            // self.navigationController?.pushViewController(liveSVController, animated: true)
            self.present(liveSVController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction.init(title: "Cancel", style: .default) { action in
        }
        alert.addAction(accept)
        alert.addAction(reject)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    func showAlert(_ title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .black
    }
    
    @IBAction func facebookAction(_ sender: UIButton) {
        // facebook Action
//        if self.facebookTickImage.isHidden {
//            self.facebookTickImage.isHidden = false
//            return
//        }
//        self.facebookTickImage.isHidden = true
    }
    
    @IBAction func twitterAction(_ sender: UIButton) {
        // twitter Action
//        if self.twitterTickImage.isHidden {
//            self.twitterTickImage.isHidden = false
//            return
//        }
//        self.twitterTickImage.isHidden = true
    }
    
    @IBAction func linkedInAction(_ sender: UIButton) {
        // LinkedIn Action
//        if self.linkedInTickImage.isHidden {
//            self.linkedInTickImage.isHidden = false
//            return
//        }
//        self.linkedInTickImage.isHidden = true
    }
}

extension CreateStreamVC: LiveStreamingViewControllerDelegate {
    func StreamClosed() {
     
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 , execute: {
            self.navigationController?.popViewController(animated: true)
        })
    }
}

extension CreateStreamVC: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return gestureRecognizer.view === touch.view
    }
}

extension CreateStreamVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfTags || textField == broadcastTitleField {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}

extension CreateStreamVC {
    func button(with title: String) -> UIButton {
        var font = UIFont.preferredFont(forTextStyle: .body)
       // [UIFont boldSystemFontOfSize:13.f]
        font = font.withSize(11)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = title.size(withAttributes: attributes)
        
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = font
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = (size.height + 10.0 ) / 2
        button.backgroundColor = UIColor(red: CGFloat(10.0/255.0), green: CGFloat(73.0/255.0), blue: CGFloat(122.0/255.0), alpha: CGFloat(1.0))
        button.frame = CGRect(x: 10.0, y: 0.0, width: size.width + 20.0, height: size.height + 10.0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0)
        return button
    }
}
