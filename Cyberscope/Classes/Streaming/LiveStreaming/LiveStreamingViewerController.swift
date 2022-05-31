//
//  LiveStreamingViewerController.swift
//  CyberScope
//
//  Created by Salman on 18/05/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import PeriscommentView
import WowzaGoCoderSDK

class LiveStreamingViewerController: UIViewController, AddUpdateVideo_Protocol, WOWZPlayerStatusCallback {
    
    let SDKSampleSavedConfigKey = "SDKSampleSavedConfigKey"
    let SDKSampleAppLicenseKey = "GOSK-0E47-010C-0499-E641-2E7D"
    
    var goCoderConfig:WowzaConfig!
    
    lazy var player = WOWZPlayer()
    
    var receivedGoCoderEventCodes = Array<WOWZPlayerEvent>()
    
    var currentVideo = COVideo()
    
    var commentsArray:[Comment] = []
    
    var numberOfViewers: Int = 0
    @IBOutlet weak var viewersLabel: UILabel!
    @IBOutlet weak var lblStreamTime: UILabel!
    
    var newArnForThisBroadcast: String = ""
    var subscriptionArn: String = ""
    var lastStatusCallBack = ""
    fileprivate let kStartButtonTag: NSInteger = 0
    
    fileprivate let kStopButtonTag: NSInteger = 1
    
    // MARK: - Private Properties -
    
    var streamComment : [StreamComment] =  [
       
    ]
    
    @IBOutlet weak var startButton: UIButton!
    
    //    @IBOutlet weak var leftLabel: UILabel!
    var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    //    var rightLabel: UILabel!
    
    var playerLayerAlreadyAdded = false
    
    @IBOutlet weak var periscopeCommentView: PeriscommentView!
    @IBOutlet weak var commentsSection: UIView!
    @IBOutlet weak var commentsTableView: UITableView!
    
    @IBOutlet weak var tvViewerComments: UITableView!
    
    @IBOutlet weak var commentsTypeView: UIView!
    @IBAction func sendCommentAction(_ sender: UIButton) {
        let stringText = self.textViewText.text
        print("### come in send comment action ")
        print("publishMessageToTopicfunction call")
        print(stringText)
        self.publishMessageToTopic(messageText: stringText!)
        self.textViewText.text = ""
    }
    
    @IBOutlet weak var textViewText: UITextView!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var recorderView: UIView!
    
    @IBOutlet weak var overlayView: UIView!
    
  
    var nameForVideo = ""
    
    /// The recorder
    fileprivate var recorder: AXRecorder!
    
    /// The stream info
    fileprivate var streamInfo: AXStreamInfo!
    
    /// The recorder settings
    fileprivate var recorderSettings: AXRecorderSettings!
    
    var videoObject = COVideo()
    var timer = Timer()
    var secondsPassed = 0
    var minsPassed = 0
    
    @IBAction func closeThisController(_ sender: UIButton) {
        
        
        self.unsubscibrForTopic(topicArn: self.newArnForThisBroadcast)
        self.goBackToMapVC()
        
        if (self.navigationController != nil) {
            self.navigationController?.popViewController(animated: true)
            print("###Moving Back in Navigation Stack")
            return
        }
        print("###Moving Back in with Dismiss Action")
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        commentsTableView.delegate = self
//        commentsTableView.dataSource = self
//        commentsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        commentsTableView.backgroundColor = .clear
        
        tvViewerComments.delegate = self
        tvViewerComments.dataSource = self
        tvViewerComments.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tvViewerComments.backgroundColor = .clear

        print("##come in view did load LiveStreamingViewerController")
        // Log version and platform info
        print("WowzaGoCoderSDK version =\n major: \(WOWZVersionInfo.majorVersion())\n minor: \(WOWZVersionInfo.minorVersion())\n revision: \(WOWZVersionInfo.revision())\n build: \(WOWZVersionInfo.buildNumber())\n string: \(WOWZVersionInfo.string())\n verbose string: \(WOWZVersionInfo.verboseString())")
        
        print("Platform Info:\n\(WOWZPlatformInfo.string())")
        
        if let goCoderLicensingError = WowzaGoCoder.registerLicenseKey(SDKSampleAppLicenseKey) {
            self.showAlert("GoCoder SDK Licensing Error", error: goCoderLicensingError as NSError)
        }
        self.recorderView.backgroundColor = .black
        
        self.setupStreaming()
        
        self.textViewText.text = ""
        self.newArnForThisBroadcast = self.currentVideo.arn
        if !(self.newArnForThisBroadcast == "" || self.newArnForThisBroadcast == "NA") {
            self.commentsSection.isHidden = false
            print("###subscribeToThisTopic fun call",self.currentVideo.arn)
            self.subscribeToThisTopic(topicArn: self.currentVideo.arn)
        } else {
            self.commentsSection.isHidden = true
        }
        if (self.currentVideo.status == Constants.VideoStatus.offline) {
            self.updatedVideoCounter()
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func setupStreaming() {
        
        // Get a copy of the active config
        let goCoderBroadcastConfig = WowzaConfig()
        
        // Set the defaults for 288p video
        //goCoderBroadcastConfig.load(WOWZFrameSizePreset.preset960x540)
        goCoderBroadcastConfig.load(WOWZFrameSizePreset.preset1280x720)
        //goCoderBroadcastConfig.load(WOWZFrameSizePreset.preset640x480)
        goCoderBroadcastConfig.broadcastScaleMode = .aspectFill
//        goCoderBroadcastConfig.videoFrameRate = 30
//        goCoderBroadcastConfig.videoKeyFrameInterval = 30
//        goCoderBroadcastConfig.videoBitrate = 2500 //3750 //6000 // 3750 // 2500 // 1000
//        goCoderBroadcastConfig.videoBitrateLowBandwidthScalingFactor = 0.0
        
        // Set the connection properties for the target Wowza Streaming Engine server or Wowza Streaming Cloud live stream
        goCoderBroadcastConfig.hostAddress = "web.scottishhealth.live"
        goCoderBroadcastConfig.portNumber = 1935
        goCoderBroadcastConfig.applicationName = "live"
        
        goCoderBroadcastConfig.streamName = self.currentVideo.broadcast
        goCoderBroadcastConfig.broadcastVideoOrientation = .alwaysPortrait
        
        // Update the active config
        self.goCoderConfig = goCoderBroadcastConfig
    }
    
    @objc func updateTimer() {
        
        self.secondsPassed += 1
        self.lblStreamTime.text = "\(self.minsPassed):\(self.secondsPassed)"
        if(self.secondsPassed == 60){
            self.minsPassed += 1
            self.secondsPassed = 0
        }
        print("0:\(self.secondsPassed)")
    }

    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("###addNewCommentInTableViewupdate")
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(self.addNewCommentInTableView),
                                       name: .commentReachedThisDevice,
                                       object: nil)
        
        if(self.player.currentPlayState() == WOWZPlayerState.idle){
            print("$$ come in self.player.playerView?.backgroundColor = .black")
            self.player.playerView?.backgroundColor = .black
            self.player.play(self.goCoderConfig, callback: self)
        }
        else {
            print("$$ come in self.player.stop()")
            self.player.resetPlaybackErrorCount()
            self.player.stop()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .commentReachedThisDevice, object: nil)
    }
    
    @objc func addNewCommentInTableView(notification: NSNotification) {
        print("### comeaddNewCommentInTableView")
        let currentUserReference = CurrentUser.Current_UserObject
        
        let newCommentMessage = notification.value(forKey: "object") as! [String: String]
        let newComment = Comment()
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
                if (image != nil) {
                    print("### errror nil image found")
                 //   self.periscopeCommentView.addCell(profileImage: image!, name: newComment.name, comment: newComment.text)
                    self.streamComment.append(StreamComment(image: image!, name: newComment.name, comment: newComment.text))
                }
                else
                {
                    print("### errror profileImage")
                    let profileImage = UIImage(named: Constants.imagesName.default_UserImage)!
                  
                    self.streamComment.append(StreamComment(image: profileImage, name: newComment.name, comment: newComment.text))
                }
            }
            else
            {
                print("### 22 errror profileImage")
                let profileImage = UIImage(named: Constants.imagesName.default_UserImage)!
                self.streamComment.append(StreamComment(image: profileImage, name: newComment.name, comment: newComment.text))
            }
            
            DispatchQueue.main.async {
                print("comment table view reload")
                self.tvViewerComments.reloadData()
                
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1, execute: {
                self.tvViewerComments.scrollTableViewToBottom(animated: true)
            })
        })
    }
    
    // MARK: - Public methods -
    
    func updatedVideoCounter() {
        
        self.currentVideo.viewers += 1
        let shSingeltonObject = DataAccess.sharedInstance
        shSingeltonObject.addOrUpdateVideo(self.currentVideo, delegate: self as AddUpdateVideo_Protocol)
    }
    
    func updatedResponse(isSuccess: Bool , error: String, id: Int)
    {
        print("updated response :: ", isSuccess)
    }
    
    // MARK: - Actions -
    
    @IBAction func startButtonPressed(_ button: UIButton) {
        
    }
    
    func goBackToMapVC() {
        //performSegue(withIdentifier: "unwind789678", sender: self)
        timer.invalidate()
        self.unsubscibrForTopic(topicArn: self.subscriptionArn)
        if (self.navigationController != nil) {
            self.navigationController?.popViewController(animated: true)
            print("###Moving Back in Navigation Stack")
            return
        }
        print("###Moving Back in with Dismiss Action")
        dismiss(animated: true, completion: nil)
    }
    
    func subscribeToThisTopic(topicArn : String) {
        let topicSubscribeRequestInput = AWSSNSSubscribeInput()
        topicSubscribeRequestInput?.topicArn = self.currentVideo.arn
        topicSubscribeRequestInput?.protocols = "application"
        topicSubscribeRequestInput?.endpoint = UserDefaults.standard.value(forKey: "endpointArnForSNSCyberScope787") as? String
        print("###topicSubscribeRequestInput end point",topicSubscribeRequestInput?.endpoint)
        
        let sns = AWSSNS.default()
        sns.subscribe(topicSubscribeRequestInput!).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("###error topicSubscribeRequestInputError: \(String(describing: task.error))")
            } else {
                let createEndpointResponse = task.result! as AWSSNSSubscribeResponse
                if let subscriptionArn = createEndpointResponse.subscriptionArn {
                    print("### error subscriptionArn: \(subscriptionArn)")
                    self.subscriptionArn = subscriptionArn
                    if (self.currentVideo.status == Constants.VideoStatus.online) {
                        print("### pupublishMessageToTopicView call")
                        self.publishMessageToTopicView(messageText: "")
                        self.getViewersFrom(topicArn: self.newArnForThisBroadcast)
                    }
                }
            }
            return nil
        })
    }
    
    func unsubscibrForTopic(topicArn: String) {
        print("##come in unsubscibrForTopic")
        let topicSubscribeRequestInput = AWSSNSUnsubscribeInput()
        topicSubscribeRequestInput?.subscriptionArn = topicArn
        
        let sns = AWSSNS.default()
        sns.unsubscribe(topicSubscribeRequestInput!).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("Error: \(String(describing: task.error))")
            } else {
//                let createEndpointResponse = task.result! as AWSSNSUnsubscribeResponse
//                if let subscriptionArn = createEndpointResponse.subscriptionArn {
//                    print("subscriptionArn: \(subscriptionArn)")
//                }
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
        print("###publishMessageToTopicView")
        let currentUserReference = CurrentUser.Current_UserObject
        
        let publishToTopicRequestInput = AWSSNSPublishInput()
        publishToTopicRequestInput?.messageStructure = "json"
        let messageDict = ["name":currentUserReference.name, "text":messageText, "user":currentUserReference.username, "type":"view", "arn":self.subscriptionArn]
        publishToTopicRequestInput?.message = ["default":messageDict.dict2json()].dict2json() //messageDict.dict2json()
        print(publishToTopicRequestInput?.message!)
        publishToTopicRequestInput?.topicArn = self.newArnForThisBroadcast
        
        let sns = AWSSNS.default()
        sns.publish(publishToTopicRequestInput!).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("Error: \(String(describing: task.error))")
            } else {
                let publishMessageResponse = task.result! as AWSSNSPublishResponse
                if let messageId = publishMessageResponse.messageId {
                    print("subscriptionArn: \(messageId)")
                }
            }
            return nil
        })
    }
    
    func publishMessageToTopic(messageText: String) {
        print("## come in publish messag eto topic")
        let currentUserReference = CurrentUser.Current_UserObject
        
        let newComment = Comment()
        newComment.arn = currentUserReference.arn
        newComment.name = currentUserReference.name
        newComment.text = messageText
        newComment.type = "message"
        newComment.user = currentUserReference.username

        let userPhotoUrl = Utilities.getUserImage_URL(username: newComment.user)
        UIImageView().sd_setImage(with: userPhotoUrl, placeholderImage: UIImage(named: Constants.imagesName.broadcaster_image), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            // Perform operation.
            if (error == nil) {
                if (image != nil) {
                    print("###come in image is not equal to nil")
                 //   self.periscopeCommentView.addCell(profileImage: image!, name: newComment.name, comment: newComment.text)
                    self.streamComment.append(StreamComment(image: image!, name: newComment.name, comment: newComment.text))
                }
                else
                {
                    print("###come in image is equal to nil")
                    let profileImage = UIImage(named: Constants.imagesName.default_UserImage)!
                   // self.periscopeCommentView.addCell(profileImage: profileImage, name: newComment.name, comment: newComment.text)
                    self.streamComment.append(StreamComment(image: profileImage, name: newComment.name, comment: newComment.text))
                }
            }
            else{
                let profileImage = UIImage(named: Constants.imagesName.default_UserImage)!
                self.streamComment.append(StreamComment(image: profileImage, name: newComment.name, comment: newComment.text))
            }
            
            DispatchQueue.main.async {
                print("comment table view reload")
                self.tvViewerComments.reloadData()
                
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1, execute: {
                self.tvViewerComments.scrollTableViewToBottom(animated: true)
            })
        })
        
        print("###come after that to AWSSNSPublishInput")
        let publishToTopicRequestInput = AWSSNSPublishInput()
        publishToTopicRequestInput?.messageStructure = "json"
        let messageDict = ["name":currentUserReference.name, "text":messageText, "user":currentUserReference.username, "type":"message", "arn":self.subscriptionArn]
        publishToTopicRequestInput?.message = ["default":messageDict.dict2json()].dict2json() //messageDict.dict2json()
        print("# message",publishToTopicRequestInput?.message!)
        publishToTopicRequestInput?.topicArn = self.newArnForThisBroadcast
        let sns = AWSSNS.default()
        print("###sns.publish")
        sns.publish(publishToTopicRequestInput!).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("###Error: \(String(describing: task.error))")
            } else {
                let publishMessageResponse = task.result! as AWSSNSPublishResponse
                if let messageId = publishMessageResponse.messageId {
                    print("#### error free subscriptionArn: \(messageId)")
                }
            }
            return nil
        })
    }
    
    func setLabelViwersCountText() {
        let viewersLabelText = ".\(self.numberOfViewers) viewers"
        self.viewersLabel.text = viewersLabelText
        self.viewersLabel.textColor = .black

    }
    
    
    
    
    //MARK:- STREAMING CODE
    func onWOWZStatus(_ status: WOWZPlayerStatus!) {
        
        print("$$player status is called : ", status.state.rawValue)
        switch (status.state) {
        case .idle:
            
            print("$$player stream is idle \(status.state.rawValue)")
            if (self.lastStatusCallBack != "") {
                DispatchQueue.main.async { () -> Void in
                    self.closeThisController(UIButton())
                }
            }
            break
        
        case .connecting:
//            DispatchQueue.main.async { () -> Void in
//                // A streaming playback session is.connecting up
//            }
            self.player.playerView = self.recorderView;
            print("$$player stream is connecting \(status.state.rawValue)")
            break;
        case .playing:
            DispatchQueue.main.async { () -> Void in
                UIView.animate(withDuration: 0.25, animations: {
                    
                })
            }
            self.lastStatusCallBack = "playing"
            print("$$player stream is idle \(status.state.rawValue)")
            break;
        case .stopping:
            DispatchQueue.main.async { () -> Void in
                self.closeThisController(UIButton())
            }
            print("$$player stream is stopping \(status.state.rawValue)")
            break;

        case .buffering:
//            DispatchQueue.main.async { () -> Void in
//
//            }
            self.lastStatusCallBack = "buffering"
            print("$$player stream is buffering \(status.state.rawValue)")
            break;
        default: break
        }
    }
    
    func onWOWZError(_ status: WOWZPlayerStatus!) {
        print("$$onWOWZError(_ status called 9999")
        print(status.error?.localizedDescription ?? "error occured")
    }
    
    func showAlert(_ title:String, error:NSError) {
        let alertController = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)

        self.present(alertController, animated: true, completion: nil)
    }
}

//extension LiveStreamingViewerController: UITableViewDelegate, UITableViewDataSource
//{
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if (self.commentsArray.count > 3) {
//            return 3
//        }
//        return self.commentsArray.count
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        var height: CGFloat = (tableView.frame.size.height / 6)
//        let minHeight: CGFloat = 79.0
//
//        if(height < minHeight) {
//            height = minHeight
//        }
//
//        return height
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableView_Cells.messagesTableViewCell, for: indexPath) as! CommentsTableViewCell
//        var commentAtIndex = self.commentsArray[indexPath.row] as Comment
//        print("##come in commentstablewviewcell")
//        if (self.commentsArray.count >= 3) {
//            switch indexPath.row {
//            case 0:
//                // do something
//                commentAtIndex = self.commentsArray[self.commentsArray.count - 3]
//                cell.alpha = 0.33
//                break
//            case 1:
//                commentAtIndex = self.commentsArray[self.commentsArray.count - 2]
//                cell.alpha = 0.66
//                break
//            case 2:
//                commentAtIndex = self.commentsArray[self.commentsArray.count - 1]
//                cell.alpha = 1.0
//                break
//            // other rows
//            default:
//                commentAtIndex = self.commentsArray[self.commentsArray.count-1]
//                cell.alpha = 1.0
//                break
//            }
//        }
//        else if (self.commentsArray.count == 2) {
//            switch indexPath.row {
//            case 0:
//                cell.alpha = 0.66
//                break
//            case 1:
//                cell.alpha = 1.0
//                break
//            default:
//                cell.alpha = 1.0
//                break
//            }
//        }
//        else {
//            cell.alpha = 1.0
//        }
//        cell.nameLabel.text = commentAtIndex.name
//        cell.messageLabel.text = commentAtIndex.text
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
//    {
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//
//    func scrollToBottom() {
//        DispatchQueue.main.async {
//            if (self.commentsArray.count == 0) {
//                return
//            }
//            var indexPath:IndexPath
//            if (self.commentsArray.count > 3) {
//                indexPath = IndexPath(row: 2, section: 0)
//            }
//            else {
//                indexPath = IndexPath(row: self.commentsArray.count-1, section: 0)
//            }
//            self.commentsTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//        }
//    }
//}


extension LiveStreamingViewerController : UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("come in number of rows in section -- Viewer")
        return self.streamComment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("come in cellForRowAt")
        let cell = tableView.dequeueReusableCell(withIdentifier: "StreamChatCell") as! StreamChatCell
        cell.name.text = self.streamComment[indexPath.row].name
        cell.comment.text = self.streamComment[indexPath.row].comment
        print(self.streamComment[indexPath.row].comment
)
        
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


