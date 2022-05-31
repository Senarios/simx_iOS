//
//  IncomingCallVC.swift
//  CyberScope
//
//  Created by Saad Furqan on 24/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import Toaster

class IncomingCallVC: UIViewController, QBRTCClientDelegate
{
    @IBOutlet weak var label_topTitle: UILabel!
    @IBOutlet weak var button_rejectCall: UIButton!
    @IBOutlet weak var button_acceptCall: UIButton!
    
    var topTitle = "Incoming Call"
    var vibrationTimer: Timer?
    var ringtoneTimer: Timer?
    
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("555 I am IncomingCallVC viewDidLoad")
        // Do any additional setup after loading the view.
        self.setup_controls()
    }

    func setup_controls()
    {
        QBRTCClient.instance().add(self)
        
        self.label_topTitle.text = self.topTitle
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        print("555 I am IncomingCallVC viewWillAppear")
        self.set_Timers()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        print("555 I am IncomingCallVC viewWillDisappear")
        self.deset_Timers()
        QMSoundManager.instance().stopAllSounds()
    }
    
    func set_Timers()
    {
        self.vibrationTimer?.invalidate()
        self.vibrationTimer = nil
        
        self.ringtoneTimer?.invalidate()
        self.ringtoneTimer = nil
        
        self.vibrationTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.vibrateMobile), userInfo: nil, repeats: true)
        
        self.playSound()
        self.ringtoneTimer = Timer.scheduledTimer(timeInterval: 6.0, target: self, selector: #selector(self.playSound), userInfo: nil, repeats: true)
    }
    
    func deset_Timers()
    {
        self.vibrationTimer?.invalidate()
        self.vibrationTimer = nil
        
        self.ringtoneTimer?.invalidate()
        self.ringtoneTimer = nil
        
        self.player?.stop()
        self.player = nil
    }
    
    @objc func vibrateMobile()
    {
        UIDevice.vibrate()
    }
    
    @objc func playSound()
    {
        player = nil // release the precontained instance (if any)
        guard let url = Bundle.main.url(forResource: "ringtone", withExtension: "wav") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func button_rejectCallTapped(_ sender: Any)
    {
        self.deset_Timers()
        AppDelegate.QB_VideoChat_session?.rejectCall(nil)
        AppDelegate.QB_VideoChat_session = nil
    }
    
    @IBAction func button_acceptCallTapped(_ sender: Any)
    {
        self.deset_Timers()
        
      //  AppDelegate.QB_VideoChat_session?.acceptCall(nil)
        let vc =  UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil).instantiateViewController(withIdentifier: Constants.ViewControllers.CallingVC) as! CallingVC
        vc.acceptCall = true
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        print ("I am IncomingCallVC 888, Window Presentation")
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1
        alertWindow.makeKeyAndVisible()
        AppDelegate.shared_instance.popupWindow = alertWindow
        alertWindow.rootViewController?.present(vc, animated: true, completion:{
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    // *********************        DELEGATE METHODS        ************************** \\
    // QBRTCClientDelegate methods
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil)
    {
        print("\n ** IncomingCallVC ** didReceiveNewSession called ... \n")
    }
    
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber)
    {
        print("\n ** IncomingCallVC ** connectedToUser called with userID = \(userID) \n")
        AppDelegate.QB_VideoChat_connectedTo_UserID = userID
    }
    
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil)
    {
        print("\n ** IncomingCallVC ** hungUpByUser called and userID = \(userID) \n")
    }
    
    func session(_ session: QBRTCBaseSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {
        
        print("\n ** IncomingCallVC ** receivedRemoteVideoTrack called fromUser userID \(userID) \n")
    }
    
    func sessionDidClose(_ session: QBRTCSession)
    {
        if ProviderDelegate.accepted {
            ProviderDelegate.accepted = false // to be made false when ever closing the call
            ProviderDelegate.CloseCallKIT()
        }
        
        print("\n ** IncomingCallVC ** sessionDidClose called ...\n")
        if (true) //AppDelegate.QB_VideoChat_session != nil
        {
            AppDelegate.QB_VideoChat_session?.hangUp(nil)
            
            AppDelegate.QB_VideoChat_connectedTo_UserID = nil
            AppDelegate.QB_VideoChat_current_CallType = nil
            AppDelegate.QB_VideoChat_session = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute: {
                self.dismiss(animated: true, completion: nil)
            })
        }
//        do {
//            try AVAudioSession.sharedInstance().setActive(false)
//        }
//        catch {
//            Toast(text: "Exception while de-activating audio session IncomingCallVC:: \(error.localizedDescription)", delay: 5.0, duration: Delay.short)
//            print(error)
//        }
    }
    
}
