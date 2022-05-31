//
//  AccountSettingsVC.swift
//  CyberScope
//
//  Created by Saad Furqan on 11/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import AVKit
import FirebaseAuth

enum setting_actions: String
{
    case Blocked = "Blocked Users"
    case FAQs = "Frequently Asked Questions"
    case Terms_and_Conditions = "Terms and Conditions"
    case Privacy_Policy = "Privacy Policy"
    case Share_The_App = "Share App"
    case How_To_use = "How to use the app?"
    case LinkedinProfile = "Linkedin Profile"
    case Sign_out = "Signout"
}

class AccountSettingsVC: UIViewController
{
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var button_cancel: UIButton!
    @IBOutlet weak var label_settings: UILabel!
    @IBOutlet weak var actions_tableview: UITableView!
    
    var actionsList1: [String] = [setting_actions.Blocked.rawValue, setting_actions.FAQs.rawValue, setting_actions.Terms_and_Conditions.rawValue, setting_actions.Privacy_Policy.rawValue, setting_actions.Share_The_App.rawValue,setting_actions.LinkedinProfile.rawValue,setting_actions.Sign_out.rawValue,
    ]
    // setting_actions.How_To_use.rawValue,
    
    var actionsList2: [String] = [] //[setting_actions.Share_The_App.rawValue, setting_actions.Rate_The_App.rawValue, setting_actions.Send_Us_Feedback.rawValue]
    
    var actionsList3: [String] = [setting_actions.Sign_out.rawValue]
    
    var allActionsList: [[String]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Come in Account setings vc")
        self.setup_Controls()
    }

    func setup_Controls()
    {
        self.allActionsList = [actionsList1]// [actionsList1, actionsList2, actionsList3]
        
        self.actions_tableview.delegate = self
        self.actions_tableview.dataSource = self
        self.actions_tableview.tableFooterView = UIView()
        
        self.topView.setBorders(cornerRadius: 0.0, borderWidth: 0.5, borderColor: Constants.Colors.lightBorderColor_forCollectionCELLS.cgColor)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func moveBack()
    {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func button_cancelAction(_ sender: Any)
    {
        self.moveBack()
    }
    
    func unsubscribeQuickblox()
    {
        var subdIdsSet : Set<UInt> = []
        if let subsIds = UserDefaults.standard.object(forKey: "apns_subsciptionarray_simx_786") as? [UInt] {
            for subsId in subsIds {
                subdIdsSet.insert(subsId)
            }
        }
        if let subsIds2 = UserDefaults.standard.object(forKey: "apnsVoip_subsciptionarray_simx_786") as? [UInt] {
            for subsId in subsIds2 {
                subdIdsSet.insert(subsId)
            }
        }
        print("subscription Ids: ", subdIdsSet)
        subdIdsSet.forEach {(number) in
            QBRequest.deleteSubscription(withID: number, successBlock: nil, errorBlock: nil)
        }
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

extension AccountSettingsVC: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return self.allActionsList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.allActionsList[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        var height: CGFloat = (tableView.frame.size.height / 7)
        let minHeight: CGFloat = 75.0
        
        if(height < minHeight)
        {
            height = minHeight
        }
        
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1.0))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
     /*   if(indexPath.section == (self.allActionsList.count - 1))
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableView_Cells.settingsWithIconCell, for: indexPath) as! settingsWithIconCell
            
            cell.titleLabel.text = self.allActionsList[indexPath.section][indexPath.row]
            
            return cell
        }
        else
        {*/
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableView_Cells.settingsSimpleCell, for: indexPath) as! settingsSimpleCell

            cell.titleLabel.text = self.allActionsList[indexPath.section][indexPath.row]
            return cell
     //   }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let action = self.allActionsList[indexPath.section][indexPath.row]
        if(action == setting_actions.Sign_out.rawValue)
        {
            // Logout Current User
            Utilities.show_ProgressHud(view: self.view)
            
            CurrentUser.deSetCurrentUser_UserDefaults()
            CurrentUser.setCurrentUserStatus_as_LogOut()
            self.unsubscribeQuickblox()
            SignInViewController.LogOut_from_Facebook()
            SignInViewController.LogOut_from_Twitter()
            SignInViewController.LogOut_from_LinkedIn()
            SignInViewController.Logout_fromQB()
            UserDefaults.standard.removeObject(forKey: Constants.Twitter.TWITTER_Token)
            UserDefaults.standard.removeObject(forKey: Constants.Twitter.TWITTER_TokenSecret)
            
            do {
                try Auth.auth().signOut()
            }catch {
                print("already logged out")
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now()+2.0, execute: {
                
                Utilities.hide_ProgressHud(view: self.view)
                AppDelegate.shared_instance.goTo_Main_StoryBoard_afterLogout()
            })
        }
        else if (action == setting_actions.Terms_and_Conditions.rawValue) {
            let storyboard = UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil)
            let liveViewerViewController = storyboard.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
            self.present(liveViewerViewController, animated: true, completion: nil)
//            if let link = URL(string: "https://privacyauditors.co.uk/privacy-policy/") {
//                UIApplication.shared.open(link)
//            }
        }
        else if (action == setting_actions.Privacy_Policy.rawValue) {
            let storyboard = UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil)
            let liveViewerViewController = storyboard.instantiateViewController(withIdentifier: "PrivacyViewController") as! PrivacyViewController
            self.present(liveViewerViewController, animated: true, completion: nil)
        }
        else if (action == setting_actions.FAQs.rawValue) {
            let storyboard = UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil)
            let liveViewerViewController = storyboard.instantiateViewController(withIdentifier: "FAQsViewController") as! FAQsViewController
            self.present(liveViewerViewController, animated: true, completion: nil)
        }
        else if (action == setting_actions.Blocked.rawValue) {
            let storyboard = UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil)
            let blockedUsersList = storyboard.instantiateViewController(withIdentifier: "BlockedUsersViewController") as! BlockedUsersViewController
            blockedUsersList.blockedList = CurrentUser.BlockedUsers_List_whichAreBlocked_byCurrentUser
            self.present(blockedUsersList, animated: true, completion: nil)
        }
        else if (action == setting_actions.Share_The_App.rawValue) {
            self.shareChatterboxApp()
        }
        else if (action == setting_actions.How_To_use.rawValue) {
            self.HowToUse()
        }
        else if (action == setting_actions.LinkedinProfile.rawValue) {
            self.showLinkedinProfile()
        }
        else
        {}
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .black
    }
    
    func HowToUse(){
        let videoURLString = "\(Constants.Stream_URLs.videoBaseLink)Other/demo.mp4"
        self.playThisVideoInAVPlayer(videoFileURLString: videoURLString)
    }
    
    func showLinkedinProfile(){
        let current_UserData = CurrentUser.getCurrentUser_From_UserDefaults()
       // let linkedinProfileLink = "https://linkedin.com/in/" + current_UserData.link
        let linkedinProfileLink = current_UserData.link
        print("linkedinProfileLink",current_UserData.link)
        if let link = URL(string: linkedinProfileLink) {
            UIApplication.shared.open(link)
        }
    }
    
    

    
    func shareChatterboxApp() {
        
        // grab an item we want to share
        //https://apps.apple.com/us/app/SimX/id1387163430
        //let appStoreLink = "https://itunes.apple.com/us/app/chaterbox-livestream/id1387163430?mt=8"
       // let appStoreLink = "https://apps.apple.com/us/app/SimX/id1387163430"
        let appStoreLink = "https://apps.apple.com/us/app/h2startup/id1387163430"
        //let playStoreLinkToChatPesa = "https://itunes.apple.com/us/app/chaterbox-livestream/id1387163430?mt=8"
        // as [Any]
        
        //let items = ["Download chatpesa app to chat and earn instant money.\n", "App Store (Apple):\n", appStoreLinkToChatPesa, "Play Store (Android):\n", playStoreLinkToChatPesa]
        let items = ["Download Scottish Health\n\n", "App Store (Apple):\n", NSURL(string: appStoreLink) ?? appStoreLink] as [Any]
        
        // build an activity view controller
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // exclude several items
        let excluded = [UIActivityType.print, UIActivityType.airDrop, UIActivityType.openInIBooks]
        controller.excludedActivityTypes = excluded
        
        // and present it
        self.present(controller, animated: true, completion: nil)
    }
}

//https://itunes.apple.com/us/app/chaterbox-livestream/id1387163430?mt=8


extension UserDefaults {

    enum Keys: String, CaseIterable {

        case unitsNotation
        case temperatureNotation
        case allowDownloadsOverCellular

    }

    func reset() {
        Keys.allCases.forEach { removeObject(forKey: $0.rawValue) }
    }

}
