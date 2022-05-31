//
//  VODWowzaViewController.swift
//  SimX
//
//  Created by Apple on 08/11/2019.
//  Copyright © 2019 Agilio. All rights reserved.
//

import UIKit
import WowzaGoCoderSDK
import Toaster

class VODWowzaViewController : UIViewController, WOWZPlayerStatusCallback, AddUpdateVideo_Protocol {
    let SDKSampleSavedConfigKey = "SDKSampleSavedConfigKey"
    let SDKSampleAppLicenseKey = "GOSK-0E47-010C-0499-E641-2E7D"
    
    var goCoderConfig : WowzaConfig!
    
    var player = WOWZPlayer()
    
    var receivedGoCoderEventCodes = Array<WOWZPlayerEvent>()
    
    var currentVideo = COVideo()
    
    var videoUrlString: String = ""
    
//    var newArnForThisBroadcast: String = ""
//    var subscriptionArn: String = ""
//    var lastStatusCallBack = ""
    
    // MARK: - Private Properties -
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    
    //    @IBOutlet weak var leftLabel: UILabel!
    var playerLayerAlreadyAdded = false
    var lastStatusCallBack = ""
    
    @IBOutlet weak var recorderView: UIView!
    var videoObject = COVideo()
    
    @IBAction func playingStatusButtonTapped(_ sender: UIButton) {
        if self.player.currentPlayState() != .playing {
            self.player.hlsPlayer?.play()
        }
    }
    
    @IBAction func closeThisController(_ sender: UIButton) {
        if self.player.currentPlayState() == .playing {
            self.player.stop()
        }
        if (self.navigationController != nil) {
            self.navigationController?.popViewController(animated: true)
            print("Moving Back in Navigation Stack")
            return
        }
        print("Moving Back in with Dismiss Action")
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Log version and platform info
        print("WowzaGoCoderSDK version =\n major: \(WOWZVersionInfo.majorVersion())\n minor: \(WOWZVersionInfo.minorVersion())\n revision: \(WOWZVersionInfo.revision())\n build: \(WOWZVersionInfo.buildNumber())\n string: \(WOWZVersionInfo.string())\n verbose string: \(WOWZVersionInfo.verboseString())")
        
        print("Platform Info:\n\(WOWZPlatformInfo.string())")
        self.videoTitleLabel.text = self.currentVideo.title
        
        if let goCoderLicensingError = WowzaGoCoder.registerLicenseKey(SDKSampleAppLicenseKey) {
            self.showAlert("GoCoder SDK Licensing Error", error: goCoderLicensingError as NSError)
        }
        self.recorderView.backgroundColor = .black
        
        self.setUpWowzaPlayer()
        if (self.currentVideo.status == Constants.VideoStatus.offline) {
            self.updatedVideoCounter()
        }
    }
    
    func setUpWowzaPlayer() {
        
        let goCoderBroadcastConfig = WowzaConfig()
        
        goCoderBroadcastConfig.hostAddress = "54.70.143.84" //"www.simx.tv" //54.70.143.84
        goCoderBroadcastConfig.portNumber = 1935
        goCoderBroadcastConfig.applicationName = "vod"
        
        goCoderBroadcastConfig.streamName = self.currentVideo.broadcast
        
        // Set the defaults for 288p video
        goCoderBroadcastConfig.load(WOWZFrameSizePreset.preset1280x720)
        
        goCoderBroadcastConfig.broadcastVideoOrientation = .alwaysPortrait
        
        // // Update the active config
        //DispatchQueue.main.async {
        self.goCoderConfig = goCoderBroadcastConfig
        //}
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print ("\n\n\n\n 9999 \n", self.currentVideo.broadcast, ".mp4\n\n\n\n")
        if(self.player.currentPlayState() == WOWZPlayerState.idle) {
             
            self.player.playerView?.backgroundColor = .black

            if self.goCoderConfig != nil {
                self.player.play(self.goCoderConfig, callback: self)
            }
            else {
                print("888 goCoderConfig Crash handled")
                self.showAlertWithDismiss("Try Again", message: "Settings not found")
            }
        }
        else {
            self.player.resetPlaybackErrorCount()
            self.player.stop()
        }
    }
    
    func showAlertWithDismiss(_ title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .default, handler: { action in
            DispatchQueue.main.async {
                self.goBackToMapVC()
            }
        })
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        //print("Video Finished")
        Toast(text: "Video Finished").show()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.player.resetPlaybackErrorCount()
        self.player.stop()
        self.goCoderConfig = nil
    }
    
    func addVideoPlayer() {
        
        self.videoUrlString = Constants.Stream_URLs.liveStreamViewerUrl + self.currentVideo.broadcast as String + Constants.Stream_URLs.liveStreamPostFix
        //        videoURLString = Constants.Stream_URLs.liveStreamViewerUrl + "myWowzaTest1" + Constants.Stream_URLs.liveStreamPostFix
        
        //"http://www.simx.tv:1935/live/ADCCiTN4lN15671448853700/playlist.m3u8"
        
        //print("video url 3333", videoURLString)
        let url = URL(string: self.videoUrlString)
        let asset = AVURLAsset(url: url!, options: nil)
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        
        let playerLayer = AVPlayerLayer(player: player) // keep the layer hidden
        playerLayer.frame = self.recorderView.frame
        playerLayer.backgroundColor = UIColor.black.cgColor
        self.recorderView.layer.addSublayer(playerLayer)
        player.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            player.play()
        })
    }
    
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
        if (self.navigationController != nil) {
            self.navigationController?.popViewController(animated: true)
            print("Moving Back in Navigation Stack")
            return
        }
        print("Moving Back in with Dismiss Action")
        dismiss(animated: true, completion: nil)
    }
    
    func onWOWZStatus(_ status: WOWZPlayerStatus!) {
        
        print("player status is called : ", status.state.rawValue)
        switch (status.state) {
        case .idle:
            
            print("player stream is idle \(status.state.rawValue)")
            if (self.lastStatusCallBack != "") {
                DispatchQueue.main.async { () -> Void in
                    self.closeThisController(UIButton())
                }
            }
            Toast(text: "Idle").show()
            break
            
        case .connecting:
            self.player.playerView = self.recorderView;
            print("player stream is connecting \(status.state.rawValue)")
            Toast(text: "Connecting").show()
            break;
        case .playing:
            DispatchQueue.main.async { () -> Void in
                UIView.animate(withDuration: 0.25, animations: {
                    
                })
            }
            self.lastStatusCallBack = "playing"
            print("player stream is playing \(status.state.rawValue)")
            Toast(text: "Playing").show()
            break;
        case .stopping:
//            if (self.lastStatusCallBack != "") {
//                DispatchQueue.main.async { () -> Void in
                    self.closeThisController(UIButton())
//                }
//            }
            print("player stream is stopping \(status.state.rawValue)")
            break;
            
        case .buffering:
            //            DispatchQueue.main.async { () -> Void in
            //
            //            }
            self.lastStatusCallBack = "buffering"
            print("player stream is buffering \(status.state.rawValue)")
            Toast(text: "Buffering").show()
            break;
        default: break
        }
    }
    
    func onWOWZError(_ status: WOWZPlayerStatus!) {
        print("onWOWZError(_ status called 9999")
        print(status.error?.localizedDescription ?? "error occured")
    }
    
    func showAlert(_ title:String, error:NSError) {
        let alertController = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
