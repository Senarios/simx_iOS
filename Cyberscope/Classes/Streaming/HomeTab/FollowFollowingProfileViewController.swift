//
//  FollowFoolowingProfileViewController.swift
//  CyberScope
//
//  Created by Salman on 03/07/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import Toaster
import AVKit
//import QMChatViewController

class FollowFollowingProfileViewController: UIViewController, Add_Follower_Delegate, removeFollower_Delegate, Add_BlockedUser_Delegate, Remove_BlockedUser_Delegate, get_Users_Delegate, getFollowers_Data_Delegate, VideosDetailsDelegate, AddUpdateVideo_Protocol
{
    
    @IBOutlet weak var lblBlockUser: UILabel!
    @IBOutlet weak var viewDetails: UIView!
    @IBOutlet weak var button_back: UIButton!
    @IBOutlet weak var button_blockUser: UIButton!
    
    @IBOutlet weak var broadcastsTableView: UITableView!
    var broadcastsArray : [COVideo] = []
    
    @IBOutlet weak var socialMediaProfileIcon: UIImageView!
    
    @IBOutlet weak var label_broadcasterName: UILabel!
    @IBOutlet weak var label_broadcasterJobTitle: UILabel!
    @IBOutlet weak var broadcaster_profileImage: UIImageView!
    
    @IBOutlet weak var label_numberOfFollwers: UILabel!
    @IBOutlet weak var label_numberOfFollwings: UILabel!
    @IBOutlet weak var label_numberOfBroadcasts: UILabel!
    
    @IBOutlet weak var button_follow: UIButton!
    @IBOutlet weak var button_message: UIButton!
    @IBOutlet weak var button_appointment: UIButton!
    @IBOutlet weak var rateLabel: UILabel!
    
    @IBOutlet weak var rateViewContainer: UIView!
    @IBOutlet weak var button_Call: UIButton!
    
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var btnViewRating: UIButton!
    @IBOutlet weak var viewRating: StarRatingView!
    
    //MARK: New View Outlet
    
    @IBOutlet weak var previousView: UIView!
    @IBOutlet weak var newView: UIView!
    
    @IBOutlet weak var followerBtnN: UIButton!
    @IBAction func followerBtnN(_ sender: Any) {
    }
    
    @IBOutlet weak var appointmentBtnN: UIButton!
    @IBAction func appointmentBtnN(_ sender: Any) {
    }
    
    var selectedStream: COVideo?
    var selectedUserId: String?
    var selectedBroadcaster: User?
    var selectedBroadcaster_FollowersList: [Follower] = []
    var selectedBroadcaster_FollowingsList: [Follower] = []
    var firstTimeCalled = true
    
    fileprivate let dataAccess = DataAccess.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: NSNotification.Name("updateUserInfo"), object: nil, queue: nil){(note) in
            
            self.dataAccess.get_Users((self.selectedUserId)!, resultDelegate: self)
            Utilities.show_ProgressHud(view: self.view)
            self.firstTimeCalled = false
            let queryParams: [String: String] = ["filter": "(\(Constants.Follower_Fields.userid)=\(self.selectedUserId!))OR(\(Constants.Follower_Fields.followerid)=\(self.selectedUserId!))"]
            self.dataAccess.get_Followers_Data(queryParams: queryParams, delegate: self)
            
            self.setupView()
        }
        // Do any additional setup after loading the view.
        self.dataAccess.get_Users((self.selectedUserId)!, resultDelegate: self)
        Utilities.show_ProgressHud(view: self.view)
        firstTimeCalled = true
        let queryParams: [String: String] = ["filter": "(\(Constants.Follower_Fields.userid)=\(self.selectedUserId!))OR(\(Constants.Follower_Fields.followerid)=\(self.selectedUserId!))"]
        self.dataAccess.get_Followers_Data(queryParams: queryParams, delegate: self)
        
        self.broadcastsTableView.delegate = self
        self.broadcastsTableView.dataSource = self
        self.setupView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !(firstTimeCalled) {
            let queryParams: [String: String] = ["filter": "(\(Constants.Follower_Fields.userid)=\(self.selectedUserId!))OR(\(Constants.Follower_Fields.followerid)=\(self.selectedUserId!))"]
            self.dataAccess.get_Followers_Data(queryParams: queryParams, delegate: self)
        }
        firstTimeCalled = false
        self.setupView()
    }
    
    func updateUserInfo(totalRating: String, userRating: String)
    {
        self.viewRating.rating = Float(userRating)!
        self.lblRating.text = userRating + " (" + totalRating + ")"
        UserDefaults.standard.set(totalRating, forKey:Constants.CurrentUser_UserDefaults.total_ratings)
        UserDefaults.standard.set(userRating, forKey:Constants.CurrentUser_UserDefaults.user_ratings)
        UserDefaults.standard.synchronize()
    }
    
    func controlSetupReplacer() {
        self.setup_Controls()
    }
    
    func setupView()
    {
        socialMediaProfileIcon.layer.cornerRadius = socialMediaProfileIcon.frame.height / 2
        
        button_follow.layer.cornerRadius = button_follow.frame.height / 2
        button_message.layer.cornerRadius = button_message.frame.height / 2
        button_appointment.layer.cornerRadius = button_appointment.frame.height / 2
        
        viewDetails.layer.shadowColor = UIColor.black.cgColor
        viewDetails.layer.shadowOpacity = 0.3
        viewDetails.layer.shadowOffset = .zero
        viewDetails.layer.shadowRadius = 3
        
        broadcaster_profileImage.layer.borderWidth = 2
        broadcaster_profileImage.layer.borderColor = UIColor(red: 112/255, green: 112/255, blue: 112/255, alpha: 1).cgColor
        broadcaster_profileImage.layer.cornerRadius = broadcaster_profileImage.frame.height / 2
        broadcaster_profileImage.clipsToBounds = true
        
        rateViewContainer.layer.cornerRadius = rateViewContainer.frame.height / 2
        rateViewContainer.layer.shadowColor = UIColor.black.cgColor
        rateViewContainer.layer.shadowOpacity = 0.3
        rateViewContainer.layer.shadowOffset = .zero
        rateViewContainer.layer.shadowRadius = 3
        
        self.view.bringSubview(toFront: self.button_Call)
    }
    
    func setup_Controls()
    {
        self.label_broadcasterName.text = (self.selectedBroadcaster?.name)!
        if (self.selectedBroadcaster?.skills == Constants.userSkillsType.viewer) {
            //            self.label_broadcasterJobTitle.text = Constants.userSkillsType.viewer
            self.button_appointment.isHidden = true
            if (CurrentUser.Current_UserObject.skills == Constants.userSkillsType.viewer) {
                self.button_Call.isHidden = true
            }
        } else  {
            //            self.label_broadcasterJobTitle.text = Constants.userSkillsType.broadcaster
        }
        
        let isFollowing = Utilities.check_isCurrentUser_AlreadyFollowing_Broadcaster(broadcaster_username: (self.selectedUserId)!)
        if(isFollowing)
        {
            self.button_follow.setTitle(Constants.strings.Unfollow, for: .normal)
        }
        else
        {
            self.button_follow.setTitle(Constants.strings.Follow, for: .normal)
        }
        
        let isBlocked = Utilities.check_isBroadcaster_AlreadyBlocked(broadcaster_username: (self.selectedUserId)!)
        if(isBlocked)
        {
            self.lblBlockUser.text = Constants.strings.Unblock_User
            //            self.button_blockUser.setTitle(Constants.strings.Unblock_User, for: .normal)
        }
        else
        {
            self.lblBlockUser.text = Constants.strings.Block_User
            //            self.button_blockUser.setTitle(Constants.strings.Block_User, for: .normal)
        }
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
    
    func update_Labels()
    {
        if let user = self.selectedBroadcaster
        {
            self.label_broadcasterName.text = user.name
            //            self.label_broadcasterJobTitle.text = user.skills
            let totalRating = user.total_ratings as String
            let userRating = user.user_ratings as String
            self.lblRating.text = userRating + " (" + totalRating + ")"
            self.setupRating(rating: userRating)
            let url = Utilities.getUserImage_URL(username: user.username)
            self.broadcaster_profileImage.sd_setImage(with: url, placeholderImage: UIImage(named: Constants.imagesName.broadcaster_image), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                // Perform operation.
                if (error == nil) {
                    self.broadcaster_profileImage.image = self.broadcaster_profileImage.image?.circle
                }
            })
            
            self.label_numberOfBroadcasts.text = String(user.broadcasts)
        }
        
        self.label_numberOfFollwers.text = String(self.selectedBroadcaster_FollowersList.count)
        self.label_numberOfFollwings.text = String(self.selectedBroadcaster_FollowingsList.count)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == Constants.Segues.FollowerFollowings_to_Request_AppointmentVC)
        {
            let nextVC = segue.destination as! RequestAppointmentViewController
            nextVC.selected_broadcaster = self.selectedBroadcaster
        }
        if(segue.identifier == Constants.Segues.followFollowingVC_to_Rating_VC)
        {
            let controller = segue.destination as! RatingViewController
            controller.fromSelfProfile = false
            controller.user = self.selectedBroadcaster
        }
    }
    
    
    func moveBack()
    {
        DispatchQueue.main.async {
            if (self.navigationController == nil) {
                self.dismiss(animated: true, completion: nil)
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnViewRating_pressed(_ sender: Any) {
        self.performSegue(withIdentifier: Constants.Segues.followFollowingVC_to_Rating_VC, sender: self)
    }
    
    @IBAction func button_backTapped(_ sender: Any)
    {
        self.moveBack()
    }
    
    @IBAction func button_blockUserTapped(_ sender: Any)
    {
        Utilities.show_ProgressHud(view: self.view)
        if(self.lblBlockUser.text == Constants.strings.Block_User)
        {
            // Going to add follower
            if (self.selectedBroadcaster != nil)
            {
                let u = CurrentUser.getCurrentUser_From_UserDefaults()
                let b: BlockedUser = BlockedUser()
                b.id = u.username + "\(Utilities.currentTimeStamp_withoutMS())"
                b.userid = u.username
                b.username = u.name
                b.blockedid = (self.selectedBroadcaster?.username)!
                b.blockedname = (self.selectedBroadcaster?.name)!
                b.isNew_object = true
                
                DataAccess().addNew_BlockedUser(blockedUser: b, delegate: self, senderTag: Int((self.selectedBroadcaster?.qbid)!)!)
            }
            else {
                //Toast(text: "Broadcaster object is nil.Can't block user bcz Broadcaster data in not available..").show()
            }
        }
        else if(self.lblBlockUser.text == Constants.strings.Unblock_User) {
            // Going to remove follower
            if let b_user = Utilities.get_Required_BlockedUser_Object_fromList_using_blockedid(id: self.selectedUserId!) {
                self.dataAccess.remove_BlockedUser(blockedUser: b_user, resultDelegate: self, senderTag: Int((self.selectedBroadcaster?.qbid)!)!)
            }
        }
        else {
            print("\n Unknown text is written on button_blockUser  ... \n")
        }
    }
    
    @IBAction func button_followTapped(_ sender: Any) {
        
        if isUserBlocked() {
            self.showTaost(message: "Unblock user first")
            return
        }
        
        if(self.button_follow.titleLabel?.text == Constants.strings.Follow) {
            // Going to add follower
            if (self.selectedBroadcaster != nil) {
                let u = CurrentUser.getCurrentUser_From_UserDefaults()
                let f: Follower = Follower()
                f.id = (self.selectedBroadcaster?.username)! + "\(Utilities.currentTimeStamp_withoutMS())"
                f.userid = u.username
                f.username = u.name
                f.followerid = (self.selectedBroadcaster?.username)!
                f.followername = (self.selectedBroadcaster?.name)!
                f.isNew_object = true
                
                self.dataAccess.addNewFollower(follower: f, delegate: self, senderTag: Int((self.selectedBroadcaster?.qbid)!)!)
            }
            else {
                //Toast(text: "Broadcaster object is nil.Can't follow bcz Broadcaster data in not available..").show()
            }
        }
        else if(self.button_follow.titleLabel?.text == Constants.strings.Unfollow) {
            // Going to remove follower
            if let follower = Utilities.get_RequiredFollowerObject_fromFollowingList_using_followerid(id: self.selectedUserId!) {
                self.dataAccess.removeFollower(follower, resultDelegate: self, senderTag: Int((self.selectedBroadcaster?.qbid)!)!)
            }
        }
        else {
            print("\n Unknown text is written on Follow button ... \n")
        }
    }
    
    @IBAction func button_messageTapped(_ sender: Any) {
        
        if isUserBlocked() {
            self.showTaost(message: "Unblock user first")
            return
        }
        
        if(self.selectedBroadcaster != nil) {
            Utilities.show_ProgressHud(view: self.view)
            let chatDialog: QBChatDialog = QBChatDialog(dialogID: nil, type: QBChatDialogType.private)
            let qbid = Int((self.selectedBroadcaster?.qbid)!)
            chatDialog.occupantIDs = [NSNumber(value: qbid!)]
            print("Qbid :: ", qbid!, " Occupants :: ", chatDialog.occupantIDs!)
            QBRequest.createDialog(chatDialog, successBlock: {(response: QBResponse?, createdDialog: QBChatDialog?) in
                Utilities.hide_ProgressHud(view: self.view)
                let newQMChateVC = ChatViewController()
                newQMChateVC.dialog = createdDialog
                newQMChateVC.chatimage = self.broadcaster_profileImage.image
                self.navigationController?.pushViewController(newQMChateVC, animated: true)
                
            }, errorBlock: {(response: QBResponse!) in
                Utilities.hide_ProgressHud(view: self.view)
                Alert.showAlertWithMessageAndTitle(message: "Encountered some error here, please check your internet connection and try again.", title: "Error!")
                print(response.debugDescription)
            })
        }
    }
    
    @IBAction func button_appointmentAction(_ sender: Any) {
        
        if isUserBlocked() {
            self.showTaost(message: "Unblock user first")
            return
        }
        
        if (self.selectedBroadcaster != nil) {
            self.performSegue(withIdentifier: Constants.Segues.FollowerFollowings_to_Request_AppointmentVC, sender: self)
            //            AppDelegate.send_PUSH_Notification(notification_type: .Appointment_Notification, toUsers: (self.selectedBroadcaster?.qbid)!)
        }
        else {
            //Toast(text: "Broadcaster object is nil.Can't make appointment bcz Broadcaster data in not available..").show()
        }
    }
    
    @IBAction func button_CallTapped(_ sender: Any) {
        if isUserBlocked() {
            self.showTaost(message: "Unblock user first")
            return
        }
        
        //if(CurrentUser.Current_UserObject.credit > 0){
            self.goto_selectCallTypeVC()
        //}
//        else{
//            DispatchQueue.main.async {
////                let refreshAlert = UIAlertController(title: "Insufficient Balance", message: "You have Insufficient Balance to make this call, do you want to recharge your account right now?", preferredStyle: UIAlertController.Style.alert)
////
////                refreshAlert.addAction(UIAlertAction(title: "NO", style: .default, handler: { (action: UIAlertAction!) in
////                    print("Handle NO logic here")
////                }))
//                
//               // refreshAlert.addAction(UIAlertAction(title: "YES", style: .cancel, handler: { (action: UIAlertAction!) in
//                    print("Handle YES Logic here")
//                    let storyBoard: UIStoryboard = UIStoryboard(name: Constants.StoryBoards.Payments, bundle: nil)
//                    let nextVC = storyBoard.instantiateViewController(withIdentifier: "AddPaymentCredits") as! Purchaseplan
//                    
//                    AppDelegate.QB_VideoChat_opponetUser = self.selectedBroadcaster
//                    
//                    self.present(nextVC, animated: true, completion: nil)
//                    //refreshAlert .dismiss(animated: true, completion: nil)
//                //}))
//                
//                //self.present(refreshAlert, animated: true, completion: nil)
//                
//            }
//        }
        
        
    }
    
    func goto_selectCallTypeVC() {
        if(self.selectedBroadcaster != nil) {
            DispatchQueue.main.async {
                let storyBoard: UIStoryboard = UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil)
                let nextVC = storyBoard.instantiateViewController(withIdentifier: Constants.ViewControllers.selectCallTypeVC) as! selectCallTypeVC
                
                AppDelegate.QB_VideoChat_opponetUser = self.selectedBroadcaster
                self.present(nextVC, animated: true, completion: nil)
            }
        }
    }
    
    // :- ********************
    
    // get_Users_Delegate methods
    func get_Users_Success(_ users: [User]) {
        print("\n get_Users_Success called ... AND users count = \(users.count) \n")
        self.selectedBroadcaster = users.first
        
        if (self.selectedBroadcaster == nil) {
            self.moveBack()
            return
        }
        
        self.rateLabel.text = "\((self.selectedBroadcaster?.rate)!)/hr"
        
        if (self.selectedBroadcaster?.skills == Constants.userSkillsType.broadcaster) {
            self.rateViewContainer.isHidden = false
            self.button_appointment.isHidden = false
        } else {
            self.button_appointment.isHidden = true
            if (CurrentUser.Current_UserObject.skills == Constants.userSkillsType.viewer) {
                self.button_Call.isHidden = true
            }
        }
        
        if (self.selectedBroadcaster?.link == nil || self.selectedBroadcaster?.link == "" || self.selectedBroadcaster?.link == "NA" || self.selectedBroadcaster?.link == "No") {
            
            self.socialMediaProfileIcon.isHidden = true
        }
        else {
            self.socialMediaProfileIcon.isHidden = false
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            self.socialMediaProfileIcon.isUserInteractionEnabled = true
            self.socialMediaProfileIcon.addGestureRecognizer(tapGestureRecognizer)
            // empty case is already checked in above if ()
            let imageString = Utilities.getImageNameForCurrentUserProfileWithLinkString(linkString: (self.selectedBroadcaster?.link)!)
            
            self.socialMediaProfileIcon.image = UIImage(named: imageString)
            socialMediaProfileIcon.layer.cornerRadius = socialMediaProfileIcon.frame.height / 2
        }
        
        if (self.selectedBroadcaster?.username == "" || self.selectedBroadcaster?.username == nil) {
            self.moveBack()
            return
        }
        
        self.controlSetupReplacer()
        
        DispatchQueue.main.async {
            self.update_Labels()
            Utilities.hide_ProgressHud(view: self.view)
        }
        
        let sessionObject = dataAccess
        sessionObject.getVideosForThisBroadcaster(self, broadcaster_username: (self.selectedBroadcaster?.username)!)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        _ = tapGestureRecognizer.view as! UIImageView
        // Your action
        print("Image Social Media linke tapped")
        
        if let link = URL(string: (self.selectedBroadcaster?.link)!) {
            UIApplication.shared.open(link)
        }
    }
    
    func get_Users_Error(_ error: NSError?)
    {
        print("\n getUsers_Data_ResponseError called ... AND error = \(String(describing: error?.localizedDescription)) \n")
        self.moveBack()
    }
    
    func isUserBlocked() -> Bool {
        if(self.lblBlockUser.text != Constants.strings.Block_User) {
            return true
        }
        return false
    }
    
    func showTaost(message: String) {
        Toast(text: message).show()
    }
    
    // MARK: - - GetVideosDelegate Methods
    func setVideosRecieved(_ videos: [COVideo])
    {
        print("\n setVideosRecieved called ... AND videos count: \(videos.count) \n")
        self.broadcastsArray.removeAll()
        
        for video in videos
        {
            if(!Utilities.check_isBroadcaster_AlreadyBlocked(broadcaster_username: video.username))
            {
                self.broadcastsArray.append(video)
            }
        }
        self.label_numberOfBroadcasts.text = "\(self.broadcastsArray.count)"
        //        BlockedUsers_IDList_whichAreBlocked_byCurrentUser
        self.broadcastsTableView.reloadData()
    }
    
    func removeBlockedUserAndReload(blockedUserId: Int) {
        if (blockedUserId == 0) { return } // return if id is 0
        var videosArray : [COVideo] = []
        for video in self.broadcastsArray {
            if(blockedUserId != video.id) {
                videosArray.append(video)
            }
        }
        self.broadcastsArray = videosArray
        self.label_numberOfBroadcasts.text = "\(self.broadcastsArray.count)"
        self.broadcastsTableView.reloadData()
    }
    
    func set_n_VideosRecieved(_ videos: [COVideo]) {
        
    }
    
    func dataAccessError(_ error:NSError?) {
        print("\n dataAccessError called ... AND error = \(String(describing: error?.localizedDescription)) \n")
    }
    
    // getFollowers_Data_Delegate methods
    func getFollowers_Data_ResponseSuccess(followers: [Follower])
    {
        print("\n getFollowers_Data_ResponseSuccess called ... AND followers count = \(followers.count) \n")
        //Toast(text: "Received Followers Data count is \(followers.count)", duration: Delay.short).show()
        print("\n Received Followers Data count is \(followers.count) \n")
        
        self.selectedBroadcaster_FollowersList.removeAll()
        self.selectedBroadcaster_FollowingsList.removeAll()
        
        print("\n** Start printing selected broadcaster follow followings **\n")
        let username = self.selectedUserId!
        for follower in followers {
            print("=> \(follower.id) - \(follower.userid) - \(follower.username) ** \(follower.followerid) - \(follower.followername) <=")
            
            if(follower.userid == username) {
                self.selectedBroadcaster_FollowingsList.append(follower)
            }
            if(follower.followerid == username) {
                self.selectedBroadcaster_FollowersList.append(follower)
            }
        }
        print("\n ||:--  ********************************  --:|| \n")
        
        DispatchQueue.main.async {
            self.update_Labels()
        }
    }
    
    func getFollowers_Data_ResponseError(_ error: NSError?)
    {
        print("\n getFollowers_Data_ResponseError called ... AND error = \(String(describing: error?.localizedDescription)) \n")
    }
    
    // Add_Follower_Delegate methods
    func Add_Follower_ResponseSuccess(senderTag: Int, id: String)
    {
        print("\n Add_Follower_ResponseSuccess called ... AND senderTag = \(senderTag), id = \(id) \n")
        Toast(text: "You started following \(String(describing: (self.selectedBroadcaster?.name)!))").show()
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(Constants.Notifications_name.getCurrentUser_Followings_Followers_Data), object: nil)
            
            self.button_follow.setTitle(Constants.strings.Unfollow, for: .normal)
        }
    }
    
    func Add_Follower_ResponseError(error: NSError) {
        print("\n Add_Follower_ResponseError called ... AND error = \(error.localizedDescription) \n")
    }
    
    // removeFollower_Delegate methods
    func removeFollower_Delegate_Response(isSuccess: Bool , error: String, senderTag: Int, id: String) {
        print("\n removeFollower_Delegate_Response called ... AND error = \(error) \n")
        if isSuccess {
            print("Deleted Follower id = \(id)")
            Toast(text: "You Unfollowed \(String(describing: (self.selectedBroadcaster?.name)!))").show()
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(Constants.Notifications_name.getCurrentUser_Followings_Followers_Data), object: nil)
                
                self.button_follow.setTitle(Constants.strings.Follow, for: .normal)
            }
        }
        else {
            Toast(text: "Error Occured when try to Unfollow").show()
            print("\nError Occured when try to Unfollow...\n")
        }
    }
    
    // Add_BlockedUser_Delegate methods
    func Add_BlockedUser_ResponseSuccess(senderTag: Int, id: String) {
        Utilities.hide_ProgressHud(view: self.view)
        print("\n Add_BlockedUser_ResponseSuccess called ... AND senderTag = \(senderTag), id = \(id) \n")
        Toast(text: "You blocked \(String(describing: (self.selectedBroadcaster?.name)!))").show()
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(Constants.Notifications_name.getCurrentUser_BlockedUsers_Data), object: nil)
            
            self.lblBlockUser.text = Constants.strings.Unblock_User
            //            self.button_blockUser.setTitle(Constants.strings.Unblock_User, for: .normal)
            //self.removeBlockedUserAndReload(blockedUserId: id == "0" ? 0 : Int(id)!)
            //self.removeBlockedUserAndReload(blockedUserId: Int(id) ?? 0)
        }
    }
    
    func Add_BlockedUser_ResponseError(error: NSError)
    {
        Utilities.hide_ProgressHud(view: self.view)
        print("\n Add_BlockedUser_ResponseError called ... AND error = \(error.localizedDescription) \n")
        Toast(text: "Error Occured when try to block user...").show()
    }
    
    // Remove_BlockedUser_Delegate methods
    func Remove_BlockedUser_ResponseSuccess(senderTag: Int, id: String)
    {
        Utilities.hide_ProgressHud(view: self.view)
        print("\n Remove_BlockedUser_ResponseSuccess called ... \n Unblocked User id = \(id) \n")
        Toast(text: "You Unblocked \(String(describing: (self.selectedBroadcaster?.name)!))").show()
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(Constants.Notifications_name.getCurrentUser_BlockedUsers_Data), object: nil)
            self.lblBlockUser.text = Constants.strings.Block_User
            //            self.button_blockUser.setTitle(Constants.strings.Block_User, for: .normal)
        }
    }
    
    func Remove_BlockedUser_ResponseError(error: NSError)
    {
        Utilities.hide_ProgressHud(view: self.view)
        print("\n Remove_BlockedUser_ResponseError called ... AND error = \(error.localizedDescription) \n")
        Toast(text: "Error Occured when try to Unblock User ...").show()
    }
    
    @IBAction func followersButtonTapped(_ sender: Any)
    {
        if isUserBlocked() {
            self.showTaost(message: "Unblock user first")
            return
        }
        if (self.selectedBroadcaster_FollowersList.count == 0) {
            Toast(text: "No followers to show.").show()
            return
        }
        let storyboard = UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil)
        let followersViewController = storyboard.instantiateViewController(withIdentifier: "FollowersList_VC") as! FollowersList_VC
        followersViewController.followersList = self.selectedBroadcaster_FollowersList
        self.navigationController?.pushViewController(followersViewController, animated: false)
    }
    
    @IBAction func followingsButtonTapped(_ sender: Any)
    {
        if isUserBlocked() {
            self.showTaost(message: "Unblock user first")
            return
        }
        if (self.selectedBroadcaster_FollowingsList.count == 0) {
            Toast(text: "No followings to show.").show()
            return
        }
        let storyboard = UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil)
        let followingsViewController = storyboard.instantiateViewController(withIdentifier: "FollowingsList_VC") as! FollowingsList_VC
        followingsViewController.followingsList = self.selectedBroadcaster_FollowingsList
        self.navigationController?.pushViewController(followingsViewController, animated: false)
        //self.performSegue(withIdentifier: Constants.Segues.ProfileVC_to_FollowingsList_VC, sender: self)
    }
    
    @IBAction func broadcastsButtonTapped(_ sender: Any) {
    }
    
    @IBAction func button_editProfile_Tapped(_ sender: Any)
    {
        //self.performSegue(withIdentifier: Constants.Segues.ProfileVC_to_EditProfileVC, sender: self)
    }
    
    // MARK : - Update Video Counter
    func updatedVideoCpunter(videoObject: COVideo) {
        
        videoObject.viewers += 1
        let shSingeltonObject = DataAccess.sharedInstance
        shSingeltonObject.addOrUpdateVideo(videoObject, delegate: self as AddUpdateVideo_Protocol)
    }
    
    func updatedResponse(isSuccess: Bool , error: String, id: Int)
    {
        print("updated response :: ", isSuccess)
    }
}

extension FollowFollowingProfileViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return self.broadcastsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 15))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = (tableView.frame.size.height / 1.8)
        
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableView_Cells.streamsTableViewCell, for: indexPath) as! streamsTableViewCell
        
        let broadcast = self.broadcastsArray[indexPath.section]
        
        // set broadcast data
        let url1 = Utilities.getUserImage_URL(username: broadcast.broadcast)
        cell.image_thumbnail.sd_setImage(with: url1, placeholderImage: UIImage(named: Constants.imagesName.broadcastThumbNail_image))
        _ = Utilities.getUserImage_URL(username: broadcast.username)
        
        //        cell.image_broadcaster.sd_setImage(with: url2, placeholderImage: UIImage(named: Constants.imagesName.broadcaster_image))
        //        cell.image_broadcaster.image = cell.image_broadcaster.image?.circle
        
        cell.broadcast_name.text = broadcast.title
        cell.broadcaster_name.text = broadcast.name
        
        if broadcast.viewers < 0{
            cell.label_viewers.text = "0"
        }else{
            cell.label_viewers.text = "\(broadcast.viewers)"
        }
        
        
        cell.lblJobDescriptionUrl.attributedText = NSAttributedString(string: broadcast.jobDescriptionURL, attributes:
                                                                        [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
        
        if broadcast.jobDescriptionURL.isEmpty {
            cell.lblJobDescriptionUrl.frame.size.height = 0
        }
        
        //        cell.image_broadcaster.tag = indexPath.section
        //        cell.image_broadcaster.isUserInteractionEnabled = true
        //
        //        if (broadcast.status == Constants.VideoStatus.online) {
        //            cell.redContainer.isHidden = false
        //        } else {
        //            cell.redContainer.isHidden = true
        //        }
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    @objc func broadcasterImageTapped(sender: UITapGestureRecognizer)
    {
        let view = sender.view as! UIImageView
        print("\n broadcasterImageTapped with tag = \(view.tag) \n")
        
        let stream = self.broadcastsArray[view.tag]
        self.selectedStream = stream
        
        let u = CurrentUser.getCurrentUser_From_UserDefaults()
        if((u.username) != (self.selectedStream?.username)!)
        {
            self.performSegue(withIdentifier: Constants.Segues.HomeVC_to_BroadCaster_ProfileVC, sender: self)
        }
        else
        {
            print("\n Can't open my own profile ... \n")
            self.tabBarController?.selectedIndex = 0
            let firstNavContr = self.tabBarController?.viewControllers?.first as! UINavigationController
            firstNavContr.popToRootViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let stream = self.broadcastsArray[indexPath.section]
        self.selectedStream = stream
        
        let videoURLString = ""
        if (stream.status as String == Constants.VideoStatus.offline) {
            
            print("video url 4444", videoURLString)
            let vc =  UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil).instantiateViewController(withIdentifier: Constants.ViewControllers.VODWowzaViewController) as! VODWowzaViewController
            //vc.videoUrlString = videoURLString
            vc.currentVideo = stream
            self.present(vc, animated: true, completion: nil)
        }
        else if (stream.status as String == Constants.VideoStatus.online) {
            let storyboard = UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil)
            let liveViewerViewController = storyboard.instantiateViewController(withIdentifier: "LiveStreamingViewerController") as! LiveStreamingViewerController
            liveViewerViewController.currentVideo = stream
            self.present(liveViewerViewController, animated: true, completion: nil)
        }
    }
}
