//
//  HomeVC.swift
//  CyberScope
//
//  Created by Saad Furqan on 03/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import Toaster
import SDWebImage
import AVKit
import Alamofire
import Toaster
import FirebaseDatabase
import YoutubeKit
import YouTubePlayer_Swift


class HomeVC: UIViewController, VideosDetailsDelegate, SignInDelegate, FollowersDetailDelegate, getBlockedUsers_Data_Delegate, getAppointments_Data_Delegate, AddUpdateVideo_Protocol, UITextFieldDelegate, get_UserData_Delegate
{

    var ref: DatabaseReference!
    var handle: DatabaseHandle!
    
    var topView_toShow_loader = UIView()
    
    @IBOutlet weak var loadBtnView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var button_goToMap: UIButton!
    @IBOutlet weak var textfield_search: UITextField!
    
    @IBOutlet weak var streamsTableView: UITableView!
    @IBOutlet weak var button_createStream: UIButton!
    
//    var myLocationManager : CLLocationManager?
    
    let dfUserEmail                 = "abc@xyz.com"
    let dfUserPassword              = "123456"
    
    var searchTimer: Timer?
    var isSearching = false
    
    var streamsArray : [COVideo] = []
    var mainArray : [COVideo] = []
    var filteredData: [COVideo] = []
    var jobApplicationArray : [JobApplication] = []
    var selectedStreamIndex: Int = 0
    var selectedStream: COVideo?
    var streamOffset = 0
    
    var refreshControl = UIRefreshControl()

    var vibrationTimer: Timer?
    var ringtoneTimer: Timer?
    var currentUser = User()
    var player: YTSwiftyPlayer!
    
    var videoPlayer: YouTubePlayerView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        streamsArray = filteredData
        
        
        let type = UserDefaults.standard.string(forKey: Constants.CurrentUser_UserDefaults.skills)
       
        
        if type == "Recruiter"{
            loadBtnView.isHidden = false
            loadBtnView.clipsToBounds = false

        }else if type == "Job hunter"{
            loadBtnView.isHidden = true
            loadBtnView.clipsToBounds = true

        }else{
            loadBtnView.isHidden = true
            loadBtnView.clipsToBounds = true
        }
        
        ref = Database.database().reference()
        
        //MARK: - Register NiB
        self.streamsTableView.register(UINib(nibName: "StreamsTVCell", bundle: nil), forCellReuseIdentifier: "StreamsTVCell")
        
        // Do any additional setup after loading the view.
        self.add_OBSERVERS()
        self.setup_Controls()
        
        self.textfield_search.delegate = self
        self.textfield_search.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)

        self.refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControlEvents.valueChanged)
        self.streamsTableView.addSubview(refreshControl) // not required when using UITableViewController
        
        let popupTap = UITapGestureRecognizer(target: self, action: #selector(showPopUp))
        loadBtnView.addGestureRecognizer(popupTap)
        
        print ("Test I am Home VC 787")
        
        self.refreshControl.beginRefreshing()
        self.updateUserData()
        self.currentUser = CurrentUser.Current_UserObject
        
   //     addStreamInFirebase()
    //    observeDb()

//        DispatchQueue.main.asyncAfter(deadline: .now()+10) {
//            self.addStream1InFirebase()
//        }
    }
    
    @objc func dismissView(gesture: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.4) {
            
            self.player.inputViewController?.dismiss(animated: true)
            self.player.resignFirstResponder()
            self.player.isHidden = true
//            if let theWindow = UIApplication.shared.keyWindow {
//                gesture.view?.frame = CGRect(x:theWindow.frame.width - 15 , y: theWindow.frame.height - 15, width: 10 , height: 10)
//            }
        }
    }
    
    private func addStreamInFirebase(){
        
        print("%%%add stream in firebase")
        
        ref.child("streams").child("zainahmed1264").setValue(["id":"123frzainahmed1264"]) { error, _ in
            
            if error == nil{
                print("%%%successfully store on db")
            }
        }
        
        
        
        
        
    }
    
    
    
    private func addStream1InFirebase(){

        print("%%%add stream in firebase")

        
        
          ref.child("streams").child("zainahmed1236").setValue(["id":"123fr"]) { error, _ in

            if error == nil{
                print("%%%successfully store on db")
            }
        }

        




    }

    
    
//    private func observeDb(){
//        print("%%%observeDbrun")
//      handle = ref.child("streams").observe(.value) { snapshot in
//            print("%%snapshot value",snapshot.value)
//            guard let value = snapshot.value as? [String:Any] else{
//                print("%% fail in guard")
//                return
//            }
//            print("%%",value.count)
//        }
//
//
//    }
//
//    private func removeObserver(){
//        ref.child("streams").removeObserver(withHandle: handle)
//    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .black
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
    @objc func vibrateMobile()
    {
        UIDevice.vibrate()
    }
    
    @objc func playSound()
    {
        QMSoundManager.playRingtoneSound()
    }

    deinit {
        self.remove_OBSERVERS()
    }
    
    override func viewWillAppear(_ animated: Bool) {
          print("viewWillAppear called")
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        button_createStream.isHidden = true
        button_createStream.clipsToBounds = true
        print("viewWillAppear called viewDidAppear")
        DispatchQueue.global(qos: .background).async {
            self.getJobsData()
            
            self.getCurrentUser_Followings_Followers_Data()
            self.getCurrentUser_BlockedUsers_Data()
            self.getCurrentUser_Appointments_Data()
        }
        
        if(Constants.UserData.lastBroadcastId.count > 0){
            print("Constants.UserData.lastBroadcastId")
            self.imageCreatationAPI(videoName: Constants.UserData.lastBroadcastId)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refresh(sender:AnyObject) {
        self.getJobsData()
    }
    
    func add_OBSERVERS()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(HomeVC.getCurrentUser_Followings_Followers_Data), name: Notification.Name(Constants.Notifications_name.getCurrentUser_Followings_Followers_Data), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeVC.getCurrentUser_BlockedUsers_Data), name: Notification.Name(Constants.Notifications_name.getCurrentUser_BlockedUsers_Data), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeVC.getCurrentUser_Appointments_Data), name: Notification.Name(Constants.Notifications_name.getCurrentUser_Appointments_Data), object: nil)
    }
    
    func remove_OBSERVERS()
    {
        // Remove from all notifications being observed
        NotificationCenter.default.removeObserver(self)
    }
    
    func getJobsData()
    {
        self.getMyJobApplications()
        self.getStreamsListFromDFInstance()
    }
    //:- ****************
    func setup_Controls()
    {
        self.streamsTableView.delegate = self
        self.streamsTableView.dataSource = self
        self.getDF_Session()
    }
    
    func getDF_Session()
    {
        let sessionObject = DataAccess.sharedInstance
        sessionObject.signInWithEmail(dfUserEmail, password: dfUserPassword, signInDelegate: self as SignInDelegate)
    }

    @objc func getCurrentUser_Followings_Followers_Data()
    {
        let sessionObject = DataAccess.sharedInstance
        sessionObject.getCurrentUser_Followings_Followers_Data(self)
    }
    
    @objc func getCurrentUser_BlockedUsers_Data()
    {
        let sessionObject = DataAccess.sharedInstance
        sessionObject.getCurrentUser_BlockedUsers_Data(delegate: self)
    }
    
    @objc func getCurrentUser_Appointments_Data()
    {
        let sessionObject = DataAccess.sharedInstance
        sessionObject.getCurrentUser_Appointments_Data(delegate: self)
    }
    
    func getMyJobApplications ()
    {
        let sessionObject = DataAccess.sharedInstance
        sessionObject.getMyJobApplicationList(self as MyJobApplicationsDelegate)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == Constants.Segues.HomeVC_to_MapVC)
        {
            let nextVC = segue.destination as! MapVC
            nextVC.streamsArray = self.streamsArray
        }
        
        if(segue.identifier == Constants.Segues.HomeVC_to_BroadCaster_ProfileVC)
        {
            if #available(iOS 13.0, *) {
                let nextVC = segue.destination as! BroadCaster_ProfileVC
                nextVC.selectedStream = self.selectedStream
                if (nextVC.selectedStream == nil) {
                }
            } else {
                // Fallback on earlier versions
            }
            
        }
        
        if(segue.identifier == Constants.Segues.HomeVC_to_VideoCVs)
        {
            let selectedData = self.streamsArray[self.selectedStreamIndex]
            let nextVC = segue.destination as! VideoCVsVC
            nextVC.broadcastData = selectedData
            nextVC.isFromHome = true
            nextVC.delegate = self
        }
    }

    @IBAction func button_goToMap_Action(_ sender: Any)
    {
        self.performSegue(withIdentifier: Constants.Segues.HomeVC_to_MapVC, sender: self)
    }
    
    @IBAction func button_createStream_Action(_ sender: Any)
    {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            Utilities.show_ProgressHud(view: self.view)
            DataAccess.sharedInstance.get_UserData_using_UserName(userName: CurrentUser.get_User_username_fromUserDefaults(), resultDelegate: self)
        })
        
    }
    //MARK: Riz Create
    @objc func showPopUp(){
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            Utilities.show_ProgressHud(view: self.view)
            DataAccess.sharedInstance.get_UserData_using_UserName(userName: CurrentUser.get_User_username_fromUserDefaults(), resultDelegate: self)
        })
        
    }
   
    
    func get_UserData_ResponseError(_ error: NSError?) {
        print("Error data not get")
        Utilities.hide_ProgressHud(view: self.view)
    }
    func get_UserData_ResponseSuccess(isExist: Bool, requiredUser: User)
    {
        print("####\n get_UserData_ResponseSuccess called ... \n")
       
        Utilities.hide_ProgressHud(view: self.view)
        if(isExist)
        {
            CurrentUser.setCurrentUser_UserDefaults(user: requiredUser)
            
            let refreshAlert = UIAlertController(title: "Create your pitch", message: "You need to add video for users to find you . It doesn’t need to be a selfie 😊", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { (action: UIAlertAction!) in
                // self.deleteVideoCV()
                print("Handle CANCEL Logic here")
                
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "OFFLINE", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle OFFLINE Logic here")
                let vc = UIStoryboard(name: "StreamBoard", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeTo_CreateOfflineStream") as? CreateStreamOfflineVC
                vc!.modalPresentationStyle = .fullScreen
                self.present(vc!, animated: true, completion: nil)
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "LIVE STREAM", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle LIVE Logic here")
                self.performSegue(withIdentifier: Constants.Segues.HomeVC_to_CreateStreamVC, sender: self)
            }))
            
            self.present(refreshAlert, animated: true, completion: nil)
            self.performSegue(withIdentifier: Constants.Segues.HomeVC_to_CreateStreamVC, sender: self)
        }
        else
        {
            
        }
    }
    
    
    // // :--    *****************************************************************     --: //
    
    // MARK: - - SignInDelegate Methods
    func userIsSignedInSuccess(_ bSignedIn:Bool, message:String?) {
        
        if (bSignedIn) {
          //  self.getStreamsListFromDFInstance() // Call hit for Videos List
        }
        else {
            
        }
         // print("Signed IN Status : ", bSignedIn, " with message : ", message ?? "null-String_98394")
    }
    
    func userIsSignedOut() {
         // print("User is signed Out from the System")
    }
    
    // MARK: -- FollowersDetailDelegate methods
    func getFollowersData_ResponseSuccess(_ followers: [Follower])
    {
        CurrentUser.CurrentUser_Followers_List.removeAll()
        CurrentUser.CurrentUser_Followings_List.removeAll()
        CurrentUser.CurrentUser_FollowersID_List.removeAll()
        CurrentUser.CurrentUser_FollowingsID_List.removeAll()
        
         // print("\n** Start printing current user follow followings **\n")
        let currentUser_username = CurrentUser.get_User_username_fromUserDefaults()
        for follower in followers
        {
             // print("=> \(follower.id) - \(follower.userid) - \(follower.username) ** \(follower.followerid) - \(follower.followername) <=")
            
            if(follower.userid == currentUser_username)
            {
                CurrentUser.CurrentUser_Followings_List.append(follower)
                CurrentUser.CurrentUser_FollowingsID_List.append(follower.followerid)
            }
            if(follower.followerid == currentUser_username)
            {
                CurrentUser.CurrentUser_Followers_List.append(follower)
                CurrentUser.CurrentUser_FollowersID_List.append(follower.userid)
            }
        }
         // print("\n ||:--  ********************************  --:|| \n")
    }
    
    func getFollowersData_ResponseError(_ error: NSError?)
    {
        //Toast(text: "Error Occured While getting Followers Data", duration: Delay.short).show()
         // print("\n Error Occured While getting Data Followers \n")
    }
    
    // getBlockedUsers_Data_Delegate methods
    func getBlockedUsers_Data_ResponseSuccess(blockedUsers: [BlockedUser])
    {
         // print("\n getBlockedUsers_Data_ResponseSuccess called ... AND blockedUsers count = \(blockedUsers.count) \n")
        //Toast(text: "Received blocked_Users Data count is \(blockedUsers.count)", duration: Delay.short).show()
         // print("\n Received blocked_Users Data count is \(blockedUsers.count) \n")
        
        CurrentUser.BlockedUsers_List_whichAreBlocked_byCurrentUser.removeAll()
        CurrentUser.BlockedUsers_IDList_whichAreBlocked_byCurrentUser.removeAll()
        CurrentUser.BlockedUsers_List_whoBlocked_CurrentUser.removeAll()
        CurrentUser.BlockedUsers_IDList_whoBlocked_CurrentUser.removeAll()
        
         // print("\n** Start printing current user Blocked Users.. **\n")
        let currentUser_username = CurrentUser.get_User_username_fromUserDefaults()
        for b_user in blockedUsers
        {
             // print("=> \(b_user.id) - \(b_user.userid) - \(b_user.username) ** \(b_user.blockedid) - \(b_user.blockedname) <=")
            
            if(b_user.userid == currentUser_username)
            {
                CurrentUser.BlockedUsers_List_whichAreBlocked_byCurrentUser.append(b_user)
                CurrentUser.BlockedUsers_IDList_whichAreBlocked_byCurrentUser.append(b_user.blockedid)
            }
            if(b_user.blockedid == currentUser_username)
            {
                CurrentUser.BlockedUsers_List_whoBlocked_CurrentUser.append(b_user)
                CurrentUser.BlockedUsers_IDList_whoBlocked_CurrentUser.append(b_user.userid)
            }
        }
        // print("\n ||:--  ********************************  --:|| \n")
        self.getJobsData()
    }
    
    func getBlockedUsers_Data_ResponseError(_ error: NSError?) {
        //Toast(text: "Error Occured While getting Blocked_Users Data", duration: Delay.short).show()
         // print("\n Error Occured While getting Blocked_Users Data \n")
    }
    
    // getAppointments_Data_Delegate methods
    func getAppointments_Data_ResponseSuccess(appointments: [Appointment]) {
        // print("\n getAppointments_Data_ResponseSuccess called ... AND appointments count = \(appointments.count) \n")
        // Toast(text: "Received appointments Data count is \(appointments.count)", duration: Delay.short).show()
        // print("\n Received appointments Data count is \(appointments.count) \n")
        
        CurrentUser.CurrentUser_All_Appointments_List.removeAll()
        CurrentUser.Appointments_List_whichAreMade_byCurrentUser.removeAll()
        CurrentUser.Appointments_List_whoAppoint_CurrentUser.removeAll()
        
        CurrentUser.CurrentUser_All_Appointments_List = appointments
        
        // // print("\n** Start printing current user appointments.. **\n")
        let currentUser_username = CurrentUser.get_User_username_fromUserDefaults()
        for app in appointments {
            // // print("=> \(app.patientId) - \(app.patientName) ** \(app.doctorId) - \(app.doctorName) <=")
            if (app.patientId == currentUser_username) {
                CurrentUser.Appointments_List_whichAreMade_byCurrentUser.append(app)
            }
            if (app.doctorId == currentUser_username) {
                CurrentUser.Appointments_List_whoAppoint_CurrentUser.append(app)
            }
        }
        // // print("\n ||:--  ********************************  --:|| \n")
        NotificationCenter.default.post(name: Notification.Name(Constants.Notifications_name.update_appointments_tableView_data), object: nil)
    }
    
    func getAppointments_Data_ResponseError(_ error: NSError?)
    {
        //Toast(text: "Error Occured While getting Appointments Data", duration: Delay.short).show()
         // print("\n Error Occured While getting Appointments Data \n")
    }
    
    // MARK: - - GetVideos
    func getStreamsListFromDFInstance ()
    {
        let sessionObject = DataAccess.sharedInstance
        sessionObject.getVideoDetailsList(self as VideosDetailsDelegate)
    }
    
    func getMore_n_StreamsListFromDFInstance(offset: Int)
    {
         // print("getMore_n_VideosListFromDFInstance Called... ")
        
        let sessionObject = DataAccess.sharedInstance
        sessionObject.getNext_n_VideoSDetail(self as VideosDetailsDelegate, offset: offset)
    }
    
    func searchOutVideosWith(text: String) {
        print("##serachout video with function call")
        self.view.endEditing(true)
        print("##text first letter is",text.first)
        if text.first == "#"{
            let arr = text.replacingOccurrences(of: "#", with: "")
            if arr.count > 0{
                searchHashTag(with : arr)
            }
            
            return
        }
        
        Utilities.show_ProgressHud(view: self.view)
        
        let sessionObject = DataAccess.sharedInstance
        sessionObject.filterBroadcastsWithThisText(self, searchString: text)
    }
    
    private func searchHashTag(with txt : String){
        print("##serach tag is",txt)
        var item = 0
        
        let videos = self.mainArray
        var temp = [COVideo]()
//        for video in videos.prefix(through: 1){
//            var found = false
//            print("item number ",item, "and tags are",video.broadcastTags.count)
//            item += 1
//            for tag in video.broadcastTags.prefix(through: 3){
//                print("1#tags",tag.tag.trimmingCharacters(in: .whitespaces).lowercased()," txt",txt.trimmingCharacters(in: .whitespaces).lowercased())
//                if tag.tag.elementsEqual(txt){
//                    print("##element equal run")
//                }else{
//                    print("##element not equal")
//                }
//
//                if tag.tag.lowercased().trimmingCharacters(in: .whitespaces) == txt.trimmingCharacters(in: .whitespaces).lowercased(){
//                    print("##tag match",tag.tag)
//                    found = true
//
//                }
//            }
//            if found{
//                temp.append(video)
//            }
//        }
        
        print("##tempCount",temp.count)
        self.streamsArray = temp

        let filterTags = videos.filter({
            $0.broadcastTags.contains(where: {
                $0.tag.trimmingCharacters(in: .whitespaces).lowercased() == txt.trimmingCharacters(in: .whitespaces).lowercased()

            })
        })
        print("##filterTagCount",filterTags.count)
        self.streamsArray = filterTags
        DispatchQueue.main.async {
            self.streamsTableView.reloadData()
        }
    }
    
    // MARK: - - GetVideosDelegate Methods
    func setVideosRecieved(_ videos: [COVideo])
    {
        print("###setVideosRecieved ... ")
        
      
         // print("\n setVideosRecieved called ... AND videos count: \(videos.count) \n")
        print(videos.count)
        self.streamOffset = videos.count
        print(streamOffset)
        print(streamsArray.count)
        self.streamsArray.removeAll()
        
       let whoBlocked = CurrentUser.BlockedUsers_List_whoBlocked_CurrentUser
       let whoBlockedIDs = CurrentUser.BlockedUsers_IDList_whoBlocked_CurrentUser
        
        if (self.isSearching) {
            Utilities.hide_ProgressHud(view: self.view)
        }

         for video in videos {
             print(video.jobPostStatus)
            if(!Utilities.check_isBroadcaster_AlreadyBlocked(broadcaster_username: video.username))
            {
                print("jobApplicationArray.count \(self.jobApplicationArray.count)")
                for lVideo in self.jobApplicationArray {
                    if video.broadcast == lVideo.broadcast{
                        video.isJob = false
                        break
                    }
                }
                print(streamsArray.contains(where: {$0.id == video.id}))
                print(streamsArray.count)
                    
                    self.streamsArray.append(video)
            }
            else {
                print("Alread blocked")
            }
         }
        
        self.streamsArray.sort(by: {$0.id > $1.id})
        
         mainArray = streamsArray
//        print("%%stream array count",streamsArray.count)
//        print("%%main array count",mainArray.count)
         self.refreshControl.endRefreshing()
         self.streamsTableView.reloadData()
        
        if(self.streamsArray.count == 0)
        {
            if (self.isSearching) {
                Toast(text: "No results found for your search.", duration: Delay.short).show()
                return
            }
            self.getMore_n_StreamsListFromDFInstance(offset: self.streamOffset)
        }
    }
    
    func set_n_VideosRecieved(_ videos: [COVideo])
    {
        // //  // print("\n set_n_VideosRecieved called ... AND videos count: \(videos.count) \n")
        self.streamOffset = self.streamOffset + videos.count
        
        for video in videos {
            if(!Utilities.check_isBroadcaster_AlreadyBlocked(broadcaster_username: video.username)) {
                
                if !streamsArray.contains(where: {$0.id == video.id}) {
                    
                    self.streamsArray.append(video)
                }
//                self.streamsArray.append(video)
            }
        }
        
        self.streamsArray.sort(by: {$0.id > $1.id})
        
        if (videos.count > 0) {
            self.streamsTableView.reloadData()
        }
        self.refreshControl.endRefreshing()
        if(self.streamsArray.count == 0)
        {
            self.getMore_n_StreamsListFromDFInstance(offset: self.streamOffset)
        }
    }
    
    func dataAccessError(_ error:NSError?)
    {
        print("Lag gaye")
    }
    
    func updatedVideoCpunter(videoObject: COVideo) {
        
        videoObject.viewers += 1
        let shSingeltonObject = DataAccess.sharedInstance
        shSingeltonObject.addOrUpdateVideo(videoObject, delegate: self as AddUpdateVideo_Protocol)
    }
    
    func updatedResponse(isSuccess: Bool , error: String, id: Int) {
        
        // print("updated response :: ", isSuccess)
    }
    
    // MARK: - API call
    
    func imageCreatationAPI(videoName: String){
        var name : String = videoName
        let videoLink : String = "https://simx.s3-us-west-2.amazonaws.com/offlineVideos/\(videoName).mp4"
        // let videoLink : String = "https://simx.s3-us-west-2.amazonaws.com/offlineVideos/_fZj2Zds8J15943515249107.mp4"

        let parameters = [
            "imageName": name,
            "videoLink": videoLink
        ]
        print(Constants.API_URLs.uploadVideoThumbnailAPI_URL)
        print(parameters)
        Constants.UserData.lastBroadcastId = ""
        
        Alamofire.upload(multipartFormData: { multipartFormData in
                //loop this "multipartFormData" and make the key as array data
            
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            } //Optional for extra parameters
        },
        to: Constants.API_URLs.uploadVideoThumbnailAPI_URL)
        { (result) in
            switch result {
            case .success(let upload, _, _):

                upload.uploadProgress(closure: { (progress) in
                 //   print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseString{ response in
                print("response.result.value")
                    let JsonResponseData = response.result.value
                    print(response.result.value)
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        }// End
    }
    
    // MARK: - TextField Delegate
    
    @objc func textFieldDidChange(_ textField: UITextField?) {
        // reset the search timer whenever the text field changes
        // if a timer is already active, prevent it from firing
        print("##textfield change function call")
        if self.searchTimer != nil {
            self.searchTimer?.invalidate()
            self.searchTimer = nil
        }
        if (textfield_search.text == nil || textfield_search.text == "") {
            self.isSearching = false // update the check if user us searching or not
            self.getJobsData()
            return
        }
        else {
            self.isSearching = true // update the check if user us searching or not
        }
        // reschedule the search: in 2.0 second, call the searchForKeyword: method on the new textfield content
        searchTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.search(forKeyword:)), userInfo: self.textfield_search.text, repeats: false)
    }
    
    @objc func search(forKeyword timer: Timer?) {
        // retrieve the keyword from user info
        let keyword = timer?.userInfo as? String
        self.searchOutVideosWith(text: keyword!)
        // perform your search (stubbed here using NSLog)
         // print("Searching for keyword \(keyword ?? "")")
    }

}

// MARK:- TableViewDelegate And DataSource
extension HomeVC: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        if streamsArray.count > 10{
            return 10
        }else{
            return self.streamsArray.count
        }
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 15))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = (tableView.frame.size.height / 4.1)
        
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StreamsTVCell", for: indexPath) as! StreamsTVCell
       
        
        // MARK: Checking Aprroved and Unapproved stream
      
        let ar = streamsArray[indexPath.row]
        print(ar)
        
        if streamsArray[indexPath.section].jobPostStatus != "Approved"{
            filteredData = streamsArray.filter({(ele)-> Bool in
                ele.jobPostStatus.lowercased() == "approved"
                })
            streamsArray = filteredData
            updateUserData()
            self.refreshControl.endRefreshing()
            self.streamsTableView.reloadData()

        }else{
            
        }

        
        let broadcast = self.streamsArray[indexPath.section]
        // set broadcast data
        let url1 = Utilities.getUserImage_URL(username: broadcast.broadcast)
        print(url1)
        if broadcast.videourl.contains(find: "youtu"){
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
        

        print("broadcast -> ", broadcast.title, url1)
        print("broadcast.skill", broadcast.skill)
        print("Current user skills  \(self.currentUser.skills)")
        print("Constants userSkillsType \(Constants.userSkillsType.freelancer)")
        print("broadcast userSkill \(broadcast.userSkill)")
        print("Constants userSkills Type \(Constants.userSkillsType.client)")
        let type = UserDefaults.standard.string(forKey: Constants.CurrentUser_UserDefaults.skills)
        
        if type == "Recruiter"{
            cell.lblSwipeToApply.isHidden = true
        }else{
            cell.lblSwipeToApply.isHidden = false
        }
        
        
        for view in cell.viewTags.subviews {
            view.removeFromSuperview()
        }
        
        print(broadcast.broadcastTags)
        var lTags = [String]()
        for tag in broadcast.broadcastTags {
            let ltagExist = lTags.filter { $0 == tag.tag }
            if ltagExist.count == 0 {
                lTags.append(tag.tag)
            }
        }
        let tags = lTags.map { button(with: $0) }
        let frame = CGRect(x: 0, y: 0, width: cell.viewTags.frame.width , height: cell.viewTags.frame.height)
        let tagsView = TagsView(frame: frame)
        tagsView.backgroundColor = .none
        tagsView.create(cloud: tags)
        
        print("tags height: \(tagsView.tagsViewHeight)")
        
        cell.viewTags.translatesAutoresizingMaskIntoConstraints = false
        cell.tagsViewHeightConstraint.constant = tagsView.tagsViewHeight //viewTags.heightAnchor.constraint(equalToConstant: tagsView.tagsViewHeight).isActive = true
        cell.viewTags.addSubview(tagsView)
        cell.viewTags.clipsToBounds = true
        
        
//        cell.image_broadcaster.contentMode = .scaleAspectFill
        
        cell.broadcast_name.text = broadcast.title
        cell.broadcaster_name.text = "Contact me"
        cell.lblRate.text = broadcast.rate  + "/hr"
        
        cell.label_viewers.text = "\(broadcast.viewers)"
        cell.lblJobDescriptionUrl.attributedText = NSAttributedString(string: broadcast.jobDescriptionURL, attributes:
                                                                        [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
        
        if broadcast.jobDescriptionURL.isEmpty {
            cell.lblJobDescriptionUrl.frame.size.height = 0
        }
        
        // Add gesture on broadcaster picture
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.broadcasterNameTapped(sender:)))
        singleTap.numberOfTapsRequired = 1
        cell.broadcaster_name.tag = indexPath.section
        cell.broadcaster_name.isUserInteractionEnabled = true
        cell.broadcaster_name.addGestureRecognizer(singleTap)
        
        cell.contentView.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell
    }

  
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let broadcast = self.streamsArray[indexPath.section]
        self.selectedStreamIndex = indexPath.section
       
            if (broadcast.name == currentUser.name) {
                return nil
            }
            else
            {
                
                let type = UserDefaults.standard.string(forKey: Constants.CurrentUser_UserDefaults.skills)
                //Riz Change
                if type == "Recruiter"{
                   return nil
                }else{
                    
                    let link = streamsArray[indexPath.section].jobSiteLink
                    print(link)
                    
                    var text = ""
                    if link.isEmpty == true{
                        text = "Apply Video"
                    }else{
                        text = "Apply on Job Site"
                    }
                    
                    print(text)
                    let applyAction = UIContextualAction(style: .destructive, title: text) { (action, sourceView, completionHandler) in
                        print("Edit tapped")
                        if text == "Apply on Job Site"{
                            UIApplication.shared.open(URL(string: link)! as URL, options: [:], completionHandler: nil)
                        }else{
                            self.performSegue(withIdentifier: Constants.Segues.HomeVC_to_VideoCVs, sender: self)
                            completionHandler(true)
                        }
                       
                    }
                    applyAction.backgroundColor = UIColor(red: CGFloat(10.0/255.0), green: CGFloat(73.0/255.0), blue: CGFloat(122.0/255.0), alpha: CGFloat(1.0))
                    let swipeAction = UISwipeActionsConfiguration(actions: [applyAction])
                    swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
                    return swipeAction
                }
            }
            
        }
       
    
    @objc func broadcasterNameTapped(sender: UITapGestureRecognizer) {
        let view = sender.view as! UILabel
         // print("\n broadcasterImageTapped with tag = \(view.tag) \n")
        
        let stream = self.streamsArray[view.tag]
        self.selectedStream = stream
        
        let u = CurrentUser.getCurrentUser_From_UserDefaults()
        
        if((u.username) != (self.selectedStream?.username)!)
        {
            self.performSegue(withIdentifier: Constants.Segues.HomeVC_to_BroadCaster_ProfileVC, sender: self)
            
        }
        else
        {
             // print("\n Can't open my own profile ... \n")
            self.tabBarController?.selectedIndex = 0
            let firstNavContr = self.tabBarController?.viewControllers?.first as! UINavigationController
            firstNavContr.popToRootViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        
        
        if(indexPath.section == (self.streamsArray.count - 3) && self.streamsArray.count > 19) {
            filteredData = streamsArray
            if (self.isSearching) { return }
            self.getMore_n_StreamsListFromDFInstance(offset: self.streamOffset)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let stream = self.streamsArray[indexPath.section]
        
        self.selectedStream = stream
        
       // if (stream.status as String == Constants.VideoStatus.offline) {
        //if (stream.isOffline) {
        if (stream.isOffline) {
            print("### come in stream is offline")
          //  let videoURLString = Constants.Stream_URLs.savedStreamUrl + stream.broadcast as String + Constants.Stream_URLs.savedStreamPostFix
            let videoURLString = "\(Constants.Stream_URLs.videoBaseLink)offlineVideos/\(stream.broadcast).mp4"
            print("about to launch Player with 8888 : \(videoURLString)")
            //self.playThisVideoInAVPlayer(videoFileURLString: videoURLString)
            
            if stream.videourl.contains(find: "youtu"){
               
                let videoId = stream.videourl.youtubeID
                let vc = storyboard?.instantiateViewController(withIdentifier: "CustomYoutubeVc") as? CustomYoutubeVc
                vc!.youTubeId = videoId ?? ""
                vc!.modalPresentationStyle = .fullScreen
                present(vc!, animated: false, completion: nil)
            }else{
                self.playCVVideo(broadcastVideo: videoURLString, videoTitle: stream.title, broadcastID: stream.id, viewerCount: stream.viewers)
            }
            
            
            
           
          /* let vc =  UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil).instantiateViewController(withIdentifier: Constants.ViewControllers.VODWowzaViewController) as! VODWowzaViewController
            vc.videoUrlString = videoURLString
            vc.currentVideo = stream
            self.present(vc, animated: true, completion: nil)*/
        }
        else if (stream.status == Constants.VideoStatus.offline)//if (stream.status as String == Constants.VideoStatus.online)
        {
            print("###come in stream.status == Constants.VideoStatus.offline",Constants.VideoStatus.offline)
            let videoURLString = "\(Constants.Stream_URLs.videoBaseLink)recordedvideos/\(stream.broadcast).mp4"
             print("about to launch Player with 8888 : \(videoURLString)")
             //self.playThisVideoInAVPlayer(videoFileURLString: videoURLString)
             
             self.playCVVideo(broadcastVideo: videoURLString, videoTitle: stream.title, broadcastID: stream.id, viewerCount: stream.viewers)
            
            

        }
        else {
            if(stream.username == currentUser.username)
            {
                Alert.showAlertWithMessageAndTitle(message: "You cannot join your own stream", title: "")
            }
            else
            {
                print("###come in Constants.StoryBoards.StreamBoard" )
                let storyboard = UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil)
                let liveViewerViewController = storyboard.instantiateViewController(withIdentifier: "LiveStreamingViewerController") as! LiveStreamingViewerController
                liveViewerViewController.currentVideo = stream
                liveViewerViewController.modalPresentationStyle = .fullScreen
                self.present(liveViewerViewController, animated: true, completion: nil)
            }
            
        }
    }
    
    func updateUserData()
    {
        let user = CurrentUser.getCurrentUser_From_UserDefaults()
        
        let data = ["\(Constants.UserFields.username)": user.username as AnyObject,
                    "\(Constants.UserFields.skills)": user.skills as AnyObject,
                    "\(Constants.UserFields.rate)": user.rate as AnyObject,
                    "\(Constants.UserFields.link)": user.link as AnyObject,
                    "\(Constants.UserFields.arn)": user.arn as AnyObject] as AnyObject
        let newDataAccess = DataAccess()
        newDataAccess.Update_Data_in_UsersTable(data, delegate: self)
    }
}

extension HomeVC: UpdateUser_Delegate
{
    // UpdateUser_Delegate methods
    func UpdateUser_ResponseSuccess(updated_user: User, status: Bool)
    {
    }
    
    func UpdateUser_ResponseError(_ error:NSError?)
    {
    }
}

extension HomeVC: MyJobApplicationsDelegate {
    func setMyJobApplicationsRecieved(_ videos: [JobApplication]) {
        print("setMyJobApplicationsRecieved")
        print(videos)
        
        self.jobApplicationArray = videos
     /*   for lVideo in videos {
            if self.streamsArray.count > 0{
                for index in 0...(self.streamsArray.count - 1) {
                    if self.streamsArray[index].broadcast == lVideo.broadcast{
                        self.streamsArray[index].isJob = false
                    }
                }
            }
        }

        DispatchQueue.main.async {
            self.streamsTableView.reloadData()
        }*/
    }
}

extension HomeVC{
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
        
//      ****** Previous code comment by zain *********
        
//        let vc =  UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil).instantiateViewController(withIdentifier: "playerVC") as! playerVC
//        vc.videoUrl = url!
//        vc.videoTitle = videoTitle
//        vc.broadcastID = broadcastID
//        vc.viewerCount = viewerCount
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true, completion: nil)
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
    //        // to overcome .stalled state
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
    //            playerViewController.player!.play()
    //        })
    }
}


extension HomeVC: PlayerDelegate {
    
    func playerReady(_ player: Player) {
        print("\(#function) ready")
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        print("\(#function) \(player.playbackState.description)")
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
    }
    
    func playerBufferTimeDidChange(_ bufferTime: Double) {
    }
    
    func player(_ player: Player, didFailWithError error: Error?) {
        print("\(#function) error.description")
    }
    
}

extension HomeVC: VideoCVsVCDelegate {
    func setJobTitle(broadcastID: String) {
            
        for index in 0...(self.streamsArray.count - 1) {
            if self.streamsArray[index].broadcast == broadcastID{
                self.streamsArray[index].isJob = false
                break
            }
        }
        DispatchQueue.main.async {
            self.streamsTableView.reloadData()
        }
    }
    
    
}
// MARK: - PlayerPlaybackDelegate
extension HomeVC: PlayerPlaybackDelegate {
    
    func playerCurrentTimeDidChange(_ player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
    }

    func playerPlaybackDidLoop(_ player: Player) {
    }
}

extension HomeVC{
    func button(with title: String) -> UIButton {
        var font = UIFont.preferredFont(forTextStyle: .body)
       // [UIFont boldSystemFontOfSize:13.f]
        font = font.withSize(11)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = title.size(withAttributes: attributes)
        
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = font
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = (size.height + 10.0 ) / 2
        button.backgroundColor = UIColor(red: CGFloat(10.0/255.0), green: CGFloat(73.0/255.0), blue: CGFloat(122.0/255.0), alpha: CGFloat(1.0))
        button.frame = CGRect(x: 10.0, y: 0.0, width: size.width + 20.0, height: size.height + 10.0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0)
        return button
    }
}

typealias MethodHandler1 = (_ sender: UIButton)  -> Void

class TagsView: UIView {
    
    // MARK: - Properties
    var offset: CGFloat = 2
    var Yoffset: CGFloat = 5
    var tagsViewHeight: CGFloat = 0

    // MARK: - Public functions

    func create(cloud tags: [UIButton]) {
        var x = offset
        var y = Yoffset
        for (index, tag) in tags.enumerated() {
            tag.frame = CGRect(x: x, y: y, width: tag.frame.width, height: tag.frame.height)
            x += tag.frame.width + offset
            
            let nextTag = index <= tags.count - 2 ? tags[index + 1] : tags[index]
            let nextTagWidth = nextTag.frame.width + 0
            self.tagsViewHeight = tag.frame.height + 5
            if x + nextTagWidth > frame.width {
                x = offset
                y += tag.frame.height + offset
                self.tagsViewHeight = y
            }
            
            addSubview(tag)
        }
    }
    
    func reloadTagsView(with tagsArray: [String], selector: Selector, parentView: UIView, sss: UIViewController) -> TagsView {
        
        var lTags = [String]()
        for tag in tagsArray {
            let ltagExist = lTags.filter { $0 == tag }
            if ltagExist.count == 0 {
                lTags.append(tag)
            }
        }
        let tags = lTags.map { button(with: $0) }
        tags.forEach({$0.addTarget(sss, action: selector, for: .touchUpInside)})
//        print(selector, "333333")
        let frame = CGRect(x: 0, y: 0, width: parentView.frame.width, height: parentView.frame.height)
        self.frame = frame
        self.backgroundColor = .none
        self.create(cloud: tags)
        return self
    }
    
    func button(with title: String) -> UIButton {
        var font = UIFont.preferredFont(forTextStyle: .body)
       // [UIFont boldSystemFontOfSize:13.f]
        font = font.withSize(10)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = title.size(withAttributes: attributes)
        
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = font
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = (size.height + 10.0 ) / 2
        button.backgroundColor = UIColor(red: CGFloat(10.0/255.0), green: CGFloat(73.0/255.0), blue: CGFloat(122.0/255.0), alpha: CGFloat(1.0))
        button.frame = CGRect(x: 10.0, y: 0.0, width: size.width + 12.0, height: size.height + 10.0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 3.0, bottom: 0.0, right: 3.0)
        return button
    }
}
//
//extension Array where Element: Hashable {
//    func difference(from other: [Element]) -> [Element] {
//        let thisSet = Set(self)
//        let otherSet = Set(other)
//        return Array(thisSet.subtracting(otherSet))
//    }
//}
