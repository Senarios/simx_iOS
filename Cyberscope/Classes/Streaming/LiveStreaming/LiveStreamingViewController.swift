//
//  LiveStreamingViewController.swift
//  CyberScope
//
//  Created by Salman on 27/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//


/*
 AVAudioSession.mm:998:-[AVAudioSession setActive:withOptions:error:]: Deactivating an audio session that has running I/O. All I/O should be stopped or paused prior to deactivating the audio session. Unable to activate audio session:  The operation couldn’t be completed. (OSStatus error 560030580.)
 */

import UIKit
import AVFoundation
import Toaster

import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit
import TwitterKit

import Alamofire

import MBProgressHUD
import PeriscommentView

import StreamaxiaSDK
import Firebase
import FirebaseDatabase



protocol LiveStreamingViewControllerDelegate: class {
    func StreamClosed()
}


// Modify this to your desired stream name
// Playback will be available at play.streamaxia.com/<your-stream-name>

class LiveStreamingViewController: UIViewController, UpdateUserBroadcastsCount_Delegate, UpdateUser_Delegate, CLLocationManagerDelegate {
    // MARK: - Private Constants -
    

    
    var ref: DatabaseReference!
    
    let SDKSampleSimXSavedConfigKey = "SDKSampleSimXSavedConfigKey"
    let SDKSampleAppLicenseKey      = "GOSK-0E47-010C-0499-E641-2E7D"
    let BlackAndWhiteEffectKey      = "BlackAndWhiteKey"
    let BitmapOverlayEffectKey      = "BitmapOverlayKey"
    

    var blackAndWhiteVideoEffect = false
    var bitmapOverlayVideoEffect = false /// Not supported in swift version
 //   var goCoderRegistrationChecked = false
    
    static var kStreamaxiaStreamName: String = "myStream101"
    var newArnForThisBroadcast: String = "NA"
    var subscriptionArn: String = ""
    var lat = ""
    var long = ""
    var address = ""
    var broadcastTitle = ""
    var msgStr : Bool = false
    var callStr: Bool = false
    var bothStr: Bool = false
    var applyOnVide: Bool = false
    var applyOnJob: Bool = false
    
    var isFacebookChoosen:Bool = false
    var isTwitterChoosen: Bool = false
    var isLinkedInChoosen: Bool = false
    var isFrontChoosen: Bool = false
    var isCommentsOptionChoosen = true
    let locationManager = CLLocationManager()
    
    var myLatitued = 0.0
    var myLongitude = 0.0
    var jobDescriptionURL = ""
    
    
    var delegate: LiveStreamingViewControllerDelegate?
    
    var isSharedSuccessfully = false
    var isHittingSharingApi = false
    var isCloseStreamCall = false
    var isAlreadyDismissed = false
    var isMinimumStreamLimitReached = false
    var isBroadcastStartedSuccessully = -1
    var numberOfHitsAfterEndStreamHit = -1
    
    var numberOfViewers: Int = 0
    
    var streamComment : [StreamComment] =  []

    @IBOutlet weak var viewersLabel: UILabel!
    
    fileprivate let kStartButtonTag: NSInteger = 0
    
    fileprivate let kStopButtonTag: NSInteger = 1
    
    // MARK: - Private Properties -
    
    var commentsArray:[Comment] = []
    
    @IBOutlet weak var startButton: UIButton!
    
//    @IBOutlet weak var leftLabel: UILabel!
    var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
//    var rightLabel: UILabel!
    
    @IBOutlet weak var periscopeCommentView: PeriscommentView!
    @IBOutlet weak var commentsSection: UIView!
    @IBOutlet weak var commentsTableView: UITableView!
    
    @IBOutlet weak var tvStreamComment: UITableView!
    @IBOutlet weak var commentsTypeView: UIView!
    @IBOutlet weak var textViewText: UITextView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var recorderView: UIView!
    @IBOutlet weak var overlayView: UIView!
    //@IBOutlet weak var bitmapOverlayImgView:UIImageView!
    
    @IBOutlet weak var endButton: UIButton!
    
    @IBOutlet weak var titleTextContainer: UIView!
    @IBOutlet weak var broadcastTitleField: UITextField!
    
    
    /// The recorder
    fileprivate var recorder: AXRecorder!
    /// The stream info
    fileprivate var streamInfo: AXStreamInfo!
    /// The recorder settings
    fileprivate var recorderSettings: AXRecorderSettings!
    
    
    var bitmapOverlayImgView = UIImageView()
    var nameForVideo = ""
    
    var videoObject = COVideo()
    
    var isJobSelected: Bool = true
    var tagsCollection: [String] = []
    
    @IBOutlet weak var counterContainerView: UIView!
    @IBOutlet weak var countDownLabel: UILabel!
    var timerCounter = 3
    weak var timer: Timer?
    
    var broadcastTimerCounter = 0.0
    var initialisationTimer = 3
    var maxStreamLenght = 30//30
    let minStreamLength = 10
    
    weak var broadcastTimer: Timer?
    var timerDispatchSourceTimer : DispatchSourceTimer?
    var broadcastTimerDispatchSourceTimer : DispatchSourceTimer?
    
    var countDownTimer : Timer!
    var streamTimeCheck: Bool = false
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(broadcastTitle)
        print("###come in the live streaming view didload")
        self.title = "StreamaxiaSDK Demo"
     //   timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(fire), userInfo: nil, repeats: true)
        print(jobDescriptionURL)
        print(videoObject)
        print(lat, long, address)
        
       // commentsTableView.delegate = self
      //  commentsTableView.dataSource = self
       // commentsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "StreamChatCommentCell")
      //  commentsTableView.register(StreamChatCell.getNib(), forCellReuseIdentifier: "\(StreamChatCell.self)")
      //  commentsTableView.backgroundColor = .clear
        
        tvStreamComment.delegate = self
        tvStreamComment.dataSource = self
        tvStreamComment.register(StreamChatCell.getNib(), forCellReuseIdentifier: "\(StreamChatCell.self)")
        tvStreamComment.backgroundColor = .clear
        
        ref = Database.database().reference()   
        
       // self.setUpLocationManager()
        self.countDownLabel.text = "\(initialisationTimer)"
        self.handleFiveSecondsCountDown()
        
        self.nameForNewStreamVideoObject()
        self.setupUI()
       
        self.setupStreamaxiaSDK()
        self.isCommentsOptionChoosen = true
        if (self.isCommentsOptionChoosen == true) {
            self.createNewTopicForBroadast(topicName: CurrentUser.Current_UserObject.username+self.nameForVideo)
          
        }
        else {
            // call start broadcast button
            self.newArnForThisBroadcast = "NA"
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.startButtonPressed(self.startButton)
//            })
        }
        self.setLabelViwersCountText()
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(true)
        } catch {
            print("\(error)")
        }
        
  
        print("$$countdowntimer initilize")
        countDownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountDown), userInfo: nil, repeats: true)
        addStreamInFirebase()
    }
    
//
//    }
    
    @objc private func updateCountDown(){
        print("$$ update count down run")
        if initialisationTimer > 1{
//            print("$$ come in true condition and return")
            initialisationTimer -= 1
            DispatchQueue.main.async {
                self.countDownLabel.text = String(self.initialisationTimer)
            }
            return
        }
//        print("$$ overcome condition and invalidate timer")
        countDownTimer.invalidate()
        
        
    }
    
    
    private func addStreamInFirebase(){
        
//        print("%%%add stream in firebase")
//
//        ref.child("\(curren)").setValue(["id":"123frzainahmed1263"]) { error, _ in
//
//            if error == nil{
//                print("%%%successfully store on db")
//            }
//        }
        
        
        
    }
    
    
    deinit {
     //   self.recorder = nil
     //   self.recorderSettings = nil
     //   self.streamInfo = nil
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
        } catch {
            print("\(error)")
        }
    }
    
    
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .black
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        myLatitued  = locValue.latitude
        myLongitude = locValue.longitude
        locationManager.stopUpdatingLocation()
        
        let longitude :CLLocationDegrees = myLongitude
        let latitude :CLLocationDegrees = myLatitued
        
        self.videoObject.longi = "\(long)"
        self.videoObject.latti = "\(lat)"
        
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
                self.videoObject.location = self.address
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func handleFiveSecondsCountDown() {
        self.startTimer()
    }
    
    func startTimer() {
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                // do something here
                self?.updateTimer()
            }
           // timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        } else {
            // Fallback on earlier versions
            timerDispatchSourceTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
            timerDispatchSourceTimer?.scheduleRepeating(deadline: .now(), interval: .seconds(1))
            timerDispatchSourceTimer?.setEventHandler{
                // do something here
                self.updateTimer()
            }
            timerDispatchSourceTimer?.resume()
        }
    }
    

    
    func startBroadcastTimer() {
        print("startBroadcastTimer ...... ")
        self.broadcastTimerCounter = 0.0
        if #available(iOS 10.0, *) {
            broadcastTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                // do something here
                self?.updateBroadcastTimer()
            }
        } else {
            // Fallback on earlier versions
            broadcastTimerDispatchSourceTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
            broadcastTimerDispatchSourceTimer?.scheduleRepeating(deadline: .now(), interval: .seconds(1))
            broadcastTimerDispatchSourceTimer?.setEventHandler{
                // do something here
                self.updateBroadcastTimer()
            }
            broadcastTimerDispatchSourceTimer?.resume()
        }
    }
    
    func stopTimer() {
        print("stopTimer ............")
        timer?.invalidate()
        timer = nil
        //timerDispatchSourceTimer?.suspend() // if you want to suspend timer
        timerDispatchSourceTimer?.cancel()
        timerDispatchSourceTimer = nil
        
        self.startBroadcastTimer()
        DispatchQueue.main.async {
            self.rightLabel.isHidden = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0, execute: {
            self.hitAndCheckThumbnailApiFromLiveStream()
        })
    }
    
    func stopBroadcastTimer() {
        broadcastTimer?.invalidate()
        broadcastTimer = nil
        //broadcastTimerDispatchSourceTimer?.suspend() // if you want to suspend timer
        broadcastTimerDispatchSourceTimer?.cancel()
        broadcastTimerDispatchSourceTimer = nil
    }
    
    func updateTimer() {
        print("Update time function run",self.timerCounter)
        if self.timerCounter < 1 {
            self.stopTimer()
            self.counterContainerView.isHidden = true
        } else {
            self.timerCounter -= 1
            print("Timer : \(self.timerCounter)")
            DispatchQueue.main.async {
              //  self.countDownLabel.text = "\(self.timerCounter)"
            }
            
        }
    }
    
    func updateBroadcastTimer() {
        self.broadcastTimerCounter = self.broadcastTimerCounter + 1.001
        self.updateLabel(time: self.broadcastTimerCounter)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(self.addNewCommentInTableView),
                                       name: .commentReachedThisDevice,
                                       object: nil)
        
        self.startButton.isHidden = true
        self.endButton.setCornerRadisConst(with: 5)
        self.rightLabel.setCornerRadisConst(with: 5)
        
     //   self.setupStreaming()
        
      
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
     
        self.recorderView.contentMode = .scaleToFill
        
    }
    
    //func
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear ... called")
   //     self.unsubscibrForTopic(topicArn: self.subscriptionArn)

//        let session = AVAudioSession.sharedInstance()
//        do {
//            // 1) Configure your audio session category, options, and mode
//            // 2) Activate your audio session to enable your custom configuration
//            try session.setActive(false)
//        } catch let error as NSError {
//            print("Unable to activate audio session:  \(error.localizedDescription)")
//        }
        UIApplication.shared.isIdleTimerDisabled = false
   
   //     NotificationCenter.default.removeObserver(self, name: .commentReachedThisDevice, object: nil)
        if (self.recorder == nil) {return}
        
       /* if let lRecorder = self.recorder {
            if lRecorder.isActive {
                lRecorder.stopStreaming()
            }
        }*/
    }
    
    @objc func addNewCommentInTableView(notification: NSNotification) {
        print("come in addnewcommentin tableview")
        let currentUserReference = CurrentUser.Current_UserObject
        
        let newCommentMessage = notification.value(forKey: "object") as! [String: String]
        let newComment  = Comment()
        if (newCommentMessage[Constants.CommentField.arn] != nil) {
            newComment.arn  = newCommentMessage[Constants.CommentField.arn]!
        }
        if (newCommentMessage[Constants.CommentField.text] != nil) {
            if (newCommentMessage[Constants.CommentField.text]! == "") {
                newComment.type = "view"
            }
            else {
                newComment.type = "message"
            }
        }else{
            print("Cant send empty message")
        }
        if (newCommentMessage[Constants.CommentField.type] != nil) {
            newComment.type  = newCommentMessage[Constants.CommentField.type]!
        }
        newComment.name = newCommentMessage[Constants.CommentField.name]!
        newComment.text = newCommentMessage[Constants.CommentField.text]!
        newComment.user = newCommentMessage[Constants.CommentField.user]!
        if (currentUserReference.username == newComment.user) {
            return
        }
        
        if (newComment.type == "view") {
            self.numberOfViewers += 1
            self.setLabelViwersCountText()
            return
        }

        let userPhotoUrl = Utilities.getUserImage_URL(username: newComment.user)
        UIImageView().sd_setImage(with: userPhotoUrl, placeholderImage: UIImage(named: Constants.imagesName.broadcaster_image), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            // Perform operation.
            if (error == nil) {
                //cell.image_broadcaster.image = cell.image_broadcaster.image?.circle
                if (image != nil) {
                    print("come in image != nil")
                //    self.periscopeCommentView.addCell(profileImage: image!, name: newComment.name, comment: newComment.text)
                    print(newComment.text)
                    self.streamComment.append(StreamComment(image: image!, name: newComment.name, comment: newComment.text))
                    
                }
                else
                {
                    print("come in image == nil")
                    let profileImage = UIImage(named: Constants.imagesName.default_UserImage)!
                  //  self.periscopeCommentView.addCell(profileImage: profileImage, name: newComment.name, comment: newComment.text)
                    self.streamComment.append(StreamComment(image: profileImage, name: newComment.name, comment: newComment.text))
                }
            }
            else
            {
                print("come in image == nil 2")
                let profileImage = UIImage(named: Constants.imagesName.default_UserImage)!
                self.streamComment.append(StreamComment(image: profileImage, name: newComment.name, comment: newComment.text))
            }
            DispatchQueue.main.async {
                print("comment table view reload View")
                self.tvStreamComment.reloadData() //tvStreamComment
                
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1, execute: {
  //              self.commentsTableView.scrollTableViewToBottom(animated: true)
            })

        })
    }
    
    // MARK: - Public methods -
    
    fileprivate func takeSnapshot() {
        recorder.takeSnapshot { (image, error) in
            if let image = image {
                print("Took a snapshot with:\(image.size)")
                // do something with the snapshot
            }
        }
    }
    
    // MARK: - Actions -
    
    @IBAction func startButtonPressed(_ button: UIButton) {
        print("*** DEMO *** Recorder button pressed.")
//        self.goBackToMapVC()
//        return
        
        if (button.tag == self.kStartButtonTag) {
            print("*** DEMO *** START button pressed.")
            //Toast(text: "*** DEMO *** START button pressed.", duration: Delay.short).show()
            
            self.addNewStreamVideoObject()
            self.checkOrientation()
        }
        else if (button.tag == self.kStopButtonTag) {
            print("*** DEMO *** STOP button pressed.")
            //Toast(text: "*** DEMO *** STOP button pressed.", duration: Delay.short).show()
            self.hitAndCheckThumbnailApiFromLiveStream()
            self.videoObject.status = Constants.VideoStatus.offline
            self.videoObject.viewers = self.numberOfViewers
            
            print(self.videoObject.asJSON())
            let shSingeltonObject = DataAccess.sharedInstance
            shSingeltonObject.addOrUpdateVideo(videoObject, delegate: self as AddUpdateVideo_Protocol)
            
            self.startButton.tag = self.kStartButtonTag
            self.startButton.setTitle("Start", for: .normal)
            
            DispatchQueue.main.async {
                self.setupStreaming()
                if let lRecorder = self.recorder {
                    lRecorder.stopStreaming()
                    print("Memory released ..... EXEC called")
                }
            }
            self.stopBroadcastTimer()
            self.updateLabel(time: 0.0)
            print ("1")
            self.goBackToMapVC()
        }
    }
    
    func goBackToMapVC() {
        timer?.invalidate()
        if (self.isAlreadyDismissed) {
            return
        }
        //performSegue(withIdentifier: "unwind789678", sender: self)
        if (self.navigationController != nil) {
            self.isAlreadyDismissed = true
        
           // self.navigationController?.popViewController(animated: true)
            self.navigationController?.popToRootViewController(animated: true)
            print("Moving Back in Navigation Stack")
            return
        }
        print("Moving Back in with Dismiss Action")
        if (!self.isAlreadyDismissed) {
            self.isAlreadyDismissed = true
            self.delegate?.StreamClosed()
            self.dismiss(animated: true, completion: nil)
            
        }

    }
    
    @IBAction func closeThisController(_ sender: UIButton) {
        
        if (!self.isMinimumStreamLimitReached) {
            if (self.isBroadcastStartedSuccessully == 0) {
                print ("3")
                self.goBackToMapVC()
                let messageToast = Toast(text: "Stream stopped before starting", duration: Delay.short)
                messageToast.show()
            }
            else {
                let messageToast = Toast(text: "It cannot be stoped before \(minStreamLength) seconds of streaming", duration: Delay.short)
                messageToast.show()
            }
            return
        }
        if (!self.isSharedSuccessfully) {

            self.isCloseStreamCall = true
            self.getSignatureTemp()
            return
        }
        if self.startButton.tag == self.kStopButtonTag {
            self.startButtonPressed(self.startButton)
        }
        else {
            print ("4")
            self.goBackToMapVC()
        }
        
        // UserDefaults.standard.set("Done", forKey: "STATUS")
        let n = UserDefaults.standard.string(forKey: "STATUS")
        if n == "Done"{
            sendEmail()
            dismiss(animated: true, completion: nil)
        }else{
            sendEmail()
        }
        
        
    }
    
    func sendEmail(){
        
        //MARK: Sending Email
       let email = "colinjohn563@gmail.com"
        DataAccess.sharedInstance.sendEmail(to: "colinjohn563@gmail.com", toName: "Colin", subject: "Job Post Approval", body: "A new broadcast \(broadcastTitle) is pending for approval") { msgs in
            print(msgs)
            
            if self.streamTimeCheck == true{
                self.dismiss(animated: true, completion: nil)
            }
            
        } failure: { error in
            Toast.init(text: error).show()
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func createNewTopicForBroadast(topicName: String) {
        print("## createNewTopicForBroadast func call")
        let topicRequestInput = AWSSNSCreateTopicInput()
        topicRequestInput?.name = topicName
        print("## topic name is",topicRequestInput?.name)
        
        let sns = AWSSNS.default()
        sns.createTopic(topicRequestInput!).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("### createTopic Error: \(String(describing: task.error))")
            } else {
                let createEndpointResponse = task.result! as AWSSNSCreateTopicResponse
                if let newTopicArn = createEndpointResponse.topicArn {
                    print("topicArn: \(newTopicArn)")
                    self.newArnForThisBroadcast = newTopicArn
                    self.startButtonPressed(self.startButton)
                    self.subscribeToThisTopic(topicArn: self.newArnForThisBroadcast)
                }
            }
            return nil
        })
    }
    
    func subscribeToThisTopic(topicArn : String) {
        print("subscribeToThisTopic func call",topicArn)
        let topicSubscribeRequestInput = AWSSNSSubscribeInput()
        topicSubscribeRequestInput?.topicArn = topicArn
        topicSubscribeRequestInput?.protocols = "application"
        topicSubscribeRequestInput?.endpoint = UserDefaults.standard.value(forKey: "endpointArnForSNSCyberScope787") as? String
        
        let sns = AWSSNS.default()
        sns.subscribe(topicSubscribeRequestInput!).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("## fil subscribeError: \(String(describing: task.error))")
            } else {
                let createEndpointResponse = task.result! as AWSSNSSubscribeResponse
                if let subscriptionArn = createEndpointResponse.subscriptionArn {
                    print("successfully subscribe subscriptionArn: \(subscriptionArn)")
                    self.subscriptionArn = subscriptionArn
                    self.publishMessageToTopicView(messageText: "")
                }
            }
            return nil
        })
    }
    
    func unsubscibrForTopic(topicArn: String) {
        let topicSubscribeRequestInput = AWSSNSUnsubscribeInput()
        topicSubscribeRequestInput?.subscriptionArn = topicArn
        
        let sns = AWSSNS.default()
        sns.unsubscribe(topicSubscribeRequestInput!).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("Error: \(String(describing: task.error))")
            } else {
                //let createEndpointResponse = task.result! as AWSSNSUnsubscribeResponse
                //if let subscriptionArn = createEndpointResponse.subscriptionArn {
                //    print("subscriptionArn: \(subscriptionArn)")
                //}
            }
            return nil
        })
    }
    
    func getViewersFrom(topicArn: String) {
        let getSubscribersRequestInput = AWSSNSListSubscriptionsByTopicInput()
        getSubscribersRequestInput?.topicArn = topicArn
        
        let sns = AWSSNS.default()
        sns.listSubscriptions(byTopic: getSubscribersRequestInput!).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("Error: \(String(describing: task.error))")
            } else {
                let createEndpointResponse = task.result! as AWSSNSListSubscriptionsByTopicResponse
                if let subscriptions = createEndpointResponse.subscriptions {
                    print("subscriptionArn: \(subscriptions) :: count :: \(subscriptions.count)")
                    self.numberOfViewers = subscriptions.count
                    self.setLabelViwersCountText()
                }
            }
            return nil
        })
    }
    
    func publishMessageToTopicView(messageText: String) {
        print("## publishMessageToTopicView func call")
        let currentUserReference = CurrentUser.Current_UserObject
        
        let publishToTopicRequestInput = AWSSNSPublishInput()
        publishToTopicRequestInput?.messageStructure = "json"
        let messageDict = ["name":currentUserReference.name, "text":messageText, "user":currentUserReference.username, "type":"view", "arn":self.subscriptionArn]
        publishToTopicRequestInput?.message = ["default":messageDict.dict2json()].dict2json() //messageDict.dict2json()
        print(publishToTopicRequestInput?.message as Any)
        publishToTopicRequestInput?.topicArn = self.newArnForThisBroadcast
        
        let sns = AWSSNS.default()
        sns.publish(publishToTopicRequestInput!).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("### publish in publishMessageToTopicView Error: \(String(describing: task.error))")
            } else {
                let publishMessageResponse = task.result! as AWSSNSPublishResponse
                if let messageId = publishMessageResponse.messageId {
                    print("subscriptionArn in publishMessageToTopicView: \(messageId)")
                }
            }
            return nil
        })
    }
    
    func publishMessageToTopic(messageText: String) {
        print("##publishMessageToTopic func call")
        
        let currentUserReference = CurrentUser.Current_UserObject
        
        let newComment = Comment()
        newComment.arn = currentUserReference.arn
        newComment.name = currentUserReference.name
        newComment.text = messageText
        newComment.type = ""
        newComment.user = currentUserReference.username

        let userPhotoUrl = Utilities.getUserImage_URL(username: newComment.user)
        UIImageView().sd_setImage(with: userPhotoUrl, placeholderImage: UIImage(named: Constants.imagesName.broadcaster_image), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            // Perform operation.
            if (error == nil) {
                //cell.image_broadcaster.image = cell.image_broadcaster.image?.circle
                if (image != nil) {
                    print("##image != nil add cell")
                    self.streamComment.append(StreamComment(image: image!, name: newComment.name, comment: newComment.text))
                 //   self.periscopeCommentView.addCell(profileImage: image!, name: newComment.name, comment: newComment.text)
                }
                else
                {
                    print("##image == nil add cell")
                    let profileImage = UIImage(named: Constants.imagesName.default_UserImage)!
            //        self.periscopeCommentView.addCell(profileImage: profileImage, name: newComment.name, comment: newComment.text)
                    self.streamComment.append(StreamComment(image: profileImage, name: newComment.name, comment: newComment.text))
                }
            }
            else
            {
                print("##image == nil add cell -- 2")
                let profileImage = UIImage(named: Constants.imagesName.default_UserImage)!
        //        self.periscopeCommentView.addCell(profileImage: profileImage, name: newComment.name, comment: newComment.text)
                self.streamComment.append(StreamComment(image: profileImage, name: newComment.name, comment: newComment.text))
            }
       
        })
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.1, execute: {
                print("comment table view reload View 2")
                self.tvStreamComment.reloadData() // tvStreamComment
                
            })
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.7, execute: {
             //   self.commentsTableView.scrollTableViewToBottom(animated: true) tvStreamComment
            })
        let publishToTopicRequestInput = AWSSNSPublishInput()
        publishToTopicRequestInput?.messageStructure = "json"
        let messageDict = ["name":currentUserReference.name, "text":messageText, "user":currentUserReference.username, "type":"message", "arn":self.subscriptionArn]
        publishToTopicRequestInput?.message = ["default":messageDict.dict2json()].dict2json() //messageDict.dict2json()
        print(publishToTopicRequestInput?.message as Any)
        publishToTopicRequestInput?.topicArn = self.newArnForThisBroadcast
        let sns = AWSSNS.default()
        sns.publish(publishToTopicRequestInput!).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("###Error publishMessageToTopic: \(String(describing: task.error))")
            } else {
                let publishMessageResponse = task.result! as AWSSNSPublishResponse
                if let messageId = publishMessageResponse.messageId {
                    print("###subscriptionArn publishMessageToTopic \(messageId)")
                }
            }
            return nil
        })
    }
    
    func hitShareApiToShareThisStream() {
        
        self.getSignatureTemp()
    }
    
    func getSignatureTemp()
    {
        if (!isFacebookChoosen && !isLinkedInChoosen && !isTwitterChoosen) {
            self.isSharedSuccessfully = true
            if(self.isCloseStreamCall) {
                
                
                var refreshAlert = UIAlertController(title: "Thank You", message: "Your job is posted to Administrator and will show on wall as soon as it is approved", preferredStyle: UIAlertControllerStyle.alert)

                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                 
        
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        let messageToast = Toast(text: "New Broadcast created", duration: Delay.short)
                        messageToast.show()
                        self.dismiss(animated: true, completion: nil)
                        MBProgressHUD.hide(for: self.view, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.closeThisController(UIButton())
                        }
                    }
                    
                  }))
                present(refreshAlert, animated: true, completion: nil)
               
            }
            else {
            }
            
            videoObject.jobPostStatus = "Pending"
            return
        }
        
        let apiService = ApiServices()
        let headerParam = [String:String]()
        
        var param = [String : String]();
        param["videoName"] = "\(self.videoObject.broadcast)"
        if (isFacebookChoosen) {
            if (FBSDKAccessToken.current() != nil) {
                if FBSDKAccessToken.current().hasGranted("publish_actions") {
                    param["fb_token"] = "\(FBSDKAccessToken.current().tokenString!)"
                }
            }
        }
        if (isLinkedInChoosen) {
            if let accessToken = UserDefaults.standard.object(forKey: "LIAccessToken") {
                param["linkedin_token"] = accessToken as? String
            }
        }
        
        if (isTwitterChoosen) {
            if (UserDefaults.standard.string(forKey: Constants.Twitter.TWITTER_Token) != nil) {
                let twitter_USERID = UserDefaults.standard.string(forKey: Constants.Twitter.TWITTER_Token)
                if (twitter_USERID == nil) {
                    return
                }
                else {
//                    if let twitterSession = TWTRTwitter.sharedInstance().sessionStore.session(forUserID: twitter_USERID!) {
                        param["twitter_token"] = UserDefaults.standard.string(forKey: Constants.Twitter.TWITTER_Token)
                        //"\(twitterSession.authToken)"
                        param["twitter_token_secret"] = UserDefaults.standard.string(forKey: Constants.Twitter.TWITTER_TokenSecret)
                        //"\(twitterSession.authTokenSecret)"
//                    }
                }
            }
        }
        param["broadcast_title"] = "\(self.videoObject.title)"

        if (self.isCloseStreamCall) {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.closeThisController(UIButton())
            })
        }
        param["requested_by_user_id"] = CurrentUser.Current_UserObject.username
        if (self.isHittingSharingApi) {
            return
        }
        else {
            self.isHittingSharingApi = true
        }
        apiService.postRequest(serviceName: "https://web.scottishhealth.live/social/videosharing.php", param: param, header: headerParam, success: { (data) in
            print("success")
            self.isHittingSharingApi = false
            if let bool = data["status"] as? Bool {
                if (bool) {
                    self.isSharedSuccessfully = true
                    print("success")
                    if(self.isCloseStreamCall) {
                        DispatchQueue.main.async {
                            self.closeThisController(UIButton())
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                    }
                }
                else {
                    print("failure")
                    print("\(data)")

                    DispatchQueue.main.async {
                        self.getSignatureTemp()
                    }
                }
            }
        }, failure: { (data) in
            self.isHittingSharingApi = false
            print("failure")
            print("\(data)")
            DispatchQueue.main.async {
                self.getSignatureTemp()
            }
        })
    }
    
    func replaceUrl(oldString : String) -> String{
        return oldString.replacingOccurrences(of: " ", with: "%20")
    }
    
    func postRequest (serviceName :String, param : [String : Any], header : [String : String], success: @escaping ( _ data:[String:AnyObject]) -> Void, failure: @escaping ( _ data:[String:AnyObject]) -> Void){
        
        //var url =  serviceName
        var url = "\(serviceName)?\(param.myDesc)"
        print(url)
        url = self.replaceUrl(oldString: url)
        print(param)
        //URLEncoding(destination: .httpBody)
        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers:header)// URLEncoding(destination: .httpBody)
            .responseJSON { response in
                
                if response.result.value != nil{
                    let data = response.result.value as! [String : AnyObject]
                    print("Success")
                    print(data)
                    success(data)
                } else {
                    print("Failure \(response.result)")
                    failure(["Error":"error to server" as AnyObject])
                }
        }
    }
    
    func hitAndCheckThumbnailApiFromLiveStream() {
        
        let urlString = "https://web.scottishhealth.live/uploadvideoapi.php?videoName=\(self.videoObject.broadcast)"
        print("hit URL ", urlString)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        { data, response, error in
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 15.0, execute: {
//                self.checkSharingsOnSocailMedia()
//            })
            
            if error != nil
            {
                print("Error -> \(String(describing: error))")
                DispatchQueue.main.async { () -> Void in
                    if (self.startButton.tag == self.kStopButtonTag) {
                        self.hitAndCheckThumbnailApiFromLiveStream()
                    }
                }
                return
            }
            do {
                print ("response 31313: ", data!)
                let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                print("Response data \(result)")
                
                let msg = result["message"] as! String
                let statusVal = result["status"] as! Bool
                print("Printing Response message = \(msg)", "and Status = \(statusVal)")
//                let messageToast = Toast(text: "message = \(msg) and Status = \(statusVal)", duration: Delay.short)
//                messageToast.show()
                if (!statusVal || msg == "file not found") {
                    DispatchQueue.main.async { () -> Void in
                        if (self.startButton.tag == self.kStopButtonTag) {
                            self.hitAndCheckThumbnailApiFromLiveStream()
                        }
                    }
                    return
                }
                else {
                    
                }
            } catch {
                print("Error -> \(error)")
                print("About to make one more attempt")
                DispatchQueue.main.async { () -> Void in
                    if (self.startButton.tag == self.kStopButtonTag) {
                        self.hitAndCheckThumbnailApiFromLiveStream()
                    }
                }
                return
            }
        }
        task.resume()
    }
    
    func setLabelViwersCountText() {
        let viewersLabelText = "\(self.numberOfViewers) viewers"
        self.viewersLabel.text = viewersLabelText
     //   self.viewersLabel.textColor = .white
    }
    
    func shareFacebbok() {
        
        if FBSDKAccessToken.current().hasGranted("publish_actions") {
            
            FBSDKGraphRequest(graphPath: "me/feed", parameters: ["message": Utilities.getShareableLink(broadcastName: self.videoObject.broadcast, imageLink: self.videoObject.broadcast)], httpMethod: "POST").start(completionHandler: {(_ connection: FBSDKGraphRequestConnection?, _ result: Any?, _ error: Error?) -> Void in
                if error == nil {
                    print("Post id: ", result as Any)
                }
            })
        }
    }
    
    @IBAction func sendCommentAction(_ sender: UIButton) {
        
        let stringText = self.textViewText.text

        if stringText == ""{
            print("Nothing")
        }else{
            self.publishMessageToTopic(messageText: stringText!)
            self.textViewText.text = ""
        }
    }
    
    // MARK: - Sharing FTL Methods
    
    func checkSharingsOnSocailMedia() {
        self.hitShareApiToShareThisStream()
    
//        print(Utilities.getShareableLink(broadcastName: self.videoObject.broadcast, imageLink: self.videoObject.broadcast))
//        if (self.isFacebookChoosen) {
//            self.shareOnFacebook()
//        }
//        if (self.isLinkedInChoosen) {
//            self.ShareOnLinkedIn()
//        }
//        if (self.isTwitterChoosen) {
//            self.shareOnTwitter()
//        }
         
    }
    
    func ShareOnLinkedIn()
    {
        if LISDKSessionManager.hasValidSession()
        {
            
            let url: String = "https://api.linkedin.com/v1/people/~/shares"
            
            let stringText = Utilities.getShareableLink(broadcastName: self.videoObject.broadcast, imageLink: self.videoObject.broadcast)
            
            print("link to LinkedIn 789:: ", stringText)
            
            let payloadStr: String = "{\"comment\":\"My Live Stream on SimX\",\"content\":{\"title\":\"SimX Livestream Resources\",\"description\":\"Leverage LinkedIn's APIs to maximize engagement\",\"submitted-url\":\"\(stringText)\"},\"visibility\":{\"code\":\"anyone\"}}"
            
            //let payloadStr: String = "{\"comment\":\"My Live Stream on CyberscopeTV\",\"content\":{\"title\":\"CyberscopeTV Resources\",\"description\":\"Leverage LinkedIn's APIs to maximize engagement\",\"submitted-url\":\"\(stringText)\",\"submitted-image-url\":\"http://www.chattterbox.co.uk/picture/Photos/1498045484.png\"},\"visibility\":{\"code\":\"anyone\"}}"
            
            let payloadData = payloadStr.data(using: String.Encoding.utf8)
            
            LISDKAPIHelper.sharedInstance().postRequest(url, body: payloadData, success: { (response) in
                print("Linked in", response!.data)
//                let messageToast = Toast(text: "Shared On LinkedIn", duration: Delay.short)
//                messageToast.show()
            }, error: { (error) in
                
                print(error!)
                
                let alert = UIAlertController(title: "Alert!", message: "something went wrong", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    func shareOnFacebook() {
        if FBSDKAccessToken.current().hasGranted("publish_actions") {
            let stringText = Utilities.getShareableLink(broadcastName: self.videoObject.broadcast, imageLink: self.videoObject.broadcast)
            let pictureLink = Utilities.getUserImage_URL(username: self.videoObject.broadcast)
            print("Link to Facebook 789:: ", stringText, "\n Picture Link :: ", pictureLink)
            FBSDKGraphRequest(graphPath: "/me/feed", parameters: ["message": "Colin Rawlinson", "link": stringText, "picture": pictureLink], httpMethod: "POST").start(completionHandler: {(_ connection: FBSDKGraphRequestConnection?, _ result: Any?, _ error: Error?) -> Void in
                if error == nil {
                    print("Post id: ", result as Any)
//                    let messageToast = Toast(text: "Shared On Facebook", duration: Delay.short)
//                    messageToast.show()
                }
            })
        }
    }
    
    func shareOnTwitter(userid: String = "id") {
        
        let twitter_USERID = UserDefaults.standard.string(forKey: Constants.Twitter.TWITTER_Token)
        if (twitter_USERID == nil) { return }
        
        let stringText = Utilities.getUserImage_URLString(username: self.videoObject.broadcast)
        let url = URL(string: stringText)
        let tweetImage = try? Data(contentsOf: url!)
        let tweetString = stringText
        let uploadUrl = Utilities.getShareableLink(broadcastName: self.videoObject.broadcast, imageLink: self.videoObject.broadcast)//"https://upload.twitter.com/1.1/media/upload.json"
        let updateUrl = "https://api.twitter.com/1.1/statuses/update.json"
        let imageString = tweetImage?.base64EncodedString(options: NSData.Base64EncodingOptions())
        print("link to Twitter 789:: ", stringText)
        let client = TWTRAPIClient.init(userID: twitter_USERID)
        
        if(imageString == nil) { return }
        
        let requestUploadUrl = client.urlRequest(withMethod: "POST", urlString: uploadUrl, parameters: ["media": imageString], error: nil)
        client.sendTwitterRequest(requestUploadUrl) { (urlResponse, data, connectionError) -> Void in
            if connectionError == nil {
                if let mediaDict = self.dataToJSON(data: (data! as NSData) as Data) as? [String : Any] {
                    let media_id = mediaDict["media_id_string"] as! String
                    let message = ["status": tweetString, "media_ids": media_id]
                    
                    let requestUpdateUrl = client.urlRequest(withMethod: "POST", urlString: updateUrl, parameters: message, error: nil)
                    client.sendTwitterRequest(requestUpdateUrl, completion: { (urlResponse, data, connectionError) -> Void in
                        if connectionError == nil {
                            if let _ = self.dataToJSON(data: (data! as NSData) as Data) as? [String : Any] {
                                print("Upload suceess to Twitter")
//                                let messageToast = Toast(text: "Shared On Twitter", duration: Delay.short)
//                                messageToast.show()
                            }
                        }
                    })
                }
            }
        }
    }
    
    func dataToJSON(data: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
    
    @IBAction func didTapSwitchCameraButton(_ sender:AnyObject?) {
        
        guard let lRecorder = self.recorder else {
            self.setupStreaming()
            return
        }
        
        switch self.recorder.settings.currentCamera {
        case .front:
            //self.recorder.settings.currentCamera = .back
            print("\nChanging To BACK Camera")

            self.recorder.switch(to: .back, withCompletion: nil)
            break
        case .back:
            print("\nChanging To FRONT Camera")
            self.recorder.switch(to: .front, withCompletion: nil)
            break
        default:
            print("UnKnown camera state found")
            break
        }
        return
    }

    func updateUserObject() {
        //UpdateUserBroadcastsCount_Delegate
        //let userName = CurrentUser.get_User_username_fromUserDefaults() // "002130578"
        let loggedinUser = CurrentUser.Current_UserObject
        let newCount = loggedinUser.broadcasts + 1
        loggedinUser.broadcasts = newCount
        loggedinUser.setUserDefaults()
        
        let data = ["\(Constants.UserFields.username)": loggedinUser.username as AnyObject, "\(Constants.UserFields.broadcasts)": loggedinUser.broadcasts as AnyObject] as AnyObject
        
        DataAccess.sharedInstance.Update_Data_in_UsersTable(data, delegate: self)//UpdateUser_Delegate
    }
    
    func UpdateUser_ResponseSuccess(updated_user: User, status: Bool) {
        
    }
    
    func UpdateUser_ResponseSuccess(isUserUpdated: Bool) {
        
    }
    
    func UpdateUser_ResponseError(_ error:NSError?) {
        
    }
    
    @objc func handleBitmapOverlayPinch(_ sender:UIPinchGestureRecognizer){
            let recognizer = sender.view;
            let state = sender.state;
            let recognizerView:UIImageView = bitmapOverlayImgView;
            if (state == UIGestureRecognizer.State.began || state == UIGestureRecognizer.State.changed)
            {
                let scale  = sender.scale;
                recognizerView.transform = view.transform.scaledBy(x: scale, y: scale);
                recognizer?.contentScaleFactor = 1.0;
            }
            if(state == UIGestureRecognizer.State.ended){
                bitmapOverlayImgView.frame = CGRect(x: recognizerView.frame.origin.x, y: recognizerView.frame.origin.y, width: recognizerView.frame.size.width, height: recognizerView.frame.size.height);
            }
        }
        
        @objc func handleBitmapDragged(_ sender:UIPanGestureRecognizer){
            let recognizer:UIImageView = bitmapOverlayImgView;
            self.view.bringSubview(toFront: recognizer)
            let translation = sender.translation(in: recognizer)
            recognizer.center = CGPoint(x: recognizer.center.x + translation.x, y: recognizer.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: recognizer)
     
            bitmapOverlayImgView.frame = CGRect(x: recognizer.frame.origin.x, y: recognizer.frame.origin.y, width: recognizer.frame.size.width, height: recognizer.frame.size.height);
        }

        func showAlert(_ title:String, error:NSError) {
            let alertController = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)

            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)

            self.present(alertController, animated: true, completion: nil)
        }
}

// MARK: - Private methods -

fileprivate extension LiveStreamingViewController {
    //#pragma mark - Private methods
    
//    func defaultStreamInfo() -> AXStreamInfo {
//        let info = AXStreamInfo.init()
//        info.useSecureConnection = false
//
//        info.customStreamURLString = "\(Constants.Stream_URLs.liveStreamBrodacsterUrl)\(CurrentUser.Current_UserObject.username+self.nameForVideo)"
//
////        // Alternatively you can split the URL into its corresponding RTMP parts
////        info.serverAddress = "rtmp.streamaxia.com"
////        info.applicationName = "streamaxia"
////        info.streamName = LiveStreamingViewController.kStreamaxiaStreamName;
//
//        info.username = "" //"cryout"
//        info.password = "" //"Salman101"
//
//        return info
//    }
//
//    fileprivate func defaultRecorderSettings() -> AXRecorderSettings {
//        let utils = AXUtils.init()
//        let settings = AXRecorderSettings.init()
//        settings.frameRate = 60
//        settings.videoFrameResolution = .standard1080p
//        settings.videoBitrate = utils.bitrate(for: settings.videoFrameResolution)
//        //settings.audioSampleRate = 44100
//        settings.keyFrameInterval = settings.frameRate //Int(0.5 * Double(settings.frameRate))
//        settings.videoOrientation = .autorotate //AXVideoOrientationAutorotate
//        settings.currentCamera = .front
//
//        return settings
//    }
    
    fileprivate func setupStreamaxiaSDK() {
        print("$$setupStreamaxiaSDK")
        let sdk = AXStreamaxiaSDK.sharedInstance()!
        
        // Alternatively, a custom bundle can be used to load the certificate:
        let bundleURL = Bundle.main.url(forResource: "demo-certificate", withExtension: "bundle")
        let bundle = Bundle.init(url: bundleURL!)
        
        sdk.setupSDK(with: bundle?.bundleURL) { (success, error) in
            sdk.debugPrintStatus()
            
            if (success) {
                DispatchQueue.main.async {
                    self.setupStreaming()
                }
            }
        }
    }
    
    func setupStreaming() {
        print("$$ setupStreaming")
        self.streamInfo = self.defaultStreamInfo()
        self.recorderSettings = self.defaultRecorderSettings()
        
        if let recorder = AXRecorder.init(streamInfo: self.streamInfo, settings: self.recorderSettings) {
            recorder.recorderDelegate = self
            recorder.setup(with: self.recorderView)
            recorder.prepareToRecord()
            
            var error: AXError?
            
            // Enable adaptive bitrate
            // Video quality will be adjusted based on available network and hardware resources
            recorder.activateFeatureAdaptiveBitRateWithError(&error)
            if error != nil {
                print("*** ERROR activating feature adaptive bitrate: \(error!.message)")
                error = nil
            }
            
            // Enable local save
            // The broadcast will be saved to the users camera roll when finished
            
//            recorder.activateFeatureSaveLocallyWithError(&error)
//            if error != nil {
//                print("*** ERROR activating feature save locally: \(error!.message)")
//            }
            
            // Enable tap to focus
            // The focus and exposure will be adjusted based on your selection
            recorder.activateFeatureTapToFocus { (success, error) in
                guard success else {
                    print("*** ERROR activating feature tap to focus: \(error!.message)")
                    return
                }
            }
         //   if self.recorder == nil {
                self.recorder = recorder
            
            if (self.isFrontChoosen) {
                self.recorder.switch(to: .front, withCompletion: nil)
            }
            else
            {
                self.recorder.switch(to: .back, withCompletion: nil)
            }
         //   }
        }
        
        // Printing some debug info about the initialiation settings
        let debugRecorderSettings = AXDebug.init().string(from: self.recorderSettings)
        let debugStreamInfo = AXDebug.init().string(from: self.streamInfo)
        
        print("*** DEMO **** Did set up the recorder with the following settings:\n%@\n%@", debugRecorderSettings!, debugStreamInfo!)
    }
    
    fileprivate func defaultStreamInfo() -> AXStreamInfo {
            let info = AXStreamInfo.init()
            info.useSecureConnection = false
        let streamName = CurrentUser.Current_UserObject.username + self.nameForVideo
        print(streamName)
        info.customStreamURLString = "rtmp://web.scottishhealth.live:1935/live/\(streamName)"
       // info.customStreamURLString = "rtmp://54.70.143.84:1935/live/\(streamName)"
            
           // info.customStreamURLString = "rtmp://rtmp.streamaxia.com/streamaxia/\(kStreamaxiaStreamName)"
            
    //    Alternatively you can split the URL into its corresponding RTMP parts
    //      info.serverAddress = "rtmp.streamaxia.com"
    //      info.applicationName = "streamaxia"
    //      info.streamName = kStreamaxiaStreamName;
            
            info.username = ""
            info.password = ""
            
            return info
        }
        
        fileprivate func defaultRecorderSettings() -> AXRecorderSettings {
            let utils = AXUtils.init()
            let settings = AXRecorderSettings.init()
            
            settings.videoFrameResolution = .standard1080p
            settings.frameRate = 30
            settings.videoBitrate = 1500 //utils.bitrate(for: settings.videoFrameResolution)
           // settings.videoBitrate = utils.bitrate(for: settings.videoFrameResolution)
            settings.keyFrameInterval = Int(0.5 * Double(settings.frameRate))
        
            return settings
        }
    
    func updateLabel(time: TimeInterval) {
        let t = Int(time)
        let s = t % 60
        let m = (t / 60) % 60
        let h = t / 3600
        
        let text = String.init(format: "%.2ld:%.2ld:%.2ld", Int(h), Int(m), Int(s))
        if (t > minStreamLength) {
            self.isMinimumStreamLimitReached = true
        }
        
        if (t >= maxStreamLenght) {//(t >= 20*60)
           // self.stopTimer()
            self.stopBroadcastTimer()
            let messageToast = Toast(text: "New broadcast created", duration: Delay.short)
            UserDefaults.standard.set("Done", forKey: "STATUS")
            
            var alertController = UIAlertController(title: "Thank You", message: "Your job is posted to Administrator and will show on wall as soon as it is approved", preferredStyle: UIAlertControllerStyle.alert)

              alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                  self.streamTimeCheck = true
                  self.dismiss(animated: true, completion: nil)
                  messageToast.show()
                  self.closeThisController(UIButton())
              }))

            self.present(alertController, animated: true, completion: nil)
            
        }
        
        DispatchQueue.main.async {
            let n = UserDefaults.standard.string(forKey: "STATUS")
            if n == "Done"{
                self.rightLabel.text = "00:00:30"
                UserDefaults.standard.removeObject(forKey: "STATUS")
                
            }else{
                self.rightLabel.text = text
            }
           
        }
    }
    
    func checkOrientation() {
//        let currentOrientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
////        var error: AXError? = nil
////        if currentOrientation == .portrait {
////            recorder.changeResolutionInversion(true, withError: &error)
////        } else if currentOrientation != .portraitUpsideDown {
////            recorder.changeResolutionInversion(false, withError: &error)
////        }
////        if error != nil {
////            // Handle error
////        }
    }
    
    func nameForNewStreamVideoObject() {
        
        var ticks = NSDate().timeIntervalSince1970
        ticks = ticks * 10000
        let nameForNewVideo = String(format: "%10.0f", ticks)
        let uniqueVideoName = nameForNewVideo
        self.nameForVideo = uniqueVideoName
    }
    //MARK:- addNewStreamVideoObject
    func addNewStreamVideoObject() {
        
        videoObject.name = CurrentUser.Current_UserObject.name
        videoObject.broadcast = CurrentUser.Current_UserObject.username+self.nameForVideo
        videoObject.jobSiteLink = self.jobDescriptionURL
        videoObject.arn = self.newArnForThisBroadcast
        videoObject.imglink = CurrentUser.Current_UserObject.username+self.nameForVideo
        videoObject.status = Constants.VideoStatus.online
        videoObject.viewers = 0
        videoObject.time = Date().today() //"2017-05-17 09:11:47"
        videoObject.skill = CurrentUser.Current_UserObject.skills //"abc"
        videoObject.isJob = true
        videoObject.latti = "\(myLatitued)" //"22.00"
        videoObject.longi = "\(myLongitude)" //"74.00"
        videoObject.isApproved = true
        videoObject.jobPostStatus = "Approved"
        print(address)
        videoObject.location = address
        videoObject.latti = lat //"22.00"
        videoObject.longi = long
       
        videoObject.title = LiveStreamingViewController.kStreamaxiaStreamName // ?? "Ttile 321"
        //Riz
        
        videoObject.username = CurrentUser.Current_UserObject.username
     //   videoObject.location = ""
        videoObject.isOffline = false
        var tagsData: [Tag] = []
        for tag in tagsCollection {
            let lTag = Tag()
            lTag.tag = tag
            lTag.broadcast = self.nameForVideo
            tagsData.append(lTag)
        }
        videoObject.broadcastTags = tagsData
        videoObject.messageonly = msgStr
        videoObject.callonly = callStr
        videoObject.bothmsgcall = bothStr
        videoObject.Applyonvideo = applyOnVide
        videoObject.Applyonjobsite = applyOnJob
        
        //videoObject.asJSON()
        let shSingeltonObject = DataAccess.sharedInstance
        shSingeltonObject.addOrUpdateVideo(videoObject, delegate: self as AddUpdateVideo_Protocol)
    }
    
    // MARK: - Thumbnail-Image Handling Methods
    
    func image(with view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        if let aContext = UIGraphicsGetCurrentContext() {
            view.layer.render(in: aContext)
        }
        
        let img: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img ?? UIImage()
    }
    
    
    func takeSnapshotAndLoadItToServer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
            // Your code with delay
            //let screenshot = self.recorderView.screenShot
            
            let screenshot = self.image(with: self.recorderView)
            self.postThumbNailImage(imageData: screenshot)
        }
    }
    
    func postThumbNailImage(imageData: UIImage) {
        
        //let imageData = self.convert(cmage: image)
        let image_data = self.compressImage(imageData)
        let image : String = (image_data.base64EncodedString())
        var name : String = "abc" + self.nameForVideo
        name = name + ".png"
        
        uploadImage(url:Constants.API_URLs.uploadThumbnailAPI_URL, withParams:["base64": image , "ImageName" : name ])
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


extension LiveStreamingViewController : AddUpdateVideo_Protocol {
    //MARK: - New BroadCast Handling
    
    func updatedResponse(isSuccess: Bool , error: String, id: Int)
    {
        
//        DispatchQueue.main.async {
//            //MBProgressHUD.hide(for: self.view, animated: true)
//        }
//        //broadcastButton.isEnabled    = true
        
        if isSuccess
        {
            if videoObject.status == Constants.VideoStatus.offline //"offline"
            {
                
                //self.stopBroadcastTimer()
                
                //self.performSegue(withIdentifier: "backToPlayList", sender: nil)
                //self.navigationController?.popViewController(animated: true)
                print ("2")
                self.goBackToMapVC()
                UIApplication.shared.isIdleTimerDisabled = false
            }
            else {
                if id != 0 && videoObject.id == -1
                {
                    videoObject.id = id
                    self.startStreaming()
                    UIApplication.shared.isIdleTimerDisabled = true
                    print("Streaming Started with videoId = \(videoObject.id)")
                    self.updateUserObject()
                }
                else
                {
                    self.isBroadcastStartedSuccessully = 0
                    print("Object Creation Error")
                }
            }
        }
        else
        {
            print("isSuccess : ", isSuccess)
            self.isBroadcastStartedSuccessully = 0
            //returnButton.isEnabled = true
            //let messageToast = Toast(text: "Failed To Create New BroadCast, Please Check Your Connection and retry in a moment!", duration: Delay.short)
            //messageToast.show()
            //self.broadcastTitleContainer.isHidden = false
        }
    }
    
    func startStreaming() {
        
        if (self.recorder == nil) {
            print("$$The recorder was not properly initialized.")
            self.showAlert("Error", message: "Incomplete Streaming Settings")
            return;
        }
        else {
            print("$$startStreaming")
            self.recorder.startStreaming(completion: { (success, error) in
                print("$$ stream started with success: %@", success ? "YES" : "NO")
                if (success) {
                 //   self.startBroadcastTimer()
                    DispatchQueue.main.async {
                        self.startButton.tag = self.kStopButtonTag
                        self.startButton.setTitle("Stop", for: .normal)
                         
                        if !(self.videoObject.arn == "" || self.videoObject.arn == "NA") {
                            self.commentsSection.isHidden = false
                        }
                        /*
                        if (self.isFrontChoosen) {
                            self.recorder.switch(to: .front, withCompletion: nil)
                        }
                        else
                        {
                            self.recorder.switch(to: .back, withCompletion: nil)
                        }*/
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
//                            if (self.isFrontChoosen) {
//                                self.recorder.switch(to: .front, withCompletion: nil)
//                            }
//                            else
//                            {
//                                self.recorder.switch(to: .back, withCompletion: nil)
//                            }
//                        })
                        
                        self.rightLabel.isHidden = false
                        self.startButton.isHidden = true
                        //self.commentsTableView.delegate = self
                        //self.commentsTableView.dataSource = self
                        self.textViewText.text = ""
                        self.isBroadcastStartedSuccessully = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                        self.hitAndCheckThumbnailApiFromLiveStream()
                    })
                } else {
                    print("$$ strat stream Error: %@", error ?? "")
                    print(error.debugDescription)
                    self.isBroadcastStartedSuccessully = 0
                }
            })
            
        }

//        //    micButton.setImage(UIImage(named: audioMuted ? "mic_off_button" : "mic_on_button"), for: UIControlState())
    }
}

//// MARK: - AXRecorderDelegate -

//
//    func recorder(_ recorder: AXRecorder!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from captureOutput: AVCaptureOutput!) {
//
//        //        if videoObject.id == -1 {
//        //            return
//        //        }
//        //        if recorder.isStreaming {
//        //            var stillImageOutput: AVCaptureStillImageOutput!
//        //
//        //            //...Initialize stillImageOutput
//        //
//        //            stillImageOutput.captureStillImageAsynchronouslyFromConnection(captureOutput, completionHandler: {(imageSampleBuffer, error) in
//        //                if imageSampleBuffer {
//        //                    var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer as CMSampleBuffer) // I get error on this line saying: 'Use of module ' CMSampleBuffer' as a type'
//        //                    self.processImage(UIImage(data: imageData))
//        //                }
//        //            })
//        //        }
//
//        // ==============================================================================
//        //        print("Abc Info")
//        //        let buff = captureOutput            // Have you have CMSampleBuffer
//        //        if #available(iOS 10.0, *) {
//        //            if let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buff as! CMSampleBuffer, previewPhotoSampleBuffer: nil) {
//        //                let image = UIImage(data: imageData) //  Here you have UIImage
//        //                if (image != nil) {
//        //                    print("Image FOUND 8****")
//        //                }
//        //            }
//        //        } else {
//        //            // Fallback on earlier versions
//        //            print("for older iOS this feature is  not available")
//        //        }
//    }
//}

// MARK: - UI Setup -

fileprivate extension LiveStreamingViewController {
    
    private func infoFont() -> UIFont? {
        return UIFont.init(name: "AvenirNextCondensed-UltraLight", size: 14.0)
    }
    
    private func labelFont() -> UIFont? {
        return UIFont.init(name: "AvenirNextCondensed-Regular", size: 16.0)
    }
    
    private func buttonFont() -> UIFont? {
        return UIFont.init(name: "AvenirNextCondensed-Medium", size: 20.0)
    }
    
    func setupUI() {
        self.setupMain()
        self.setupStartButton()
        self.setupLeftLabel()
        self.setupRightLabel()
        self.setupInfoLabel()
    }
    
    private func setupMain() {
        self.recorderView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        self.overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        self.view.backgroundColor = UIColor.lightGray
    }
    
    private func setupStartButton() {
        let button: UIButton = self.startButton!
        
        button.layer.cornerRadius = self.startButton.frame.size.height * 0.5
        button.backgroundColor = UIColor.black
        button.tintColor = UIColor.white
        button.tag = self.kStartButtonTag
        button.titleLabel?.font = self.buttonFont()
        button.setTitle("Start", for: .normal)
    }
    
    private func setupLeftLabel() {
//        let label = self.leftLabel!
//
//        label.font = self.labelFont()
//        label.backgroundColor = UIColor.black.withAlphaComponent(0.8)
//        label.text = "[N/A]"
//        label.textColor = UIColor.white
    }
    
    private func setupRightLabel() {
//        let label = self.rightLabel!
//
//        label.font = self.labelFont()
//        label.backgroundColor = UIColor.black.withAlphaComponent(0.8)
//        label.text = "T: 00:00:00"
//        label.textColor = UIColor.white
    }
    
    private func setupInfoLabel() {
//        let label = self.infoLabel!
//
//        label.font = self.infoFont()
//        label.backgroundColor = UIColor.black.withAlphaComponent(0.4)
//        label.text = ""
//        label.textColor = UIColor.white
    }
    
    func showAlert(_ title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension UIView{
    
    var screenShot: UIImage?  {
        //        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0);
        //        if let _ = UIGraphicsGetCurrentContext() {
        //            drawHierarchy(in: bounds, afterScreenUpdates: true)
        //            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        //            UIGraphicsEndImageContext()
        //            return screenshot
        //        }
        //        return nil
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        if let aContext = UIGraphicsGetCurrentContext() {
            self.layer.render(in: aContext)
        }
        let img: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img ?? UIImage()
    }
}

//extension LiveStreamingViewController: UITableViewDelegate, UITableViewDataSource
//{
//    func numberOfSections(in tableView: UITableView) -> Int
//    {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
//    {
//        if (self.commentsArray.count > 3) {
//            return 3
//        }
//        return self.commentsArray.count
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        var height: CGFloat = (tableView.frame.size.height / 6)
//        let minHeight: CGFloat = 79.0
//
//        if(height < minHeight)
//        {
//            height = minHeight
//        }
//
//        return height
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
//    {
//        print("come in cell for row at")
//        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableView_Cells.messagesTableViewCell, for: indexPath) as! CommentsTableViewCell
//       // var commentAtIndex = self.commentsArray[indexPath.row] as Comment
//        let object = self.streamComment[indexPath.row]
////        if (self.commentsArray.count >= 3) {
////            switch indexPath.row {
////            case 0:
////                // do something
////                commentAtIndex = self.commentsArray[self.commentsArray.count - 3]
////                cell.alpha = 0.33
////                break
////            case 1:
////                commentAtIndex = self.commentsArray[self.commentsArray.count - 2]
////                cell.alpha = 0.66
////                break
////            case 2:
////                commentAtIndex = self.commentsArray[self.commentsArray.count - 1]
////                cell.alpha = 1.0
////                break
////            // other rows
////            default:
////                commentAtIndex = self.commentsArray[self.commentsArray.count-1]
////                cell.alpha = 1.0
////                break
////            }
////        }
////        else if (self.commentsArray.count == 2) {
////            switch indexPath.row {
////            case 0:
////                cell.alpha = 0.66
////                break
////            case 1:
////                cell.alpha = 1.0
////                break
////            default:
////                cell.alpha = 1.0
////                break
////            }
////        }
////        else {
////            cell.alpha = 1.0
////        }
//        cell.nameLabel.text = object.name
//        cell.messageLabel.text = object.comment
//        cell.profileImage.image = object.image
//        print("return from cell")
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
//    {
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//
////    func scrollToBottom() {
////        DispatchQueue.main.async {
////            if (self.commentsArray.count == 0) {
////                return
////            }
////            var indexPath:IndexPath
////            if (self.commentsArray.count > 3) {
////                indexPath = IndexPath(row: 2, section: 0)
////            }
////            else {
////                indexPath = IndexPath(row: self.commentsArray.count-1, section: 0)
////            }
////            self.commentsTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
////        }
////    }
//}
// MARK:- Recoder Code
extension LiveStreamingViewController: AXRecorderDelegate {
    func recorder(_ recorder: AXRecorder!, didChange state: AXRecorderState) {
        print("$$Recorder State Changed to: \(state)")
        
        var string = "N/A"
        
        switch state {
        case .stopped:
            string = "$$[Stopped]"
            self.recorder.endSession()
            self.recorder = nil
        case .recording:
            string = "$$[Recording]"
        case .starting:
            string = "$$[Starting...]"
        case .stopping:
            string = "$$[Stopping...]"
        case .collectingExtraData:
            string = "$$[Get Extra Data]"
        case .processingExtraData:
            string = "$$[Proc. Extra Data]"
        default:
            string = "$$[Unknown state]"
        }
        
        DispatchQueue.main.async {
         //   self.leftLabel.text = string
            print("Streamaxia Stream " + string)
        }
    }
    
    func recorder(_ recorder: AXRecorder!, didUpdateStreamTime deltaTime: TimeInterval) {
        // Show the recording time in the right label
        DispatchQueue.main.async {
            self.updateLabel(time: deltaTime)
        }
    }
    
    func recorder(_ recorder: AXRecorder!, didChange status: AXNetworkStatus) {
        print("$$did change network status: \(status)")
        
        var string = "Unknown network status"
        
        switch status {
        case .notReachable:
            string = "Lost internet connection"
        case .reachableViaWiFi:
            string = "Internet is reachable on wifi"
        case .reachableViaWWAN:
            string = "Internet is reachabale on Cellular"
        }
        
        DispatchQueue.main.async {
     //       self.infoLabel.text = string
        }
    }
    
    func recorder(_ recorder: AXRecorder!, didReceive info: AXInfo!) {
        print("$$did receive info: %@", info)
    }
    
    func recorder(_ recorder: AXRecorder!, didReceive warning: AXWarning!) {
        print("$$ did receive warning: %@", warning)
    }
    
    func recorder(_ recorder: AXRecorder!, didReceiveError error: AXError!) {
        print("$$ did receive error: %@", error)
    }
}



extension LiveStreamingViewController : UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("come in number of rows in section - View")
        return self.streamComment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("come in cellForRowAt")
        let cell = tableView.dequeueReusableCell(withIdentifier: "StreamChatCommentCell") as! StreamChatCell
        cell.name.text = self.streamComment[indexPath.row].name
        cell.comment.text = self.streamComment[indexPath.row].comment
        
        cell.name.textColor = .white
        cell.comment.textColor = .white
        
        cell.img.contentMode = .scaleAspectFit
        cell.img.layer.cornerRadius = cell.img.frame.height/2
        cell.img.layer.borderWidth = 1
        cell.img.clipsToBounds = true
        cell.img.layer.borderColor = UIColor.black.cgColor
            
        cell.img.image = self.streamComment[indexPath.row].image
        cell.backgroundColor = .clear
        return cell
    }
}
















extension Dictionary {
    
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    func dict2json() -> String {
        return json
    }
}

extension String {
    
    func toDictionary() -> NSDictionary {
        
        let jsonString = "{\"uchlo\":[\"1\",\"2\",\"3\"]}"
        let jsonData = jsonString.data(using: .utf8)
        let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
        print(dictionary!)
        return dictionary as! NSDictionary
    }
}

extension Notification.Name {
    
    static let commentReachedThisDevice = Notification.Name(rawValue: "newCommentReachedThisDevice")
}

extension Dictionary {
    var myDesc: String {
        get {
            var v = ""
            var counter = 0
            for (key, value) in self {
                if counter > 0 {
                    v += "&"
                }
                //let lValue = "\(value)".utf8EncodedString()
                v += ("\(key)=\(value)")
                counter += 1
            }
            return v
        }
    }
}


extension UITableView {
    func scrollTableViewToBottom(animated: Bool) {
        guard let dataSource = dataSource else { return }

        var lastSectionWithAtLeasOneElements = (dataSource.numberOfSections?(in: self) ?? 1) - 1

        while dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeasOneElements) < 1 {
            lastSectionWithAtLeasOneElements -= 1
        }

        let lastRow = dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeasOneElements) - 1

        guard lastSectionWithAtLeasOneElements > -1 && lastRow > -1 else { return }

        let bottomIndex = IndexPath(item: lastRow, section: lastSectionWithAtLeasOneElements)
        scrollToRow(at: bottomIndex, at: .bottom, animated: animated)
    }
}
