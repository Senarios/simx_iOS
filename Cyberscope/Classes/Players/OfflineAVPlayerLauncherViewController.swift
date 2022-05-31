//
//  OfflineAVPlayerLauncherViewController.swift
//  SimX
//
//  Created by Apple on 07/11/2019.
//  Copyright © 2019 Agilio. All rights reserved.
//

import UIKit
import AVKit
import WowzaGoCoderSDK

class OfflineAVPlayerLauncherViewController : UIViewController, WOWZPlayerStatusCallback, AddUpdateVideo_Protocol {
    let SDKSampleSavedConfigKey = "SDKSampleSavedConfigKey"
    let SDKSampleAppLicenseKey = "GOSK-0E47-010C-0499-E641-2E7D"
    
    var goCoderConfig : WowzaConfig!
    
    lazy var player = WOWZPlayer()
    
    var receivedGoCoderEventCodes = Array<WOWZPlayerEvent>()
    
    var currentVideo = COVideo()
    
    
//    var newArnForThisBroadcast: String = ""
//    var subscriptionArn: String = ""
//    var lastStatusCallBack = ""
//    fileprivate let kStartButtonTag: NSInteger = 0
//
//    fileprivate let kStopButtonTag: NSInteger = 1
    
    // MARK: - Private Properties -
    
    @IBOutlet weak var startButton: UIButton!
    
    //    @IBOutlet weak var leftLabel: UILabel!
    var playerLayerAlreadyAdded = false
    var lastStatusCallBack = ""
    
    @IBOutlet weak var recorderView: UIView!
    var videoObject = COVideo()
    
    @IBAction func closeThisController(_ sender: UIButton) {
        
        
//        //self.goBackToMapVC()
        
//        if (self.navigationController != nil) {
//            self.navigationController?.popViewController(animated: true)
//            print("Moving Back in Navigation Stack")
//            return
//        }
        print("Moving Back in with Dismiss Action")
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.commentsTableView.delegate = self
        //        self.commentsTableView.dataSource = self
        
        // Log version and platform info
        print("WowzaGoCoderSDK version =\n major: \(WOWZVersionInfo.majorVersion())\n minor: \(WOWZVersionInfo.minorVersion())\n revision: \(WOWZVersionInfo.revision())\n build: \(WOWZVersionInfo.buildNumber())\n string: \(WOWZVersionInfo.string())\n verbose string: \(WOWZVersionInfo.verboseString())")
        
        print("Platform Info:\n\(WOWZPlatformInfo.string())")
        
        if let goCoderLicensingError = WowzaGoCoder.registerLicenseKey(SDKSampleAppLicenseKey) {
            self.showAlert("GoCoder SDK Licensing Error", error: goCoderLicensingError as NSError)
        }
        self.recorderView.backgroundColor = .black
        
        self.setupStreaming()
        //self.addVideoPlayer()
        if (self.currentVideo.status == Constants.VideoStatus.offline) {
            self.updatedVideoCounter()
        }
    }
    
    func setupStreaming() {
        
        let goCoderBroadcastConfig = WowzaConfig()
        
        // Set the defaults for 288p video
        //goCoderBroadcastConfig.load(WOWZFrameSizePreset.preset960x540)
        //goCoderBroadcastConfig.load(WOWZFrameSizePreset.preset1280x720)
        goCoderBroadcastConfig.load(WOWZFrameSizePreset.preset640x480)
        goCoderBroadcastConfig.videoFrameRate = 30
        goCoderBroadcastConfig.broadcastScaleMode = .aspectFill
        goCoderBroadcastConfig.videoKeyFrameInterval = 30
        goCoderBroadcastConfig.videoBitrate = 2500 //3750 //6000 // 3750 // 2500 // 1000
        goCoderBroadcastConfig.videoBitrateLowBandwidthScalingFactor = 0.0
        
        // Set the connection properties for the target Wowza Streaming Engine server or Wowza Streaming Cloud live stream
        goCoderBroadcastConfig.hostAddress = "web.scottishhealth.live"
        goCoderBroadcastConfig.portNumber = 1935
        goCoderBroadcastConfig.applicationName = "live"
        
        goCoderBroadcastConfig.streamName = self.currentVideo.broadcast
        goCoderBroadcastConfig.broadcastVideoOrientation = .alwaysPortrait
        
        goCoderBroadcastConfig.hlsURL = (Constants.Stream_URLs.savedStreamUrl + self.currentVideo.broadcast + Constants.Stream_URLs.savedStreamPostFix) as NSString
        
        // Update the active config
        self.goCoderConfig = goCoderBroadcastConfig
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if(self.player.currentPlayState() == WOWZPlayerState.idle){
            
            self.player.playerView?.backgroundColor = .black
            self.player.play(self.goCoderConfig, callback: self)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        }
        else {
            self.player.resetPlaybackErrorCount()
            self.player.stop()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.player.resetPlaybackErrorCount()
        self.player.stop()
        self.goCoderConfig = nil
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        
    }
    
    func addVideoPlayer() {
        var videoURLString = ""
        videoURLString = Constants.Stream_URLs.liveStreamViewerUrl + self.currentVideo.broadcast as String + Constants.Stream_URLs.liveStreamPostFix
        //        videoURLString = Constants.Stream_URLs.liveStreamViewerUrl + "myWowzaTest1" + Constants.Stream_URLs.liveStreamPostFix
        
        //"http://www.simx.tv:1935/live/ADCCiTN4lN15671448853700/playlist.m3u8"
        
        print("video url 3333", videoURLString)
        let url = URL(string: videoURLString)
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
//        //performSegue(withIdentifier: "unwind789678", sender: self)
//        if (self.navigationController != nil) {
//            self.navigationController?.popViewController(animated: true)
//            print("Moving Back in Navigation Stack")
//            return
//        }
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
            break
            
        case .connecting:
            //            DispatchQueue.main.async { () -> Void in
            //                // A streaming playback session is.connecting up
            //            }
            self.player.playerView = self.recorderView;
            print("player stream is connecting \(status.state.rawValue)")
            break;
        case .playing:
            DispatchQueue.main.async { () -> Void in
                UIView.animate(withDuration: 0.25, animations: {
                    
                })
            }
            self.lastStatusCallBack = "playing"
            print("player stream is idle \(status.state.rawValue)")
            break;
        case .stopping:
            DispatchQueue.main.async { () -> Void in
                self.closeThisController(UIButton())
            }
            print("player stream is stopping \(status.state.rawValue)")
            break;
            
        case .buffering:
            //            DispatchQueue.main.async { () -> Void in
            //
            //            }
            self.lastStatusCallBack = "buffering"
            print("player stream is buffering \(status.state.rawValue)")
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

//class OfflineAVPlayerLauncherViewController: UIViewController {
//
//    var videoUrlString = ""
//    var isPlayerFirstLaunched = false
//
//    var url: URL! // Asset URL
//    var asset: AVAsset!
//    var player: AVPlayer!
//    var playerItem: AVPlayerItem!
//
//    // Key-value observing context
//    private var playerItemContext = 0
//
//    let requiredAssetKeys = [
//        "playable",
//        "hasProtectedContent"
//    ]
//
//    func prepareToPlay() {
//        // Create the asset to play
//        asset = AVAsset(url: url)
//
//        // Create a new AVPlayerItem with the asset and an
//        // array of asset keys to be automatically loaded
//        playerItem = AVPlayerItem(asset: asset,
//                                  automaticallyLoadedAssetKeys: requiredAssetKeys)
//
//        // Register as an observer of the player item's status property
//        playerItem.addObserver(self,
//                               forKeyPath: #keyPath(AVPlayerItem.status),
//                               options: [.old, .new],
//                               context: &playerItemContext)
//
//        // Associate the player item with the player
//        player = AVPlayer(playerItem: playerItem)
//        let playerLayer = AVPlayerLayer(player: player) // keep the layer hidden
//        playerLayer.frame = self.view.frame
//        playerLayer.backgroundColor = UIColor.black.cgColor
//        self.view.layer.addSublayer(playerLayer)
//        player.play()
//    }
//
//    @IBAction func closeButtonTapped(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//
//        url = URL(string:videoUrlString)
//    }
//
//
//    override func viewWillAppear(_ animated: Bool) {
//        if (!isPlayerFirstLaunched) {
//            isPlayerFirstLaunched = true
////            self.prepareToPlay()
//            self.playThisVideoInAVPlayer(videoFileURLString: videoUrlString)
//            return
//        }
//
////        player?.addObserver(self, forKeyPath: "status", options:NSKeyValueObservingOptions(), context: nil)
////        player?.addObserver(self, forKeyPath: "playbackBufferEmpty", options:NSKeyValueObservingOptions(), context: nil)
////        player?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options:NSKeyValueObservingOptions(), context: nil)
////        player?.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions(), context: nil)
////        // Register as an observer of the player item's status property
////        playerItem.addObserver(self,
////                               forKeyPath: #keyPath(AVPlayerItem.status),
////                               options: [.old, .new],
////                               context: &playerItemContext)
//    }
//
//    deinit {
//        if let player = self.player {
//            self.deallocObservers(player: player)
//        }
//    }
//
//    func deallocObservers(player: AVPlayer) {
////        player.removeObserver(self, forKeyPath: "status")
////        player.removeObserver(self, forKeyPath: "playbackBufferEmpty")
////        player.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
////        player.removeObserver(self, forKeyPath: "loadedTimeRanges")
//        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: &playerItemContext)
//
//    }
//
////    //observer for avPlayer
////     override  func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
////
////        if keyPath == "status" {
////
////            print("Change at keyPath = \(keyPath) for \(object)")
////            if let player = object as? AVPlayer {
////                print(player.status.rawValue)
////            }
////        }
////
////        if keyPath == "playbackBufferEmpty" {
////            print("playbackBufferEmpty - Change at keyPath = \(keyPath) for \(object)")
//////            if let player = object as? AVPlayer {
//////                print(player.empty)
//////            }
////        }
////
////        if keyPath == "playbackLikelyToKeepUp" {
////            print("Change at keyPath = \(keyPath) for \(object)")
////        }
////        if keyPath == "loadedTimeRanges" {
////            print("Change at keyPath = \(keyPath) for \(object)")
////        }
////
////        /*
////         if keyPath == "status" {
////             print("Change at keyPath = \(String(describing: keyPath)) for \(String(describing: object))")
////         }
////
////         if keyPath == "playbackBufferEmpty" {
////             print("playbackBufferEmpty - Change at keyPath = \(String(describing: keyPath)) for \(String(describing: object))")
////         }
////
////         if keyPath == "playbackLikelyToKeepUp" {
////             print("Change at keyPath = \(String(describing: keyPath)) for \(String(describing: object))")
////         }
////         if keyPath == "loadedTimeRanges" {
////             print("Change at keyPath = \(String(describing: keyPath)) for \(String(describing: object))")
////         }
////         */
////    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        // // // self.printReasonForWaitingToPlay()
//    }
//
//    override func observeValue(forKeyPath keyPath: String?,
//                               of object: Any?,
//                               change: [NSKeyValueChangeKey : Any]?,
//                               context: UnsafeMutableRawPointer?) {
//
//        print("I am Observer")
//        // Only handle observations for the playerItemContext
//        guard context == &playerItemContext else {
//            super.observeValue(forKeyPath: keyPath,
//                               of: object,
//                               change: change,
//                               context: context)
//            return
//        }
//
//        if keyPath == #keyPath(AVPlayerItem.status) {
//            let status: AVPlayerItemStatus
//            if let statusNumber = change?[.newKey] as? NSNumber {
//                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
//            } else {
//                status = .unknown
//            }
//
//            // Switch over status value
//            switch status {
//            case .readyToPlay:
//                // Player item is ready to play.
//                print ("Player item is ready to play.")
//                break
//
//            case .failed:
//                // Player item failed. See error.
//                print ("Player item failed. See error.")
//                break
//            case .unknown:
//                // Player item is not yet ready.
//                print("Player item is not yet ready.")
//                break
//            default:
//                print ("undefined status call back")
//                break
//            }
//
//        }
//    }
//
//    func printReasonForWaitingToPlay() {
//// //        print ("Reason for Waiting To Play", self.player?.reasonForWaitingToPlay)
////
////        if (self != nil) {
////            print(self.player.reasonForWaitingToPlay.debugDescription)
////            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 , execute: {
////                self.printReasonForWaitingToPlay()
////            })
////        }
//    }
//
//    func playThisVideoInAVPlayer(videoFileURLString: String) {
//
//        print("about to launch Player with : \(videoFileURLString)")
//        asset = AVAsset(url: url)
//
//        // Create a new AVPlayerItem with the asset and an
//        // array of asset keys to be automatically loaded
//        playerItem = AVPlayerItem(asset: asset,
//                                  automaticallyLoadedAssetKeys: requiredAssetKeys)
//
//        // Register as an observer of the player item's status property
//        playerItem.addObserver(self,
//                               forKeyPath: #keyPath(AVPlayerItem.status),
//                               options: [.old, .new],
//                               context: &playerItemContext)
//
//        // Associate the player item with the player
//        player = AVPlayer(playerItem: playerItem)
//
//        let playerViewController = AVPlayerViewController()
//        playerViewController.player = player
//        player.play()
//        self.present(playerViewController, animated: true) {
//            playerViewController.player!.play()
//        }
//
//        //player.play()
////        // as soon as playback begins, reset it to default
////        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
////            playerViewController.player!.play()
////        })
//    }
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
