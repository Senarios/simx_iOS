//
//  InitiateCallVC.swift
//  CyberScope
//
//  Created by Saad Furqan on 19/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import Foundation
import Quickblox
import QuickbloxWebRTC

class InitiateCallVC: UIViewController, QBChatDelegate, QBRTCClientDelegate, QBCoreDelegate
{
    
 //   @IBOutlet weak var myVideoTrack: QBRTCRemoteVideoView!
 //   @IBOutlet weak var oponentVideoTrack: QBRTCRemoteVideoView!
    @IBOutlet weak var button_initiateCall: UIButton!
    @IBOutlet weak var button_acceptCall: UIButton!
    @IBOutlet weak var button_rejectCall: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    
    var videoCapture: QBRTCCameraCapture!
    var session : QBRTCSession?
    let userInfo :[String:String] = ["key":"value"]
    
    //opponent's id's list
 //   let opponentsIDs: [NSNumber] = [47909442] // senarios
    let opponentsIDs: [NSNumber] = [47909264] // saad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup_controls()
    }

    func setup_controls()
    {
        QBRTCClient.initializeRTC()
        QBRTCClient.instance().add(self)
        
        cofigureVideo()
        configureAudio()
        
        self.login_to_QBChat(startCall: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.resumeVideoCapture()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: WebRTC configuration
    func cofigureVideo()
    {
        QBRTCConfig.mediaStreamConfiguration().videoCodec = QBRTCVideoCodec.h264Baseline //.H264
        
        let videoFormat = QBRTCVideoFormat.init()
        videoFormat.frameRate = 21
        videoFormat.pixelFormat = .format420f
        videoFormat.width = 640
        videoFormat.height = 480
        
        self.videoCapture = QBRTCCameraCapture.init(videoFormat: videoFormat, position: .front)
        self.videoCapture.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        self.videoCapture.startSession {
            
            let localView = LocalVideoView.init(withPreviewLayer:self.videoCapture.previewLayer)
            self.stackView.addArrangedSubview(localView)
        }
    }
    
    func configureAudio() {
        
        QBRTCConfig.mediaStreamConfiguration().audioCodec = .codecOpus
        //Save current audio configuration before start call or accept call
        QBRTCAudioSession.instance().initialize()
        QBRTCAudioSession.instance().currentAudioDevice = .speaker
        //OR you can initialize audio session with a specific configuration
        QBRTCAudioSession.instance().initialize { (configuration: QBRTCAudioSessionConfiguration) -> () in
            
            var options = configuration.categoryOptions
            if #available(iOS 10.0, *) {
                options = options.union(AVAudioSessionCategoryOptions.allowBluetoothA2DP)
                options = options.union(AVAudioSessionCategoryOptions.allowAirPlay)
            } else {
                options = options.union(AVAudioSessionCategoryOptions.allowBluetooth)
            }
            
            configuration.categoryOptions = options
            configuration.mode = AVAudioSessionModeVideoChat
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func login_to_QBChat(startCall: Bool)
    {
        let current_user = CurrentUser.getCurrentUser_From_UserDefaults()
        let user    = QBUUser()
        user.id = UInt(current_user.qbid)!
        user.login = current_user.username
        user.password = Constants.QuickBlox.QB_User_Default_Password
        user.fullName = current_user.name
        
        QBCore.instance().setCurrentUser(user)
        
        if QBChat.instance.isConnected
        {
            print("\n Already LogedIn to the chat... \n")
            
            if(startCall)
            {
                self.start_call()
            }
        }
        else
        {
            QBChat.instance.connect(withUserID: user.id, password: user.password!, completion: { (error) in
                
                if error == nil
                {
                    print("\n Successfully LogIn to QB chat ... \n")
                    if(startCall)
                    {
                        self.start_call()
                    }
                }
                else
                {
                    print("\n Error = \(String(describing: error?.localizedDescription)) \n")
                }
                
            })
        }
    }
    
    @IBAction func button_initiateCall_Action(_ sender: Any)
    {
        self.login_to_QBChat(startCall: true)
    }
    
    @IBAction func button_End_Call(_ sender: Any)
    {
        if self.session != nil {
            self.session?.hangUp(nil)
        }
    }
    func start_call()
    {
        let alert = UIAlertController.init(title: "Select Call Type", message: " ?? ", preferredStyle: .actionSheet)
        let current_user = CurrentUser.getCurrentUser_From_UserDefaults()
        let accept = UIAlertAction.init(title: "Audio", style: .default) { action in
            
            self.session = QBRTCClient.instance().createNewSession(withOpponents: self.opponentsIDs, with: .audio)
            
            // userInfo - the custom user information dictionary for the call. May be nil.
            self.session?.localMediaStream.videoTrack.videoCapture = self.videoCapture
            let userInfo = ["name":current_user.name]
            self.session?.startCall(userInfo)
        }
        
        let reject = UIAlertAction.init(title: "Video", style: .default) { action in
            
            self.session = QBRTCClient.instance().createNewSession(withOpponents: self.opponentsIDs, with: .video)
            
            // userInfo - the custom user information dictionary for the call. May be nil.
            let userInfo = ["name":current_user.name]
            self.session?.localMediaStream.videoTrack.videoCapture = self.videoCapture
            self.session?.startCall(userInfo)
        }
        
        alert.addAction(accept)
        alert.addAction(reject)
        self.present(alert, animated: true)
        
    }
    
    @IBAction func button_acceptCall_Action(_ sender: Any)
    {
        // userInfo - the custom user information dictionary for the accept call. May be nil.
        let userInfo :[String:String] = ["key":"value"]
        self.session?.acceptCall(userInfo)
    }
    
    @IBAction func button_rejectCall_Action(_ sender: Any)
    {
        // userInfo - the custom user information dictionary for the reject call. May be nil.
        let userInfo :[String:String] = ["key":"value"]
        self.session?.rejectCall(userInfo)
        
        // and release session instance
        self.session = nil;
    }
    
    func handleIncomingCall() {
        
        let alert = UIAlertController.init(title: "Incoming call", message: "Accept ?", preferredStyle: .actionSheet)
        
        let accept = UIAlertAction.init(title: "Accept", style: .default) { action in
            
            self.session?.localMediaStream.videoTrack.videoCapture = self.videoCapture
            self.session?.acceptCall(nil)
        }
        
        let reject = UIAlertAction.init(title: "Reject", style: .default) { action in
            self.session?.rejectCall(nil)
        }
        
        alert.addAction(accept)
        alert.addAction(reject)
        self.present(alert, animated: true)
    }
    
    /*
     
     |||||||||||||||||||||||||||||||||||||||||||||||||||||
     ||                                                 ||
     ||        *****    DELEGATE METHODS    *****       ||
     ||                                                 ||
     |||||||||||||||||||||||||||||||||||||||||||||||||||||
     
     */
    
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        
        if self.session == nil {
            self.session = session
            handleIncomingCall()
        }
    }
    
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {
        
        if (session as! QBRTCSession).id == self.session?.id {
            if session.conferenceType == QBRTCConferenceType.video {
                
            }
        }
    }
    
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        
        if session.id == self.session?.id {
            
            self.removeRemoteView(with: userID.uintValue)
            if userID == session.initiatorID {
                self.session?.hangUp(nil)
            }
        }
    }
    
    func session(_ session: QBRTCBaseSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {
        
        if (session as! QBRTCSession).id == self.session?.id {
            
            let remoteView :QBRTCRemoteVideoView = QBRTCRemoteVideoView.init()
            remoteView.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
            remoteView.clipsToBounds = true
            remoteView.setVideoTrack(videoTrack)
            remoteView.tag = userID.intValue
            self.stackView.addArrangedSubview(remoteView)
        }
    }
    
    func sessionDidClose(_ session: QBRTCSession) {
        
        if ProviderDelegate.accepted {
            ProviderDelegate.accepted = false // to be made false when ever closing the call
            ProviderDelegate.CloseCallKIT()
        }
        
        if session.id == self.session?.id
        {
            for userID in self.opponentsIDs
            {
                self.removeRemoteView(with: UInt(userID))
            }
            self.session = nil
        }
    }
    
    //MARK: Helpers
    
    func resumeVideoCapture() {
        // ideally you should always stop capture session
        // when you are leaving controller in any way
        // here we should get its running state back
        if self.videoCapture != nil && !self.videoCapture.hasStarted {
            self.session?.localMediaStream.videoTrack.videoCapture = self.videoCapture
            self.videoCapture.startSession(nil)
        }
    }
    
    func removeRemoteView(with userID: UInt) {
        
        for view in self.stackView.arrangedSubviews {
            if view.tag == userID {
                self.stackView.removeArrangedSubview(view)
            }
        }
    }
    
    /*
    
    // QBChatDelegate methods
    //func chat
    
    // MARK: QBRTCClientDelegate
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        
        if self.session != nil
        {
            // we already have a video/audio call session, so we reject another one
            // userInfo - the custom user information dictionary for the call from caller. May be nil.
            let userInfo :[String:String] = ["key":"value"]
            session.rejectCall(userInfo)
        }
        else if self.session == nil
        {
            self.session = session
            handleIncomingCall()
        }
    }
    
    // method that indicates accept call signal
    func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil)
    {
        print("Accepted by user \(userID)")
    }
    
    // method that indicates reject call signal
    func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil)
    {
        print("Rejected by user \(userID)")
    }
    
    // Connection life-cycle
    // Called when connection is initiated with user:
    func session(_ session: QBRTCBaseSession, startedConnectingToUser userID: NSNumber)
    {
        print("Started connecting to user \(userID)")
    }
    
    // Called when connection is closed for user
    func session(_ session: QBRTCBaseSession, connectionClosedForUser userID: NSNumber)
    {
        print("Connection is closed for user \(userID)")
    }
    
    // Called in case when connection is established with user:
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber)
    {
        print("Connection is established with user \(userID)")
    }
    
    // Called in case when user is disconnected:
    func session(_ session: QBRTCBaseSession, disconnectedFromUser userID: NSNumber)
    {
        print("Disconnected from user \(userID)");
    }
    
    // Called in case when user did not respond to your call within timeout .
    // note: use +[QBRTCConfig setAnswerTimeInterval:value] to set answer time interval
    func session(_ session: QBRTCSession, userDidNotRespond userID: NSNumber)
    {
        print("User \(userID) did not respond to your call within timeout")
    }
    
    // Called in case when connection failed with user.
    func session(_ session: QBRTCBaseSession, connectionFailedForUser userID: NSNumber)
    {
        print("Connection has failed with user \(userID)")
    }
    
    // States
    // Called when QBRTCSession state was changed. Session's state might be new, pending, connecting, connected and closed.
    func session(_ session: QBRTCBaseSession, didChange state: QBRTCSessionState)
    {
        print("Session did change state to \(state)")
    }
    
    // Called when session connection state changed for a specific user. Connection state might be unknown, new, pending, connecting, checking, connected, disconnected, closed, count, disconnect timeout, no answer, rejected, hangup and failed.
    func session(_ session: QBRTCBaseSession, didChange state: QBRTCConnectionState, forUser userID: NSNumber)
    {
        print("Session did change state to \(state) for userID \(userID)")
    }
    
    // Manage remote media tracks
    // In order to show video views with streams which you have received from your opponents you should create QBRTCRemoteVideoView views on storyboard and then use the following code:
    
    // Called in case when receive remote video track from opponent
    func session(_ session: QBRTCBaseSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber)
    {
        // we suppose you have created UIView and set it's class to QBRTCRemoteVideoView class
        // also we suggest you to set view mode to UIViewContentModeScaleAspectFit or
        // UIViewContentModeScaleAspectFill
       // self.oponentVideoTrack?.setVideoTrack(videoTrack)
    }
    
    // You can as well get remote audio track for a specific user in call using this QBRTCClientDelegate method (use it, for example, to mute a specific user audio in call:
    
    // //Called in case when receive remote video track from opponent
    func session(_ session: QBRTCBaseSession, receivedRemoteAudioTrack audioTrack: QBRTCAudioTrack, fromUser userID: NSNumber)
    {
        // mute specific user audio track here (for example)
        // you can also always do it later by using '[QBRTCSession remoteAudioTrackWithUserID:]' method
        audioTrack.isEnabled = false
    }
    
    // Manage local video track
    
    */
}



