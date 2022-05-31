//
//  selectCallTypeVC.swift
//  CyberScope
//
//  Created by Saad Furqan on 23/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import Quickblox
import QuickbloxWebRTC

class selectCallTypeVC: UIViewController
{
    @IBOutlet weak var button_cancel: UIButton!
    @IBOutlet weak var button_audio: UIButton!
    @IBOutlet weak var button_video: UIButton!
    
    @IBOutlet weak var btnAddPayment: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup_controls()
    }

    func setup_controls()
    {
        if(CurrentUser.Current_UserObject.credit > 0){
            self.btnAddPayment.isHidden = true
        }
        else
        {
            self.btnAddPayment.isHidden = false
        }
    }
    @IBAction func AddPaymentControl(_ sender: Any) {
        // addPaymentFromCall
        self.performSegue(withIdentifier: "addPaymentFromCall", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.connectToChat()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func connectToChat()
    {
        let current_user = CurrentUser.getCurrentUser_From_UserDefaults()
        let user    = QBUUser()
        user.id = UInt(current_user.qbid)!
        user.login = current_user.username
        user.password = Constants.QuickBlox.QB_User_Default_Password
        
        QBChat.instance.connect(withUserID: user.id, password: user.password!, completion: { (error) in
            
            if error == nil
            {
                print("\n Successfully LogIn to QB chat ... \n")
            }
            else
            {
                print("\n Error = \(String(describing: error?.localizedDescription)) \n")
            }
            
        })
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == Constants.Segues.selectCallTypeVC_to_callingVC)
        {
            let vc = segue.destination as! CallingVC
            vc.acceptCall = false
        }
    }

    @IBAction func button_cancelAction(_ sender: Any)
    {
       self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func button_audioTapped(_ sender: Any)
    {
        //////let otherAlert = UIAlertController(title: "Message!", message: "This call would cost you around \((AppDelegate.QB_VideoChat_opponetUser?.rate)!)£/hour, and your current balance is \(CurrentUser.Current_UserObject.credit)£.\n Choose 'Call' to continue\n or\n 'Cancel' to move back.", preferredStyle: .actionSheet)
        //let otherAlert = UIAlertController(title: "Message!", message: "This call will cost you £\((AppDelegate.QB_VideoChat_opponetUser?.rate)!)/hour, and your current balance is £\(CurrentUser.Current_UserObject.credit).", preferredStyle: .actionSheet)
       // let callFunction = UIAlertAction(title: "Call", style: .default) { _ in
            print("We can run a block of code." )
            
            //let stringRate : NSString = NSString(string: (AppDelegate.QB_VideoChat_opponetUser?.rate)!)
//            if (CurrentUser.Current_UserObject.credit < stringRate.doubleValue/2.0) {
//            if (CurrentUser.Current_UserObject.credit < stringRate.doubleValue/2.0) {
//                let cannotCallAlert = UIAlertController(title: "Sorry!", message: "You don't have enough balance to make this call. Please add some balance using edit profile option.", preferredStyle: .actionSheet)
//                let okFunction = UIAlertAction(title: "OK", style: .default) { _ in
//                }
//                cannotCallAlert.addAction(okFunction)
//                self.present(cannotCallAlert, animated: true, completion: nil)
//                return
//            }
            
            AppDelegate.QB_VideoChat_current_CallType = QBRTCConferenceType.audio
            self.performSegue(withIdentifier: Constants.Segues.selectCallTypeVC_to_callingVC, sender: self)
        }
        
//        let dismiss = UIAlertAction(title: "Cancel", style: .default) { _ in
//            print("User canceled the call." )
//            self.dismiss(animated: true, completion: nil)
//        }
//        // relate actions to controllers
//
//        otherAlert.addAction(callFunction)
//        otherAlert.addAction(dismiss)
//
//        present(otherAlert, animated: true, completion: nil)
//    }
    
    @IBAction func button_videoTapped(_ sender: Any)
    {
        //////let otherAlert = UIAlertController(title: "Message!", message: "This call would cost you around \((AppDelegate.QB_VideoChat_opponetUser?.rate)!)£/hour, and your current balance is \(CurrentUser.Current_UserObject.credit)£.\n Choose 'Call' to continue\n or\n 'Cancel' to move back.", preferredStyle: .actionSheet)
//        let otherAlert = UIAlertController(title: "Message!", message: "This call will cost you £\((AppDelegate.QB_VideoChat_opponetUser?.rate)!)/hour, and your current balance is £\(CurrentUser.Current_UserObject.credit).", preferredStyle: .actionSheet)
        //let callFunction = UIAlertAction(title: "Call", style: .default) { _ in
            
           // let stringRate:NSString = NSString(string:(AppDelegate.QB_VideoChat_opponetUser?.rate)!)
//            if (CurrentUser.Current_UserObject.credit < stringRate.doubleValue/2.0) {
//                let cannotCallAlert = UIAlertController(title: "Sorry!", message: "You don't have enough balance to make this call. Please add some balance using edit profile option.", preferredStyle: .actionSheet)
//                let okFunction = UIAlertAction(title: "OK", style: .default) { _ in
//                }
//                cannotCallAlert.addAction(okFunction)
//                self.present(cannotCallAlert, animated: true, completion: nil)
//                return
//            }
            
            print("We can run a block of code." )
            AppDelegate.QB_VideoChat_current_CallType = QBRTCConferenceType.video
            self.performSegue(withIdentifier: Constants.Segues.selectCallTypeVC_to_callingVC, sender: self)
       // }
            
        
        let dismiss = UIAlertAction(title: "Cancel", style: .default) { _ in
            print("User canceled the call." )
            self.dismiss(animated: true, completion: nil)
        }
        // relate actions to controllers
        
//        otherAlert.addAction(callFunction)
//        otherAlert.addAction(dismiss)
//
//        present(otherAlert, animated: true, completion: nil)
    }
}
