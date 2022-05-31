//
//  ProfileVC.swift
//  CyberScope
//
//  Created by Saad Furqan on 03/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

// table cell identifier ::: streamsTableViewCell


import UIKit
import AVKit
import SwiftMessages

class ProfileVC: UIViewController, VideosDetailsDelegate, UpdateUserBroadcastsCount_Delegate, DeleteBroadcastDelegate, UpdateUser_Delegate
{
 
    @IBOutlet weak var broadCastRecrView: UIView!
    @IBOutlet weak var broadCastHunterView: UIView!
    
    
    @IBOutlet weak var label_numberOfFollowers1: UILabel!
    
    @IBAction func followersBtn1(_ sender: Any) {
        self.performSegue(withIdentifier: Constants.Segues.ProfileVC_to_FollowersList_VC, sender: self)
    }
    
    @IBOutlet weak var label_numberOfFollowing1: UILabel!
    
    @IBAction func followingBtn1(_ sender: Any) {
        self.performSegue(withIdentifier: Constants.Segues.ProfileVC_to_FollowingsList_VC, sender: self)
    }
    
    @IBOutlet weak var hideView: UIView!
    @IBOutlet weak var broadCastView: UIView!
    @IBOutlet weak var viewDetails: UIView!
    @IBOutlet weak var viewRate: UIView!
    @IBOutlet weak var viewButtons: UIView!
    @IBOutlet weak var button_info: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var button_editProfile: UIButton!

    @IBOutlet weak var btnMyGallery: UIButton!
    //@IBOutlet weak var btnMyJobApplications: UIButton!
    @IBOutlet weak var label_user_name: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    
    @IBOutlet weak var broadcastsTableView: UITableView!
    var broadcastsArray : [COVideo] = []
    var selectedStream: COVideo?
    
    @IBOutlet weak var label_numberOfFollwers: UILabel!
    @IBOutlet weak var label_numberOfFollwings: UILabel!
    @IBOutlet weak var label_numberOfBroadcasts: UILabel!
   
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var btnViewRating: UIButton!
    @IBOutlet weak var viewRating: StarRatingView!
    
    
    var streamsArray : [JobApplication] = []
    var isMyGallerySelected: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        self.broadcastsTableView.delegate = self
        self.broadcastsTableView.dataSource = self
        // Do any additional setup after loading the view.
        self.setup_Controls()
        

        let user = CurrentUser.getCurrentUser_From_UserDefaults()
        if user.skills == "Recruiter"{
            btnMyGallery.setTitle("My Gallery", for: .normal)
            broadCastHunterView.isHidden = true
            broadCastHunterView.clipsToBounds = true
            
        }else{
            btnMyGallery.setTitle("My Applications", for: .normal)
            broadCastRecrView.isHidden = true
            broadCastRecrView.clipsToBounds = true
            
        }
        
//        let sessionObject = DataAccess.sharedInstance
//        sessionObject.getVideosForThisBroadcaster(self, broadcaster_username: CurrentUser.Current_UserObject.username)
      
        
//        self.broadcastsTableView.backgroundColor = UIColor.white
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        let loggedinUser = CurrentUser.Current_UserObject
//        print(loggedinUser)
////          self.updateUserObjectNumberOfBroadcats()
//    }
    
    @IBAction func btnViewRating_pressed(_ sender: Any) {
        self.performSegue(withIdentifier: Constants.Segues.profileVC_to_Rating_VC, sender: self)
    }
    
    @IBAction func myGalleryClicked(_ sender: Any) {
       
        
    }
    
    @IBAction func myJobApplicationsClicked(_ sender: Any) {

//        btnMyJobApplications.backgroundColor = UIColor(red: 61/255, green: 71/255, blue: 133/255, alpha: 1)
//        btnMyJobApplications.setTitleColor(UIColor.white, for: .normal)
        
        btnMyGallery.backgroundColor = UIColor.white
        btnMyGallery.setTitleColor(UIColor(red: 61/255, green: 71/255, blue: 133/255, alpha: 1), for: .normal)
        self.isMyGallerySelected = false
        
        self.broadcastsTableView.reloadData()
        if(self.streamsArray.count > 0)
        {
            self.broadcastsTableView.isHidden = false
        }
        else
        {
            self.broadcastsTableView.isHidden = true
        }
    }
    func myGallaryBtnCheck(){
        btnMyGallery.backgroundColor = UIColor(red: 61/255, green: 71/255, blue: 133/255, alpha: 1)
        btnMyGallery.setTitleColor(UIColor.white, for: .normal)
        
//        btnMyJobApplications.backgroundColor = UIColor.white
//        btnMyJobApplications.setTitleColor(UIColor(red: 61/255, green: 71/255, blue: 133/255, alpha: 1), for: .normal)

        self.isMyGallerySelected = true
        self.broadcastsTableView.reloadData()
        if(self.broadcastsArray.count > 0)
        {
            self.broadcastsTableView.isHidden = false
        }
        else
        {
            self.broadcastsTableView.isHidden = true
        }
    }
    func myJobApplicationBtnCheck(){

        self.isMyGallerySelected = false
        
        self.broadcastsTableView.reloadData()
        if(self.streamsArray.count > 0)
        {
            self.broadcastsTableView.isHidden = false
        }
        else
        {
            self.broadcastsTableView.isHidden = true
        }
    }
    
    func getMyJobApplications()
    {
        let sessionObject = DataAccess.sharedInstance
        sessionObject.getMyJobApplicationList(self as MyJobApplicationsDelegate)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .black
    }
    
    //MARK: Player
    
    func playThisVideoInPlayer(videoFileURLString: String, videoTitle: String = "", broadcastID: Int, viewerCount: Int) {
        //        print("about to launch With Player with : \(videoFileURLString)")
        if let url = URL(string: videoFileURLString){
            
            let player = AVPlayer(url: url)
            let vc = AVPlayerViewController()
            vc.player = player
            vc.allowsPictureInPicturePlayback = false
            present(vc, animated: true) {
                vc.player?.play()
            }
            
        }
    }
    
    func showSwiftyWarningMessage() {
//        let view = MessageView.viewFromNib(layout: .statusLine)
//        view.configureTheme(.warning)
//        view.configureDropShadow()
//        view.configureContent(body: "PayPal account missing...")
//        view.frame.size.width = 30.0
//        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
//        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
//        SwiftMessages.show(view: view)
        let info = MessageView.viewFromNib(layout: .messageView)
        info.configureTheme(.info)
        info.button?.isHidden = true
        info.configureContent(title: "Warning Info", body: "PayPal info is missing, as a Client you must set PayPal info to your account so that you can get payments on each call - according to your rate")
        SwiftMessages.show(view: info)
        // var infoConfig = SwiftMessages.defaultConfig
        // infoConfig.presentationStyle = .bottom
        // infoConfig.duration = .seconds(seconds: 0.25)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let user = CurrentUser.getCurrentUser_From_UserDefaults()
        let sessionObject = DataAccess.sharedInstance
        sessionObject.getVideosForThisBroadcaster(self, broadcaster_username: user.username)
        self.setup_Controls()
        
        self.rateLabel.text = "\(user.rate)/hr"
        
        //        self.label_user_jobTitle.text = user.skills
        //        self.rateViewContainer.isHidden = false
        if (user.skills == Constants.userSkillsType.freelancer) {
            //            self.rateViewContainer.isHidden = false
            
        }
        else {
            // self.rateViewContainer.isHidden = true
            //            self.viewMyJobApplications.isHidden = true
            //self.btnMyJobApplications.isHidden = false
        }
        
        
    }
    
    func get_Users_Error(_ error: NSError?) {
        print("\n getUsers_Data_ResponseError called ... AND error = \(String(describing: error?.localizedDescription)) \n")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == Constants.Segues.ProfileVC_To_MapDetailVC) {
            let viewController = segue.destination as! MapDetailVC
            viewController.selectedStream = self.selectedStream
        }
        if(segue.identifier == Constants.Segues.profileVC_to_Rating_VC)
        {
            let controller = segue.destination as! RatingViewController
            controller.fromSelfProfile = true
            controller.user = CurrentUser.getCurrentUser_From_UserDefaults()
        }
    }
    
    // MARK: - - GetVideosDelegate Methods
    func setVideosRecieved(_ videos: [COVideo]) {
        print("\n setVideosRecieved called ... AND videos count: \(videos.count) \n")
        
        self.broadcastsArray.removeAll()
        
        for video in videos
        {
            print(video)
            if(!Utilities.check_isBroadcaster_AlreadyBlocked(broadcaster_username: video.username))
            {
                self.broadcastsArray.append(video)
            }
        }
        if (CurrentUser.Current_UserObject.broadcasts != self.broadcastsArray.count) {
            CurrentUser.Current_UserObject.broadcasts = self.broadcastsArray.count
            let user = CurrentUser.getCurrentUser_From_UserDefaults()
            let user2 = CurrentUser.Current_UserObject
            CurrentUser.setCurrentUser_UserDefaults(user: user)
            
            self.updateUserObject()
        }
        
        print(broadcastsArray.count)
        self.label_numberOfBroadcasts.text = "\(self.broadcastsArray.count)"
        self.broadcastsTableView.reloadData()
        if self.isMyGallerySelected {
            if self.broadcastsArray.count > 0
            {
                self.broadcastsTableView.isHidden = false
            }
            else
            {
                self.broadcastsTableView.isHidden = true
            }

        }
    }
    
    func updateUserObject() {
        //UpdateUserBroadcastsCount_Delegate
        //let loggedinUser = CurrentUser.Current_UserObject
        let loggedinUser = CurrentUser.getCurrentUser_From_UserDefaults()
       // loggedinUser.setUserDefaults()
        let data = ["\(Constants.UserFields.username)": loggedinUser.username as AnyObject, "\(Constants.UserFields.broadcasts)": loggedinUser.broadcasts as AnyObject, "\(Constants.UserFields.link)": loggedinUser.link as AnyObject] as AnyObject
        
        DataAccess.sharedInstance.Update_Data_in_UsersTable(data, delegate: self)//UpdateUser_Delegate
    }
    
    func UpdateUser_ResponseSuccess(updated_user: User, status: Bool) {
        
    }
    
    func UpdateUser_ResponseSuccess(isUserUpdated: Bool) {
     
        print("Broadcasts Count updated")
    }
    func UpdateUser_ResponseError(_ error:NSError?) {
        print("Broadcasts Count didn't get updated")
    }
    
    func set_n_VideosRecieved(_ videos: [COVideo]) {
        
    }
    
    func dataAccessError(_ error:NSError?)
    {
        print("\n dataAccessError called ... AND error = \(String(describing: error?.localizedDescription)) \n")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup_Controls()
    {
        
        userImage.layer.borderWidth = 2
        userImage.layer.borderColor = UIColor(red: 112/255, green: 112/255, blue: 112/255, alpha: 1).cgColor
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.clipsToBounds = true
        
        btnMyGallery.layer.cornerRadius = btnMyGallery.layer.frame.height / 2
        btnMyGallery.clipsToBounds = true
//
//        btnMyJobApplications.layer.cornerRadius = btnMyJobApplications.layer.frame.height / 2
//        btnMyJobApplications.clipsToBounds = true
        
        viewRate.layer.cornerRadius = viewRate.frame.height / 2
        viewRate.layer.shadowColor = UIColor.black.cgColor
        viewRate.layer.shadowOpacity = 0.3
        viewRate.layer.shadowOffset = .zero
        viewRate.layer.shadowRadius = 3

        
        viewButtons.layer.cornerRadius = viewButtons.frame.height / 2
        viewButtons.layer.borderWidth = 1
        viewButtons.layer.borderColor = UIColor(red: 61/255, green: 71/255, blue: 133/255, alpha: 1).cgColor
        
        viewDetails.layer.shadowColor = UIColor.black.cgColor
        viewDetails.layer.shadowOpacity = 0.3
        viewDetails.layer.shadowOffset = .zero
        viewDetails.layer.shadowRadius = 3

        
        let user = CurrentUser.getCurrentUser_From_UserDefaults()
        
        let totalRating = user.total_ratings as String
        let userRating = user.user_ratings as String
        
        self.lblRating.text = userRating + " (" + totalRating + ")"
        self.setupRating(rating: userRating)
        
        self.label_user_name.text = user.name
//        self.label_user_jobTitle.text = user.skills
        self.label_numberOfFollwers.text = "\(CurrentUser.CurrentUser_Followers_List.count)"
        self.label_numberOfFollowers1.text = "\(CurrentUser.CurrentUser_Followers_List.count)"
        
        self.label_numberOfFollwings.text = "\(CurrentUser.CurrentUser_Followings_List.count)"
        self.label_numberOfFollowing1.text = "\(CurrentUser.CurrentUser_Followings_List.count)"
        self.label_numberOfBroadcasts.text = "\(user.broadcasts)"
        
        let url = Utilities.getUserImage_URL(username: user.email)
      
        
        self.userImage.sd_setImage(with: url, placeholderImage: UIImage(named: Constants.imagesName.broadcaster_image), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            // Perform operation.
            if (error == nil) {
                self.userImage.image = self.userImage.image?.circle
            }
        })
        
//        self.viewMyJobApplications.isHidden = trueF
//        self.viewMyGallery.isHidden = false
        
        //viewMyJobApplications
        let user1 = CurrentUser.getCurrentUser_From_UserDefaults()
        if user1.skills == "Recruiter"{
            myGallaryBtnCheck()
        }else{
            myJobApplicationBtnCheck()
        }
        self.getMyJobApplications()
    }
    
    func setupRating(rating: String)
    {
        if(rating == "")
        {
            self.lblRating.text = "Unrated yet"
            btnViewRating.isUserInteractionEnabled = false
        }
        else
        {
            btnViewRating.isUserInteractionEnabled = true
            let rate = (rating as NSString).floatValue
            viewRating.rating = rate
        }
    }
    
    @IBAction func button_warningTapped(_ sender: Any)
    {
//        if ('if payapl info missing') {
        self.showSwiftyWarningMessage()
//        }
    }
    
    @IBAction func button_infoTapped(_ sender: Any)
    {
        self.performSegue(withIdentifier: Constants.Segues.ProfileVC_to_AccountSettingsVC, sender: self)
    }
    
    @IBAction func followersButtonTapped(_ sender: Any)
    {
        self.performSegue(withIdentifier: Constants.Segues.ProfileVC_to_FollowersList_VC, sender: self)
    }
    
    @IBAction func followingsButtonTapped(_ sender: Any)
    {
        self.performSegue(withIdentifier: Constants.Segues.ProfileVC_to_FollowingsList_VC, sender: self)
    }
    
    @IBAction func broadcastsButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func button_editProfile_Tapped(_ sender: Any)
    {
        self.performSegue(withIdentifier: Constants.Segues.ProfileVC_to_EditProfileVC, sender: self)
    }
    
    var deleteButtonTag : Int?
    
    //The target function
    @objc func deleteRequestButtonTapped(_ sender: UIButton) { //<- needs `@objc`
        print("delete request tapped", sender.tag)
        
        let jobApplication = self.streamsArray[sender.tag]
        let refreshAlert = UIAlertController(title: "Alert!", message: "Do you really want to delete the Job application?", preferredStyle: UIAlertControllerStyle.alert)

        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
           // self.deleteVideoCV()
            print("Handle Yes Logic here")
            let sessionObject = DataAccess.sharedInstance
            sessionObject.removeJobApplication(jobApplicationId: jobApplication.id, resultDelegate: self as RemoveJobApplicationDelegate)
            
          }))

        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
          print("Handle No Logic here")
            
          }))

        self.present(refreshAlert, animated: true, completion: nil)
    }
    @objc func deleteButtonTapped(_ sender: UIButton) { //<- needs `@objc`
        print("\(sender)")
        let otherAlert = UIAlertController(title: nil, message: "Are you sure you want to delete this broadcast?", preferredStyle: .actionSheet)
        let callFunction = UIAlertAction(title: "Yes", style: .default) { _ in
            self.deleteButtonTag = sender.tag
            var i = 0
            for object2 in self.broadcastsArray {
                if (i == sender.tag) {
                    self.deleteButtonTag = sender.tag
                    let broadcast = object2
                    let sessionObject = DataAccess.sharedInstance
                    sessionObject.deleteThisBroadcast(broadcast: broadcast, delegate: self)
                    return
                }
                i += 1
            }
        }
        
        let dismiss = UIAlertAction(title: "No", style: .default) { _ in
            print("You canceled the action." )
        }
        // relate actions to controllers
        
        otherAlert.addAction(callFunction)
        otherAlert.addAction(dismiss)
        
        present(otherAlert, animated: true, completion: nil)
    }
    
    func deleteBroadcast(broadcastIndex: Int)
    {
        let otherAlert = UIAlertController(title: nil, message: "Are you sure you want to delete this broadcast?", preferredStyle: .actionSheet)
        let callFunction = UIAlertAction(title: "Yes", style: .default) { _ in
            self.deleteButtonTag = broadcastIndex
      //      var i = 0
      //      for object2 in self.broadcastsArray {
      //          if (i == sender.tag) {//
                    let broadcast = self.broadcastsArray[broadcastIndex]
                    let sessionObject = DataAccess.sharedInstance
                    sessionObject.deleteThisBroadcast(broadcast: broadcast, delegate: self)
                    return
        //        }
         //       i += 1
          //  }
        }
        
        let dismiss = UIAlertAction(title: "No", style: .default) { _ in
            print("You canceled the action." )
        }
        // relate actions to controllers
        
        otherAlert.addAction(callFunction)
        otherAlert.addAction(dismiss)
        
        present(otherAlert, animated: true, completion: nil)
    }
    
    func shareBroadcast(broadcastIndex: Int){
        
        
        let broadcast = self.broadcastsArray[broadcastIndex]
//        let imgeURLTS = Utilities.getUserImage_URL(username: broadcast.broadcast)
        
        let textToShare = "\n\nPlease watch my video in the link, and download Scottish Health to video chat 👇🏼\n"//"Watch my stream on this link!\n"
        
        //https://h2startup.com/stream/index2.php?v=
        
      //  let dataImg = try? Data(contentsOf: imgeURLTS) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        let linkType = broadcast.isOffline ? "&type=offline" : "&type=recorded"
        let urlString = "https://scottishhealth.live/stream/index2.php?v=\(broadcast.broadcast)\(linkType)"
        
        if let myWebsite = NSURL(string: urlString) {
          //  let objectsToShare = [textToShare, myWebsite, UIImage(data: dataImg!) ?? UIImage.init(named: "broadcastThumbNail_image") as Any] as [Any]
            
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            // New Excluded Activities Code
            activityVC.excludedActivityTypes = [.airDrop, .addToReadingList]
            
            //
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    //The target function
    @objc func shareMyBroadcast(_ sender: UIButton){ //<- needs `@objc`
        print("\(sender)")
        let textToShare = "" // " Download the SimX app to video chat with me.\n\nSee my stream and/or download SimX from the given link 👇🏼\n"//"Watch my stream on this link!\n"
        
        let broadcast = self.broadcastsArray[sender.tag]
     //   let imgeURLTS = Utilities.getUserImage_URL(username: broadcast.broadcast)
        
      //  let dataImg = try? Data(contentsOf: imgeURLTS) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        let urlString = "https://web.scottishhealth.live/stream/index2.php?v=\(broadcast.broadcast)"
        //"https://web.simx.tv/stream/index2.php?v=\(broadcast.broadcast)"
        if let myWebsite = NSURL(string: urlString) {
          //  let objectsToShare = [textToShare, myWebsite, UIImage(data: dataImg!) ?? UIImage.init(named: "broadcastThumbNail_image") as Any] as [Any]
         //   let objectsToShare = [textToShare, myWebsite, UIImage(data: dataImg!) ?? UIImage.init(named: "broadcastThumbNail_image") as Any] as [Any]
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            // New Excluded Activities Code
            activityVC.excludedActivityTypes = [.airDrop, .addToReadingList]
            //
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func deleteBroadcastSuccess(_ status: String) {
        print("Delete Api Response Success:: ", status)
        
        print("Count before removing:: ", self.broadcastsArray.count)
        if let tagOrIndex = self.deleteButtonTag {
            DispatchQueue.main.async {
                
                self.broadcastsArray.remove(at: tagOrIndex)
                
                print("Count after removing:: ", self.broadcastsArray.count)
                self.broadcastsTableView.reloadData()
                self.label_numberOfBroadcasts.text = "\(self.broadcastsArray.count)"
            }
        }
        self.updateUserObjectNumberOfBroadcats()
    }
    
    func deleteBroadcastError(_ error: NSError?) {
        print("Delete Api Response error::")
        print(error?.localizedDescription ?? "no description found")
        self.viewDidAppear(false)
    }
    
    func updateUserObjectNumberOfBroadcats() {
        //UpdateUserBroadcastsCount_Delegate
        let loggedinUser = CurrentUser.Current_UserObject
        let numberOfBroadcasts = loggedinUser.broadcasts - 1
        loggedinUser.broadcasts = numberOfBroadcasts
        loggedinUser.setUserDefaults()
        
        self.updateUserObject()
    }
    
    func playThisVideoInPlayer(videoFileURLString: String, videoTitle: String = "") {
        print("about to launch With Player with : \(videoFileURLString)")
        if let url = URL(string: videoFileURLString){
            
            let player = AVPlayer(url: url)
            let vc = AVPlayerViewController()
            vc.player = player
            present(vc, animated: true) {
                vc.player?.play()
            }

        }
//        let url = URL(string: videoFileURLString)
//
//        let vc =  UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil).instantiateViewController(withIdentifier: "playerVC") as! playerVC
//        vc.videoUrl = url!
//        vc.videoTitle = videoTitle
//        vc.modalPresentationStyle = .fullScreen
//         self.present(vc, animated: true, completion: nil)
        // self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func playThisVideoInAVPlayer(videoFileURLString: String) {
            
        print("about to launch Player with : \(videoFileURLString)")
        let url = URL(string: videoFileURLString)
        let asset = AVURLAsset(url: url!)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)

        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        player.play()
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
}

extension ProfileVC: MyJobApplicationsDelegate {
    func setMyJobApplicationsRecieved(_ videos: [JobApplication]) {
        print("MYJobAppplications")
        print(videos)
        self.streamsArray.removeAll()
        for jobApplication in videos {
            if !(jobApplication.broadcast.count == 0 && jobApplication.broadcastId == -1) {
                self.streamsArray.append(jobApplication)
            }
        }
    //    self.streamsArray = videos
  //      self.broadcastsTableView.
        DispatchQueue.main.async {
            self.broadcastsTableView.reloadData()
        }
    }
}

extension ProfileVC: RemoveJobApplicationDelegate{
    func removeJobApplicationResponse() {
        print("removeJobApplicationResponse")
        self.getMyJobApplications()
    }
    
    func dataAccessError(_ error: String){
        
    }
}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if self.isMyGallerySelected {
            return self.broadcastsArray.count
        }
        else
        {
            return self.streamsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 15.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 15.0))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let height: CGFloat = (tableView.frame.size.height / 1.8)
        
//        if(height < minHeight)
//        {
//            height = minHeight
//        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableView_Cells.streamsTableViewCell, for: indexPath) as! streamsTableViewCell
         if self.isMyGallerySelected {
            let broadcast = self.broadcastsArray[indexPath.section]
            
            // set broadcast data
            let url1 = Utilities.getUserImage_URL(username: broadcast.broadcast)
             print(url1)
             
             if broadcast.videourl.contains("youtu"){
                 print(broadcast.videourl)
                 let videoId = broadcast.videourl.youtubeID
                 let url = URL(string: "https://img.youtube.com/vi/\(videoId ?? "")/default.jpg")
                 
                 if let data = try? Data(contentsOf: url!) {
                     cell.image_thumbnail.image = UIImage(data: data)
                 }
              
                 
             }else{
                 
                 let url1 = Utilities.getUserImage_URL(username: broadcast.broadcast)
                 print(url1)
                 cell.image_thumbnail.sd_setImage(with: url1, placeholderImage: UIImage(named: Constants.imagesName.broadcastThumbNail_image3))
             }
             
//            cell.image_thumbnail.sd_setImage(with: url1, placeholderImage: UIImage(named: Constants.imagesName.broadcastThumbNail_image3))
            
            cell.broadcast_name.text = broadcast.title
            cell.broadcaster_name2.text = broadcast.name
            cell.label_viewers.text = "\(broadcast.viewers)"
            cell.lblJobDescriptionUrl.attributedText = NSAttributedString(string: broadcast.jobDescriptionURL, attributes:
                                                                            [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
            
            if broadcast.jobDescriptionURL == "" {
                cell.lblJobDescriptionUrl.frame.size.height = 0
                cell.lblJobDescriptionUrl.isHidden = true
            }
            cell.broadcaster_name2.isHidden = false
            cell.broadcaster_name.isHidden  = true
            cell.btnDeleteRequest.isHidden = true
            cell.backgroundColor = UIColor.white
        
        }
        else
        {
            let broadcast = self.streamsArray[indexPath.section]
                    
            // set broadcast data
            let url1 = Utilities.getUserImage_URL(username: broadcast.broadcast)
            cell.image_thumbnail.sd_setImage(with: url1, placeholderImage: UIImage(named: Constants.imagesName.broadcastThumbNail_image3))
            
            cell.broadcast_name.text = broadcast.title
            cell.broadcaster_name.text = broadcast.name
            cell.label_viewers.text = "\(broadcast.viewers)"

            cell.btnDeleteRequest.isHidden = false
            cell.broadcaster_name2.isHidden = true
            cell.broadcaster_name.isHidden  = false
            cell.btnDeleteRequest.tag = indexPath.section
            cell.btnDeleteRequest.addTarget(self, action: #selector(self.deleteRequestButtonTapped(_:)), for: .touchUpInside)
            cell.backgroundColor = UIColor.white
            
            cell.lblJobDescriptionUrl.frame.size.height = 0
            cell.lblJobDescriptionUrl.isHidden = true
            cell.btnDeleteRequest.layer.cornerRadius = cell.btnDeleteRequest.frame.height / 2
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if self.isMyGallerySelected {
         //   let broadcast = self.broadcastsArray[indexPath.section]
           // self.selectedStreamIndex = indexPath.section
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
                print("index path of delete: \(indexPath) -- \(indexPath.section)")
                self.deleteBroadcast(broadcastIndex: indexPath.section)
                completionHandler(true)
            }
            deleteAction.backgroundColor = UIColor.red
        
            let shareAction = UIContextualAction(style: .destructive, title: "Share") { (action, sourceView, completionHandler) in
                print("index path of Share: \(indexPath) -- \(indexPath.section)")
                self.shareBroadcast(broadcastIndex: indexPath.section)
                completionHandler(true)
            }
            shareAction.backgroundColor = UIColor(red: CGFloat(10.0/255.0), green: CGFloat(73.0/255.0), blue: CGFloat(122.0/255.0), alpha: CGFloat(1.0))
        
            let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
            swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
            return swipeAction
        }
        else
        {
            return nil
        }
    }
    
  /*  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
         if self.isMyGallerySelected {
            let broadcast = self.broadcastsArray[indexPath.section]
           // self.selectedStreamIndex = indexPath.section
            
                let editAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
                    print("Edit tapped")
                    self.deleteBroadcast(broadcastIndex: indexPath.section)
                  
                })
                editAction.backgroundColor = UIColor.red
            
                let shareAction = UITableViewRowAction(style: .default, title: "Share", handler: { (action, indexPath) in
                    print("Share tapped")
                    self.shareBroadcast(broadcastIndex: indexPath.section)
                })
            shareAction.backgroundColor = UIColor(red: CGFloat(10.0/255.0), green: CGFloat(73.0/255.0), blue: CGFloat(122.0/255.0), alpha: CGFloat(1.0))
            
            
            return [editAction, shareAction]
        }
        else
        {
            return nil
        }
    }*/
    
    @objc func broadcasterImageTapped(sender: UITapGestureRecognizer)
    {
////        let view = sender.view as! UIImageView
////        print("\n broadcasterImageTapped with tag = \(view.tag) \n")
//
//        let stream = self.broadcastsArray[view.tag]
//        self.selectedStream = stream
//
//        let u = CurrentUser.getCurrentUser_From_UserDefaults()
//        if((u.username) != (self.selectedStream?.username)!)
//        {
//            self.performSegue(withIdentifier: Constants.Segues.HomeVC_to_BroadCaster_ProfileVC, sender: self)
//        }
//        else
//        {
//            print("\n Can't open my own profile ... \n")
//            self.tabBarController?.selectedIndex = 0
//            let firstNavContr = self.tabBarController?.viewControllers?.first as! UINavigationController
//            firstNavContr.popToRootViewController(animated: true)
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.isMyGallerySelected {
            let stream = self.broadcastsArray[indexPath.section]
            self.selectedStream = stream
      //      var videoURLString = ""
               // && CurrentUser.Current_UserObject.skills == Constants.userSkillsType.client
//            if stream.isJob{
                self.selectedStream = stream
                
                print(stream.videourl)
                //MARK: Player to play video
                if stream.videourl.contains(find: "youtu"){
                    let videoId = stream.videourl.youtubeID
                    let vc = storyboard?.instantiateViewController(withIdentifier: "YouTubeVideoPlayer") as? YouTubeVideoPlayer
                    vc!.youTubeId = videoId ?? ""
                    vc?.titleStr = stream.title
                    vc!.broadCast = stream.broadcast
                    vc!.modalPresentationStyle = .fullScreen
                    present(vc!, animated: false, completion: nil)
                }else{
                    print(stream.videourl)
                    
                    
                    self.performSegue(withIdentifier: Constants.Segues.ProfileVC_To_MapDetailVC, sender: self)
                    
//                    self.playCVVideo(broadcastVideo: videoURLString, videoTitle: stream.title, broadcastID: stream.id, viewerCount: stream.viewers)
                }
                
                

            //}
           // else{
                
//                if (stream.isOffline) {
//
//
//                    let videoURLString = "\(Constants.Stream_URLs.videoBaseLink)offlineVideos/\(stream.broadcast).mp4"
//
//
//                    //MARK: Player to play video
//                    if stream.videourl.contains(find: "youtu"){
//                        let videoId = stream.videourl.youtubeID
//                        let vc = storyboard?.instantiateViewController(withIdentifier: "YouTubeVideoPlayer") as? YouTubeVideoPlayer
//                        vc!.youTubeId = videoId ?? ""
//                        vc?.titleStr = stream.title
//                        vc?.broadCast = stream.broadcast
//                        vc!.modalPresentationStyle = .fullScreen
//                        present(vc!, animated: false, completion: nil)
//                    }else{
//                        print(stream.videourl)
//                        self.playCVVideo(broadcastVideo: videoURLString, videoTitle: stream.title, broadcastID: stream.id, viewerCount: stream.viewers)
//                    }
//
//
//
//                }
                //else
//                {
//                    let videoURLString = "\(Constants.Stream_URLs.videoBaseLink)recordedvideos/\(stream.broadcast).mp4"
//                    //MARK: Player to play video
//                    if stream.videourl.contains(find: "youtu"){
//                        let videoId = stream.videourl.youtubeID
//                        let vc = storyboard?.instantiateViewController(withIdentifier: "YouTubeVideoPlayer") as? YouTubeVideoPlayer
//                        vc!.youTubeId = videoId ?? ""
//                        vc!.modalPresentationStyle = .fullScreen
//                        present(vc!, animated: false, completion: nil)
//                    }else{
//                        self.playCVVideo(broadcastVideo: videoURLString, videoTitle: stream.title, broadcastID: stream.id, viewerCount: stream.viewers)
//                    }
//                }
            }
        }
//        else
//        {
//            let stream = self.streamsArray[indexPath.section]
//            
//      //      var videoURLString = ""
//            if (stream.isOffline) {
//                let videoURLString = "\(Constants.Stream_URLs.videoBaseLink)offlineVideos/\(stream.broadcast).mp4"
//                print("Link to play : \(videoURLString)")
//               
//                self.playThisVideoInPlayer(videoFileURLString: videoURLString, videoTitle: stream.title)
//            }
//            else
//            {
//                let videoURLString = "\(Constants.Stream_URLs.videoBaseLink)recordedvideos/\(stream.broadcast).mp4"
//                print("Link to play : \(videoURLString)")
//                self.playThisVideoInPlayer(videoFileURLString: videoURLString, videoTitle: stream.title)
//            }
            
          /*  if (stream.status as String == Constants.VideoStatus.offline) {
                let lStream = COVideo()
                lStream.arn = stream.arn
                lStream.status = stream.status
                lStream.broadcast = stream.broadcast
                lStream.viewers = stream.viewers
                
                print("video url 4444", videoURLString)
                let vc =  UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil).instantiateViewController(withIdentifier: Constants.ViewControllers.VODWowzaViewController) as! VODWowzaViewController
                //vc.videoUrlString = videoURLString
                vc.currentVideo = lStream
                self.present(vc, animated: true, completion: nil)
            }
            else if (stream.status as String == Constants.VideoStatus.online) {
                let lStream = COVideo()
                lStream.arn = stream.arn
                lStream.status = stream.status
                lStream.broadcast = stream.broadcast
                lStream.viewers = stream.viewers
                
                let storyboard = UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil)
                let liveViewerViewController = storyboard.instantiateViewController(withIdentifier: "LiveStreamingViewerController") as! LiveStreamingViewerController
                liveViewerViewController.currentVideo = lStream
                self.present(liveViewerViewController, animated: true, completion: nil)
            }*/
        }

extension ProfileVC{
    func playCVVideo(broadcastVideo: String, videoTitle: String = "", broadcastID: Int, viewerCount: Int) {
        print(broadcastVideo)
//        let videoURLString = Constants.Stream_URLs.videoCVsStreamUrl + videoCV + Constants.Stream_URLs.directServerLinkURLPostfix
        
      //  let videoURLString = "\(Constants.Stream_URLs.videoBaseLink)offlineVideos/\(broadcastVideo).mp4"
       //  print(videoURLString)
        self.playThisVideoInPlayer(videoFileURLString: broadcastVideo, videoTitle: videoTitle, broadcastID: broadcastID, viewerCount: viewerCount)
        
    /* var videoView = COVideo()
        videoView.broadcast = videoCV
        let vc =  UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil).instantiateViewController(withIdentifier: Constants.ViewControllers.VODWowzaViewController) as! VODWowzaViewController
       // vc.videoUrlString = videoURLString
        vc.currentVideo = videoView
        self.present(vc, animated: true, completion: nil)*/
    }
}
