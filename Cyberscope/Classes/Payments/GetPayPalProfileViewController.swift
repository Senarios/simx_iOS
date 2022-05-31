//
//  GetPayPalProfileViewController.swift
//  SimX
//
//  Created by Salman on 27/08/2019.
//  Copyright © 2019 Agilio. All rights reserved.
//

import UIKit

class GetPayPalProfileViewController: UIViewController, PayPalProfileSharingDelegate {
    
    var environment:String = PayPalEnvironmentSandbox
        // PayPalEnvironmentProduction // PayPalEnvironmentNoNetwork // PayPalEnvironmentSandbox
        {
        willSet(newEnvironment)
        {
            if (newEnvironment != environment) {
                print("issues in environment")
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    var payPalConfig = PayPalConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.launchProfileSharingController()
    }
    
    
    func launchProfileSharingController() {
        let scope: Set<String> = Set([kPayPalOAuth2ScopeEmail, kPayPalOAuth2ScopeFuturePayments])
        let paypalProfileSharing = PayPalProfileSharingViewController(scopeValues: scope, configuration: payPalConfig, delegate: self)
        present(paypalProfileSharing!, animated: true, completion: nil)
    }

//    func profileController() -> PayPalProfileSharingViewController {
//        let scope: Set<String> = Set([kPayPalOAuth2ScopeEmail, kPayPalOAuth2ScopeFuturePayments])
//        let controller = PayPalProfileSharingViewController(scopeValues: scope, configuration: self.paypalConfiguration!, delegate: self)
//        return controller!
//    }
    
    
    func userDidCancelPayPalProfileSharingViewController(profileSharingViewController: PayPalProfileSharingViewController) {
        print ("user canceled")
    }
    
    func processAuthorization(authorization: [String: Any]) {
        if let authCode = authorization["response"] {
            //self.delegate?.didSucceedPayPalConsent(authCode)
            print(authCode)
        }
        else {
            print ("user canceled")
        }
    }
    
    func userDidCancel(_ profileSharingViewController: PayPalProfileSharingViewController) {
        print("user did cancel")
    }
    
    func payPalProfileSharingViewController(_ profileSharingViewController: PayPalProfileSharingViewController, userDidLogInWithAuthorization profileSharingAuthorization: [AnyHashable : Any]) {
        self.processAuthorization(authorization: profileSharingAuthorization as! [String : Any])
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
