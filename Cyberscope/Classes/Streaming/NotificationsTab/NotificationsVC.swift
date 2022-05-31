//
//  NotificationsVC.swift
//  CyberScope
//
//  Created by Saad Furqan on 03/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import Toaster

class NotificationsVC: UIViewController, Add_Appointment_Delegate, Delete_Appointment_Delegate, QMChatServiceDelegate, QMChatConnectionDelegate, QMAuthServiceDelegate
{
    @IBOutlet weak var viewButtons: UIView!
    @IBOutlet weak var btnMessages: UIButton!
    @IBOutlet weak var btnAppointments: UIButton!
    @IBOutlet weak var messagesParentView: UIView!
    @IBOutlet weak var appointmentsParentView: UIView!
    @IBOutlet weak var lblMessages: UILabel!
    
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var appointmentsTableView: UITableView!
    
    var messages = ["Hi!", "there?", "its me..", "here..", "???"]
    var appointments_user_made = CurrentUser.Appointments_List_whichAreMade_byCurrentUser
    var appointments_inWhich_userAppointed = CurrentUser.Appointments_List_whoAppoint_CurrentUser
    
    var chatDialogues = [QBChatDialog]()
    var isMessagesSelected: Bool = true
    
    fileprivate let dataAccess = DataAccess.sharedInstance
    var panGesturedCell: user_Appointment_Cell?
    
    private var didEnterBackgroundDate: NSDate?
    var refreshControl = UIRefreshControl()
    var refreshControlAppointments = UIRefreshControl()
    
    override func awakeFromNib() {
        
        ServicesManager.instance().chatService.addDelegate(self)
        ServicesManager.instance().authService.add(self as QMAuthServiceDelegate)
        
        super.awakeFromNib()
        
        if (QBChat.instance.isConnected) {
            //self.fetchAllDialogues()
        }
    }
    
    @objc func didEnterBackgroundNotification() {
        self.didEnterBackgroundDate = NSDate()
    }
    
    @objc func refresh(sender:AnyObject) {
        if (QBChat.instance.isConnected) {
            //self.fetchAllDialogues()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .black
    }
    
    @objc func refreshAppoinments(sender:AnyObject) {
     
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.refreshControlAppointments.endRefreshing()
        })
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //self.add_OBSERVERS()
        self.setup_controls()
        
        //self.setUp_tableData()
        
        self.refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControlEvents.valueChanged)
        self.messagesTableView.addSubview(refreshControl) // not required when using UITableViewController
        
        self.refreshControlAppointments.addTarget(self, action: #selector(self.refreshAppoinments(sender:)), for: UIControlEvents.valueChanged)
        self.appointmentsTableView.addSubview(refreshControlAppointments)
        
        self.refreshControl.beginRefreshing()
        
        if (QBChat.instance.isConnected) {
            //self.fetchAllDialogues()
        }
        self.messagesTableView.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.setUp_tableData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.fetchAllDialogues()
        self.setupView()
    }
    
    func setupView()
    {
        btnMessages.layer.cornerRadius = btnMessages.frame.height / 2
        btnMessages.clipsToBounds = true
        
        btnAppointments.layer.cornerRadius = btnAppointments.frame.height / 2
        btnAppointments.clipsToBounds = true
        
        viewButtons.layer.cornerRadius = viewButtons.frame.height / 2
        viewButtons.layer.borderWidth = 1
        viewButtons.layer.borderColor = UIColor(red: 61/255, green: 71/255, blue: 133/255, alpha: 1).cgColor
    }
    
    deinit {
        //self.remove_OBSERVERS()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func add_OBSERVERS()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationsVC.setUp_tableData), name: Notification.Name(Constants.Notifications_name.update_appointments_tableView_data), object: nil)
    }
    
    func remove_OBSERVERS()
    {
        // Remove from all notifications being observed
        //NotificationCenter.default.removeObserver(self)
    }
    
    func setup_controls()
    {
        self.messagesTableView.delegate = self
        self.messagesTableView.dataSource = self
        self.messagesTableView.tableFooterView = UIView()
        
        self.appointmentsTableView.delegate = self
        self.appointmentsTableView.dataSource = self
        self.appointmentsTableView.tableFooterView = UIView()
        
        self.set_parentViews()
         
//        self.segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: CGFloat(10.0/255.0), green: CGFloat(73.0/255.0), blue: CGFloat(122.0/255.0), alpha: CGFloat(1.0))], for: .selected)
//        self.segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
    /*    if #available(iOS 13.0, *) {
            self.segmentControl.selectedSegmentTintColor = UIColor(red: CGFloat(10.0/255.0), green: CGFloat(73.0/255.0), blue: CGFloat(122.0/255.0), alpha: CGFloat(1.0))
            self.segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
            
            self.segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: CGFloat(10.0/255.0), green: CGFloat(73.0/255.0), blue: CGFloat(122.0/255.0), alpha: CGFloat(1.0))], for: .normal)
        } else {
            // Fallback on earlier versions
        }*/
    }
    
    @objc func setUp_tableData()
    {
        // if(tableView == appointmentsTableView){
        self.refreshAppointments()
        self.fetchAllDialogues()
    }
    
    func refreshAppointments() {
        // if(tableView == appointmentsTableView){
        self.appointments_user_made = CurrentUser.Appointments_List_whichAreMade_byCurrentUser
        self.appointments_inWhich_userAppointed = CurrentUser.Appointments_List_whoAppoint_CurrentUser
        DispatchQueue.main.async {
            self.appointmentsTableView.reloadData()
        }
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
//    @IBAction func segmentControl_Action(_ sender: Any)
//    {
//        self.set_parentViews()
//    }
    
    @IBAction func btnMessages_pressed(_ sender: Any) {
        
        btnMessages.backgroundColor = UIColor(red: 61/255, green: 71/255, blue: 133/255, alpha: 1)
        btnMessages.setTitleColor(UIColor.white, for: .normal)
        
        btnAppointments.backgroundColor = UIColor.white
        btnAppointments.setTitleColor(UIColor(red: 61/255, green: 71/255, blue: 133/255, alpha: 1), for: .normal)
        
        self.isMessagesSelected = true
        self.lblMessages.isHidden = false
        self.set_parentViews()
    }
    
    @IBAction func btnAppointments_pressed(_ sender: Any) {
        
        btnAppointments.backgroundColor = UIColor(red: 61/255, green: 71/255, blue: 133/255, alpha: 1)
        btnAppointments.setTitleColor(UIColor.white, for: .normal)
        
        btnMessages.backgroundColor = UIColor.white
        btnMessages.setTitleColor(UIColor(red: 61/255, green: 71/255, blue: 133/255, alpha: 1), for: .normal)
        
        self.lblMessages.isHidden = true
        self.isMessagesSelected = false
        self.set_parentViews()
    }
    
    func set_parentViews()
    {
        if(isMessagesSelected)
        {
            self.messagesParentView.isHidden = false
            self.appointmentsParentView.isHidden = true
        }
        else
        {
            self.messagesParentView.isHidden = true
            self.appointmentsParentView.isHidden = false
        }
    }
    
    // :--  *****************************************
    // Delete_Appointment_Delegate methods
    func Delete_Appointment_ResponseSuccess(senderTag: Int, id: Int) {
        print("\n Delete_Appointment_ResponseSuccess called ... AND id = \(id) \n")
        DispatchQueue.main.async {
        self.appointmentsTableView.reloadData()
        }
        DispatchQueue.main.async {
            
            NotificationCenter.default.post(name: Notification.Name(Constants.Notifications_name.getCurrentUser_Appointments_Data), object: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                self.refreshControlAppointments.endRefreshing()
                self.refreshAppointments()
            })
        }
    }
    
    func Delete_Appointment_ResponseError(error: NSError) {
        print("\n Delete_Appointment_ResponseError called ... AND error = \(error.localizedDescription) \n")
        self.refreshControlAppointments.endRefreshing()
        self.refreshAppointments()
    }
    
    // Add_Appointment_Delegate methods
    func Add_Appointment_ResponseSuccess(senderTag: Int, id: Int)
    {
        print("\n Add_Appointment_ResponseSuccess called ... AND id = \(id) \n")
        
        
        
        DispatchQueue.main.async {
            self.appointmentsTableView.reloadData()
            
            NotificationCenter.default.post(name: Notification.Name(Constants.Notifications_name.getCurrentUser_Appointments_Data), object: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                self.refreshControlAppointments.endRefreshing()
                self.refreshAppointments()
            })
        }
        
    }
    
    func Add_Appointment_ResponseError(error: NSError)
    {
        print("\n Add_Appointment_ResponseError called ... AND error = \(error.localizedDescription) \n")
        self.refreshControlAppointments.endRefreshing()
        self.refreshAppointments()
    }
    
    
    func isUserBlocked(userProfileName: String) -> Bool {
        let blockedUsers = CurrentUser.BlockedUsers_List_whichAreBlocked_byCurrentUser
        if (blockedUsers.count > 0) {
            for bUser in blockedUsers {
                if (bUser.blockedname == userProfileName) {
                    return true
                }
            }
            return false
        }
        else {
            return false
        }
    }
    
    func showTaost(message: String) {
        Toast(text: message).show()
    }
    
}

extension NotificationsVC: TableViewCellDelegate
{
    func hasPerformedSwipe(passedInfo: String, cell: user_Appointment_Cell)
    {
        print(passedInfo)
        if panGesturedCell == nil
        {
            panGesturedCell = cell
        }
        else
        {
            panGesturedCell?.leftSwipeCount = 0
            
            UIView.animate(withDuration: 0.5, animations: {
                cell.layoutIfNeeded()
            })
            panGesturedCell = cell
        }
    }
}

extension NotificationsVC: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if(tableView == self.appointmentsTableView)
        {
            if (self.appointments_inWhich_userAppointed.count == 0 && self.appointments_user_made.count == 0) {
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text          = "No data available"
                noDataLabel.textColor     = UIColor.lightGray
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
                
                return 0
            }
            tableView.backgroundView = nil
            return 2
        }
        else
        {
            if (self.chatDialogues.count == 0) {
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text          = "No data available"
                noDataLabel.textColor     = UIColor.lightGray
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
                
                return 0
            }
            tableView.backgroundView = nil
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(tableView == self.appointmentsTableView)
        {
            if(section == 0)
            {
                return self.appointments_inWhich_userAppointed.count
            }
            else
            {
                return self.appointments_user_made.count
            }
        }
        else
        {
            //            //SORT
            //            if let dialogs = self.dialogs() {
            //              self.chatDialogues = dialogs
            //                print("SORT")
            //                return chatDialogues.count
            //
            //               // return chatDialogues.count
            //            }
            //            return 0
            return self.chatDialogues.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if(tableView == self.appointmentsTableView)
        {
            return 50.0
        }
        else
        {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50.0)
        label.minimumScaleFactor = 0.7
        label.textAlignment = .left
        label.textColor = Constants.Colors.darkBlue_headings_themeColor
        label.backgroundColor = self.view.backgroundColor
        label.font = UIFont(name: "Raleway-Bold", size: 20.0)
        
        if(section == 0)
        {
            label.text = "Appointments You have"
        }
        else
        {
            label.text = "Appointments You made"
        }
        
        if(tableView == self.appointmentsTableView)
        {
            return label
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if(tableView == self.appointmentsTableView)
        {
            var height: CGFloat = (tableView.frame.size.height / 4)
            let minHeight: CGFloat = 140.0
            
            if(height < minHeight)
            {
                height = minHeight
            }
            
            return height
        }
        else
        {
            var height: CGFloat = (tableView.frame.size.height / 6)
            let minHeight: CGFloat = 75.0
            
            if(height < minHeight)
            {
                height = minHeight
            }
            
            return height
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if(tableView == self.appointmentsTableView)
        {
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if(tableView == self.appointmentsTableView)
        {
            var app: Appointment?
            if(indexPath.section == 0)
            {
                app = self.appointments_inWhich_userAppointed[indexPath.row]
            }
            else
            {
                app = self.appointments_user_made[indexPath.row]
            }
            let url1 = Utilities.getUserImage_URL(username: (app?.doctorId)!)
            let url2 = Utilities.getUserImage_URL(username: (app?.patientId)!)
            
            if(app?.status == Appointment_Status.accepted.rawValue)
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableView_Cells.user_AcceptedAppointment_Cell, for: indexPath) as! user_AcceptedAppointment_Cell
                cell.label_appointmentStatus.layer.cornerRadius = 5
                cell.label_appointmentStatus.clipsToBounds = true
                if(indexPath.section == 0) {
                    cell.label_appointmentTime.text = app?.time
                    cell.label_appointmentStatus.text = app?.status
                    cell.label_appointmentStatus.backgroundColor = UIColor(red: 11/255, green: 165/255, blue: 69/255, alpha: 1)
                    cell.label_appointmentDate.text = app?.date
                    cell.broadcaster_name.text = app?.patientName
                    cell.image_broadcaster.image = UIImage(named: "greenBg")
//                    cell.broadcast_name.text = app?.patientName
                    
//                    cell.image_thumbnail.sd_setImage(with: url2, placeholderImage: UIImage(named: Constants.imagesName.broadcastThumbNail_image))
                    
//                    cell.image_broadcaster.sd_setImage(with: url2, placeholderImage: UIImage(named: Constants.imagesName.broadcaster_image), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
//                        // Perform operation.
//                        if (error == nil) {
////                            cell.image_broadcaster.image = cell.image_broadcaster.image?.circle
//                        }
//                    })
                }
                else {
                    cell.label_appointmentTime.text = app?.time
                    cell.label_appointmentStatus.text = app?.status
                    cell.label_appointmentStatus.backgroundColor = UIColor(red: 11/255, green: 165/255, blue: 69/255, alpha: 1)
                    cell.label_appointmentDate.text = app?.date
                    cell.broadcaster_name.text = app?.doctorName
//                    cell.broadcast_name.text = app?.doctorName
                    
//                    cell.image_thumbnail.sd_setImage(with: url1, placeholderImage: UIImage(named: Constants.imagesName.broadcastThumbNail_image))
                    
//                    cell.image_broadcaster.sd_setImage(with: url1, placeholderImage: UIImage(named: Constants.imagesName.broadcaster_image), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
//                        // Perform operation.
//                        if (error == nil) {
////                            cell.image_broadcaster.image = cell.image_broadcaster.image?.circle
//                        }
//                    })
                }
                cell.backgroundColor = UIColor.white
                return cell
            }
            else if(app?.status == Appointment_Status.rejected.rawValue)
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableView_Cells.user_RejectedAppointment_Cell, for: indexPath) as! user_RejectedAppointment_Cell
                cell.image_broadcaster.image = UIImage(named: "redBg")
                cell.label_appointmentStatus.layer.cornerRadius = 5
                cell.label_appointmentStatus.clipsToBounds = true
                if(indexPath.section == 0) {
                    cell.label_appointmentTime.text = app?.time
                    cell.label_appointmentStatus.text = app?.status
                    cell.label_appointmentStatus.backgroundColor = UIColor(red: 223/255, green: 65/255, blue: 86/255, alpha: 1)
                    cell.label_appointmentDate.text = app?.date
                    cell.broadcaster_name.text = app?.patientName
                   
//                    cell.broadcast_name.text = app?.patientName
//
//                    cell.image_thumbnail.sd_setImage(with: url2, placeholderImage: UIImage(named: Constants.imagesName.broadcastThumbNail_image))
                    
//                    cell.image_broadcaster.sd_setImage(with: url2, placeholderImage: UIImage(named: Constants.imagesName.broadcaster_image), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
//                        // Perform operation.
//                        if (error == nil) {
////                            cell.image_broadcaster.image = cell.image_broadcaster.image?.circle
//                        }
//                    })
                }
                else {
                    cell.label_appointmentTime.text = app?.time
                    cell.label_appointmentStatus.text = app?.status
                    cell.label_appointmentStatus.backgroundColor = UIColor(red: 223/255, green: 65/255, blue: 86/255, alpha: 1)
                    cell.label_appointmentDate.text = app?.date
                    cell.broadcaster_name.text = app?.doctorName
                  
//                    cell.broadcast_name.text = app?.doctorName
//
//                    cell.image_thumbnail.sd_setImage(with: url1, placeholderImage: UIImage(named: Constants.imagesName.broadcastThumbNail_image))
                    
//                    cell.image_broadcaster.sd_setImage(with: url1, placeholderImage: UIImage(named: Constants.imagesName.broadcaster_image), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
//                        // Perform operation.
//                        if (error == nil) {
////                            cell.image_broadcaster.image = cell.image_broadcaster.image?.circle
//                        }
//                    })
                }
                cell.backgroundColor = UIColor.white
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableView_Cells.user_Appointment_Cell, for: indexPath) as! user_Appointment_Cell
                cell.label_appointmentStatus.layer.cornerRadius = 5
                cell.label_appointmentStatus.clipsToBounds = true
                
                if(indexPath.section == 0) {
                    cell.label_appointmentTime.text = app?.time
                    if (app?.status != "pending"){
                        cell.lblSwipeToRespond.isHidden = true
                    }
                    else
                    {
                        cell.lblSwipeToRespond.isHidden = false
                        cell.image_broadcaster.image = UIImage(named: "blackBg")
                    }
                    
                    cell.label_appointmentStatus.text = app?.status
                    cell.label_appointmentStatus.backgroundColor = UIColor(red: 112/255, green: 112/255, blue: 112/255, alpha: 1)
                    cell.label_appointmentDate.text = app?.date
                    cell.broadcaster_name.text = app?.patientName
                    
//                    cell.broadcast_name.text = app?.patientName
//                    cell.image_thumbnail.sd_setImage(with: url2, placeholderImage: UIImage(named: Constants.imagesName.broadcastThumbNail_image))
//                    cell.image_broadcaster.sd_setImage(with: url2, placeholderImage: UIImage(named: Constants.imagesName.broadcaster_image), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
//                        // Perform operation.
//                        if (error == nil) {
////                            cell.image_broadcaster.image = cell.image_broadcaster.image?.circle
//                        }
//                    })
                }
                else {
                    cell.label_appointmentTime.text = app?.time
                    cell.label_appointmentStatus.text = app?.status
                    cell.label_appointmentStatus.backgroundColor = UIColor(red: 112/255, green: 112/255, blue: 112/255, alpha: 1)
                    cell.label_appointmentDate.text = app?.date
                    cell.broadcaster_name.text = app?.doctorName
//                    cell.broadcast_name.text = app?.doctorName
//                    cell.image_thumbnail.sd_setImage(with: url1, placeholderImage: UIImage(named: Constants.imagesName.broadcastThumbNail_image))
//                    cell.image_broadcaster.sd_setImage(with: url1, placeholderImage: UIImage(named: Constants.imagesName.broadcaster_image), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
//                        // Perform operation.
//                        if (error == nil) {
////                            cell.image_broadcaster.image = cell.image_broadcaster.image?.circle
//                        }
//                    })
                }
                cell.backgroundColor = UIColor.white
                return cell
            }
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableView_Cells.messagesTableCell, for: indexPath) as! messagesTableCell
            
            let chatDialogue = self.chatDialogues[indexPath.row]
            print("chatDialogue--")
            print(chatDialogue)
            cell.name.text = chatDialogue.name
            cell.lastMessage.text = chatDialogue.lastMessageText
            if(chatDialogue.photo != nil)
            {
                cell.lastMessage.text = "Attachment"
            }
            cell.unreadMessagesCount.text = "\(chatDialogue.unreadMessagesCount)"
            //  cell.getImageNameForQBUser(qbid: chatDialogue.occupantIDs)
            if (chatDialogue.unreadMessagesCount == UInt(0)) {
                cell.unreadMessagesCount.isHidden = true
            }
            else if (self.isUserBlocked(userProfileName: chatDialogue.name ?? "no user found")) {
                cell.unreadMessagesCount.isHidden = true
             }
            else { // wriiten just for case of cell re-use
                cell.unreadMessagesCount.isHidden = false
            }
            
            
            
           

            
            
            //fetch images
            let users = chatDialogue.occupantIDs
            var userToFetch = UInt(0)
            if (users![0] == NSNumber(value: Int(CurrentUser.Current_UserObject.qbid) ?? 0)) {
                userToFetch = UInt(truncating: users![1])
            }
            else if (users![1] == NSNumber(value: Int(CurrentUser.Current_UserObject.qbid)!)) {
                userToFetch = UInt(truncating: users![0])
            }
            else {
                userToFetch = UInt(truncating: users![0])
            }
            cell.getImageNameForQBUser(qbid: userToFetch)
            
            if (chatDialogue.photo != nil && chatDialogue.photo != "") {
                let photoString = chatDialogue.photo
                let urlForChatImage = Utilities.getUserImage_URL(username: photoString!)
                cell.chatImage.sd_setImage(with: urlForChatImage, placeholderImage: UIImage(named: Constants.imagesName.broadcaster_image))
                //Utilities.getUserImage_URL(username: photoString)//UIImage(named: chatDialogue.photo!)
            }
            else {
                cell.chatImage.image = UIImage(named: Constants.imagesName.broadcaster_image)
            }
            cell.backgroundColor = UIColor.white
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        if(tableView == self.appointmentsTableView)
        {
            var app: Appointment?
            if(indexPath.section == 0)
            {
                app = self.appointments_inWhich_userAppointed[indexPath.row]
                
                if(app?.status == Appointment_Status.Pending.rawValue) {
                    return true
                }
                else {
                    return false
                }
            }
            else
            {
                //app = self.appointments_user_made[indexPath.row]
                return true // yes user can (delete) appointemnets they have made
            }
        }
        else
        {
            return false
        }
    }
    
 /*   func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        if(tableView == self.appointmentsTableView)
        {
            var app: Appointment?
            if(indexPath.section == 0)
            {
                app = self.appointments_inWhich_userAppointed[indexPath.row]
                
                if(app?.status == Appointment_Status.Pending.rawValue)
                {
                    let accept = UITableViewRowAction(style: .normal, title: "Accept") { action, index in
                        
                        print("Accept button tapped")
                        app?.status = Appointment_Status.accepted.rawValue
                        self.dataAccess.add_OR_update_Appointment(appointment: app!, delegate: self, senderTag: (app?.id)!)
                        
                        //self.appointmentsTableView.reloadData()
                        DispatchQueue.main.async {
                            self.refreshControlAppointments.beginRefreshing()
                        }
                    }
                    accept.backgroundColor = Constants.Colors.acceptAppointment_cellColor
                    
                    
                    let decline = UITableViewRowAction(style: .normal, title: "Reject") { action, index in
                        
                        print("Decline button tapped")
                        app?.status = Appointment_Status.rejected.rawValue
                        self.dataAccess.add_OR_update_Appointment(appointment: app!, delegate: self, senderTag: (app?.id)!)
                        
                        //self.appointmentsTableView.reloadData()
                        DispatchQueue.main.async {
                            self.refreshControlAppointments.beginRefreshing()
                        }
                    }
                    decline.backgroundColor = Constants.Colors.declineAppointment_cellColor
                    return [accept, decline]
                }
                else
                {
                    return nil
                }
            }
            else {
                // appointments you made
                app = self.appointments_user_made[indexPath.row]
                let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
                    print("Delete button tapped")
                    let otherAlert = UIAlertController(title: nil, message: "Are you sure you want to delete this appointment?", preferredStyle: .actionSheet)
                    let callFunction = UIAlertAction(title: "Yes", style: .default) { _ in

                        self.dataAccess.delete_Appointment(appointment: app!, delegate: self, senderTag: (app?.id)!)
                        DispatchQueue.main.async {
                            self.refreshControlAppointments.beginRefreshing()
                        }
                    }
                    let dismiss = UIAlertAction(title: "No", style: .default) { _ in
                        print("You canceled the action." )
                    }
                    // relate actions to controllers
                    otherAlert.addAction(callFunction)
                    otherAlert.addAction(dismiss)
                    
                    self.present(otherAlert, animated: true, completion: nil)
                }
                delete.backgroundColor = Constants.Colors.declineAppointment_cellColor
                
                return [delete]
                //app = self.appointments_user_made[indexPath.row]
                //return nil
            }
        }
        else {
            return nil
        }
    }*/
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if(tableView == self.appointmentsTableView)
        {
            var app: Appointment?
            if(indexPath.section == 0)
            {
                app = self.appointments_inWhich_userAppointed[indexPath.row]
                
                if(app?.status == Appointment_Status.Pending.rawValue)
                {
                    let acceptAction = UIContextualAction(style: .destructive, title: "Accept") { (action, sourceView, completionHandler) in
                        
                        print("Accept button tapped")
                        app?.status = Appointment_Status.accepted.rawValue
                        self.dataAccess.add_OR_update_Appointment(appointment: app!, delegate: self, senderTag: (app?.id)!)
                        
                        //self.appointmentsTableView.reloadData()
                        DispatchQueue.main.async {
                         //   self.refreshControlAppointments.beginRefreshing()
                        }
                        completionHandler(true)
                    }
                    acceptAction.backgroundColor = Constants.Colors.acceptAppointment_cellColor
                    
                    let rejectAction = UIContextualAction(style: .destructive, title: "Reject") { (action, sourceView, completionHandler) in
                        
                        print("Decline button tapped")
                        app?.status = Appointment_Status.rejected.rawValue
                        self.dataAccess.add_OR_update_Appointment(appointment: app!, delegate: self, senderTag: (app?.id)!)
                        
                        //self.appointmentsTableView.reloadData()
                        DispatchQueue.main.async {
                            self.refreshControlAppointments.beginRefreshing()
                        }
                        completionHandler(true)
                    }
                    rejectAction.backgroundColor = Constants.Colors.declineAppointment_cellColor
                    
                    let swipeAction = UISwipeActionsConfiguration(actions: [acceptAction, rejectAction])
                    swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
                    return swipeAction
                }
                else
                {
                    return nil
                }
            }
            else {
                // appointments you made
                app = self.appointments_user_made[indexPath.row]
                let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
                    print("Delete button tapped")
                    let otherAlert = UIAlertController(title: nil, message: "Are you sure you want to delete this appointment?", preferredStyle: .actionSheet)
                    let callFunction = UIAlertAction(title: "Yes", style: .default) { _ in

                        self.dataAccess.delete_Appointment(appointment: app!, delegate: self, senderTag: (app?.id)!)
                        DispatchQueue.main.async {
                            self.refreshControlAppointments.beginRefreshing()
                        }
                    }
                    let dismiss = UIAlertAction(title: "No", style: .default) { _ in
                        print("You canceled the action." )
                    }
                    // relate actions to controllers
                    otherAlert.addAction(callFunction)
                    otherAlert.addAction(dismiss)
                    
                    self.present(otherAlert, animated: true, completion: nil)
                    completionHandler(true)
                }
                deleteAction.backgroundColor = Constants.Colors.declineAppointment_cellColor
                
                let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
                swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
                return swipeAction
            }
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == messagesTableView {
            if let cell = tableView.cellForRow(at: indexPath) as? messagesTableCell {
                let chatDialogue = self.chatDialogues[indexPath.row]
                if (self.isUserBlocked(userProfileName: chatDialogue.name ?? "no user found")) {
                    self.showTaost(message: "You have blocked this user")
                    return
                }
                let newQMChateVC = ChatViewController()
                newQMChateVC.dialog = chatDialogue
                newQMChateVC.chatimage = cell.chatImage.image
                //let navController = UINavigationController(rootViewController: newQMChateVC)
                self.navigationController?.pushViewController(newQMChateVC, animated: true)
            }
            else {
                
            }
        }
//        //        if let cell = tableView.cellForRow(at: indexPath) as? user_Appointment_Cell
//        //        {
//        //            if(indexPath.section == 0) //&& (app?.status == Appointment_Status.Pending.rawValue))
//        //            {
//        //                cell.leftSwipeCount = 0
//        //                cell.leadingConstraintTopViewOutlet.constant = -8
//        //                cell.trailingConstraintActionViewOutlet.constant = -122
//        //                UIView.animate(withDuration: 0.5, animations: {
//        //                    cell.layoutIfNeeded()
//        //                })
//        //            }
//        //        }
    }
    
    func buttonAcceptTapped(tag: Int)
    {
        print("\n Button Accept Tapped for TAG: \(tag) \n")
        Toast(text: " Button Accept Tapped for Cell: \(tag) ").show()
    }
    
    func buttonDeclineTapped(tag: Int)
    {
        print("\n Button Decline Tapped for TAG: \(tag) \n")
        Toast(text: " Button Decline Tapped for Cell: \(tag) ").show()
    }
    
    //Sort dialogs accoridng to recent message to the top of list
    func dialogs() -> [QBChatDialog]? {
        
        // Returns dialogs sorted by updatedAt date.
        return ServicesManager.instance().chatService.dialogsMemoryStorage.dialogsSortByUpdatedAt(withAscending: false)
    }
    
    // MARK: - Quickblox Threads Fetch Methids
    func fetchAllDialogues() {
        let extendedRequest = ["sort_desc": "updated_at"]//["sort_desc" : CurrentUser.Current_UserObject.qbid]
        //let extendedRequest = ["sort_desc" : chatDialogues]
        
        let page = QBResponsePage(limit: 100, skip: 0)
        
        QBRequest.dialogs(for: page, extendedRequest: extendedRequest, successBlock: { (response: QBResponse, dialogs: [QBChatDialog]?, dialogsUsersIDs: Set<NSNumber>?, page: QBResponsePage?) -> Void in
            
            self.refreshControl.endRefreshing()
            print("dialogs are here")
            print(dialogs?.count)
            if ((dialogs?.count) != nil) {
                self.chatDialogues = dialogs!
                if self.messagesTableView == nil {
                    return
                }
                self.messagesTableView.reloadData()
            }
            else {
                Alert.showAlertWithMessageAndTitle(message: "No Chat Threads found", title: "Message!")
            }
            
        }) { (response: QBResponse) -> Void in
            
            self.refreshControl.endRefreshing()
            if (response.error == nil) {
                print("no dialogues found")
            }
            else {
                
            }
        }
    }
    
    func chatService(_ chatService: QMChatService, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog) {
        
        self.reloadTableViewIfNeeded()
    }
    
    
    func reloadTableViewIfNeeded() {
        self.fetchAllDialogues()
    }
}
