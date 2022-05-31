//
//  Purchaseplan.swift
//  SimX
//
//  Created by Salman on 15/04/2021.
//  Copyright © 2021 Agilio. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit
enum RegisteredPurchase: String {

    case purchase1
    case purchase2
    case nonConsumablePurchase
    case consumablePurchase
    case nonRenewingPurchase
    case autoRenewableWeekly
    case autoRenewableMonthly
    case autoRenewableYearly
}

class Purchaseplan: UIViewController,UpdateUser_Delegate {

    
    fileprivate let dataAccess = DataAccess.sharedInstance
    let appBundleId = "com.senarios.iOSCyberScopeTV.10Dollar"
    var productIds = ["com.senarios.iOSCyberScopeTV.150credit","com.senarios.iOSCyberScopeTV.50credit","com.senarios.iOSCyberScopeTV.100credit"]
    var product_data = [SKProduct]()
    
    @IBOutlet weak var lblCurrentCredits: UILabel!
    @IBOutlet weak var btn10: UIButton!
    @IBOutlet weak var btn50: UIButton!
    @IBOutlet weak var btn100: UIButton!
    @IBOutlet weak var btn150: UIButton!
    
    
    override func viewDidLoad() {
        print("come in purchase plan")
        super.viewDidLoad()
        self.setupView()
        let loggedinUser = CurrentUser.Current_UserObject
        self.lblCurrentCredits.text = "Current Credits : \(loggedinUser.credit)"
        Utilities.show_ProgressHud(view: self.view)
        PKIAPHandler.shared.setProductIds(ids: self.productIds)
        PKIAPHandler.shared.fetchAvailableProducts { [weak self](products)   in
           guard let sSelf = self else {
            print("return from fetch products")
            return

           }
            self!.product_data = products
           
            DispatchQueue.main.async {
                
//                sSelf.productListTableView.reloadData()
                Utilities.hide_ProgressHud(view: self!.view)
            }
        }
    }

    func setupView()
    {
        btn10.layer.cornerRadius = 5
        btn50.layer.cornerRadius = 5
        btn100.layer.cornerRadius = 5
        btn150.layer.cornerRadius = 5
    }

    @IBAction func btn10_pressed(_ sender: Any) {
        resetAllButtons()
        btn10.backgroundColor = UIColor(red: 0/255, green: 50/255, blue: 239/255, alpha: 1)
        btn10.setTitleColor(UIColor.white, for: .normal)
    }
    
    @IBAction func btn50_pressed(_ sender: Any) {
        resetAllButtons()
        btn50.backgroundColor = UIColor(red: 0/255, green: 50/255, blue: 239/255, alpha: 1)
        btn50.setTitleColor(UIColor.white, for: .normal)
        
        PKIAPHandler.shared.purchase(product: self.product_data[2]) { (alert, product, transaction) in
            if let tran = transaction, let prod = product {
                print(tran)
                Utilities.show_ProgressHud(view: self.view)
                
                if (prod.productIdentifier == "com.senarios.iOSCyberScopeTV.50credit")
                {
                    self.updateUserBalanceWithAmount(amount: 50.0)
                }
            }
            //Utilities.hide_ProgressHud(view: self.view)
            print(alert.message)
            // Globals.shared.showWarnigMessage(alert.message)
        }
    }
    
    @IBAction func btn100_pressed(_ sender: Any) {
        resetAllButtons()
        btn100.backgroundColor = UIColor(red: 0/255, green: 50/255, blue: 239/255, alpha: 1)
        btn100.setTitleColor(UIColor.white, for: .normal)
        
        PKIAPHandler.shared.purchase(product: self.product_data[0]) { (alert, product, transaction) in
            if let tran = transaction, let prod = product {
                print(tran)
                Utilities.show_ProgressHud(view: self.view)
                if (prod.productIdentifier == "com.senarios.iOSCyberScopeTV.100credit")
                {
                    self.updateUserBalanceWithAmount(amount: 100.0)
                }
            }
            //Utilities.hide_ProgressHud(view: self.view)
            print(alert.message)
            // Globals.shared.showWarnigMessage(alert.message)
        }
    }
    
    @IBAction func btn150_pressed(_ sender: Any) {
        resetAllButtons()
        btn150.backgroundColor = UIColor(red: 0/255, green: 50/255, blue: 239/255, alpha: 1)
        btn150.setTitleColor(UIColor.white, for: .normal)
        
        PKIAPHandler.shared.purchase(product: self.product_data[1]) { (alert, product, transaction) in
            if let tran = transaction, let prod = product {
                print(tran)
                Utilities.show_ProgressHud(view: self.view)
                
                if (prod.productIdentifier == "com.senarios.iOSCyberScopeTV.150credit")
                {
                    self.updateUserBalanceWithAmount(amount: 150.0)
                }
            }
            //Utilities.hide_ProgressHud(view: self.view)
            print(alert.message)
            // Globals.shared.showWarnigMessage(alert.message)
        }
    }
    
    func resetAllButtons()
    {
        btn150.backgroundColor = UIColor.white
        btn150.setTitleColor(UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1), for: .normal)
        
        btn50.backgroundColor = UIColor.white
        btn50.setTitleColor(UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1), for: .normal)
        
        btn100.backgroundColor = UIColor.white
        btn100.setTitleColor(UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1), for: .normal)
        
        btn10.backgroundColor = UIColor.white
        btn10.setTitleColor(UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1), for: .normal)
    }
    
//
//   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("product_data.count \(product_data.count)")
//        return product_data.count
//    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "productListCell") as! productListCell
//        //cell.textLabel?.text = "\(self.product_data[indexPath.row].price)"
//        let product = product_data[indexPath.row]
//        cell.textLabel?.text = product.localizedTitle
//        cell.detailTextLabel?.text = product.localizedDescription
//        print(product.localizedPrice)
//        //cell.detailTextLabel?.text = "\(self.product_data[indexPath.row].localizedDescription)"
//        return cell
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    PKIAPHandler.shared.purchase(product: self.product_data[indexPath.row]) { (alert, product, transaction) in
//       if let tran = transaction, let prod = product {
//        print(tran)
//        Utilities.show_ProgressHud(view: self.view)
//
//        if (prod.productIdentifier == "com.senarios.iOSCyberScopeTV.150credit")
//        {
//            self.updateUserBalanceWithAmount(amount: 150.0)
//        }
//        else if (prod.productIdentifier == "com.senarios.iOSCyberScopeTV.100credit")
//            {
//            self.updateUserBalanceWithAmount(amount: 100.0)
//
//        }
//        else if (prod.productIdentifier == "com.senarios.iOSCyberScopeTV.50credit")
//        {
//            self.updateUserBalanceWithAmount(amount: 50.0)
//        }
//     }
//        //Utilities.hide_ProgressHud(view: self.view)
//        print(alert.message)
//      // Globals.shared.showWarnigMessage(alert.message)
//    }
//
//    }
    func updateUserBalanceWithAmount(amount: Double)
    {
        let userName = CurrentUser.get_User_username_fromUserDefaults() // "002130578"
        let loggedinUser = CurrentUser.Current_UserObject
        print("Old Balance:: \(loggedinUser.credit)\n")
        let newBalance = loggedinUser.credit + amount
        loggedinUser.credit = newBalance
        print(loggedinUser)
        self.lblCurrentCredits.text = "Current Credits : \(loggedinUser.credit)"
        print("New Balance:: \(loggedinUser.credit)\n")
        loggedinUser.setUserDefaults()
        CurrentUser.setCurrentUser_UserDefaults(user: loggedinUser)
        CurrentUser.Current_UserObject = CurrentUser.getCurrentUser_From_UserDefaults()
        
        let data = ["\(Constants.UserFields.username)": loggedinUser.username as AnyObject, "\(Constants.UserFields.credit)": loggedinUser.credit as AnyObject] as! AnyObject
        
        self.dataAccess.Update_Data_in_UsersTable(data, delegate: self)
    }
    
    func UpdateUser_ResponseSuccess(updated_user: User, status: Bool) {
        print("Balance updated successfully!")

        DispatchQueue.main.async {
            Utilities.hide_ProgressHud(view: self.view)
            self.navigationController?.popViewController(animated: true)
            self.backButton(UIButton())
        }
        
    }
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    func UpdateUser_ResponseError(_ error: NSError?)
    {
        print("\n UpdateUser_ResponseError called ... AND Error = \(String(describing: error)) \n")
    }
}


