//
//  MapDetailVC.swift
//  SimX
//
//  Created by APPLE on 22/07/2020.
//  Copyright © 2020 Agilio. All rights reserved.
//

import UIKit
import AVKit
import DropDown
import FirebaseStorage
import FirebaseDatabase

class MapDetailVC: UIViewController {

    @IBOutlet weak var videoPortionView: UIView!
    @IBOutlet weak var viewShortlistedRemoteworker: UIView!
    @IBOutlet weak var viewRemoteworker: UIView!
    @IBOutlet weak var lblBroadcastName: UILabel!
    @IBOutlet weak var jobApplicationTV: UITableView!
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblStartTIme: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var viewPlayerControls: UIView!
    
    @IBOutlet weak var btnShortlistedRemoteworker: UIButton!
    @IBOutlet weak var btnRemoteWorker: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    // MARK: - Private variables
    
    var selectedStream: COVideo?
    var jobApplicantsArray : [JobApplication] = []
    var filteredjobApplicantsArray : [JobApplication] = []
    fileprivate var player = Player()
    
    var selectedJobId : Int = -1
    var selectedAction: String = ""
        
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = CurrentUser.getCurrentUser_From_UserDefaults()
        print(user)
        if selectedStream?.name == user.name{
            viewShortlistedRemoteworker.isHidden = false
            viewRemoteworker.isHidden = false
            btnRemoteWorker.isHidden = false
            btnShortlistedRemoteworker.isHidden = false
        }else{
            viewShortlistedRemoteworker.isHidden = true
            viewRemoteworker.isHidden = true
            btnRemoteWorker.isHidden = true
            btnShortlistedRemoteworker.isHidden = true
        }
        
        self.setupView()
        self.setupPlayer()
        self.getMyJobApplications() 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.player.playFromBeginning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear .......")
         
         self.player.pause()
    //     self.player.playerLayer()?.player!.replaceCurrentItem(with: nil)
    }
    
    // MARK: object lifecycle
    deinit {
           self.player.willMove(toParentViewController: nil)
           self.player.view.removeFromSuperview()
           self.player.removeFromParentViewController()
           
           self.player.playerLayer()?.removeFromSuperlayer()
           self.player.playerLayer()?.player = nil
    }
    
    // MARK: - Private Methods
    
    func setupView(){
        self.viewShortlistedRemoteworker.isHidden = true
        self.jobApplicationTV.backgroundColor = UIColor.white
        
        self.jobApplicationTV.delegate = self
        self.jobApplicationTV.dataSource = self
        
        self.titleLbl.text = self.selectedStream?.title
        self.slider.addTarget(self, action: #selector(playerVC.sliderChanged(sender:)), for: .valueChanged)
        self.btnRemoteWorker.setTitle("Applicants", for: .normal)

//        self.btnRemoteWorker.setTitle(Constants.userSkillsType.viewer, for: .normal)
        self.btnShortlistedRemoteworker.setTitle("Shortlisted Applicants", for: .normal)
    }
    
    func setupPlayer(){
        var videoUrl = ""
        if (self.selectedStream!.isOffline) {
            videoUrl = "\(Constants.Stream_URLs.videoBaseLink)offlineVideos/\(self.selectedStream!.broadcast).mp4"
        }
        else
        {
            videoUrl = "\(Constants.Stream_URLs.videoBaseLink)recordedvideos/\(self.selectedStream!.broadcast).mp4"
        }
        print("about to launch Player with 8888 : \(videoUrl)")
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.player.playerDelegate = self
        self.player.playbackDelegate = self
        
        self.player.playerView.playerBackgroundColor = .black
        
      //  self.addChildViewController(self.player)
        self.player.view.frame = self.videoPortionView.bounds
        self.videoPortionView.addSubview(self.player.view)
        self.player.didMove(toParentViewController: self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if (self.player.playerLayer != nil) {
            //    playerLayer = AVPlayerLayer()
                self.player.playerLayer()!.frame = self.videoPortionView.bounds
             //   self.player.playerLayer()!.videoGravity = AVLayerVideoGravity.resize
                self.videoPortionView.layer.addSublayer(self.player.playerLayer()!)
            }
        }
//        let localUrl = Bundle.main.url(forResource: "IMG_3267", withExtension: "MOV")
//        self.player.url = localUrl
        self.player.url = URL(string: videoUrl)
        
        self.player.playbackLoops = true
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.player.view.addGestureRecognizer(tapGestureRecognizer)
        
        self.indicatorView.startAnimating()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .black
    }
    
    func moveBack()
    {
        DispatchQueue.main.async {
            if self.isModal {
                self.dismiss(animated: true, completion: nil)
            }
            else
            {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func showShortlistedCandidates(){
        self.selectedJobId = -1
        self.filteredjobApplicantsArray.removeAll()
        for jobApplication in self.jobApplicantsArray {
            if jobApplication.Isshortlisted {
                self.filteredjobApplicantsArray.append(jobApplication)
            }
        }
        DispatchQueue.main.async {
            self.jobApplicationTV.reloadData()
        }
    }
    
    func showCandidates(){
        self.selectedJobId = -1
        self.filteredjobApplicantsArray.removeAll()
        for jobApplication in self.jobApplicantsArray {
            if !jobApplication.Isshortlisted {
                self.filteredjobApplicantsArray.append(jobApplication)
            }
        }
        DispatchQueue.main.async {
            self.jobApplicationTV.reloadData()
        }
    }
    
    func shareLink(linkToShare: String)
    {
        let inviteText = linkToShare
        DispatchQueue.main.async {
            let activityViewController = UIActivityViewController(activityItems: [linkToShare], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [.airDrop]
            
            self.present(activityViewController, animated: true)
        }
    }
    
    func playThisVideoInPlayer(videoFileURLString: String, videoTitle: String = "", videoCv: String) {
        print("about to launch With Player with : \(videoFileURLString)")
        
        if videoTitle == "Picture CV"{
            let vc = storyboard?.instantiateViewController(withIdentifier: "CvImageShowVc") as? CvImageShowVc
            
            
            let ref = Database.database().reference().child("images/\(videoCv)")


                ref.observeSingleEvent(of: .value, with: { (snap : DataSnapshot)  in

                    let url = URL(string: snap.value as! String)
                    print(url)
                    if let data = try? Data(contentsOf: url!) {
                        vc!.cvImageView.image = UIImage(data: data)
                    }

                }) { (err: Error) in

                    print("\(err.localizedDescription)")

                }
//           print(fireBaseUrl)
//            vc?.url = fireBaseUrl
            vc?.modalPresentationStyle = .fullScreen
            present(vc!, animated: true, completion: nil)
        }else{
            
            if let url = URL(string: videoFileURLString){
                
                let player = AVPlayer(url: url)
                let vc = AVPlayerViewController()
                vc.player = player
                present(vc, animated: true) {
                    vc.player?.play()
                }

            }
        }
        

    }
    
    func showList(){
        let dropDown = DropDown()

     //   dropDown.anchorView = self.viewTV // UIView or UIBarButtonItem

        dropDown.dataSource = ["Watch CV", "Share CV", "Shortlist"]
       // dropDown.dataSource = ["Watch CV", "Share CV", "Remove Shortlist"]
        dropDown.width = 200
        dropDown.show()
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
          print("Selected item: \(item) at index: \(index)")
            if (item == "Watch CV") {
                
                print()
            }
            else if (item == "Share CV") {
                self.shareLink(linkToShare: "")
            }
            else if (item == "Shortlist") {
                
            }
            else if (item == "Remove Shortlist") {
                
            }
        }
    }
    
    
    // MARK: - API Methods
    
    func getMyJobApplications()
    {
        print(selectedStream?.broadcast)
        let sessionObject = DataAccess.sharedInstance
        sessionObject.getMyJobApplicationListByBroadcast(self as MyJobApplicationsDelegate, broadcastName: self.selectedStream!.broadcast)
    }
    
    func getVideoCVData()
    {
        let jobData = self.filteredjobApplicantsArray[self.selectedJobId]
        let sessionObject = DataAccess.sharedInstance
        sessionObject.getVideoCVs_DataById(delegate: self as getVideoCVs_Data_Delegate, videoCvId: jobData.VideocvID)
    }
    
    func updateJobApplicant(isShortList: Bool){
        let jobData = self.filteredjobApplicantsArray[self.selectedJobId]
        
        let jobApplicant = JobCandidates()
        jobApplicant.id = jobData.id
        jobApplicant.username = jobData.username
        jobApplicant.broadcast = jobData.broadcast
        jobApplicant.broadcastid = jobData.broadcastId
        jobApplicant.Isshortlisted = isShortList
        jobApplicant.videocvid = jobData.VideocvID
        
        let sessionObject = DataAccess.sharedInstance
        sessionObject.Update_UserJobCandidate(delegate: self as UpdateJobAplication_Delegate, jobApplicationData: jobApplicant)
    }
    
    func deleteApplicantUser() {
        let jobData = self.filteredjobApplicantsArray[self.selectedJobId]
        
        let jobApplicant = JobCandidates()
        jobApplicant.id = jobData.id
        jobApplicant.username = jobData.username
        jobApplicant.broadcast = jobData.broadcast
        jobApplicant.broadcastid = jobData.broadcastId
        jobApplicant.Isshortlisted = false
        jobApplicant.videocvid = jobData.VideocvID
        
        let sessionObject = DataAccess.sharedInstance
        sessionObject.Delete_UserJobCandidate(delegate: self as UpdateJobAplication_Delegate, jobApplicationData: jobApplicant)
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
    
   // func getVideoCVs_DataById(delegate: , videoCvId: Int)
    
    @IBOutlet weak var titleLbl: UILabel!
    // MARK: - - Action Methods
    
    @IBAction func dismissBtnn(_ sender: Any) {
        DispatchQueue.main.async {
            self.player.pause()
            self.player.stop()
            self.moveBack()
        }
    }
    @IBAction func shortlistedRemoteworkerClicked(_ sender: Any) {
        self.viewRemoteworker.isHidden = true
        self.viewShortlistedRemoteworker.isHidden = false
        
        self.showShortlistedCandidates()
        
    }
    
    @IBAction func remoteworkerClicked(_ sender: Any) {
        self.viewRemoteworker.isHidden = false
        self.viewShortlistedRemoteworker.isHidden = true
        
        self.showCandidates()
    }
    
    @IBAction func backClicked(_ sender: Any) {
        DispatchQueue.main.async {
            self.player.pause()
            self.player.stop()
            self.moveBack()
        }
    }
}

// MARK: - UIGestureRecognizer
extension MapDetailVC {
    
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

// MARK: - MyJobApplicationsDelegate
extension MapDetailVC: MyJobApplicationsDelegate {
    
    func setMyJobApplicationsRecieved(_ videos: [JobApplication]) {
        print("MYJobAppplications")
        print(videos)
        self.jobApplicantsArray = videos
        print("JobAplication ", self.jobApplicantsArray.count)
        DispatchQueue.main.async {
            if self.viewRemoteworker.isHidden {
                self.showShortlistedCandidates()
            }
            else
            {
                self.showCandidates()
            }
        }
    }
    
    func dataAccessError(_ error: NSError?) {
        print("MapDetailVC - MyJobApplicationsDelegate", error.debugDescription)
    }
}

// MARK: - UpdateJobAplication_Delegate
extension MapDetailVC: UpdateJobAplication_Delegate {
    func UpdateJobApplication_ResponseSuccess(isUserUpdated: Bool) {
        print("JOb Applicationn ", isUserUpdated)
        self.getMyJobApplications()
    }
}

// MARK: - getVideoCVs_Data_Delegate
extension MapDetailVC: getVideoCVs_Data_Delegate {
    func getVideoCVs_Data_ResponseSuccess(videocvs: [Videocvs]) {
        if videocvs.count > 0 {
            let videoCV = videocvs[0]
            
            print(videoCV.videocv)
            
            let videoURLString = "\(Constants.Stream_URLs.videoBaseLink)videoCvs/\(videoCV.videocv).mp4"
            if self.selectedAction == "SHARE" {
                
                print(videoCV.title)
                
                if videoCV.title == "Picture CV"{
                    let ref = Database.database().reference().child("images/\(videoCV.videocv)")
                    ref.observeSingleEvent(of: .value, with: { (snap : DataSnapshot)  in
                        let url = URL(string: snap.value as! String)
                        print(url, snap.value)
                        self.shareLink(linkToShare: snap.value as! String)
                    }) { (err: Error) in
                        print("\(err.localizedDescription)")
                    }
                    
                }else{
                    self.shareLink(linkToShare: videoURLString)
                }
                
                
            }
            else if self.selectedAction == "SHOW" {
                
                DispatchQueue.main.async {
                    if self.player != nil {
                        self.player.pause()
                        //self.btnPlay.imageView!.image = UIImage(named: "play")
                    }
                    self.playThisVideoInPlayer(videoFileURLString: videoURLString, videoTitle: videoCV.title, videoCv: videoCV.videocv)
                }
            }
            self.selectedJobId = -1
        }
    }
    
    func getVideoCVs_Data_ResponseError(_ error: NSError?) {
        print(error.debugDescription)
    }
}

// MARK: - UITableViewDataSource

extension MapDetailVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredjobApplicantsArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableView_Cells.jobCandidateCell, for: indexPath) as! jobCandidateCell
        
        let candidates = self.filteredjobApplicantsArray[indexPath.row]
        cell.lblUsername.text = candidates.name
        let url1 = Utilities.getUserImage_URL(username: candidates.username)
        cell.imgUser.sd_setImage(with: url1, placeholderImage: UIImage(named: Constants.imagesName.broadcastThumbNail_image3))
      //  cell.imgVideoThumb.image = vidoeCVs.videocv
        cell.JobId = indexPath.row
        cell.cellDelegate = self
        cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.height / 2.0
        if self.selectedJobId == indexPath.row {
            let dropDown = DropDown()
            
            dropDown.anchorView = cell.btnSelection // UIView or UIBarButtonItem
            
            dropDown.dataSource = candidates.Isshortlisted ? ["Watch CV", "Share CV", "Remove Shortlist"] : ["Watch CV", "Share CV", "Shortlist", "Remove CV"]
            // dropDown.dataSource =
            dropDown.width = 200
            dropDown.show()
            
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                // self.selectedJobId = -1
                if (item == "Watch CV") {
                    self.selectedAction = "SHOW"
                    self.getVideoCVData()
                }
                else if (item == "Share CV") {
                    self.selectedAction = "SHARE"
                    self.getVideoCVData()
                }
                else if (item == "Shortlist") {
                    self.updateJobApplicant(isShortList: true)
                }
                else if (item == "Remove Shortlist") {
                    self.updateJobApplicant(isShortList: false)
                } else if (item == "Remove CV") {
                    self.deleteApplicantUser()
                }
            }
        }
       // cell.cellDelegate = self
        cell.backgroundColor = UIColor.white
        return cell
    }
}

@available(iOS 11.0, *)
extension MapDetailVC: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
       // let vidoeCVs = self.filteredjobApplicantsArray[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        let candidates = self.filteredjobApplicantsArray[indexPath.row]
        print(candidates)
        
         var streamData = COVideo()
         streamData.username = candidates.username
         streamData.name = candidates.name
         streamData.id = candidates.id
        
        var lUser = User()
       // lUser.id = candidates.id
        lUser.name = candidates.name
        lUser.username = candidates.username
        lUser.skills = candidates.skill
        lUser.qbid = candidates.qbid
        
         if lUser.qbid.count > 0 {
             let storyBoard: UIStoryboard = UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil)
            if #available(iOS 13.0, *) {
                let nextVC = storyBoard.instantiateViewController(withIdentifier: Constants.ViewControllers.BroadCaster_ProfileVC) as! BroadCaster_ProfileVC
                nextVC.selectedStream = streamData
                nextVC.selectedBroadcaster = lUser
                self.navigationController?.pushViewController(nextVC, animated: true)
            } else {
                // Fallback on earlier versions
            }
            
            // self.present(nextVC, animated: true, completion: nil)
         }
        
    }
    
    
}

// MARK: - jobCandidateCellDelegate
extension MapDetailVC: jobCandidateCellDelegate {
    func selectJobOptions(jobId: Int) {
        self.selectedJobId = jobId
        DispatchQueue.main.async {
            self.jobApplicationTV.reloadData()
        }
    }
    
    
}
// MARK: - PlayerDelegate
extension MapDetailVC: PlayerDelegate {
    
    func playerReady(_ player: Player) {
        print("\(#function) ready")
        DispatchQueue.main.async {
            self.lblEndTime.text = self.getTimeFormate(time: Float(self.player.maximumDuration))
            self.btnPlay.imageView!.image = UIImage(named: "pause")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
           // MBProgressHUD.hide(for: self.view, animated: false)
            self.indicatorView.stopAnimating()
        })
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        print("\(#function) \(player.playbackState.description)")
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
        print("Buffering State Did", player.bufferingState)
        //Ready
    }
    
    func playerBufferTimeDidChange(_ bufferTime: Double) {
     //   print("Buffer Time Did change")
    }
    
    
    func player(_ player: Player, didFailWithError error: Error?) {
        print("\(#function) error.description")
    }
    
    
}

// MARK: - PlayerPlaybackDelegate
extension MapDetailVC: PlayerPlaybackDelegate {
    
    func playerCurrentTimeDidChange(_ player: Player) {
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
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
    }

    func playerPlaybackDidLoop(_ player: Player) {
        player.stop()
        player.pause()
    }
}
