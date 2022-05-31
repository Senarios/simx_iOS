//
//  EnableLocationVC.swift
//  CyberScope
//
//  Created by Saad Furqan on 17/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import CoreLocation

class EnableLocationVC: UIViewController, Add_Or_Update_User_Delegate, CLLocationManagerDelegate {

    @IBOutlet weak var button_enableLocation: UIButton!
    
    private var locationManager = CLLocationManager()
    private let operationQueue = OperationQueue()
    
    @IBOutlet weak var enableLocationButton: UIButton!
    
    var user_toCreate: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        operationQueue.isSuspended = true
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        self.enableLocationButton.setCornerRadiusCircle()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.enableLocationButton.setCornerRadiusCircle()
    }
    
    ///When the user presses the allow/don't allow buttons on the popup dialogue
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        //If we're authorized to use location services, run all operations in the queue
        // otherwise if we were denied access, cancel the operations
        if(status == .authorizedAlways || status == .authorizedWhenInUse){
            self.proceedSignUp()
        }else if(status == .denied){
            self.showAlertToGoToSettingsAndEnableLocation()
        }
    }
    
    func showAlertToGoToSettingsAndEnableLocation() {
        let alertController = UIAlertController(
            title: "Location Access Disabled",
            message: "Your Location is used to help you see related and more synchronized updates.\nPlease open app's settings and set location access to 'When In Use'.\nOtherwise press Cancel!",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
            //self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url as URL)
            }
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
    }

    ///Checks the status of the location permission
    /// and adds the callback block to the queue to run when finished checking
    /// NOTE: Anything done in the UI should be enclosed in `DispatchQueue.main.async {}`
    func runLocationBlock(callback: @escaping () -> ()){
        
        //Get the current authorization status
        let authState = CLLocationManager.authorizationStatus()
        
        //If we have permissions, start executing the commands immediately
        // otherwise request permission
        if(authState == .authorizedAlways || authState == .authorizedWhenInUse){
            self.operationQueue.isSuspended = false
        }else{
            //Request permission
            locationManager.requestWhenInUseAuthorization()
        }
        
        //Create a closure with the callback function so we can add it to the operationQueue
        let block = { callback() }
        
        //Add block to the queue to be executed asynchronously
        self.operationQueue.addOperation(block)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == Constants.Segues.EnableLocationVC_to_MoreUserDetails2_VC)
        {
            let nextVC = segue.destination as! MoreUserDetails2_VC
            nextVC.user_toCreate = self.user_toCreate
            
            
        }
    }
    
    @IBAction func button_enableLocation_Tapped(_ sender: Any)
    {
        //If we're authorized to use location services, run all operations in the queue
        // otherwise if we were denied access, cancel the operations
        let status = CLLocationManager.authorizationStatus()
        if(status == .authorizedAlways || status == .authorizedWhenInUse){
            self.proceedSignUp()
        }else if(status == .denied){
            self.showAlertToGoToSettingsAndEnableLocation()
        }
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        proceedSignUp()
    }
    
    func proceedSignUp() {
//        if (self.user_toCreate?.skills == Constants.userSkillsType.viewer) {
//
//            Utilities.show_ProgressHud(view: self.view) // show progress hud
//
//            // Set defaults value to rate for a viewer
//            self.user_toCreate?.rate = "0"
//            self.user_toCreate?.password = Constants.DreamFactory.DF_User_Default_Password
//            self.user_toCreate?.isNew_object = true
//
//            self.SignUp_QB_User()
//        }
//        else {
            self.performSegue(withIdentifier: Constants.Segues.EnableLocationVC_to_MoreUserDetails2_VC, sender: self)
//        }
    }
    
//    func makeCompleteProfileHit()
//    {
//        if(self.user_toCreate != nil)
//        {
//            Utilities.show_ProgressHud(view: self.view)
//
//            self.user_toCreate?.rate = "0.0"
//            self.user_toCreate?.password = Constants.DreamFactory.DF_User_Default_Password
//            self.user_toCreate?.isNew_object = true
//
//            self.SignUp_QB_User()
//        }
//    }
    
    func SignUp_QB_User()
    {
        let user = QBUUser()
        user.fullName = self.user_toCreate?.name
        user.login = self.user_toCreate?.username
        user.password = Constants.QuickBlox.QB_User_Default_Password
        user.tags = [Constants.OS.ios]
        
        QBRequest.signUp(user, successBlock: { (response, user) in
            
            print("\n => QB SIGNUP SUCCESSFULL ... \n New User Details are:")
            print("\n \(user.id) \n \((user.fullName)!) \n \((user.login)!) \n")
            
            self.user_toCreate?.qbid = String(describing: user.id)
            if (UserDefaults.standard.object(forKey: "endpointArnForSNSCyberScope787") != nil) {
                self.user_toCreate?.arn = UserDefaults.standard.object(forKey: "endpointArnForSNSCyberScope787") as! String
            }
            DataAccess.sharedInstance.add_OR_update_User(user: self.user_toCreate!, delegate: self)
            
        }, errorBlock: { (error) in
            
            print("\n => QB SIGNUP FAILED ... \n error = \(error)")
            
            Utilities.hide_ProgressHud(view: self.view)
            let e = Utilities.getQB_ErrorMessage_andTitle_fromErrorCode(error_StatusCode: error.status.rawValue)
            Alert.showAlertWithMessageAndTitle(message: e.message, title: e.title)
        })
    }
    
    // Add_Or_Update_User_Delegate methods
    func Add_Or_Update_User_ResponseSuccess(userName: String)
    {
        Utilities.hide_ProgressHud(view: self.view)
        print("\n Add_Or_Update_User_ResponseSuccess called ... \n")
        
        CurrentUser.setCurrentUser_UserDefaults(user: self.user_toCreate!)
        CurrentUser.setCurrentUserStatus_as_Login()
        
        CurrentUser.set_CurrentDevice_Arn()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute: {
            AppDelegate.shared_instance.setStreamBoardInitialViewControllerToRoot()
        })
    }
    
    func Add_Or_Update_User_ResponseError(error: NSError)
    {
        Utilities.hide_ProgressHud(view: self.view)
        print("\n Add_Or_Update_User_ResponseError called ... AND Error = \(error.localizedDescription) \n")
    }
    
}
