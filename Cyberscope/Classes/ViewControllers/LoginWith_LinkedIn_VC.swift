//
//  tempVC.swift
//  CyberScope
//
//  Created by Saad Furqan on 18/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import LinkedinSwift

class LoginWith_LinkedIn_VC: UIViewController
{
    let linkedinHelper = LinkedinSwiftHelper(configuration: LinkedinSwiftConfiguration(clientId: Constants.LinkedIn.clientId, clientSecret: Constants.LinkedIn.clientSecret, state: Constants.LinkedIn.state, permissions: Constants.LinkedIn.permissions, redirectUrl: Constants.LinkedIn.redirectUrl))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        definesPresentationContext = true
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
      //  self.LogIn_Tapped()
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

    @IBAction func button_Tapped(_ sender: Any)
    {
        self.LogIn_Tapped()
    }
    
    func LogIn_Tapped()
    {
        let config = LinkedinSwiftConfiguration(clientId: Constants.LinkedIn.clientId, clientSecret: Constants.LinkedIn.clientSecret, state: Constants.LinkedIn.state, permissions: Constants.LinkedIn.permissions, redirectUrl: Constants.LinkedIn.redirectUrl)
        let linkedinHelper = LinkedinSwiftHelper(configuration: config!, nativeAppChecker: nil, clients: nil, webOAuthPresent: self, persistedLSToken: nil)
        linkedinHelper.authorizeSuccess({(lsToken) -> Void in
            
            print("\n Login success lsToken: \(lsToken) \n")
            self.requestProfile()
            
            }, error: {(error) -> Void in
                
                print("\n Error: \(error.localizedDescription) \n")
                self.dismiss_controller_withMessage(msg: error.localizedDescription, title: "Error!")
                
        }, cancel: {() -> Void in
            
            print("\n User Cancelled the process... \n")
            self.dismiss_controller_withMessage(msg: "You canceled the login process.", title: "Canceled!")
        })
    }
    
    func requestProfile()
    {
        linkedinHelper.requestURL("https://api.linkedin.com/v1/people/~:(id,first-name,last-name,email-address,picture-url,picture-urls::(original),positions,date-of-birth,phone-numbers,location)?format=json", requestType: LinkedinSwiftRequestGet, success: { (response) -> Void in
            
            print("\n Request success with response: \(response.description) \n")
            SignInViewController.userLinkedInData = response.jsonObject as! [String : Any]
            SignInViewController.userLinkedInData["name"] = String(describing: SignInViewController.userLinkedInData["firstName"]!) + " " + String(describing: SignInViewController.userLinkedInData["lastName"]!)
            
        }) {(error) -> Void in
            
            print("\n Error: \(error.localizedDescription) \n")
            self.dismiss_controller_withMessage(msg: error.localizedDescription, title: "Error!")
        }
    }
    
    func dismiss_controller_withMessage(msg: String, title: String)
    {
        DispatchQueue.main.async {
            
            self.dismiss(animated: true, completion: {
                
                Alert.showAlertWithMessageAndTitle(message: msg, title: title)
            })
        }
    }
}
