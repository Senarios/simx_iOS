//
//  CreateStreamOfflineVC.swift
//  SimX
//
//  Created by APPLE on 07/07/2020.
//  Copyright © 2020 Agilio. All rights reserved.
//

import UIKit
import AVKit
import Toaster
import Alamofire
import CoreLocation

import MBProgressHUD
import AWSS3
import YoutubeKit

class CreateStreamOfflineVC: UIViewController {

    
    @IBOutlet weak var myScrollView: UIScrollView!
    
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var imgCheckbox: UIImageView!
    //checkboximages
    @IBOutlet weak var videoLinkCheckImage: UIImageView!
    @IBOutlet weak var addCheckImage: UIImageView!
    @IBOutlet weak var applyVideoImage: UIImageView!
    @IBOutlet weak var applyJobImage: UIImageView!
    @IBOutlet weak var msgOnlyImage: UIImageView!
    @IBOutlet weak var callOnlyImage: UIImageView!
    @IBOutlet weak var bothImage: UIImageView!
    
    @IBOutlet weak var btnAddTags: UIButton!
    @IBOutlet weak var viewTagsOuter: UIView!
    @IBOutlet weak var tfTags: UITextField!
    @IBOutlet weak var viewAddTags: UIView!
    @IBOutlet weak var btnShowTagsView: UIButton!
    @IBOutlet weak var viewTags: UIView!
    
    @IBOutlet weak var btnUploadOfflinePitch: UIButton!
    @IBOutlet weak var btnAddVideo: UIButton!
    @IBOutlet weak var tfPitchTitle: UITextField!
    @IBOutlet weak var viewPitchTitle: UIView!
    @IBOutlet weak var imgSelectedVideo: UIImageView!
    
    
    @IBOutlet weak var tfJobURL: UITextField!
    @IBOutlet weak var viewJobURL: UIView! {
        didSet {
            viewJobURL.isHidden = true
        }
    }
    
    @IBOutlet weak var imgIsJob: UIImageView!
    @IBOutlet weak var btnIsJob: UIButton!
    @IBOutlet weak var lblIsJob: UILabel!
    
    @IBOutlet weak var adressLbl: UILabel!
    
//    @IBOutlet weak var videoLinkTf: UITextField!
    
    //MARK: Buttons
    @IBOutlet weak var slctLocationBtn: UIButton!
    
    @IBAction func slctLocationBtn(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MyMapVC") as? MyMapVC
        
        
        vc!.callback = { lat, long, address in
            print(lat, long, address)
            if address.isEmpty == true{
                print(lat, long, address)
                Toast.init(text: "Please Select Location Again").show()
            }else{
               print(lat, long, address)
                print("yes location")
                self.adressLbl.text = address
                self.lat = lat
                self.long = long
            }
        }
        
        vc!.modalPresentationStyle = .fullScreen
        present(vc!, animated: true, completion: nil)
    }
    @IBOutlet weak var linkCheckBtn: UIButton!
    @IBAction func linkCheckBtn(_ sender: Any) {
        videoCheckBtnCondition(btn: linkCheckBtn)
    }
    @IBOutlet weak var addBtnCheck: UIButton!
    
    @IBAction func addBtnCheck(_ sender: Any) {
        videoCheckBtnCondition(btn: addBtnCheck)
    }
    
    @IBOutlet weak var applyVideoBtn: UIButton!
    @IBAction func applyVideoBtn(_ sender: Any) {
        applyBtnCheck(btn: applyVideoBtn)
        createStreamUrlPopupBtn.isUserInteractionEnabled = false
        tfJobUrl.isUserInteractionEnabled = false
    }
    @IBOutlet weak var applyJobBtn: UIButton!
    @IBAction func applyJobBtn(_ sender: Any) {
        applyBtnCheck(btn: applyJobBtn)
        createStreamUrlPopupBtn.isUserInteractionEnabled = true
        tfJobUrl.isUserInteractionEnabled = false
    }
    @IBOutlet weak var msgOnlyBtn: UIButton!
    @IBAction func msgOnlyBtn(_ sender: Any) {
        contactTypeCheck(btn: msgOnlyBtn)
    }
    
    @IBOutlet weak var callOnlyBtn: UIButton!
    @IBAction func callOnlyBtn(_ sender: Any) {
        contactTypeCheck(btn: callOnlyBtn)
    }
    @IBOutlet weak var bothBtn: UIButton!
    @IBAction func bothBtn(_ sender: Any) {
        contactTypeCheck(btn: bothBtn)
    }
    
    
    
    
    @IBOutlet weak var urlPopupBtn: UIButton!
    @IBAction func urlpopupBtn(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "YouTubeURLPopup") as? YouTubeURLPopup
        vc!.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc!.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        vc!.url = tfJobURL.text ?? ""
      
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
                self.linkUrl = urlStr
                self.tfJobURL.text = urlStr
                self.videoObject.videourl = urlStr
                self.videoURL = NSURL(string: urlStr)
                print(self.videoURL)
                print(self.videoURL?.lastPathComponent)
                self.selectedVideoPath = (self.videoURL?.path)!
                let imageUrl = URL(string: "https://img.youtube.com/vi/\(message.youtubeID ?? "")/default.jpg")
                
                if let data = try? Data(contentsOf: imageUrl!) {
                    // Create Image and Update Image View
                    self.imgSelectedVideo.image = UIImage(data: data)
                }
            }
        }
        present(vc!, animated: true, completion: nil)
    }
    
    
    
    @IBOutlet weak var tfJobUrl: UITextField!
    @IBOutlet weak var createStreamUrlPopupBtn: UIButton!
    @IBAction func createStreamUrlPopupBtn(_ sender: Any) {
       
        let vc = storyboard?.instantiateViewController(withIdentifier: "YouTubeURLPopup") as? YouTubeURLPopup
        vc!.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc!.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        vc!.url = tfJobUrl.text ?? ""
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
                self.tfJobUrl.text = urlStr
                self.linkUrl = urlStr
            }
        }
        present(vc!, animated: true, completion: nil)
    }
    
    var isJobSelected: Bool = false
    var isCheck: Bool = true
    var nameForVideo = ""
    var broadcastID = ""
    
    var imagePickerController = UIImagePickerController()
    var videoURL : NSURL?
    var mp4VideoURL = URL(fileURLWithPath: "")
    var selectedVideoPath: String = ""
    var tagsCollection: [String] = []
    
    let locationManager = CLLocationManager()
    
    var myLatitued = 0.0
    var myLongitude = 0.0
    var callDone: Bool = false
    
    var videoObject = COVideo()

    var lat = ""
    var long = ""
    var applyVideoString : Bool!
    var applyJobSiteString: Bool!
    var msgString: Bool!
    var callString: Bool!
    var bothString: Bool!
    var urlCheck : Bool!
    var youtubeCheckUrl : Bool!
    var linkUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        msgString = true
        callString = false
        bothString = false
        applyVideoString = true
        applyJobSiteString = false
        myScrollView.bounces = false
        btnAddVideo.isUserInteractionEnabled = false
        createStreamUrlPopupBtn.isUserInteractionEnabled = false
        tfJobUrl.isUserInteractionEnabled = false
        //imgSelectedVideo.image = UIImage(named: "scootishHealth")
        self.setUpControls()
        
//        let tfTap = UITapGestureRecognizer(target: self, action: #selector(youtubeView)
//        tfPitchTitle.addGestureRecognizer(tfTap)
        tfPitchTitle.delegate = self
//        self.setUpLocationManager()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//            self.imageCreatationAPI(videoName: "LfMmJB-Lmj16305389375044")
//        })
        
    }
    
    
    //MARK: Check boxes functions
    func videoCheckBtnCondition(btn: UIButton){
        
        if btn == linkCheckBtn{
            videoLinkCheckImage.image = UIImage(named: "radioCheck")
            addCheckImage.image = UIImage(named: "circleIcone")
            btnAddVideo.isUserInteractionEnabled = false
            urlPopupBtn.isUserInteractionEnabled = true
            tfJobURL.isUserInteractionEnabled = true
            self.youtubeCheckUrl = true
            imgSelectedVideo.image = nil
        }else if btn == addBtnCheck{
            videoLinkCheckImage.image = UIImage(named: "circleIcone")
            addCheckImage.image = UIImage(named: "radioCheck")
            btnAddVideo.isUserInteractionEnabled = true
            urlPopupBtn.isUserInteractionEnabled = false
            tfJobURL.isUserInteractionEnabled = false
            self.youtubeCheckUrl = false
            tfJobURL.text = ""
            imgSelectedVideo.image = nil
        }
        
    }
    
    func applyBtnCheck(btn: UIButton){
        if btn == applyVideoBtn{
            applyVideoImage.image = UIImage(named: "radioCheck")
            applyJobImage.image = UIImage(named: "circleIcone")
            applyVideoString = true
            applyJobSiteString = false
            self.urlCheck = false
            
        }else if btn == applyJobBtn{
            applyVideoImage.image = UIImage(named: "circleIcone")
            applyJobImage.image = UIImage(named: "radioCheck")
            tfJobUrl.text = ""
            applyVideoString = false
            applyJobSiteString = true
            self.urlCheck = true
            
        }
        
    }
    

    
    func contactTypeCheck(btn: UIButton){
        if btn == msgOnlyBtn{
            msgOnlyImage.image = UIImage(named: "radioCheck")
            callOnlyImage.image = UIImage(named: "circleIcone")
            bothImage.image = UIImage(named: "circleIcone")
            msgString = true
            callString = false
            bothString = false
        }else if btn == callOnlyBtn{
            msgOnlyImage.image = UIImage(named: "circleIcone")
            callOnlyImage.image = UIImage(named: "radioCheck")
            bothImage.image = UIImage(named: "circleIcone")
            msgString = false
            callString = true
            bothString = false
        }else if btn == bothBtn{
            msgOnlyImage.image = UIImage(named: "circleIcone")
            callOnlyImage.image = UIImage(named: "circleIcone")
            bothImage.image = UIImage(named: "radioCheck")
            msgString = false
            callString = false
            bothString = true
        }
        
    }
    
    func setUpControls()
    {
    
        
        self.btnAddVideo.imageView?.contentMode = .scaleAspectFit
        self.btnAddVideo.layer.cornerRadius = 18
        self.btnAddVideo.layer.borderWidth = 1
        self.btnAddVideo.layer.borderColor = UIColor.green.cgColor
        self.slctLocationBtn.imageView?.contentMode = .scaleAspectFit
        self.slctLocationBtn.layer.cornerRadius = 18
        self.slctLocationBtn.layer.borderWidth = 1
        self.slctLocationBtn.layer.borderColor = UIColor.green.cgColor
//
        titleView.layer.cornerRadius = 10.0
        titleView.layer.borderColor = UIColor.lightGray.cgColor
        titleView.layer.borderWidth = 1.0
        //        self.viewPitchTitle.layer.cornerRadius = 10
        //        self.viewPitchTitle.layer.borderWidth = 1
        //        self.viewPitchTitle.layer.borderColor = UIColor.lightGray.cgColor
        //        self.viewPitchTitle.backgroundColor = .white
        //
        //        self.viewJobURL.layer.cornerRadius = 10
        //        self.viewJobURL.layer.borderWidth = 1
        //        self.viewJobURL.layer.borderColor = UIColor.lightGray.cgColor
        //        self.viewJobURL.backgroundColor = .white
//
        self.viewTagsOuter.layer.cornerRadius = 10
        self.viewTagsOuter.layer.borderWidth = 1
        self.viewTagsOuter.layer.borderColor = UIColor.lightGray.cgColor
        self.viewTagsOuter.backgroundColor = .white
//
       self.btnAddTags.layer.cornerRadius = 15
        self.btnShowTagsView.layer.cornerRadius = 14
//
        self.btnUploadOfflinePitch.layer.cornerRadius = 21
        self.viewAddTags.backgroundColor = UIColor(red: CGFloat(0.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(0.0/255.0), alpha: CGFloat(0.5))
//
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.CloseTagsView))
        gesture.delegate = self
        self.viewAddTags.addGestureRecognizer(gesture)

        self.viewAddTags.isHidden = true
        self.viewTags.backgroundColor = .clear
//
//        self.tfTags.delegate = self
//        self.tfPitchTitle.delegate = self
//
//        if (CurrentUser.Current_UserObject.skills == Constants.userSkillsType.freelancer) {
//            self.imgIsJob.isHidden = true
//            self.btnIsJob.isHidden = true
//            self.lblIsJob.isHidden = true
//        }
    }
    

    @objc func CloseTagsView(sender : UITapGestureRecognizer) {
        // Do what you want
        
        self.viewAddTags.isHidden = true
    }
    
    @IBAction func backClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addVideoClicked(_ sender: Any) {
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeMovie as String]
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .black
    }
    
    @IBAction func addTagClicked(_ sender: Any) {
        
        if self.tfTags.text!.count > 0 && self.tfTags.text!.count < 12 {
            
            if tagsCollection.contains(self.tfTags.text!) {
                return
            }
            
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
            
//            let tagsView = TagsView()
//            self.viewTags.addSubview(tagsView.reloadTagsView(with: tagsCollection, selector: #selector(self.removeTag(_:)), parentView: self.viewTags, sss: self))
        }
        else
        {
            self.showAlert("Alert", message: "Tag length must be less than 12")
        }
    }
    
    @objc func removeTag(_ sender: UIButton) {
        
        print(sender.titleLabel?.text ?? "", "Tapped")
        self.tagsCollection.removeAll(where: {$0 == sender.titleLabel?.text})
//        sender.removeFromSuperview()
        
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
//        let tagsView = TagsView()
//        self.viewTags.addSubview(tagsView.reloadTagsView(with: tagsCollection, selector: #selector(removeTag(_:)), parentView: self.viewTags, sss: self))
    }
    
    @IBAction func jobCheckboxClicked(_ sender: Any) {
        self.isJobSelected = !self.isJobSelected
        self.imgCheckbox.image = self.isJobSelected ? UIImage(named: "checkbox") : UIImage(named: "checkbox_empty")
        self.viewJobURL.isHidden = !self.isJobSelected
    }
    
    @IBAction func showTagsViewClicked(_ sender: Any) {
        
        if self.tagsCollection.count > 4 {
            return
        }
        
        self.tfTags.becomeFirstResponder()
        self.viewAddTags.isHidden = false
    }
    
    @IBAction func playSelectedVideoClicked(_ sender: Any) {
        if self.selectedVideoPath.count > 5 {
            self.playThisVideoInAVPlayer(videoFileURLString: self.selectedVideoPath)
        }
    }
    
    
    func uploadYoutube(){
        self.callDone = false
        DispatchQueue.main.async {
            self.videoObject.title = self.tfPitchTitle.text!
            self.videoObject.location = self.adressLbl.text!
            self.videoObject.latti = self.lat
            self.videoObject.longi = self.long
            self.videoObject.Applyonvideo = self.applyVideoString
            self.videoObject.Applyonjobsite = self.applyJobSiteString
            self.videoObject.messageonly = self.msgString
            self.videoObject.callonly = self.callString
            self.videoObject.bothmsgcall = self.bothString
            self.videoObject.videourl = self.tfJobURL.text!
            self.videoObject.jobSiteLink = self.tfJobUrl.text ?? ""
            self.videoObject.name = ""
        }
        self.nameForNewStreamVideoObject()
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        
        
        self.encodeVideoToMP4(at: self.videoURL as! URL, completionHandler: { url, error in
            print("encodeVideoToMP4 completed")
            if let url = url {
                self.mp4VideoURL = url
                self.AWSS3TransferUtilityUploadFunction(with: self.nameForVideo , type: "mp4")
            }
            print(error)
            if let error = error {
                  // handle error
            }
        })
    }
    
    
    func UploadPitch(){
        self.callDone = false
        DispatchQueue.main.async {
            self.videoObject.title = self.tfPitchTitle.text!
            self.videoObject.location = self.adressLbl.text!
            self.videoObject.latti = self.lat
            self.videoObject.longi = self.long
            self.videoObject.Applyonvideo = self.applyVideoString
            self.videoObject.Applyonjobsite = self.applyJobSiteString
            self.videoObject.messageonly = self.msgString
            self.videoObject.callonly = self.callString
            self.videoObject.bothmsgcall = self.bothString
            self.videoObject.jobSiteLink = self.tfJobUrl.text ?? ""
            self.videoObject.isApproved = true
           
}
        self.nameForNewStreamVideoObject()
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        print(videoURL?.path)
        
        //MARK: Sending Email
      let email = "colinjohn563@gmail.com"
       
        
        DataAccess.sharedInstance.sendEmail(to: email, toName: "Colin", subject: "Job Post Approval", body: "A new broadcast \(tfPitchTitle.text ?? "") is pending for approval") { msgs in
            print(msgs)
            if self.videoURL?.pathExtension == "MOV"{
                self.encodeVideoToMP4(at: self.videoURL as! URL, completionHandler: { url, error in
                    print("encodeVideoToMP4 completed")
                    if let url = url {
                        self.mp4VideoURL = url
                        self.AWSS3TransferUtilityUploadFunction(with: self.nameForVideo , type: "mp4")
                        self.imageCreatationAPI(videoName: self.nameForVideo)
                        Constants.UserData.lastBroadcastId = self.nameForVideo
//                        self.postThumbNailImage(imageData: self.imgSelectedVideo.image!)
                    }
                    print(error)
                    if let error = error {
                        // handle error
                    }
                })


            }else{
                //self.addNewStreamVideoObject()
                self.mp4VideoURL = self.videoURL as! URL
                print("kuch nahi yar")
                if !self.callDone{
                    self.callDone = true
                    self.addNewStreamVideoObject()
                }
               
            }
            
            
        } failure: { error in
            Toast.init(text: error).show()
            MBProgressHUD.hide(for: self.view, animated: true)
        }
       
    }
    
    func nameForNewStreamVideoObject() {
        var ticks = NSDate().timeIntervalSince1970
        ticks = ticks * 10000
        let nameForNewVideo = String(format: "%10.0f", ticks)
        let uniqueVideoName = nameForNewVideo
        self.nameForVideo = CurrentUser.Current_UserObject.username + uniqueVideoName
        videoObject.broadcast = self.nameForVideo
        videoObject.jobPostStatus = "Pending"
    }
    
    func closeView() {
          self.navigationController?.popViewController(animated: true)
       // self.dismiss(animated: true, completion: nil)
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
    
    @IBAction func uploadOfflinePitchClicked(_ sender: Any) {
        
        
        
        if (!self.checkTitleValidity()) {
            return
        }
        
        let refreshAlert = UIAlertController(title: "Confirmation", message: "You really want to upload this video?", preferredStyle: UIAlertControllerStyle.alert)

        refreshAlert.addAction(UIAlertAction(title: "LETS GO!", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Yes Logic here")
            
            self.UploadPitch()
          }))

        refreshAlert.addAction(UIAlertAction(title: "NAAH", style: .cancel, handler: { (action: UIAlertAction!) in
          print("Handle No Logic here")
            
          }))

        self.present(refreshAlert, animated: true, completion: nil)
    }
    
    func checkTitleValidity() -> Bool {
        
        if (self.tfPitchTitle.text == nil || self.tfPitchTitle.text == "") {
            
            self.showAlert("Alert", message: "Please put a title for new broadcast.")
            return false
        }
        else if ((self.tfPitchTitle.text?.count)! < 3) {
            self.showAlert("Title Strength", message: "Too short.")
            return false
        }else if self.imgSelectedVideo.image == nil{
            self.showAlert("Video missing", message: "Select Video Link or From Locall Gallery ")
            return false
        }else if (tagsCollection.count == 0) {
            self.showAlert("Tags missing", message: "Please add some tags")
            return false
        }else if self.urlCheck == true{
        print(tfJobUrl, linkUrl)
            if self.tfJobUrl.text?.isEmpty == true{
                self.showAlert("Link missing", message: "Job Site Link is missing")
                return false
            }else{
                if(!self.isValidUrl(url: self.tfJobUrl.text!))
                {
                    self.showAlert("URL", message: "Entered url is invalid")
                    return false
                    
                }else if adressLbl.text?.isEmpty == true{
                    self.showAlert("Location", message: "Select Location First")
                    return false
                }
            }
            
        }else{
            if adressLbl.text?.isEmpty == true{
                self.showAlert("Location", message: "Select Location First")
                return false
            }else {
                //self.titleTextContainer.isHidden = true
                return true
            }
        }
//        else if (self.selectedVideoPath.count < 10) {
//            self.showAlert("Video missing", message: "Please select video")
//            return false
    
        
        return true
    }
    
    func isValidUrl(url: String) -> Bool {
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: url)
        return result
    }
    
    func showAlert(_ title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    let bucketName = "simx/offlineVideos"
    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    
    func AWSS3TransferUtilityUploadFunction(with resource: String, type: String){
        
        let key = "\(resource).\(type)"
      //  let localImagePath = Bundle.main.path(forResource: resource, ofType: type)!  //2
      //  let localImageUrl = URL(fileURLWithPath: localImagePath)
        print("Video Key", key)
        
        let expression  = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task: AWSS3TransferUtilityTask,progress: Progress) -> Void in
            print(progress.fractionCompleted)
            //do any changes once the upload is finished here
            if progress.isFinished{
                print("Upload Finished...")
                if !self.callDone{
                    self.callDone = true
                    self.addNewStreamVideoObject()
                }
            }
        }
         
        expression.setValue("public-read-write", forRequestHeader: "x-amz-acl")
        expression.setValue("public-read-write", forRequestParameter: "x-amz-acl")

        completionHandler = { (task:AWSS3TransferUtilityUploadTask, error:NSError?) -> Void in
            if(error != nil){
                print("Failure uploading file")
                
            }else{
                print("Success uploading file")
            }
        } as? AWSS3TransferUtilityUploadCompletionHandlerBlock
       
        let filePath = self.mp4VideoURL.path
        if FileManager.default.fileExists(atPath: filePath) {
            if let fileData = FileManager.default.contents(atPath: filePath) {
                // process the file data
                print("Data avilable :", fileData.count)
                AWSS3TransferUtility.default().uploadData(fileData, bucket: bucketName, key: String(key), contentType: resource, expression: expression, completionHandler: self.completionHandler).continueWith(block: { (task:AWSTask) -> AnyObject? in
                    if(task.error != nil){
                        print("Error uploading file: \(String(describing: task.error?.localizedDescription))")
                    }
                    if(task.result != nil){
                        print("Starting upload...")
                    }
                    return nil
                })
            } else {
                print("Could not parse the file")
            }
        } else {
            print("File not exists")
        }
    }
    
    // Encode video from .mov to .mp4
    func encodeVideoToMP4(at videoURL: URL, completionHandler: ((URL?, Error?) -> Void)?)  {
        let avAsset = AVURLAsset(url: videoURL, options: nil)

        let startDate = Date()

        //Create Export session
        guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough) else {
            completionHandler?(nil, nil)
            return
        }

        //Creating temp path to save the converted video
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath = documentsDirectory.appendingPathComponent("rendered-Video.mp4")

        //Check if the file already exists then remove the previous file
        if FileManager.default.fileExists(atPath: filePath.path) {
            do {
                try FileManager.default.removeItem(at: filePath)
            } catch {
                completionHandler?(nil, error)
            }
        }

        exportSession.outputURL = filePath
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0.0, 0)
        let range = CMTimeRangeMake(start, avAsset.duration)
        exportSession.timeRange = range

        exportSession.exportAsynchronously(completionHandler: {() -> Void in
            switch exportSession.status {
            case .failed:
                print(exportSession.error ?? "NO ERROR")
                completionHandler?(nil, exportSession.error)
            case .cancelled:
                print("Export canceled")
                completionHandler?(nil, nil)
            case .completed:
                //Video conversion finished
                let endDate = Date()

                let time = endDate.timeIntervalSince(startDate)
                print(time)
                print("Successful!")
                print(exportSession.outputURL ?? "NO OUTPUT URL")
                completionHandler?(exportSession.outputURL, nil)

                default: break
            }

        })
    }
    
    
    
    // UPload image thumbnail
    func addNewStreamVideoObject() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.imageCreatationAPI(videoName: self.nameForVideo)
        }
        Constants.UserData.lastBroadcastId = self.nameForVideo
        
        DispatchQueue.main.async {
            self.videoObject.jobDescriptionURL = ""
        }
        print(CurrentUser.Current_UserObject.name)
        videoObject.name = CurrentUser.getCurrentUser_From_UserDefaults().name
        if videoObject.broadcast.isEmpty == true{
            videoObject.broadcast = self.nameForVideo
        }else{
            videoObject.broadcast = self.videoObject.broadcast
        }
        
        videoObject.arn = ""
        videoObject.imglink = self.nameForVideo
        videoObject.status = Constants.VideoStatus.offline
        videoObject.viewers = 0
        videoObject.time = Date().today() //"2017-05-17 09:11:47"
        videoObject.skill = CurrentUser.getCurrentUser_From_UserDefaults().skills //"abc"
        videoObject.isJob = self.isJobSelected
        videoObject.latti = self.lat //"22.00"
        videoObject.longi = self.long //"74.00"
        print(CurrentUser.Current_UserObject.username)
        
        videoObject.username = CurrentUser.getCurrentUser_From_UserDefaults().username
        videoObject.videourl = tfJobURL.text!
        
        videoObject.isOffline = true
        var tagsData: [Tag] = []
        for tag in tagsCollection {
            let lTag = Tag()
            lTag.tag = tag
            lTag.broadcast = self.nameForVideo
            tagsData.append(lTag)
        }
        videoObject.broadcastTags = tagsData
     //   videoObject.location = ""
        
        //videoObject.asJSON()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let shSingeltonObject = DataAccess.sharedInstance
            shSingeltonObject.addOrUpdateVideo(self.videoObject, delegate: self as AddUpdateVideo_Protocol)
        }
    }
    
    
    
    func postThumbNailImage(imageData: UIImage) {
        
        //let imageData = self.convert(cmage: image)
        let image_data = self.compressImage(imageData)
        let image : String = (image_data.base64EncodedString())
      //  var name : String = "abc" + self.nameForVideo
        var name : String = self.nameForVideo
        let videoLink : String = "https://simx.s3-us-west-2.amazonaws.com/offlineVideos/\(self.nameForVideo).mp4"
        name = name + ".png"
        
     //   uploadImage(url:Constants.API_URLs.uploadThumbnailAPI_URL, withParams:["base64": image , "ImageName" : name ])
        uploadImage(url:Constants.API_URLs.uploadVideoThumbnailAPI_URL, withParams:["videoLink": videoLink , "imageName" : name ])
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
                    // SwiftSpinner.hide()
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
                print("\n\ndata is ::: \(data.debugDescription).\n\nresponse is \(response?.debugDescription ?? "nothing found in response 555")")
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                postCompleted(true, dataString! as String)
            }
            else
            {
                //Alert.showOfflineAlert()
                print("\n\nERROR !!! NO INTERNET CONNECTION...DATA IS NIL")
            }
        })
        task.resume()
    }
    
    func imageCreatationAPI(videoName: String){
        var name : String = videoName
        let videoLink : String = "https://simx.s3-us-west-2.amazonaws.com/offlineVideos/\(videoName).mp4"
        // let videoLink : String = "https://simx.s3-us-west-2.amazonaws.com/offlineVideos/_fZj2Zds8J15943515249107.mp4"

        let parameters = [
            "imageName": name,
            "videoLink": videoLink
        ]
        print(Constants.API_URLs.uploadVideoThumbnailAPI_URL)
        print(parameters)
        Alamofire.upload(multipartFormData: { multipartFormData in
                //loop this "multipartFormData" and make the key as array data
            
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            } //Optional for extra parameters
        },
        to: Constants.API_URLs.uploadVideoThumbnailAPI_URL)
        { (result) in
            switch result {
            case .success(let upload, _, _):

                upload.uploadProgress(closure: { (progress) in
                 //   print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseString{ response in
                print("response.result.value")
                    let JsonResponseData = response.result.value
                    print(response.result.value)
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        }// End
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    func compressImage (_ image: UIImage) -> Data {
        
        let compressionQuality:CGFloat = 0.5
        
        let rect:CGRect = CGRect(x: 0, y: 0, width: 100, height: 80)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        let imageData:Data = UIImageJPEGRepresentation(img, compressionQuality)!//! as Data
        return imageData
    }

}
extension CreateStreamOfflineVC {
    
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

extension CreateStreamOfflineVC: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return gestureRecognizer.view === touch.view
    }
}

extension CreateStreamOfflineVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        videoURL = info[UIImagePickerControllerMediaURL] as? URL as NSURL?
        
        print(videoURL)
        
        self.selectedVideoPath = self.videoURL?.absoluteString as! String
        print("videoURL:\(String(describing: videoURL))", self.selectedVideoPath)
        do {
            let asset = AVURLAsset(url: videoURL as! URL , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            self.imgSelectedVideo.image = thumbnail
            self.postThumbNailImage(imageData: thumbnail)
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
        }
        self.dismiss(animated: true, completion: nil)
    }
}
extension CreateStreamOfflineVC: UITextFieldDelegate {
    
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfTags || textField == tfPitchTitle {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}

extension CreateStreamOfflineVC: AddUpdateVideo_Protocol {
    func updatedResponse(isSuccess: Bool , error: String, id: Int)
    {
        print("Broadcast created with", id)
        //MARK: Success Popup
        
        var refreshAlert = UIAlertController(title: "Thank You", message: "Your job is posted to Administrator and will show on wall as soon as it is approved", preferredStyle: UIAlertControllerStyle.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
         
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let messageToast = Toast(text: "New Broadcast created", duration: Delay.short)
                messageToast.show()
                self.dismiss(animated: true, completion: nil)
                MBProgressHUD.hide(for: self.view, animated: true)
                //self.nameForVideo
                self.imageCreatationAPI(videoName: self.nameForVideo)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.closeView()
                }
            }
            
          }))
        present(refreshAlert, animated: true, completion: nil)
        
        
    }
}

extension CreateStreamOfflineVC: CLLocationManagerDelegate {
    func setUpLocationManager() {
            
//        // Ask for Authorisation from the User.
//        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        myLatitued  = locValue.latitude
        myLongitude = locValue.longitude
        locationManager.stopUpdatingLocation()
        
        let longitude :CLLocationDegrees = myLongitude
        let latitude :CLLocationDegrees = myLatitued
        
        self.videoObject.longi = self.lat
        self.videoObject.latti = self.long
        
        let location = CLLocation(latitude: latitude, longitude: longitude) //changed!!!
        print(location)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            print(location)
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = placemarks![0]
                var countryString = "not found"
                if (pm.country != nil) {
                    countryString = pm.country!
                }
                self.videoObject.location = "\(pm.locality ?? "") \(pm.subLocality ?? ""),\(countryString)"
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
}


extension String {
    var youtubeID: String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"

        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: count)

        guard let result = regex?.firstMatch(in: self, range: range) else {
            return nil
        }

        return (self as NSString).substring(with: result.range)
    }
}
