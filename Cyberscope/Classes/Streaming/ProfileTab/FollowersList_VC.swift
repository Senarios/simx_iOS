//
//  FollowersList_VC.swift
//  CyberScope
//
//  Created by Saad Furqan on 09/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit

class FollowersList_VC: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var button_cancel: UIButton!
    @IBOutlet weak var label_followers: UILabel!
    @IBOutlet weak var followers_tableview: UITableView!
    
    var followersList: [Follower] = []
    
    var selectedUserId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup_Controls()
    //    self.getFollowersList()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    func setup_Controls()
    {
        if (self.followersList.count == 0) {
            self.followersList = CurrentUser.CurrentUser_Followers_List
        }
        
        self.followers_tableview.delegate = self
        self.followers_tableview.dataSource = self
        self.followers_tableview.tableFooterView = UIView()
        
        self.topView.setBorders(cornerRadius: 0.0, borderWidth: 0.5, borderColor: Constants.Colors.lightBorderColor_forCollectionCELLS.cgColor)
        self.followers_tableview.backgroundColor = UIColor.white
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .black
    }
    
    // MARK: - API Methods
    
    func getFollowersList() 
    {
        let sessionObject = DataAccess.sharedInstance
     //   sessionObject.getMyFollowersList(self as MyJobApplicationsDelegate, broadcastName: self.selectedStream!.broadcast)
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
            if self.isModal {
                self.dismiss(animated: true, completion: nil)
            }
            else
            {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func button_cancelAction(_ sender: Any)
    {
        self.moveBack()
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == Constants.Segues.followerToBroadcasterProfile)
        {
            let nextVC = segue.destination as! FollowFollowingProfileViewController
            nextVC.selectedUserId = self.selectedUserId
        }
    }
}

extension FollowersList_VC: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.followersList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        var height: CGFloat = (tableView.frame.size.height / 6)
        let minHeight: CGFloat = 75.0
        
        if(height < minHeight)
        {
            height = minHeight
        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableView_Cells.followersTableViewCell, for: indexPath) as! followersTableViewCell
        let newObject = self.followersList[indexPath.row]
        cell.profileImage.sd_setImage(with: Utilities.getUserImage_URL(username: newObject.userid), placeholderImage: UIImage(named: Constants.imagesName.broadcaster_image))
        cell.profileImage.image = cell.profileImage.image?.circle
        
        cell.nameLabel.text = newObject.username
        cell.jobTitle_Label.text = ""
        
        cell.checkIfYouFollowing(userId: newObject.userid)
        cell.backgroundColor = UIColor.white
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let currentUser = CurrentUser.getCurrentUser_From_UserDefaults()
        let newObject = self.followersList[indexPath.row]
//        
//        if newObject.followerid == currentUser.username {
//            return
//        }
        
        self.selectedUserId = newObject.userid
        self.performSegue(withIdentifier: Constants.Segues.followerToBroadcasterProfile, sender: self)
    }
}

