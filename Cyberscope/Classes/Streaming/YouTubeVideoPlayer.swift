//
//  YouTubeVideoPlayer.swift
//  SimX
//
//  Created by Hashmi on 01/04/2022.
//  Copyright © 2022 Agilio. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView
import DropDown
import AVKit
import FirebaseStorage
import FirebaseDatabase

class YouTubeVideoPlayer: UIViewController, MyJobApplicationsDelegate, UpdateJobAplication_Delegate, getVideoCVs_Data_Delegate, WKYTPlayerViewDelegate {
    func getVideoCVs_Data_ResponseSuccess(videocvs: [Videocvs]) {
        if videocvs.count > 0 {
            let videoCV = videocvs[0]
            
            print(videoCV.videocv)
            
            let videoURLString = "\(Constants.Stream_URLs.videoBaseLink)videoCvs/\(videoCV.videocv).mp4"
            if self.selectedAction == "SHARE" {
                self.shareLink(linkToShare: videoURLString)
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
    
    func playThisVideoInPlayer(videoFileURLString: String, videoTitle: String = "", videoCv: String) {
        print("about to launch With Player with : \(videoFileURLString)")
        
        if videoTitle == "Picture CV"{
            let vc = storyboard?.instantiateViewController(withIdentifier: "CvImageShowVc") as? CvImageShowVc
            
            
            let ref = Database.database().reference().child("images/\(videoCv)")


                ref.observeSingleEvent(of: .value, with: { (snap : DataSnapshot)  in

                    let url = URL(string: snap.value as! String)
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
    
    
    
    func UpdateJobApplication_ResponseSuccess(isUserUpdated: Bool) {
        print("JOb Applicationn ", isUserUpdated)
        self.getMyJobApplications()
    }
    
    func setMyJobApplicationsRecieved(_ videos: [JobApplication]) {
        print("MYJobAppplications")
        print(videos)
        self.jobApplicantsArray = videos
        print("JobAplication ", self.jobApplicantsArray.count)
        DispatchQueue.main.async{
            self.showCandidates()
        }
    }
    
    func dataAccessError(_ error: NSError?) {
        print("MapDetailVC - MyJobApplicationsDelegate", error.debugDescription)
    }
    

    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var kuchb: WKYTPlayerView!
    
    @IBOutlet weak var myTblView: UITableView!
    
    @IBOutlet weak var dismissBtn: UIButton!
    @IBAction func dismissBtnn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
//    @IBOutlet weak var applicantView: UIView!
//    @IBOutlet weak var shortListView: UIView!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBAction func applicantBtn(_ sender: Any) {
        self.viewRemoteworker.isHidden = false
        self.viewShortlistedRemoteworker.isHidden = true
        
        self.showCandidates()
    }
    @IBOutlet weak var viewRemoteworker: UIView!
    
    @IBOutlet weak var viewShortlistedRemoteworker: UIView!
    @IBOutlet weak var applicantBtn: UIButton!
    
    @IBAction func shortListBtn(_ sender: Any) {
        self.viewRemoteworker.isHidden = true
        self.viewShortlistedRemoteworker.isHidden = false
//
        self.showShortlistedCandidates()
        
    }
    
    @IBOutlet weak var shortListBtn: UIButton!
    
    var youTubeId = ""
    var titleStr = ""
    var check = ""
    var broadCast = ""
    var filteredjobApplicantsArray : [JobApplication] = []
    var selectedJobId : Int = -1
    var selectedAction: String = ""
    var selectedStream: COVideo?
    var jobApplicantsArray : [JobApplication] = []
    fileprivate var player = Player()
    override func viewDidLoad() {
        super.viewDidLoad()
        kuchb.delegate = self
        
        if check != ""{
            kuchb.load(withVideoId: youTubeId)
            self.myTblView.delegate = self
            self.myTblView.dataSource = self
            self.titleLbl.text = titleStr
        }else{
            
            kuchb.load(withVideoId: youTubeId)
            self.titleLbl.text = titleStr
        }
       
       // self.setupView()
        self.viewRemoteworker.isHidden = false
        self.viewShortlistedRemoteworker.isHidden = true
        self.getMyJobApplications()
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
            self.myTblView.reloadData()
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
    
}

// MARK: - UITableViewDataSource

extension YouTubeVideoPlayer: UITableViewDataSource {
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
//
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
                    self.shareLink(linkToShare: "")
                    //self.getVideoCVData()
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
    
    
    // MARK: - API Methods
    
    func getMyJobApplications()
    {
        print(broadCast)
        let sessionObject = DataAccess.sharedInstance
        sessionObject.getMyJobApplicationListByBroadcast(self as MyJobApplicationsDelegate, broadcastName: broadCast)
    }
    
    func getVideoCVData()
    {
        let jobData = self.filteredjobApplicantsArray[self.selectedJobId]
        
        print(jobData.VideocvID)
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
    
    
    func showCandidates(){
        self.selectedJobId = -1
        self.filteredjobApplicantsArray.removeAll()
        for jobApplication in self.jobApplicantsArray {
            if !jobApplication.Isshortlisted {
                self.filteredjobApplicantsArray.append(jobApplication)
            }
        }
        DispatchQueue.main.async {
            self.myTblView.reloadData()
        }
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
    
}


@available(iOS 11.0, *)
extension YouTubeVideoPlayer: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
       // let vidoeCVs = self.filteredjobApplicantsArray[indexPath.row]
//        tableView.deselectRow(at: indexPath, animated: true)
//        let candidates = self.filteredjobApplicantsArray[indexPath.row]
//        print(candidates)
        
//         var streamData = COVideo()
//         streamData.username = candidates.username
//         streamData.name = candidates.name
//         streamData.id = candidates.id
        
//        var lUser = User()
//       // lUser.id = candidates.id
//        lUser.name = candidates.name
//        lUser.username = candidates.username
//        lUser.skills = candidates.skill
//        lUser.qbid = candidates.qbid
        
//         if lUser.qbid.count > 0 {
//             let storyBoard: UIStoryboard = UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil)
//            if #available(iOS 13.0, *) {
//                let nextVC = storyBoard.instantiateViewController(withIdentifier: Constants.ViewControllers.BroadCaster_ProfileVC) as! BroadCaster_ProfileVC
//                nextVC.selectedStream = streamData
//                nextVC.selectedBroadcaster = lUser
//                self.navigationController?.pushViewController(nextVC, animated: true)
//            } else {
//                // Fallback on earlier versions
//            }
            
            // self.present(nextVC, animated: true, completion: nil)
         }
        
    }


// MARK: - jobCandidateCellDelegate
extension YouTubeVideoPlayer: jobCandidateCellDelegate {
    func selectJobOptions(jobId: Int) {
        self.selectedJobId = jobId
        DispatchQueue.main.async {
            self.myTblView.reloadData()
        }
    }
    
    
}
