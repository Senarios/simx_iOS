//
//  Alert.swift
//  CRYOUT
//
//  Created by Saadi on 14/03/2017.
//  Copyright © 2017 com.senarios. All rights reserved.
//

import Foundation
import UIKit
//import KRAlertController

class Alert
{
    static func showAlertWithMessageAndTitle(message: String, title: String ) {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    static func showOfflineAlert()
    {
//        DispatchQueue.main.async(execute: { () in

            let alert = UIAlertView(title: "No Internet!", message: "Please Make sure you have active internet connection.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
//            let alert = KRAlertController(title: "No Internet!", message: "Please Make sure you have active internet connection.", style: .alert)
//            alert.addAction(title: "OK") { action, textFields in
//                print("OK")
//            }
//            alert.showWarning(icon: true)
//
//        })
    }
//
//    static func showSuccessAlertWithMessageAndTitle(_ message: String, title: String )
//    {
//        DispatchQueue.main.async(execute: { () in
//
//            let alert = KRAlertController(title: title, message: message, style: .alert)
//            alert.addAction(title: "OK") { action, textFields in
//                print("OK")
//            }
//            alert.showSuccess(icon: true)
//
//        })
//    }
//
//    static func showInformationAlertWithMessageAndTitle(_ message: String, title: String )
//    {
//        DispatchQueue.main.async(execute: { () in
//
//            let alert = KRAlertController(title: title, message: message, style: .alert)
//            alert.addAction(title: "OK") { action, textFields in
//                print("OK")
//            }
//            alert.showInformation(icon: true)
//
//        })
//    }
//
//    static func showURL_loadingErrorAlert(error: String)
//    {
//        DispatchQueue.main.async(execute: { () in
//
//            let alert = KRAlertController(title: "Error!", message: error, style: .alert)
//            alert.addAction(title: "OK") { action, textFields in
//                print("OK")
//            }
//            alert.showError(icon: true)
//
//        })
//    }
//
//    static func showRemoteNotification_Alert(_ message: String, title: String, vc: UIViewController)
//    {
//        DispatchQueue.main.async(execute: { () in
//
//            let alert = KRAlertController(title: title, message: message, style: .alert)
//            alert.addAction(title: "OK") { action, textFields in
//                print("OK")
//            }
//            alert.showInformation(icon: false)
//            //alert.showInformation(icon: false, presentingVC: vc, animated: true, completion: nil)
//
//        })
//    }
    
}

