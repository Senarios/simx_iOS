//
//  playerVC.swift
//  SimX
//
//  Created by APPLE on 23/07/2020.
//  Copyright © 2020 Agilio. All rights reserved.
//

import UIKit
import AVFoundation

var audioSession: AVAudioSession!

import MBProgressHUD

class playerVC: UIViewController {
    
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var viewRecorder: UIView!
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblStartTIme: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var viewPlayerControls: UIView!
    @IBOutlet weak var closeView: UIView!
    var broadcastID: Int = 1
    var viewerCount: Int = 1
    var videoTitle : String = ""
    var videoUrl = URL(string: "https://v.cdn.vine.co/r/videos/AA3C120C521177175800441692160_38f2cbd1ffb.1.5.13763579289575020226.mp4")!
    
   fileprivate var player = Player()
   fileprivate let dataAccess = DataAccess.sharedInstance
    
    // MARK: view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      //  self.avPlayerSetup()
        self.player.playerDelegate = self
        self.player.playbackDelegate = self
        
        self.player.playerView.playerBackgroundColor = .black
        
        self.addChildViewController(self.player)
        self.viewRecorder.addSubview(self.player.view)
        self.player.didMove(toParentViewController: self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if (self.player.playerLayer != nil) {
            //    playerLayer = AVPlayerLayer()
                self.player.playerLayer()!.frame = self.viewRecorder.bounds
             //   self.player.playerLayer()!.videoGravity = AVLayerVideoGravity.resize
                self.viewRecorder.layer.addSublayer(self.player.playerLayer()!)
            }
        }
        
//        let localUrl = Bundle.main.url(forResource: "IMG_3267", withExtension: "MOV")
//        self.player.url = localUrl
        self.player.url = videoUrl
        
        self.player.playbackLoops = true
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.player.view.addGestureRecognizer(tapGestureRecognizer)
        
        self.lblTitle.text = self.videoTitle
        self.viewRecorder.contentMode = .scaleAspectFill
       // MBProgressHUD.showAdded(to: view, animated: true)
        self.indicatorView.startAnimating()
        
        self.btnClose.layer.cornerRadius = 5
        self.btnClose.backgroundColor = UIColor(displayP3Red: 255.0, green: 255.0, blue: 255.0, alpha: 0.5)
        
        self.btnClose.contentEdgeInsets = UIEdgeInsetsMake(10,10,10,10)
        self.slider.addTarget(self, action: #selector(playerVC.sliderChanged(sender:)), for: .valueChanged)
        
        self.UpdateViewerCount()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.player.playFromBeginning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear .......")
         
         self.player.pause()
     //    self.player.playerLayer()?.player!.replaceCurrentItem(with: nil)
    }
    
    // MARK: object lifecycle
    deinit {
        self.player.willMove(toParentViewController: nil)
        
        self.player.view.removeFromSuperview()
        self.player.removeFromParentViewController()
        
        self.player.playerLayer()?.removeFromSuperlayer()
        self.player.playerLayer()?.player = nil
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .black
    }
    
    func avPlayerSetup() {

         do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            try audioSession.setActive(true)
        } catch {
            print("AVPlayer setup error \(error.localizedDescription)")
        }
    }
    
    @IBAction func doneClicked(_ sender: Any) {
        DispatchQueue.main.async {
            self.player.pause()
            self.player.stop()
            if self.isModal {
                self.dismiss(animated: true, completion: nil)
            }
            else
            {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func sliderChanged(sender: UISlider) {
        let seconds : Int64 = Int64(sender.value)
        print("sliderChanged ...... ", seconds)
        
        if seconds > 0 {
            let timeRatio = 100.0 / Float(player.maximumDuration)
            let currentTime =  Float(seconds) / timeRatio
             
            
            let targetTime:CMTime = CMTimeMake(Int64(currentTime), 1)
               print("..........TargetTime : ", targetTime)
            self.player.seek(to: targetTime)
            
        }
        
     /*   player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player!.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                sender.value = Float ( time );
            }
        }*/
       /* if player?.rate == 0 {
            player?.play()
        }*/
    }
    
    func getTimeFormate(time: Float) -> String {
        let lTime = Int(time)
        if lTime == 0 {
            return "00:00"
        }
        else
        {
            let mins = lTime < 60 ? 0 : lTime / 60
            let secs = lTime - ( mins * 60)
            let formatedMins = mins < 10 ? "0\(mins)" : "\(mins)"
            let formatedSecs = secs < 10 ? "0\(secs)" : "\(secs)"
            return "\(formatedMins):\(formatedSecs)"
        }
    }
    
    func UpdateViewerCount(){
        let number = Int.random(in: 1...10)
        let lViewers = self.viewerCount + number
        let data = ["\(Constants.Stream.id)": self.broadcastID as AnyObject, "\(Constants.Stream.viewers)": lViewers as AnyObject] as AnyObject
        self.dataAccess.Update_Viewers_in_broadcastTable(data)
    }
    
}

// MARK: - UIGestureRecognizer
extension playerVC {
    
    @IBAction func player_playClicked(_ sender: Any) {
        if self.player.playbackState == .playing {
            self.player.pause()
            self.btnPlay.imageView!.image = UIImage(named: "play")
        }
        else
        {
            self.player.playFromCurrentTime()
            DispatchQueue.main.async {
                self.btnPlay.imageView!.image = UIImage(named: "pause")
            }
        }
    }
    
    @IBAction func player_fastforwardClicked(_ sender: Any) {
        if self.player.isPlayingVideo {
            let currentTime = Float(player.currentTimeInterval)
            let targetTime:CMTime = CMTimeMake(Int64(currentTime + 5.0), 1)
            self.player.seek(to: targetTime)
        }
    }
    
    @IBAction func player_fastRewindClicked(_ sender: Any) {
        if self.player.isPlayingVideo {
            let currentTime = Float(player.currentTimeInterval)
            let targetTime:CMTime = CMTimeMake(Int64(currentTime - 5.0), 1)
            self.player.seek(to: targetTime)
        }
    }
    
    @IBAction func player_SkipPreviousClicked(_ sender: Any) {
        let targetTime:CMTime = CMTimeMake(0, 1)
        self.player.seek(to: targetTime)
    }
    
    
    @objc func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
    
        DispatchQueue.main.async {
            self.viewPlayerControls.isHidden = !self.viewPlayerControls.isHidden
        }
        
        /*    switch self.player.playbackState {
        case .stopped:
            self.player.playFromBeginning()
            break
        case .paused:
            self.player.playFromCurrentTime()
            break
        case .playing:
            
            self.player.pause()
            break
        case .failed:
            self.player.pause()
            break
        }*/
    }
    
}

// MARK: - PlayerDelegate
extension playerVC: PlayerDelegate {
    
    func playerReady(_ player: Player) {
        print("\(#function) ready")
        DispatchQueue.main.async {
            self.lblEndTime.text = self.getTimeFormate(time: Float(self.player.maximumDuration))
            self.btnPlay.imageView!.image = UIImage(named: "pause")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
           // MBProgressHUD.hide(for: self.view, animated: false)
            
        })
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        print("\(#function) \(player.playbackState.description)")
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
        print("Buffering State Did", player.bufferingState)
        if "\(player.bufferingState)" == "Ready"{
            self.indicatorView.stopAnimating()
        }
        //Ready
    }
    
    func playerBufferTimeDidChange(_ bufferTime: Double) {
        print("Buffer Time Did change")
    }
    
    func player(_ player: Player, didFailWithError error: Error?) {
        print("\(#function) error.description")
    }
    
}

// MARK: - PlayerPlaybackDelegate
extension playerVC: PlayerPlaybackDelegate {
    
    func playerCurrentTimeDidChange(_ player: Player) {
     //   print("playerCurrentTimeDidChange .... ", player.currentTime.value, player.currentTimeInterval, player.maximumDuration)
        DispatchQueue.main.async {
            self.lblStartTIme.text = self.getTimeFormate(time: Float(self.player.currentTimeInterval))
        }
        if player.maximumDuration > 0.0 {
            let timeRatio = 100.0 / Float(player.maximumDuration)
            let currentTime = timeRatio * Float(player.currentTimeInterval)
             self.slider.value = currentTime
        }
        
       
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
        print("playerPlaybackWillStartFromBeginning ....", player.maximumDuration)
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
        print("playerPlaybackDidEnd .... ")
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
        print("playerPlaybackWillLoop ....")
    }

    func playerPlaybackDidLoop(_ player: Player) {
        print("playerPlaybackDidLoop ....")
    }
}
