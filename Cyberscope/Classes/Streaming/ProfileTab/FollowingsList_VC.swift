//
//  FollowingList_VC.swift
//  CyberScope
//
//  Created by Saad Furqan on 09/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit

class FollowingsList_VC: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var button_cancel: UIButton!
    @IBOutlet weak var label_followings: UILabel!
    @IBOutlet weak var followings_tableview: UITableView!
    
    var followingsList: [Follower] = []
    
    var selectedUserId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup_Controls()
    }

    func setup_Controls()
    {
        if (self.followingsList.count == 0) {
            self.followingsList = CurrentUser.CurrentUser_Followings_List
        }
        
        self.followings_tableview.delegate = self
        self.followings_tableview.dataSource = self
        self.followings_tableview.tableFooterView = UIView()
        
        self.topView.setBorders(cornerRadius: 0.0, borderWidth: 0.5, borderColor: Constants.Colors.lightBorderColor_forCollectionCELLS.cgColor)
        self.followings_tableview.backgroundColor = UIColor.white
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .black
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
        if(segue.identifier == Constants.Segues.followingsToBroadcasterProfile)
        {
            let nextVC = segue.destination as! FollowFollowingProfileViewController
            nextVC.selectedUserId = self.selectedUserId
        }
    }
}

extension FollowingsList_VC: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.followingsList.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableView_Cells.followingsTableViewCell, for: indexPath) as! followingsTableViewCell
        
        let newObject = self.followingsList[indexPath.row]
        cell.profileImage.sd_setImage(with: Utilities.getUserImage_URL(username: newObject.followerid), placeholderImage: UIImage(named: Constants.imagesName.broadcaster_image))
        cell.profileImage.image = cell.profileImage.image?.circle
        
        cell.nameLabel.text = newObject.followername
        cell.jobTitle_Label.text = ""
        
        cell.checkIfYouFollowing(userId: newObject.followerid)
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let currentUser = CurrentUser.getCurrentUser_From_UserDefaults()
        let newObject = self.followingsList[indexPath.row]
        
        if newObject.followerid == currentUser.username {
            return
        }
        
        self.selectedUserId = newObject.followerid
        self.performSegue(withIdentifier: Constants.Segues.followingsToBroadcasterProfile, sender: self)
    }
}

