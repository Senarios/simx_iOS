//
//  ChatViewController.swift
//  CyberScope
//
//  Created by SaMee on 05/06/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import CoreTelephony
import SafariServices
import Foundation

var messageTimeDateFormatter: DateFormatter {
    struct Static {
        static let instance : DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        }()
    }
    
    return Static.instance
}

extension String {
    var length: Int {
        return (self as NSString).length
    }
}

class ChatViewController: QMChatViewController, QMChatServiceDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QMChatAttachmentServiceDelegate, QMChatConnectionDelegate, QMChatCellDelegate, QMDeferredQueueManagerDelegate, QMPlaceHolderTextViewPasteDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    
    let maxCharactersNumber = 1024 // // 0 - unlimited
    
    var failedDownloads: Set<String> = []
    var dialog: QBChatDialog!
    var chatimage: UIImage!
    var willResignActiveBlock: AnyObject?
    var attachmentCellsMap: NSMapTable<AnyObject, AnyObject>!
    var detailedCells: Set<String> = []
    var vhight = CGFloat(0.0)
    let screenSize: CGRect = UIScreen.main.bounds
    let window = UIApplication.shared.keyWindow!
    
    
    
    var typingTimer: Timer?
    var popoverController: UIPopoverController?
    
    lazy var imagePickerViewController : UIImagePickerController = {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.delegate = self
        
        return imagePickerViewController
    }()
    
    var unreadMessages: [QBChatMessage]?
    var simxUser: User = User()
    var callOnly = ""
    var both = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(callOnly, both)
        //safe area check if iOS 11 above
        // let screenSize: CGRect = UIScreen.main.bounds
        if #available(iOS 11.0, *) {
            vhight = window.safeAreaInsets.bottom
            if(vhight == 0.0)
            {
                vhight = 12.0
            }
        } else {
            vhight = 12.0
            // Fallback on earlier versions
        }
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        let qid = UserDefaults.standard.string(forKey: Constants.CurrentUser_UserDefaults.qbid)
        
        var UsersIDData = self.dialog.occupantIDs
        if let index = UsersIDData!.firstIndex(of: NSNumber(value: UInt(qid!) ?? 0)) {
            UsersIDData!.remove(at: index)
        }
        if UsersIDData!.count > 0 {
            let lQBId = UsersIDData?[0]
            self.getuserDataByQBID(qbId: "\(lQBId!)")
        }
        else
        {
            if self.dialog.userID > 0 {
                // self.getuserDataByID(qbId: "\(self.dialog.userID)")
                self.getuserDataByID(qbId: "\(self.dialog.name!)")
            }
        }
        
        
        /*  if UsersIDData!.count > 0{
         let lData = UsersIDData?[0]
         self.getuserDataByID(qbId: "\(lData!)")
         }*/
        
        
        
        
        
        
        //top bar on chat view controller
        self.toptitleview()
        
        //  self.setNavigationBar()
        /** Add theLabel to the ViewControllers view */
        
        //right swipe
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        //back button
        // addBackButton()
        
        // top layout inset for collectionView
        self.topContentAdditionalInset = self.navigationController!.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height;
        //        print(UIApplication.shared.statusBarFrame.size.height - 10)
        //        print(self.navigationController!.navigationBar.frame.size.height)
        
        
        view.backgroundColor = UIColor(red: 243.0/255.0, green: 248.0/255.0, blue: 254.0/255.0, alpha: 1.0)
        self.collectionView?.backgroundColor = .clear
        
        let currentUser:QBUUser = ServicesManager.instance().currentUser 
        self.senderID = currentUser.id
        self.senderDisplayName = currentUser.fullName!
        print(self.senderDisplayName)
        
        ServicesManager.instance().chatService.addDelegate(self)
        ServicesManager.instance().chatService.chatAttachmentService.addDelegate(self)
        
        self.updateTitle()
        
        self.inputToolbar?.contentView?.backgroundColor = UIColor.white
        self.inputToolbar?.contentView?.textView?.placeHolder = "Type Something"
        
        self.attachmentCellsMap = NSMapTable(keyOptions: NSPointerFunctions.Options.strongMemory, valueOptions: NSPointerFunctions.Options.weakMemory)
        
        if self.dialog.type == QBChatDialogType.private {
            
            self.dialog.onUserIsTyping = {
                [weak self] (userID)-> Void in
                
                if ServicesManager.instance().currentUser.id == userID {
                    return
                }
                
                self?.title = self?.dialog.name
            }
            
            self.dialog.onUserStoppedTyping = {
                [weak self] (userID)-> Void in
                
                if ServicesManager.instance().currentUser.id == userID {
                    return
                }
                
                self?.updateTitle()
            }
        }
        
        // Retrieving messages
        let messagesCount = self.storedMessages()?.count
        if (messagesCount == 0) {
            //self.startSpinProgress()
        }
        else if (self.chatDataSource.messagesCount() == 0) {
            self.chatDataSource.add(self.storedMessages()!)
        }
        
        self.loadMessages()
        
        self.enableTextCheckingTypes = NSTextCheckingAllTypes
        //}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.queueManager().add(self)
        
        self.willResignActiveBlock = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: nil) { [weak self] (notification) in
            
            self?.fireSendStopTypingIfNecessary()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //
        
        // Saving current dialog ID.
        ServicesManager.instance().currentDialogID = self.dialog.id!
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let willResignActive = self.willResignActiveBlock {
            NotificationCenter.default.removeObserver(willResignActive)
        }
        
        // Resetting current dialog ID.
        ServicesManager.instance().currentDialogID = ""
        
        // clearing typing status blocks
        self.dialog.clearTypingStatusBlocks()
        
        self.queueManager().remove(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //        if let chatInfoViewController = segue.destination as? ChatUsersInfoTableViewController {
        //            chatInfoViewController.dialog = self.dialog
        //        }
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    //
    //    func setNavigationBar() {
    //        let screenSize: CGRect = UIScreen.main.bounds
    //        let window = UIApplication.shared.keyWindow!
    //        var viewHeight = CGFloat(0.0)
    //        if #available(iOS 11.0, *) {
    //             viewHeight = window.frame.size.height - window.safeAreaInsets.bottom
    //            print(viewHeight)
    //        } else {
    //            // Fallback on earlier versions
    //        }
    //        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 0))
    //        let navItem = UINavigationItem(title: "Hey")
    //        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: #selector(done))
    //        UINavigationBar.appearance().barTintColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    //        UINavigationBar.appearance().backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    //        navItem.leftBarButtonItem = doneItem
    //        navBar.setItems([navItem], animated: false)
    //        self.view.addSubview(navBar)
    //    }
    //
    //    @objc func done() { // remove @objc for Swift 3
    //
    //    }
    //
    
    func toptitleview(){
        // let window = UIApplication.shared.keyWindow!
        
        //        var vhight = CGFloat(0.0)
        //        let screenSize: CGRect = UIScreen.main.bounds
        //        if #available(iOS 11.0, *) {
        //            vhight = window.safeAreaInsets.bottom
        //        } else {
        //            // Fallback on earlier versions
        //        }
        
        let myNewView = UIView(frame: CGRect(x: 0, y: vhight + 5, width: screenSize.width, height: screenSize.height/10))
        // Change UIView background colour
        print(vhight)
        myNewView.backgroundColor = UIColor.white
        
        // Add rounded corners to UIView
        // myNewView.layer.cornerRadius=25
        
        // Add border to UIView
        myNewView.layer.borderWidth=0
        
        // Change UIView Border Color to Red
        // myNewView.layer.borderColor = UIColor.red.cgColor
        
        // Add UIView as a Subview
        self.view.addSubview(myNewView)
        
        
        let viewHeight = vhight + 8
        
        let btnBack = UIButton(frame: CGRect(x: 10, y: viewHeight, width: 35, height: 35))
        btnBack.backgroundColor = .clear
        btnBack.setImage(UIImage(named: "btnBack_message"), for: .normal)
        btnBack.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        myNewView.addSubview(btnBack)
        btnBack.center = CGPoint(x: (btnBack.frame.width / 2) + 10,
                                 y: myNewView.frame.size.height / 2)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        
        var imageView : UIImageView
        imageView  = UIImageView(frame:CGRect(x: 60, y:viewHeight - 4, width: 40, height:40));
        print("vhight ", vhight)
        imageView.image = self.chatimage!
        //make image circular
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        myNewView.addSubview(imageView)
        imageView.center = CGPoint(x: (imageView.frame.width / 2) + 60,
                                   y: myNewView.frame.size.height / 2)
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        
        let lbl = UILabel(frame: CGRect(x: imageView.frame.size.width + 65, y: viewHeight, width: screenSize.width/1.5, height: 32))
        print(screenSize.width/2)
        lbl.textAlignment = .left//For center alignment
        lbl.text = self.dialog.name//"Sulman"
        lbl.textColor = UIColor.black //UIColor(red: 10.0/255.0, green: 73.0/255.0, blue: 121.0/255.0, alpha: 1.0)
        lbl.font = UIFont (name: "Raleway-SamiBold", size: 22.0)
        //  lbl.font = UIFont.boldSystemFont(ofSize: 32.0)
        //        lbl.numberOfLines = 1
        lbl.adjustsFontSizeToFitWidth = true
        //        lbl.sizeToFit()
        myNewView.addSubview(lbl)
        lbl.center = CGPoint(x: (lbl.frame.width / 2) + imageView.frame.size.width + 65,
                             y: myNewView.frame.size.height / 2)
        
        let btnCall = UIButton(frame: CGRect(x: screenSize.width - 95 , y: viewHeight + 2, width: 30, height: 30))
        if callOnly == "true" || both == "true"{
            btnCall.backgroundColor = .clear
            btnCall.setImage(UIImage(named: "btnCall"), for: .normal)
            btnCall.addTarget(self, action: #selector(callButtonClicked), for: .touchUpInside)
            myNewView.addSubview(btnCall)
            btnCall.center = CGPoint(x: (btnCall.frame.width / 2) + screenSize.width - 95,
                                     y: myNewView.frame.size.height / 2)
        }else{
            btnCall.isHidden = true
        }
        
        
        let btnInfo = UIButton(frame: CGRect(x: screenSize.width - 45, y: viewHeight + 2, width: 30, height: 30))
        btnInfo.backgroundColor = .clear
        btnInfo.setImage(UIImage(named: "info"), for: .normal)
        btnInfo.addTarget(self, action: #selector(infoButtonClicked), for: .touchUpInside)
        myNewView.addSubview(btnInfo)
        btnInfo.center = CGPoint(x: (btnInfo.frame.width / 2) + screenSize.width - 45,
                                 y: myNewView.frame.size.height / 2)
        
    }
    
    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {
        print("didTapView Button tapped")
        var streamData = COVideo()
        streamData.username = self.simxUser.username
        streamData.name = self.simxUser.name
        streamData.id = 1
        
        if self.simxUser.qbid.count > 0 {
            let storyBoard: UIStoryboard = UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil)
            if #available(iOS 13.0, *) {
                let nextVC = storyBoard.instantiateViewController(withIdentifier: Constants.ViewControllers.BroadCaster_ProfileVC) as! BroadCaster_ProfileVC
                nextVC.selectedStream = streamData
                nextVC.selectedBroadcaster = self.simxUser
                self.navigationController?.pushViewController(nextVC, animated: true)
            } else {
                // Fallback on earlier versions
            }
            
            // self.present(nextVC, animated: true, completion: nil)
        }
    }
    
    @objc func backButtonClicked(sender: UIButton!) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func callButtonClicked(sender: UIButton!) {
        print("Call Button tapped")
        if self.simxUser.qbid.count > 0 {
            DispatchQueue.main.async {
                
                //if(CurrentUser.Current_UserObject.credit <= 0){
                    let storyBoard: UIStoryboard = UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil)
                    let nextVC = storyBoard.instantiateViewController(withIdentifier: Constants.ViewControllers.selectCallTypeVC) as! selectCallTypeVC
                    
                    AppDelegate.QB_VideoChat_opponetUser = self.simxUser
                    
                    self.present(nextVC, animated: true, completion: nil)
               // }
//                else{
////                    let refreshAlert = UIAlertController(title: "Insufficient Balance", message: "You have Insufficient Balance to make this call, do you want to recharge your account right now?", preferredStyle: UIAlertController.Style.alert)
//                    
////                    refreshAlert.addAction(UIAlertAction(title: "NO", style: .default, handler: { (action: UIAlertAction!) in
////                        print("Handle Ok logic here")
////                    }))
//                    
//                   // refreshAlert.addAction(UIAlertAction(title: "YES", style: .cancel, handler: { (action: UIAlertAction!) in
//                        print("Handle Cancel Logic here")
//                        let storyBoard: UIStoryboard = UIStoryboard(name: Constants.StoryBoards.Payments, bundle: nil)
//                        let nextVC = storyBoard.instantiateViewController(withIdentifier: "AddPaymentCredits") as! Purchaseplan
//                        
//                        AppDelegate.QB_VideoChat_opponetUser = self.simxUser
//                        
//                        self.present(nextVC, animated: true, completion: nil)
//                        //refreshAlert .dismiss(animated: true, completion: nil)
//                    //}))
//                    
//                    //self.present(refreshAlert, animated: true, completion: nil)
//                }
            }
        }
    }
    
    @objc func infoButtonClicked(sender: UIButton!) {
        print("Info Button tapped")
        var streamData = COVideo()
        streamData.username = self.simxUser.username
        streamData.name = self.simxUser.name
        streamData.id = 1
        
        if self.simxUser.qbid.count > 0 {
            let storyBoard: UIStoryboard = UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil)
            if #available(iOS 13.0, *) {
                let nextVC = storyBoard.instantiateViewController(withIdentifier: Constants.ViewControllers.BroadCaster_ProfileVC) as! BroadCaster_ProfileVC
                nextVC.selectedStream = streamData
                nextVC.selectedBroadcaster = self.simxUser
                self.navigationController?.pushViewController(nextVC, animated: true)
            } else {
                // Fallback on earlier versions
            }
            
            // self.present(nextVC, animated: true, completion: nil)
        }
        
    }
    
    //    func backAction() -> Void {
    //        self.navigationController?.popViewController(animated: true)
    //    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                self.navigationController?.popViewController(animated: true)
                break
            default:
                break
            }
        }
    }
    
    //    func addBackButton() {
    //        let backButton = UIButton(type: .custom)
    //        backButton.setImage(UIImage(named: "BackButton.png"), for: .normal) // Image can be downloaded from here below link
    //        backButton.setTitle("Back", for: .normal)
    //        backButton.setTitleColor(backButton.tintColor, for: .normal) // You can change the TitleColor
    //        backButton.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
    //
    //        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    //    }
    //
    //    @IBAction func backAction(_ sender: UIButton) {
    //        let _ = self.navigationController?.popViewController(animated: true)
    //    }
    
    
    /**
     * Called when the user click on the view (outside the UITextField).
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // MARK: Update
    
    func updateTitle() {
        
        if self.dialog.type != QBChatDialogType.private {
            
            self.title = self.dialog.name
        }
        else {
            
            if let recipient = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(self.dialog!.recipientID)) {
                
                self.title = recipient.login
            }
        }
    }
    
    func storedMessages() -> [QBChatMessage]? {
        //        if (self.dialog.id != nil){
        return ServicesManager.instance().chatService.messagesMemoryStorage.messages(withDialogID: self.dialog.id!)
        //        }
        
    }
    
    func loadMessages() {
        // Retrieving messages for chat dialog ID.
        guard let currentDialogID = self.dialog.id else {
            print ("Current chat dialog is nil")
            return
        }
        
        
        
        do {
            try ServicesManager.instance().chatService.messages(withChatDialogID: currentDialogID, completion: {
                [weak self] (response, messages) -> Void in
                
                guard let strongSelf = self else { return }
                
                guard response.error == nil else {
                    Alert.showAlertWithMessageAndTitle(message: (response.error?.error?.localizedDescription)!, title: "")
                    //SVProgressHUD.showError(withStatus: response.error?.error?.localizedDescription)
                    return
                }
                
                if messages?.count ?? 0 > 0 {
                    if !(self?.progressView?.isHidden)! {
                        self?.stopSpinProgress()
                    }
                    strongSelf.chatDataSource.add(messages)
                }
                //SVProgressHUD.dismiss()
            })
        }
        catch {
            // Couldn't create audio player object, log the error
            print("Couldn't load messages")
        }
    }
    
    func sendReadStatusForMessage(message: QBChatMessage) {
        
        guard QBSession.current.currentUser != nil else {
            return
        }
        guard message.senderID != QBSession.current.currentUser?.id else {
            return
        }
        
        if self.messageShouldBeRead(message: message) {
            
            ServicesManager.instance().chatService.loadDialog(withID: message.dialogID!, completion: {(error) -> Void in
                ServicesManager.instance().chatService.read(message, completion: { (error) -> Void in
                    
                    guard error == nil else {
                        print("Problems while marking message as read! Error: %@", error!)
                        return
                    }
                    
                    if UIApplication.shared.applicationIconBadgeNumber > 0 {
                        let badgeNumber = UIApplication.shared.applicationIconBadgeNumber
                        UIApplication.shared.applicationIconBadgeNumber = badgeNumber - 1
                    }
                })
            })
        }
    }
    
    func messageShouldBeRead(message: QBChatMessage) -> Bool {
        
        let currentUserID = NSNumber(value: QBSession.current.currentUser!.id as UInt)
        
        return !message.isDateDividerMessage
            && message.senderID != self.senderID
            && !(message.readIDs?.contains(currentUserID))!
    }
    
    func readMessages(messages: [QBChatMessage]) {
        
        if QBChat.instance.isConnected {
            
            ServicesManager.instance().chatService.read(messages, forDialogID: self.dialog.id!, completion: nil)
        }
        else {
            
            self.unreadMessages = messages
        }
        
        var messageIDs = [String]()
        
        for message in messages {
            messageIDs.append(message.id!)
        }
    }
    
    // MARK: Actions
    
    override func didPickAttachmentImage(_ image: UIImage!) {
        
        let message = QBChatMessage()
        message.senderID = self.senderID
        message.dialogID = self.dialog.id
        message.dateSent = Date()
        
        DispatchQueue.global().async { [weak self] () -> Void in
            
            guard let strongSelf = self else { return }
            
            var newImage : UIImage! = image
            //            if strongSelf.imagePickerViewController.sourceType == UIImagePickerControllerSourceType.camera {
            //                newImage = newImage.fixOrientation()
            //            }
            
            let largestSide = newImage.size.width > newImage.size.height ? newImage.size.width : newImage.size.height
            let scaleCoeficient = largestSide/560.0
            let newSize = CGSize(width: newImage.size.width/scaleCoeficient, height: newImage.size.height/scaleCoeficient)
            
            // create smaller image
            
            UIGraphicsBeginImageContext(newSize)
            
            newImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            // Sending attachment.
            DispatchQueue.main.async(execute: {
                self?.chatDataSource.add(message)
                // sendAttachmentMessage method always firstly adds message to memory storage
                ServicesManager.instance().chatService.sendAttachmentMessage(message, to: self!.dialog, withAttachmentImage: resizedImage!, completion: {
                    [weak self] (error) -> Void in
                    
                    self?.attachmentCellsMap.removeObject(forKey: message.id as AnyObject?)
                    
                    guard error != nil else { return }
                    
                    self?.chatDataSource.delete(message)
                })
            })
        }
    }
    
    //WITHOUT MEDIA FILE
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: UInt, senderDisplayName: String!, date: Date!) {
        
        if !self.queueManager().shouldSendMessagesInDialog(withID: self.dialog.id!) {
            return
        }
        self.fireSendStopTypingIfNecessary()
        
        let message = QBChatMessage()
        message.text = text
        message.senderID = self.senderID
        message.deliveredIDs = [(NSNumber(value: self.senderID))]
        message.readIDs = [(NSNumber(value: self.senderID))]
        message.markable = true
        message.dateSent = date
        
        self.sendMessage(message: message)
    }
    
    //WITH MEDIA FILE
    override func didPressSend(_ button: (UIButton?), withTextAttachments textAttachments: [Any], senderId: UInt, senderDisplayName: (String?), date: Date) {
        
        if let attachment = textAttachments.first as? NSTextAttachment {
            
            if (attachment.image != nil) {
                let message = QBChatMessage()
                message.senderID = self.senderID
                message.dialogID = self.dialog.id
                message.dateSent = Date()
                ServicesManager.instance().chatService.sendAttachmentMessage(message, to: self.dialog, withAttachmentImage: attachment.image!, completion: {
                    [weak self] (error: Error?) -> Void in
                    
                    self?.attachmentCellsMap.removeObject(forKey: message.id as AnyObject?)
                    
                    guard error != nil else { return }
                    
                    // perform local attachment message deleting if error
                    ServicesManager.instance().chatService.deleteMessageLocally(message)
                    
                    self?.chatDataSource.delete(message)
                    
                })
                
                self.finishSendingMessage(animated: true)
            }
        }
    }
    
    func sendMessage(message: QBChatMessage) {
        
        // Sending message.
        // ServicesManager.instance().chatService.send(message, toDialogID: self.dialog.id!, saveToHistory: true, saveToStorage: true)
        //ADDING QMMESSAGE.TYPE
        ServicesManager.instance().chatService.send(message, type: QMMessageType.text, to: self.dialog, saveToHistory: true, saveToStorage: true)
        { (error) ->
            Void in
            
            if error != nil {
                
                QMMessageNotificationManager.showNotification(withTitle: "SA_STR_ERROR", subtitle: error?.localizedDescription, type: QMMessageNotificationType.warning)
            }
        }
        
        self.finishSendingMessage(animated: true)
    }
    
    // MARK: Helper
    func canMakeACall() -> Bool {
        
        var canMakeACall = false
        
        if (UIApplication.shared.canOpenURL(URL.init(string: "tel://")!)) {
            
            // Check if iOS Device supports phone calls
            let networkInfo = CTTelephonyNetworkInfo()
            let carrier = networkInfo.subscriberCellularProvider
            if carrier == nil {
                return false
            }
            let mnc = carrier?.mobileNetworkCode
            if mnc?.length == 0 {
                // Device cannot place a call at this time.  SIM might be removed.
            }
            else {
                // iOS Device is capable for making calls
                canMakeACall = true
            }
        }
        else {
            // iOS Device is not capable for making calls
        }
        
        return canMakeACall
    }
    
    func placeHolderTextView(_ textView: QMPlaceHolderTextView, shouldPasteWithSender sender: Any) -> Bool {
        
        if UIPasteboard.general.image != nil {
            
            let textAttachment = NSTextAttachment()
            textAttachment.image = UIPasteboard.general.image!
            textAttachment.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
            
            let attrStringWithImage = NSAttributedString.init(attachment: textAttachment)
            self.inputToolbar?.contentView.textView.attributedText = attrStringWithImage
            self.textViewDidChange((self.inputToolbar?.contentView.textView)!)
            
            return false
        }
        
        return true
    }
    
    func showCharactersNumberError() {
        let title  = "SA_STR_ERROR";
        let subtitle = String(format: "The character limit is %lu.", maxCharactersNumber)
        QMMessageNotificationManager.showNotification(withTitle: title, subtitle: subtitle, type: .error)
    }
    
    /**
     Builds a string
     Read: login1, login2, login3
     Delivered: login1, login3, @12345
     
     If user does not exist in usersMemoryStorage, then ID will be used instead of login
     
     - parameter message: QBChatMessage instance
     
     - returns: status string
     */
    func statusStringFromMessage(message: QBChatMessage) -> String {
        
        var statusString = ""
        
        let currentUserID = NSNumber(value:self.senderID)
        
        var readLogins: [String] = []
        
        if message.readIDs != nil {
            
            let messageReadIDs = message.readIDs!.filter { (element) -> Bool in
                
                return !element.isEqual(to: currentUserID)
            }
            
            if !messageReadIDs.isEmpty {
                for readID in messageReadIDs {
                    let user = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(truncating: readID))
                    
                    guard let unwrappedUser = user else {
                        let unknownUserLogin = "@\(readID)"
                        print(readID)
                        readLogins.append(unknownUserLogin)
                        
                        continue
                    }
                    
                    readLogins.append(unwrappedUser.login!)
                }
                
                statusString += message.isMediaMessage() ? "SA_STR_SEEN_STATUS" : "SA_STR_READ_STATUS";
                statusString += ": " + readLogins.joined(separator: ", ")
            }
        }
        
        if message.deliveredIDs != nil {
            var deliveredLogins: [String] = []
            
            let messageDeliveredIDs = message.deliveredIDs!.filter { (element) -> Bool in
                return !element.isEqual(to: currentUserID)
            }
            
            if !messageDeliveredIDs.isEmpty {
                for deliveredID in messageDeliveredIDs {
                    let user = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(truncating: deliveredID))
                    
                    guard let unwrappedUser = user else {
                        let unknownUserLogin = "@\(deliveredID)"
                        deliveredLogins.append(unknownUserLogin)
                        
                        continue
                    }
                    
                    if readLogins.contains(unwrappedUser.login!) {
                        continue
                    }
                    
                    deliveredLogins.append(unwrappedUser.login!)
                    
                }
                
                if readLogins.count > 0 && deliveredLogins.count > 0 {
                    statusString += "\n"
                }
                
                if deliveredLogins.count > 0 {
                    statusString += "SA_STR_DELIVERED_STATUS" + ": " + deliveredLogins.joined(separator: ", ")
                }
            }
        }
        
        if statusString.isEmpty {
            
            let messageStatus: QMMessageStatus = self.queueManager().status(for: message)
            
            switch messageStatus {
            case .sent:
                statusString = "SA_STR_SENT_STATUS"
            case .sending:
                statusString = "SA_STR_SENDING_STATUS"
            case .notSent:
                statusString = "SA_STR_NOT_SENT_STATUS"
            }
            
        }
        
        return statusString
    }
    
    // MARK: Override
    
    override func viewClass(forItem item: QBChatMessage) -> AnyClass {
        // TODO: check and add QMMessageType.AcceptContactRequest, QMMessageType.RejectContactRequest, QMMessageType.ContactRequest
        
        if item.isNotificationMessage() || item.isDateDividerMessage {
            return QMChatNotificationCell.self
        }
        
        if (item.senderID != self.senderID) {
            
            if (item.isMediaMessage() && item.attachmentStatus != QMMessageAttachmentStatus.error) {
                
                return QMChatAttachmentIncomingCell.self
                
            }
            else {
                
                return QMChatIncomingCell.self
            }
            
        }
        else {
            
            if (item.isMediaMessage() && item.attachmentStatus != QMMessageAttachmentStatus.error) {
                
                return QMChatAttachmentOutgoingCell.self
                
            }
            else {
                
                return QMChatOutgoingCell.self
            }
        }
    }
    
    // MARK: Strings builder
    
    override func attributedString(forItem messageItem: QBChatMessage!) -> NSAttributedString? {
        
        guard messageItem.text != nil else {
            return nil
        }
        
        var textColor = messageItem.senderID == self.senderID ? UIColor.white : UIColor.black
        if messageItem.isNotificationMessage() || messageItem.isDateDividerMessage {
            textColor = UIColor.black
        }
        
        var attributes = Dictionary<NSAttributedStringKey, AnyObject>()
        attributes[NSAttributedStringKey.foregroundColor] = textColor
        attributes[NSAttributedStringKey.font] = UIFont(name: "Helvetica", size: 17)
        
        let attributedString = NSAttributedString(string: messageItem.text!, attributes: attributes)
        
        return attributedString
    }
    
    
    /**
     Creates top label attributed string from QBChatMessage
     
     - parameter messageItem: QBCHatMessage instance
     
     - returns: login string, example: @SwiftTestDevUser1
     */
    override func topLabelAttributedString(forItem messageItem: QBChatMessage!) -> NSAttributedString? {
        
        guard messageItem.senderID != self.senderID else {
            return nil
        }
        
        guard self.dialog.type != QBChatDialogType.private else {
            return nil
        }
        
        let paragrpahStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        var attributes = Dictionary<NSAttributedStringKey, AnyObject>()
        attributes[NSAttributedStringKey.foregroundColor] = UIColor(red: 10.0/255.0, green: 73.0/255.0, blue: 121.0/255.0, alpha: 1.0)
        attributes[NSAttributedStringKey.font] = UIFont(name: "Helvetica", size: 17)
        attributes[NSAttributedStringKey.paragraphStyle] = paragrpahStyle
        
        var topLabelAttributedString : NSAttributedString?
        
        if let topLabelText = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: messageItem.senderID)?.login {
            topLabelAttributedString = NSAttributedString(string: topLabelText, attributes: attributes)
        } else { // no user in memory storage
            topLabelAttributedString = NSAttributedString(string: "@\(messageItem.senderID)", attributes: attributes)
        }
        
        return topLabelAttributedString
    }
    
    /**
     Creates bottom label attributed string from QBChatMessage using self.statusStringFromMessage
     
     - parameter messageItem: QBChatMessage instance
     
     - returns: bottom label status string
     */
    override func bottomLabelAttributedString(forItem messageItem: QBChatMessage!) -> NSAttributedString! {
        
        let textColor = messageItem.senderID == self.senderID ? UIColor.white : UIColor.black
        
        let paragrpahStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        var attributes = Dictionary<NSAttributedStringKey, AnyObject>()
        attributes[NSAttributedStringKey.foregroundColor] = textColor
        attributes[NSAttributedStringKey.font] = UIFont(name: "Helvetica", size: 13)
        attributes[NSAttributedStringKey.paragraphStyle] = paragrpahStyle
        
        var text = messageItem.dateSent != nil ? messageTimeDateFormatter.string(from: messageItem.dateSent!) : ""
        
        if messageItem.senderID == self.senderID {
            //
            // text = text + "\n" + self.statusStringFromMessage(message: messageItem)
        }
        
        let bottomLabelAttributedString = NSAttributedString(string: text, attributes: attributes)
        
        return bottomLabelAttributedString
    }
    
    // MARK: Collection View Datasource
    
    override func collectionView(_ collectionView: QMChatCollectionView!, dynamicSizeAt indexPath: IndexPath!, maxWidth: CGFloat) -> CGSize {
        
        var size = CGSize.zero
        
        guard let message = self.chatDataSource.message(for: indexPath) else {
            return size
        }
        
        let messageCellClass: AnyClass! = self.viewClass(forItem: message)
        
        
        if messageCellClass === QMChatAttachmentIncomingCell.self {
            
            size = CGSize(width: min(200, maxWidth), height: 200)
        }
        else if messageCellClass === QMChatAttachmentOutgoingCell.self {
            
            let attributedString = self.bottomLabelAttributedString(forItem: message)
            
            let bottomLabelSize = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: min(200, maxWidth), height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0)
            size = CGSize(width: min(200, maxWidth), height: 200 + ceil(bottomLabelSize.height))
        }
        else if messageCellClass === QMChatNotificationCell.self {
            
            let attributedString = self.attributedString(forItem: message)
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0)
        }
        else {
            
            let attributedString = self.attributedString(forItem: message)
            
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0)
        }
        
        return size
    }
    
    override func collectionView(_ collectionView: QMChatCollectionView!, minWidthAt indexPath: IndexPath!) -> CGFloat {
        
        var size = CGSize.zero
        
        guard let item = self.chatDataSource.message(for: indexPath) else {
            return 0
        }
        
        if self.detailedCells.contains(item.id!) {
            
            let str = self.bottomLabelAttributedString(forItem: item)
            let frameWidth = collectionView.frame.width
            let maxHeight = CGFloat.greatestFiniteMagnitude
            
            size = TTTAttributedLabel.sizeThatFitsAttributedString(str, withConstraints: CGSize(width:frameWidth - kMessageContainerWidthPadding, height: maxHeight), limitedToNumberOfLines:0)
        }
        
        if self.dialog.type != QBChatDialogType.private {
            
            let topLabelSize = TTTAttributedLabel.sizeThatFitsAttributedString(self.topLabelAttributedString(forItem: item), withConstraints: CGSize(width: collectionView.frame.width - kMessageContainerWidthPadding, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines:0)
            
            if topLabelSize.width > size.width {
                size = topLabelSize
            }
        }
        
        return size.width
    }
    
    override func collectionView(_ collectionView: QMChatCollectionView!, layoutModelAt indexPath: IndexPath!) -> QMChatCellLayoutModel {
        
        var layoutModel: QMChatCellLayoutModel = super.collectionView(collectionView, layoutModelAt: indexPath)
        
        layoutModel.avatarSize = CGSize(width: 0, height: 0)
        layoutModel.topLabelHeight = 0.0
        layoutModel.spaceBetweenTextViewAndBottomLabel = 5
        layoutModel.maxWidthMarginSpace = 20.0
        
        guard let item = self.chatDataSource.message(for: indexPath) else {
            return layoutModel
        }
        
        let viewClass: AnyClass = self.viewClass(forItem: item) as AnyClass
        
        if viewClass === QMChatIncomingCell.self || viewClass === QMChatAttachmentIncomingCell.self {
            
            if self.dialog.type != QBChatDialogType.private {
                let topAttributedString = self.topLabelAttributedString(forItem: item)
                let size = TTTAttributedLabel.sizeThatFitsAttributedString(topAttributedString, withConstraints: CGSize(width: collectionView.frame.width - kMessageContainerWidthPadding, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines:1)
                layoutModel.topLabelHeight = size.height
            }
            
            layoutModel.spaceBetweenTopLabelAndTextView = 5
        }
        
        var size = CGSize.zero
        
        if self.detailedCells.contains(item.id!) {
            
            let bottomAttributedString = self.bottomLabelAttributedString(forItem: item)
            size = TTTAttributedLabel.sizeThatFitsAttributedString(bottomAttributedString, withConstraints: CGSize(width: collectionView.frame.width - kMessageContainerWidthPadding, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines:0)
        }
        
        layoutModel.bottomLabelHeight = floor(size.height)
        
        
        return layoutModel
    }
    
    override func collectionView(_ collectionView: QMChatCollectionView!, configureCell cell: UICollectionViewCell!, for indexPath: IndexPath!) {
        
        super.collectionView(collectionView, configureCell: cell, for: indexPath)
        
        // subscribing to cell delegate
        let chatCell = cell as! QMChatCell
        
        chatCell.delegate = self
        
        let message = self.chatDataSource.message(for: indexPath)
        
        if let attachmentCell = cell as? QMChatAttachmentCell {
            
            if attachmentCell is QMChatAttachmentIncomingCell {
                chatCell.containerView?.bgColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            }
            else if attachmentCell is QMChatAttachmentOutgoingCell {
                //  chatCell.containerView?.bgColor = UIColor(red: 164.0/255.0, green: 182.0/255.0, blue: 196.0/255.0, alpha: 1.0)
                chatCell.containerView?.bgColor = UIColor(red: 48.0/255.0, green: 209.0/255.0, blue: 75.0/255.0, alpha: 1.0)
            }
            
            if let attachment = message?.attachments?.first {
                
                var keysToRemove: [String] = []
                
                let enumerator = self.attachmentCellsMap.keyEnumerator()
                
                while let existingAttachmentID = enumerator.nextObject() as? String {
                    let cachedCell = self.attachmentCellsMap.object(forKey: existingAttachmentID as AnyObject?)
                    if cachedCell === cell {
                        keysToRemove.append(existingAttachmentID)
                    }
                }
                
                for key in keysToRemove {
                    self.attachmentCellsMap.removeObject(forKey: key as AnyObject?)
                }
                
                if let attachmentID = attachment.id {
                    if self.failedDownloads.contains(attachmentID) {
                        attachmentCell.setAttachmentImage(UIImage(named:"error_image"))
                        return
                    }
                }
                
                self.attachmentCellsMap.setObject(attachmentCell, forKey: attachment.id as AnyObject?)
                
                attachmentCell.attachmentID = attachment.id
                
                // Getting image from chat attachment cache.
                
                ServicesManager.instance().chatService.chatAttachmentService.image(forAttachmentMessage: message!, completion: { [weak self] (error, image) in
                    
                    guard attachmentCell.attachmentID == attachment.id else {
                        return
                    }
                    
                    self?.attachmentCellsMap.removeObject(forKey: attachment.id as AnyObject?)
                    
                    guard error == nil else {
                        if (error! as NSError).code == 404 {
                            self?.failedDownloads.insert(attachment.id!)
                            
                            attachmentCell.setAttachmentImage(UIImage(named:"error_image"))
                        }
                        print("Error downloading image from server: \(error!.localizedDescription)")
                        return
                    }
                    
                    if image == nil {
                        print("Image is nil")
                    }
                    
                    attachmentCell.setAttachmentImage(image)
                    cell.updateConstraints()
                })
            }
            
        }
        else if cell is QMChatIncomingCell || cell is QMChatAttachmentIncomingCell {
            
            chatCell.containerView?.bgColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        }
        else if cell is QMChatOutgoingCell {
            
            let status: QMMessageStatus = self.queueManager().status(for: message!)
            
            switch status {
            case .sent:
                chatCell.containerView?.bgColor = UIColor(red: 48.0/255.0, green: 209.0/255.0, blue: 75.0/255.0, alpha: 1.0)
            case .sending:
                chatCell.containerView?.bgColor = UIColor(red: 166.3/255.0, green: 171.5/255.0, blue: 171.8/255.0, alpha: 1.0)
            case .notSent:
                chatCell.containerView?.bgColor = UIColor(red: 254.6/255.0, green: 30.3/255.0, blue: 12.5/255.0, alpha: 1.0)
            }
            
        }
        else if cell is QMChatAttachmentOutgoingCell {
            chatCell.containerView?.bgColor = UIColor(red: 10.0/255.0, green: 95.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        }
        else if cell is QMChatNotificationCell {
            cell.isUserInteractionEnabled = false
            chatCell.containerView?.bgColor = self.collectionView?.backgroundColor
        }
    }
    
    /**
     Allows to copy text from QMChatIncomingCell and QMChatOutgoingCell
     */
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        guard let item = self.chatDataSource.message(for: indexPath) else {
            return false
        }
        
        let viewClass: AnyClass = self.viewClass(forItem: item) as AnyClass
        
        if  viewClass === QMChatNotificationCell.self ||
                viewClass === QMChatContactRequestCell.self {
            return false
        }
        
        return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
        let item = self.chatDataSource.message(for: indexPath)
        
        if (item?.isMediaMessage())! {
            ServicesManager.instance().chatService.chatAttachmentService.localImage(forAttachmentMessage: item!, completion: { (image) in
                
                if image != nil {
                    guard let imageData = UIImageJPEGRepresentation(image!, 1) else { return }
                    
                    let pasteboard = UIPasteboard.general
                    
                    pasteboard.setValue(imageData, forPasteboardType:kUTTypeJPEG as String)
                }
            })
        }
        else {
            UIPasteboard.general.string = item?.text
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let lastSection = self.collectionView!.numberOfSections - 1
        
        if (indexPath.section == lastSection && indexPath.item == (self.collectionView?.numberOfItems(inSection: lastSection))! - 1) {
            // the very first message
            // load more if exists
            // Getting earlier messages for chat dialog identifier.
            
            guard let dialogID = self.dialog.id else {
                print("DialogID is nil")
                return super.collectionView(collectionView, cellForItemAt: indexPath)
            }
            
            ServicesManager.instance().chatService.loadEarlierMessages(withChatDialogID: dialogID).continueWith(block: {[weak self](task) -> Any? in
                
                guard let strongSelf = self else { return nil }
                
                if (task.result?.count ?? 0 > 0) {
                    
                    strongSelf.chatDataSource.add(task.result as! [QBChatMessage]!)
                }
                
                return nil
            })
        }
        
        // marking message as read if needed
        if let message = self.chatDataSource.message(for: indexPath) {
            self.sendReadStatusForMessage(message: message)
        }
        
        return super.collectionView(collectionView, cellForItemAt
                                        : indexPath)
    }
    
    // MARK: QMChatCellDelegate
    
    /**
     Removes size from cache for item to allow cell expand and show read/delivered IDS or unexpand cell
     */
    func chatCellDidTapContainer(_ cell: QMChatCell!) {
        let indexPath = self.collectionView?.indexPath(for: cell)
        
        guard let currentMessage = self.chatDataSource.message(for: indexPath) else {
            return
        }
        
        let messageStatus: QMMessageStatus = self.queueManager().status(for: currentMessage)
        
        if messageStatus == .notSent {
            self.handleNotSentMessage(currentMessage, forCell:cell)
            return
        }
        
        if self.detailedCells.contains(currentMessage.id!) {
            self.detailedCells.remove(currentMessage.id!)
        } else {
            self.detailedCells.insert(currentMessage.id!)
        }
        
        self.collectionView?.collectionViewLayout.removeSizeFromCache(forItemID: currentMessage.id)
        self.collectionView?.performBatchUpdates(nil, completion: nil)
        
    }
    
    func chatCell(_ cell: QMChatCell!, didTapAtPosition position: CGPoint) {}
    
    func chatCell(_ cell: QMChatCell!, didPerformAction action: Selector!, withSender sender: Any!) {}
    
    func chatCell(_ cell: QMChatCell!, didTapOn result: NSTextCheckingResult) {
        
        switch result.resultType {
        
        case NSTextCheckingResult.CheckingType.link:
            
            let strUrl : String = (result.url?.absoluteString)!
            
            let hasPrefix = strUrl.lowercased().hasPrefix("https://") || strUrl.lowercased().hasPrefix("http://")
            
            if #available(iOS 9.0, *) {
                if hasPrefix {
                    
                    let controller = SFSafariViewController(url: URL(string: strUrl)!)
                    self.present(controller, animated: true, completion: nil)
                    
                    break
                }
                
            }
            // Fallback on earlier versions
            
            if UIApplication.shared.canOpenURL(URL(string: strUrl)!) {
                
                UIApplication.shared.openURL(URL(string: strUrl)!)
            }
            
            break
            
        case NSTextCheckingResult.CheckingType.phoneNumber:
            
            if !self.canMakeACall() {
                
                Alert.showAlertWithMessageAndTitle(message: "Your Device can't make a phone call", title: "")
                //SVProgressHUD.showInfo(withStatus: "Your Device can't make a phone call", maskType: .none)
                break
            }
            
            let urlString = String(format: "tel:%@",result.phoneNumber!)
            let url = URL(string: urlString)
            
            self.view.endEditing(true)
            
            let alertController = UIAlertController(title: "",
                                                    message: result.phoneNumber,
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "SA_STR_CANCEL", style: .cancel) { (action) in
                
            }
            
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "SA_STR_CALL", style: .destructive) { (action) in
                UIApplication.shared.openURL(url!)
            }
            alertController.addAction(openAction)
            
            self.present(alertController, animated: true) {
            }
            
            break
            
        default:
            break
        }
    }
    
    func chatCellDidTapAvatar(_ cell: QMChatCell!) {
    }
    
    // MARK: QMDeferredQueueManager
    
    func deferredQueueManager(_ queueManager: QMDeferredQueueManager, didAddMessageLocally addedMessage: QBChatMessage) {
        
        if addedMessage.dialogID == self.dialog.id {
            self.chatDataSource.add(addedMessage)
        }
    }
    
    func deferredQueueManager(_ queueManager: QMDeferredQueueManager, didUpdateMessageLocally addedMessage: QBChatMessage) {
        
        if addedMessage.dialogID == self.dialog.id {
            self.chatDataSource.update(addedMessage)
        }
    }
    
    // MARK: QMChatServiceDelegate
    
    func chatService(_ chatService: QMChatService, didLoadMessagesFromCache messages: [QBChatMessage], forDialogID dialogID: String) {
        
        if self.dialog.id == dialogID {
            if !(self.progressView?.isHidden)! {
                self.stopSpinProgress()
            }
            self.chatDataSource.add(messages)
        }
    }
    
    func chatService(_ chatService: QMChatService, didAddMessageToMemoryStorage message: QBChatMessage, forDialogID dialogID: String) {
        
        if self.dialog.id == dialogID {
            // Insert message received from XMPP or self sent
            if self.chatDataSource.messageExists(message) {
                
                self.chatDataSource.update(message)
            }
            else {
                
                self.chatDataSource.add(message)
            }
        }
    }
    
    func chatService(_ chatService: QMChatService, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog) {
        
        if self.dialog.type != QBChatDialogType.private && self.dialog.id == chatDialog.id {
            self.dialog = chatDialog
            self.title = self.dialog.name
        }
    }
    
    func chatService(_ chatService: QMChatService, didUpdate message: QBChatMessage, forDialogID dialogID: String) {
        
        if self.dialog.id == dialogID {
            self.chatDataSource.update(message)
        }
    }
    
    func chatService(_ chatService: QMChatService, didUpdate messages: [QBChatMessage], forDialogID dialogID: String) {
        
        if self.dialog.id == dialogID {
            self.chatDataSource.update(messages)
        }
    }
    
    // MARK: UITextViewDelegate
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
    }
    
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Prevent crashing undo bug
        let currentCharacterCount = textView.text?.length ?? 0
        
        if (range.length + range.location > currentCharacterCount) {
            return false
        }
        
        if !QBChat.instance.isConnected { return true }
        
        if let timer = self.typingTimer {
            timer.invalidate()
            self.typingTimer = nil
            
        } else {
            
            self.sendBeginTyping()
        }
        
        self.typingTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ChatViewController.fireSendStopTypingIfNecessary), userInfo: nil, repeats: false)
        
        if maxCharactersNumber > 0 {
            
            if currentCharacterCount >= maxCharactersNumber && text.length > 0 {
                
                self.showCharactersNumberError()
                return false
            }
            
            let newLength = currentCharacterCount + text.length - range.length
            
            if  newLength <= maxCharactersNumber || text.length == 0 {
                return true
            }
            
            let oldString = textView.text ?? ""
            
            let numberOfSymbolsToCut = maxCharactersNumber - oldString.length
            
            var stringRange = NSMakeRange(0, min(text.length, numberOfSymbolsToCut))
            
            
            // adjust the range to include dependent chars
            stringRange = (text as NSString).rangeOfComposedCharacterSequences(for: stringRange)
            
            // Now you can create the short string
            let shortString = (text as NSString).substring(with: stringRange)
            
            let newText = NSMutableString()
            newText.append(oldString)
            newText.insert(shortString, at: range.location)
            textView.text = newText as String
            
            self.showCharactersNumberError()
            
            self.textViewDidChange(textView)
            
            return false
        }
        
        return true
    }
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        
        super.textViewDidEndEditing(textView)
        
        self.fireSendStopTypingIfNecessary()
    }
    
    @objc func fireSendStopTypingIfNecessary() -> Void {
        
        if let timer = self.typingTimer {
            
            timer.invalidate()
        }
        
        self.typingTimer = nil
        self.sendStopTyping()
    }
    
    func sendBeginTyping() -> Void {
        self.dialog.sendUserIsTyping()
    }
    
    func sendStopTyping() -> Void {
        
        self.dialog.sendUserStoppedTyping()
    }
    
    // MARK: QMChatAttachmentServiceDelegate
    
    func chatAttachmentService(_ chatAttachmentService: QMChatAttachmentService, didChange status: QMMessageAttachmentStatus, for message: QBChatMessage) {
        
        if status != QMMessageAttachmentStatus.notLoaded {
            
            if message.dialogID == self.dialog.id {
                self.chatDataSource.update(message)
            }
        }
    }
    
    func chatAttachmentService(_ chatAttachmentService: QMChatAttachmentService, didChangeLoadingProgress progress: CGFloat, for attachment: QBChatAttachment) {
        
        if let attachmentCell = self.attachmentCellsMap.object(forKey: attachment.id! as AnyObject?) {
            attachmentCell.updateLoadingProgress(progress)
        }
    }
    
    func chatAttachmentService(_ chatAttachmentService: QMChatAttachmentService, didChangeUploadingProgress progress: CGFloat, for message: QBChatMessage) {
        
        guard message.dialogID == self.dialog.id else {
            return
        }
        var cell = self.attachmentCellsMap.object(forKey: message.id as AnyObject?)
        
        if cell == nil && progress < 1.0 {
            
            if let indexPath = self.chatDataSource.indexPath(for: message) {
                cell = self.collectionView?.cellForItem(at: indexPath) as? QMChatAttachmentCell
                self.attachmentCellsMap.setObject(cell, forKey: message.id as AnyObject?)
            }
        }
        
        cell?.updateLoadingProgress(progress)
    }
    
    // MARK : QMChatConnectionDelegate
    
    func refreshAndReadMessages() {
        //Alert.showAlertWithMessageAndTitle(message: "SA_STR_LOADING_MESSAGES", title: "")
        //SVProgressHUD.show(withStatus: "SA_STR_LOADING_MESSAGES", maskType: SVProgressHUDMaskType.clear)
        self.loadMessages()
        
        if let messagesToRead = self.unreadMessages {
            self.readMessages(messages: messagesToRead)
        }
        
        self.unreadMessages = nil
    }
    
    func chatServiceChatDidConnect(_ chatService: QMChatService) {
        
        self.refreshAndReadMessages()
    }
    
    func chatServiceChatDidReconnect(_ chatService: QMChatService) {
        
        self.refreshAndReadMessages()
    }
    
    func queueManager() -> QMDeferredQueueManager {
        return ServicesManager.instance().chatService.deferredQueueManager
    }
    
    func handleNotSentMessage(_ message: QBChatMessage,
                              forCell cell: QMChatCell!) {
        
        let alertController = UIAlertController(title: "", message: "AFLATOON", preferredStyle:.actionSheet)
        
        let resend = UIAlertAction(title: "SA_STR_TRY_AGAIN_MESSAGE", style: .default) { (action) in
            self.queueManager().perfromDefferedAction(for: message, withCompletion: nil)
        }
        alertController.addAction(resend)
        
        let delete = UIAlertAction(title: "SA_STR_DELETE_MESSAGE", style: .destructive) { (action) in
            self.queueManager().remove(message)
            self.chatDataSource.delete(message)
        }
        alertController.addAction(delete)
        
        let cancelAction = UIAlertAction(title: "SA_STR_CANCEL", style: .cancel) { (action) in
            
        }
        
        alertController.addAction(cancelAction)
        
        if alertController.popoverPresentationController != nil {
            self.view.endEditing(true)
            alertController.popoverPresentationController!.sourceView = cell.containerView
            alertController.popoverPresentationController!.sourceRect = cell.containerView.bounds
        }
        
        self.present(alertController, animated: true) {
        }
    }
}

extension ChatViewController: UserDetailDelegate{
    func getuserDataByID(qbId: String)
    {
        let sessionObject = DataAccess.sharedInstance
        sessionObject.getUserByAttribute("name", qbId, resultDelegate: self as UserDetailDelegate)
    }
    
    func getuserDataByQBID(qbId: String)
    {
        let sessionObject = DataAccess.sharedInstance
        sessionObject.getUserByAttribute("qbid", qbId, resultDelegate: self as UserDetailDelegate)
    }
    
    func setRecievedUserStatus(_ status: Bool, statusString: String, userData: User)
    {
        self.simxUser = userData
        print("userData ", self.simxUser)
    }
    func dataAccessError(_ error:NSError?)
    {
        print(error)
    }
}

//{
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
