//
//  CallingVC.swift
//  CyberScope
//
//  Created by Saad Furqan on 23/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import Toaster

class CallingVC: UIViewController, QBRTCClientDelegate, UpdateUser_Delegate, AddCallRecord_Delegate
{
    @IBOutlet weak var label_topTitle: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var miniStackView: UIStackView!
    
    @IBOutlet weak var button_switchCamera: UIButton!
    @IBOutlet weak var button_disconnect: UIButton!
    @IBOutlet weak var button_cameraOff: UIButton!
    @IBOutlet weak var button_dynamicOff: UIButton!
    @IBOutlet weak var button_muteOff: UIButton!
    
    var acceptCall: Bool?
    var localView: UIView!
    var remoteView: QBRTCRemoteVideoView!
    var videoCapture: QBRTCCameraCapture!
    
    var ringtoneTimer: Timer?
    var player: AVAudioPlayer?
    
    var callTimer: Timer?
    var timeDuration: TimeInterval = 0.0
    var isUpdateBalanceBeenHit = false
    var totalDuration_ofCall: (hours: Int, minutes: Int, seconds: Int) = (0, 0, 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setup_controls()
    }
    
    func presentMeOnAlertWindow() {
        print ("I am CallingVC presentMeOnAlertWindow 888, Window Presentation")
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.windowLevel = UIWindowLevelStatusBar + 1
        alertWindow.rootViewController = self // as? UIViewController //UIViewController()
        alertWindow.makeKeyAndVisible()
    }
    
    func set_Timers() {
        self.ringtoneTimer?.invalidate()
        self.ringtoneTimer = nil
        
        self.playSound()
        self.ringtoneTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.playSound), userInfo: nil, repeats: true)
    }
    
    @objc func playSound() {
        QMSoundManager.playCallingSound()
    }
    
    func deset_Timers() {
        self.ringtoneTimer?.invalidate()
        self.ringtoneTimer = nil
        
        QMSoundManager.instance().stopAllSounds()
        if (self.player == nil) { return }
        self.player?.stop()
        self.player = nil
    }
    
    func setup_controls() {
        QBRTCClient.initializeRTC()
        QBRTCClient.instance().add(self)
        
        if(AppDelegate.QB_VideoChat_current_CallType == QBRTCConferenceType.audio) {
            self.configureAudio()
            
        }
        else if(AppDelegate.QB_VideoChat_current_CallType == QBRTCConferenceType.video) {
            self.configureAudio()
            self.configureVideo()
        }
        self.setControlsForCall()
        self.callTimer?.invalidate()
        self.callTimer = nil
        self.timeDuration = 0.0
        
        self.label_topTitle.text = "Connecting... "
        if (AppDelegate.QB_VideoChat_session == nil) && (self.acceptCall == false) {
            self.login_to_QBChat(startCall: true)
        }
        else if (AppDelegate.QB_VideoChat_session != nil) && (self.acceptCall == true) {
            DispatchQueue.main.asyncAfter(deadline: .now()+2.0, execute: {
                AppDelegate.QB_VideoChat_session?.localMediaStream.videoTrack.videoCapture = self.videoCapture
                AppDelegate.QB_VideoChat_session?.acceptCall(nil)
            })
        }
    }
    
    func setControlsForCall() {
        if(AppDelegate.QB_VideoChat_current_CallType == QBRTCConferenceType.audio) {
            self.button_switchCamera.isHidden = true
            self.button_cameraOff.isHidden = true
            self.button_dynamicOff.isHidden = false
            self.button_muteOff.isHidden = false
            
            self.button_dynamicOff.isSelected = false
            self.button_muteOff.isSelected = false
        }
        else if(AppDelegate.QB_VideoChat_current_CallType == QBRTCConferenceType.video) {
            self.button_switchCamera.isHidden = false
            self.button_cameraOff.isHidden = false
            self.button_dynamicOff.isHidden = false
            self.button_muteOff.isHidden = false
            
            self.button_dynamicOff.isSelected = true
            self.button_muteOff.isSelected = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppDelegate.QB_VideoChat_session?.localMediaStream.audioTrack.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.deset_Timers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.isUpdateBalanceBeenHit = false
        super.viewDidAppear(animated)
        
        if (self.label_topTitle.text == "Connecting... ") {
            self.set_Timers()
        } else {
            QMSoundManager.instance().stopAllSounds()
        }
        self.resumeVideoCapture()
        self.resumeAudioSession()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    @IBAction func button_switchCamera_Tapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        print("888 Video Capture position Crash")
        let position: AVCaptureDevice.Position = videoCapture!.position
        let newPosition: AVCaptureDevice.Position = position == .back ? .front : .back
        if (videoCapture?.hasCamera(for: newPosition))!
        {
            let animation = CATransition.init()
            animation.duration = 0.75
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.type = "oglFlip"
            if position == .front {
                animation.subtype = kCATransitionFromRight
            }
            else if position == .back {
                animation.subtype = kCATransitionFromLeft
            }
            
            localView.layer.add(animation, forKey: nil)
            videoCapture?.position = newPosition
        }
    }
    
    @IBAction func button_muteOff_Tapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        AppDelegate.QB_VideoChat_session?.localMediaStream.audioTrack.isEnabled = !((AppDelegate.QB_VideoChat_session?.localMediaStream.audioTrack.isEnabled)!)
    }
    
    @IBAction func button_dynamicOff_Tapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        let device: QBRTCAudioDevice = QBRTCAudioSession.instance().currentAudioDevice
        QBRTCAudioSession.instance().currentAudioDevice = device == .speaker ? .receiver : .speaker
    }
    
    @IBAction func button_cameraOff_Tapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        AppDelegate.QB_VideoChat_session?.localMediaStream.videoTrack.isEnabled = !((AppDelegate.QB_VideoChat_session?.localMediaStream.videoTrack.isEnabled)!)
    }
    
    @IBAction func button_disconnect_Tapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if AppDelegate.QB_VideoChat_session != nil
        {
            AppDelegate.QB_VideoChat_session?.hangUp(nil)
        }
    }
    
    //MARK: WebRTC configuration
    func configureVideo() {
        QBRTCAudioSession.instance().currentAudioDevice = .speaker
        QBRTCConfig.mediaStreamConfiguration().videoCodec = QBRTCVideoCodec.h264Baseline //.H264
        
        let videoFormat = QBRTCVideoFormat.init()
        videoFormat.frameRate = 21
        videoFormat.pixelFormat = .format420f
        videoFormat.width = 640
        videoFormat.height = 480
        
        self.videoCapture = QBRTCCameraCapture.init(videoFormat: videoFormat, position: .front)
        self.videoCapture.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        self.videoCapture.startSession
        {
            self.localView = LocalVideoView.init(withPreviewLayer:self.videoCapture.previewLayer)
            self.stackView.addArrangedSubview(self.localView)
        }
    }
    
    func configureAudio() {
        
        QBRTCConfig.mediaStreamConfiguration().audioCodec = .codecOpus
        //Save current audio configuration before start call or accept call
        QBRTCAudioSession.instance().initialize()
        QBRTCAudioSession.instance().currentAudioDevice = .receiver //.speaker
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
            
            if AppDelegate.QB_VideoChat_session?.conferenceType == .video
            {
                configuration.mode = AVAudioSessionModeVideoChat
            }
            else
            {
                configuration.mode = AVAudioSessionModeVoiceChat
            }
        }
        
    }
    
    func start_Call() {
        let qbid: NSNumber = NSNumber(integerLiteral: Int((AppDelegate.QB_VideoChat_opponetUser?.qbid)!)!)
        print(qbid)
        AppDelegate.QB_VideoChat_session = QBRTCClient.instance().createNewSession(withOpponents: [qbid] as [NSNumber],
                                                                                   with: AppDelegate.QB_VideoChat_current_CallType!)
        AppDelegate.QB_VideoChat_session?.localMediaStream.videoTrack.videoCapture = self.videoCapture
        
        QBRTCConfig.setAnswerTimeInterval(60.0)
        let current_user = CurrentUser.getCurrentUser_From_UserDefaults()
        let userInfo = ["name":current_user.name]
        AppDelegate.QB_VideoChat_session?.startCall(userInfo)
        AppDelegate.send_VOIP_PUSH_Notification(toUsers: (AppDelegate.QB_VideoChat_opponetUser?.qbid)!)
    }
    
    func login_to_QBChat(startCall: Bool) {
        let current_user = CurrentUser.getCurrentUser_From_UserDefaults()
        let user    = QBUUser()
        user.id = UInt(current_user.qbid)!
        user.login = current_user.username
        user.password = Constants.QuickBlox.QB_User_Default_Password
        user.fullName = current_user.name
        
        QBCore.instance().setCurrentUser(user)
        
        if QBChat.instance.isConnected {
            print("\n Already LogedIn to the chat... \n")
            if(startCall) {
                DispatchQueue.main.asyncAfter(deadline: .now()+2.0, execute: {
                    self.start_Call()
                })
            }
        }
        else {
            QBChat.instance.connect(withUserID: user.id, password: user.password!, completion: { (error) in
                if error == nil {
                    print("\n Successfully LogIn to QB chat ... \n")
                    if(startCall) {
                        DispatchQueue.main.asyncAfter(deadline: .now()+2.0, execute: {
                            self.start_Call()
                        })
                    }
                }
                else {
                    print("\n Error = \(String(describing: error?.localizedDescription)) \n")
                    let alert = UIAlertController(title: "Error", message: "Unable to initiate call because user is not connected to QB chat.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                            self.button_disconnect_Tapped(self.button_disconnect)
                        })
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    @objc func refreshCallTime(_ sender: Timer?) {
        timeDuration = timeDuration + kRefreshTimeInterval
        self.label_topTitle.text = "Call time - \(stringWithTimeDuration(timeDuration: timeDuration))"
    }
    
    
    func stringWithTimeDuration(timeDuration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional // Use the appropriate positioning for the current locale
        formatter.allowedUnits = [ .hour, .minute, .second ] // Units to display in the formatted string
        formatter.zeroFormattingBehavior = [ .pad ] // Pad with zeroes where appropriate for the locale
        let formattedDuration = formatter.string(from: timeDuration)
        
        // update total call time
        self.totalDuration_ofCall = (timeDuration.hours, timeDuration.minutes, timeDuration.seconds)
        
        return formattedDuration!
    }
    
    func doubleWithTimeDuration(timeDuration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional // Use the appropriate positioning for the current locale
        formatter.allowedUnits = [ .hour, .minute, .second ] // Units to display in the formatted string
        formatter.zeroFormattingBehavior = [ .pad ] // Pad with zeroes where appropriate for the locale
        let formattedDuration = formatter.string(from: timeDuration)
        
        // update total call time
        self.totalDuration_ofCall = (timeDuration.hours, timeDuration.minutes, timeDuration.seconds)
        
        return formattedDuration!
    }
    
    //MARK: Helpers methods
    func resumeVideoCapture() {
        // ideally you should always stop capture session
        // when you are leaving controller in any way
        // here we should get its running state back
        if self.videoCapture != nil && !self.videoCapture.hasStarted {
            AppDelegate.QB_VideoChat_session?.localMediaStream.videoTrack.videoCapture = self.videoCapture
            self.videoCapture.startSession(nil)
        }
    }
    
    func resumeAudioSession() {
        print("\n resumeAudioSession called ... \n")
        QBRTCAudioSession.instance().initialize { (configuration) in
            //Toast(text: "Audio Session initialization").show()
            configuration.categoryOptions.formUnion(.allowBluetooth)
            configuration.categoryOptions.formUnion(.allowBluetoothA2DP)
            configuration.categoryOptions.formUnion(.allowAirPlay)
            if AppDelegate.QB_VideoChat_session?.conferenceType == .video {
                configuration.mode = AVAudioSessionModeVideoChat
            } else {
                configuration.mode = AVAudioSessionModeVoiceChat
            }
        }
    }
    
    func removeRemoteView(with userID: UInt) {
        
        for view in self.stackView.arrangedSubviews {
            if view.tag == userID {
                self.stackView.removeArrangedSubview(view)
            }
        }
        for view in self.miniStackView.arrangedSubviews {
            if view.tag == userID {
                self.miniStackView.removeArrangedSubview(view)
                self.miniStackView.isHidden = true
            }
        }
    }
    
    // *********************        DELEGATE METHODS        ************************** \\
    // QBRTCClientDelegate methods
    
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        print("\n ** CallingVC ** didReceiveNewSession called and userInfo = \(String(describing: userInfo)) \n")
    }
    
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {
        print("\n ** CallingVC ** connectedToUser called and userID = \(userID) \n")
        if (session as! QBRTCSession).id == AppDelegate.QB_VideoChat_session?.id {
            AppDelegate.QB_VideoChat_session?.localMediaStream.audioTrack.isEnabled = true
            AppDelegate.QB_VideoChat_connectedTo_UserID = userID
            
            if session.conferenceType == QBRTCConferenceType.video {
                QBRTCAudioSession.instance().currentAudioDevice = .speaker
                self.button_dynamicOff.isSelected = true
            }
        }
        
        self.deset_Timers()
        
        if (!(self.callTimer != nil)) {
            self.callTimer = Timer.scheduledTimer(timeInterval: kRefreshTimeInterval, target: self, selector: #selector(self.refreshCallTime(_:)), userInfo: nil, repeats: true)
        }
    }
    
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("\n ** CallingVC ** hungUpByUser called and userID = \(userID) \n")
        if session.id == AppDelegate.QB_VideoChat_session?.id {
            
            self.removeRemoteView(with: userID.uintValue)
            if userID == session.initiatorID {
                AppDelegate.QB_VideoChat_session?.hangUp(nil)
                print("\n ** CallingVC ** sessionDidClose called ... \n")
                if ProviderDelegate.accepted {
                    ProviderDelegate.accepted = false // to be made false when ever closing the call
                    ProviderDelegate.CloseCallKIT()
                }
                AppDelegate.shared_instance.popupWindow = nil
            }
        }
    }
    
    func session(_ session: QBRTCBaseSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {
        print("\n ** CallingVC ** receivedRemoteVideoTrack from userID = \(userID) \n")
        if (session as! QBRTCSession).id == AppDelegate.QB_VideoChat_session?.id {
            remoteView = QBRTCRemoteVideoView.init()
            remoteView.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
            remoteView.clipsToBounds = true
            remoteView.setVideoTrack(videoTrack)
            remoteView.tag = userID.intValue
            
            self.miniStackView.isHidden = false
            print("888 removeArrangedSubView Crash");
            self.stackView.removeArrangedSubview(self.localView)
            self.stackView.addArrangedSubview(self.remoteView)
            self.miniStackView.addArrangedSubview(self.localView)
        }
    }
    
    func session(_ session: QBRTCBaseSession, receivedRemoteAudioTrack audioTrack: QBRTCAudioTrack, fromUser userID: NSNumber) {
        print("\n ** CallingVC ** receivedRemoteAudioTrack from userID = \(userID) \n")
    }
    
    func sessionDidClose(_ session: QBRTCSession) {
        print("\n ** CallingVC ** sessionDidClose called ... \n")
        if ProviderDelegate.accepted {
            ProviderDelegate.accepted = false // to be made false when ever closing the call
            ProviderDelegate.CloseCallKIT()
        }
        AppDelegate.shared_instance.popupWindow = nil
        
        let initiatorIDString:String = String(format:"%@", session.initiatorID)
        if(initiatorIDString == CurrentUser.Current_UserObject.qbid && !self.isUpdateBalanceBeenHit) {
            
            if(Double(self.totalDuration_ofCall.minutes) > 5)
            {
                let totalHours = (Double(self.totalDuration_ofCall.hours) + Double(self.totalDuration_ofCall.minutes)/60.0 + Double(self.totalDuration_ofCall.seconds)/3600.0) - 0.084
                if totalHours > 0.0 {
                    let opponentUser = AppDelegate.QB_VideoChat_opponetUser
                    let balanceToCall = totalHours * (Double((opponentUser?.rate) ?? "") ?? 0)
                    var newBalance = 0.0
                    if (balanceToCall >= CurrentUser.Current_UserObject.credit) {
                        newBalance = 0.0
                    }
                    else {
                        newBalance = CurrentUser.Current_UserObject.credit - balanceToCall
                    }
                    let loggedinUser = CurrentUser.Current_UserObject
                    print("Old Balance:: \(loggedinUser.credit)\n")
                    loggedinUser.credit = newBalance
                    print("New Balance:: \(loggedinUser.credit)\n")
                    CurrentUser.setCurrentUser_UserDefaults(user: loggedinUser)
                    CurrentUser.Current_UserObject = CurrentUser.getCurrentUser_From_UserDefaults()
                    let data = ["\(Constants.UserFields.username)": loggedinUser.username as AnyObject, "\(Constants.UserFields.credit)": loggedinUser.credit as AnyObject] as AnyObject
                    
                    DataAccess.sharedInstance.Update_Data_in_UsersTable(data, delegate: self)
                    
                    let jsonForCallRecord = ["time_stamp": "\(Int64(Date().timeIntervalSince1970 * 1000))", "caller_id": loggedinUser.username, "caller_name": loggedinUser.name, "caller_type": loggedinUser.skills, "receiver_id": (opponentUser?.username)!, "receiver_name": (opponentUser?.name)!, "receiver_type": (opponentUser?.skills)!, "call_duration": "\(totalHours)", "receiver_hour_rate": (opponentUser?.rate)!, "call_cost": "\(balanceToCall)", "receiver_balance_bc": "NA", "receiver_balance_ac": "NA"]
                    
                    //                newJson["receiver_balance_bc"] = oldBalanceOfOponent
                    //                newJson["receiver_balance_ac"] = newBalanceOfOponent
                    self.addCallRecordInDFTable(json: jsonForCallRecord as [String : Any])
                    Toast(text: "Your new balance is \(loggedinUser.credit)£").show()
                    if (balanceToCall > 0.0) {
                        self.updateOponentBalance(balanceToAdd: balanceToCall)
                    }
                    
                    self.isUpdateBalanceBeenHit = true
                }
                else {
                    Toast(text: "Call did not get connected.").show()
                }
            }
        }
        
        if session.id == AppDelegate.QB_VideoChat_session?.id {
            if let id = AppDelegate.QB_VideoChat_connectedTo_UserID {
                self.removeRemoteView(with: UInt(truncating: id))
            }
            
            AppDelegate.QB_VideoChat_connectedTo_UserID = nil
            AppDelegate.QB_VideoChat_current_CallType = nil
            AppDelegate.QB_VideoChat_session = nil
        }
        
        self.callTimer?.invalidate()
        self.callTimer = nil
        self.timeDuration = 0.0
        //session.Audio
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func updateOponentBalance(balanceToAdd: Double) {
        if (self.isUpdateBalanceBeenHit) {
            return
        }
        
        let opponentUser = AppDelegate.QB_VideoChat_opponetUser
        let addBalanceAmount = 0.75 * balanceToAdd // 75% of call amount will be given as credit to Callee
        let oldBalanceOfOponent =  opponentUser?.credit
        let newBalanceOfOponent = oldBalanceOfOponent! + addBalanceAmount
        opponentUser?.credit = newBalanceOfOponent
        
        let newDataAccess = DataAccess()
        
        let data = ["\(Constants.UserFields.username)": opponentUser?.username as AnyObject, "\(Constants.UserFields.credit)": opponentUser?.credit as AnyObject] as AnyObject
        
        newDataAccess.Update_Data_in_UsersTable(data, delegate: self)
        //        })
    }
    
    func addCallRecordInDFTable(json:[String: Any]) {
        
        let newDataAccess = DataAccess()
        
        newDataAccess.add_Call_Record(json as AnyObject, delegate: self)
    }
    
    func AddCallRecord_Delegate_Response(isSuccess: Bool , error: String, id: String) {
        print("I am back from adding data in call records isSuccess : \(isSuccess) id : \(id) error : \(error.description)")
    }
    
    func UpdateUser_ResponseSuccess(updated_user: User, status: Bool) {
        print("Balance updated successfully!")
    }
    
    func UpdateUser_ResponseError(_ error: NSError?) {
        print("Error occoured while updating balance.")
    }
}
