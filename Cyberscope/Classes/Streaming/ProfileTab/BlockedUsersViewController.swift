//
//  BlockedUsersViewController.swift
//  SimX
//
//  Created by Apple on 27/02/2020.
//  Copyright © 2020 Agilio. All rights reserved.
//

import UIKit

class BlockedUsersViewController: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var button_cancel: UIButton!
    @IBOutlet weak var label_followers: UILabel!
    @IBOutlet weak var blockedUserTableView: UITableView!
    
    var blockedList: [BlockedUser] = CurrentUser.BlockedUsers_List_whichAreBlocked_byCurrentUser
    var selectedUserId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setup_Controls()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.blockedList = CurrentUser.BlockedUsers_List_whichAreBlocked_byCurrentUser
    }
    
    func setup_Controls()
    {
        if (self.blockedList.count == 0) {
            self.blockedList = CurrentUser.BlockedUsers_List_whichAreBlocked_byCurrentUser
        }
        
        self.blockedUserTableView.delegate = self
        self.blockedUserTableView.dataSource = self
        self.blockedUserTableView.tableFooterView = UIView()
        
        self.topView.setBorders(cornerRadius: 0.0, borderWidth: 0.5, borderColor: Constants.Colors.lightBorderColor_forCollectionCELLS.cgColor)
        self.blockedUserTableView.backgroundColor = UIColor.white
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
            if (self.navigationController == nil) {
                self.dismiss(animated: true, completion: nil)
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func button_cancelAction(_ sender: Any) {
        self.moveBack()
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == Constants.Segues.blockedToBroadcasterProfile)
        {
            if #available(iOS 13.0, *) {
                let nextVC = segue.destination as! FollowFollowingProfileViewController
                nextVC.selectedUserId = self.selectedUserId
            } else {
                // Fallback on earlier versions
            }
            
        }
    }
}

extension BlockedUsersViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.blockedList.count
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
        let newObject = self.blockedList[indexPath.row]
        cell.profileImage.sd_setImage(with: Utilities.getUserImage_URL(username: newObject.blockedid), placeholderImage: UIImage(named: Constants.imagesName.broadcaster_image))
        cell.profileImage.image = cell.profileImage.image?.circle
        
        cell.nameLabel.text = newObject.blockedname
        cell.jobTitle_Label.text = ""
        
        cell.checkIfYouFollowing(userId: newObject.userid)
        cell.backgroundColor = UIColor.white
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let newObject = self.blockedList[indexPath.row]
        self.selectedUserId = newObject.blockedid
        self.performSegue(withIdentifier: Constants.Segues.blockedToBroadcasterProfile, sender: self)
    }
}
