//
//  ViewController.swift
//  PayPall_PayU_DemoAPp
//
//  Created by saad furqan on 24/11/2016.
//  Copyright © 2016 Senarios. All rights reserved.
//

import UIKit
import Braintree
import Toaster
import MBProgressHUD
import PassKit
class AddCreditsViewController: UIViewController, PayPalPaymentDelegate, get_Users_Delegate, UpdateUser_Delegate, UpdateUserBalance_Delegate
{
	let userDefault = UserDefaults.standard
	fileprivate let dataAccess = DataAccess.sharedInstance
    var braintreeClient: BTAPIClient?

    
    
    var environment:String = PayPalEnvironmentNoNetwork
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
    var enteredAmount = 0.0
    
    
    @IBOutlet weak var label_titleNote: UITextView!
    @IBOutlet weak var label_termsAndConditions: UILabel!
    
    @IBOutlet weak var lblCurrentCredits: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var checkBoxButton: UIButton!
    var checkBox_state: Bool = false
    
    @IBOutlet weak var button_applyCouponCode: UIButton!
    
    @IBOutlet weak var viewEnterAmount: UIView!
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set up payPalConfig
        braintreeClient = BTAPIClient(authorization: "sandbox_9q89x3nw_j6wyd3mqd9vtfms2")!
        payPalConfig.acceptCreditCards = false
        //payPalConfig.merchantName = "SimX"
         payPalConfig.merchantName = "SimXLive"
        //payPalConfig.merchantName = "TellinMedicine"
        payPalConfig.merchantName = "NJU3P28NT39UW"
        
    
        
        // These urls are just Paypal merchant Privacy
        payPalConfig.merchantPrivacyPolicyURL = URL(string: Constants.SandboxPayPal.merchantPrivacyPolicyURL)
        payPalConfig.merchantUserAgreementURL = URL(string: Constants.SandboxPayPal.merchantUserAgreementURL)
        
        // Language with which PayPal ios sdk will be show to user.Use 0 as default language
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        payPalConfig.payPalShippingAddressOption = .payPal
        
        
        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")
        
        self.viewEnterAmount.layer.cornerRadius = 10
        self.viewEnterAmount.layer.borderWidth = 1
        self.viewEnterAmount.layer.borderColor = UIColor.lightGray.cgColor
        self.viewEnterAmount.backgroundColor = .white
        
        self.AddCreditButton.layer.cornerRadius = 30
        let loggedinUser = CurrentUser.Current_UserObject
        self.lblCurrentCredits.text = "Current Credits : \(loggedinUser.credit)"
        
        if #available(iOS 11.0, *) {
            let guide = self.view.safeAreaLayoutGuide
            self.view.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
            self.view.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
            self.view.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
            self.view.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.setTextOf_UIElements()
        PayPalMobile.preconnect(withEnvironment: environment)
    }
    
    func setTextOf_UIElements()
    {
        let currency = "GBP"
        let formattedString = NSMutableAttributedString()
        let font = CGFloat(14.0)
        formattedString.bold(text: "“", fontSize: font).normal(text: "Please select the amount in ", fontSize: font).bold(text: currency, fontSize: font).normal(text: " you wish to recharge your ", fontSize: font).bold(text: "SimX ACCOUNT", fontSize: font).normal(text: " with", fontSize: font).bold(text: "”", fontSize: font)
        
        self.label_titleNote.attributedText = formattedString
        self.label_titleNote.textColor = UIColor.darkGray
        self.label_titleNote.textAlignment = .center
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func checkBoxButtonTapped(_ sender: Any)
    {
        if checkBox_state == true
        {
            checkBox_state = false
            let img = UIImage(named: "uncheckedImage1")
            checkBoxButton.setImage(img, for: UIControlState.normal)
        }
        else
        {
            checkBox_state = true
            let img = UIImage(named: "checkedImg1")
            checkBoxButton.setImage(img, for: UIControlState.normal)
        }
    }
    
    @IBOutlet weak var AddCreditButton: UIButton!
    
    @IBAction func AddCreditsButtonTapped(_ sender: Any)
    {
        if(checkBox_state == true)
        {
            if(self.amountTextField.text?.isEmpty)! || NSDecimalNumber(string: self.amountTextField.text) == 0 || self.amountTextField.text?.characters.count == 0
            {
                Toast(text: "Please enter valid amount to continue.").show()
            }
            else
            {
                Payouts()
//                self.enteredAmount = Double((self.amountTextField.text! as NSString).doubleValue) // Double(self.amountTextField.text!)!
//
//                // Optional: include multiple items
//                let item1 = PayPalItem(name: "Pay for SimX", withQuantity: 1, withPrice: NSDecimalNumber(string: "\(self.enteredAmount.roundTo(places: 2))"), withCurrency: "GBP", withSku: "Hip-0037")
//
//                let items = [item1]
//                let subtotal = PayPalItem.totalPrice(forItems: items)
//
//                // Optional: include payment details
//                let shipping = NSDecimalNumber(string: "0.0")
//                let tax = NSDecimalNumber(string: "0.0")
//                let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
//
//                let total = subtotal.adding(shipping).adding(tax)
//
//                // main point here ...
//                let payment = PayPalPayment(amount: total, currencyCode: "GBP", shortDescription: "SimX", intent: .sale)
//
//                payment.items = items
//                payment.paymentDetails = paymentDetails
//
//                if (payment.processable)
//                {
//                    let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
//                    present(paymentViewController!, animated: true, completion: nil)
//                }
//                else
//                {
//                    // This particular payment will always be processable. If, for
//                    // example, the amount was negative or the shortDescription was
//                    // empty, this payment wouldn't be processable, and you'd want
//                    // to handle that here.
//                    print("Payment not processalbe: \(payment)")
//                    Toast(text: "Payment not processalbe: \(payment)").show()
//                }
            }
        }
        else
        {
            Toast(text: "Please accept terms and conditions.").show()
        }
    }
    func Payouts() {
        
        self.enteredAmount = Double((self.amountTextField.text! as NSString).doubleValue)
        var paymentRequest: PKPaymentRequest = {
               let request = PKPaymentRequest()
               request.merchantIdentifier = "merchant.com.senarios.iOSCyberScopeTV"
               request.supportedNetworks = [.visa, .masterCard,.amex,.discover]
               request.supportedCountries = ["GB"]
               request.merchantCapabilities = .capability3DS
               request.countryCode = "GB"
               request.currencyCode = "GBP"
            request.paymentSummaryItems = [PKPaymentSummaryItem(label: "H2Startup", amount: NSDecimalNumber(value: self.enteredAmount))]
               return request
           }()
        if let controller = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) {
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        }
        
//
//        MBProgressHUD.showAdded(to: self.view, animated: true)
//        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient!)
//        // Specify the transaction amount here. "2.32" is used in this example.
//            self.enteredAmount = Double((self.amountTextField.text! as NSString).doubleValue) // Double(self.amountTextField.text!)!
//        let request = BTPayPalRequest(amount: "\(self.enteredAmount.roundTo(places: 2))")
//        request.currencyCode = "GBP"
//        request.displayName = "Pay for SimX"
//
//
//
//        payPalDriver.requestOneTimePayment(request) { (tokenizedPayPalAccount, error) in
//            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
//                print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
//
//                // Access additional information
//                let email = tokenizedPayPalAccount.email
//                let firstName = tokenizedPayPalAccount.firstName
//                let lastName = tokenizedPayPalAccount.lastName
//                let phone = tokenizedPayPalAccount.phone
//
//                // See BTPostalAddress.h for details
//                let billingAddress = tokenizedPayPalAccount.billingAddress
//                let shippingAddress = tokenizedPayPalAccount.shippingAddress
//                print(email,firstName,lastName,phone,billingAddress,shippingAddress)
//
//                print("\nPayPal Payment Success !")
//                //Toast(text: "PayPal Payment Success !!", delay: 1.0, duration: 5.0).show()
//
//
//
//                    // send completed confirmaion to your server
//
//                    DispatchQueue.main.async {
//                        MBProgressHUD.hide(for: self.view, animated: true)
//                        self.updateUserBalanceWithAmount(amount: self.enteredAmount.roundTo(places: 2))
//                        //self.updateUserBalanceWithAmount(amount: Double(truncating: completedPayment.amount))
//                    }
//
//                    let alert = UIAlertController(title: "SUCCESS", message: "Your transaction of \(self.enteredAmount.roundTo(places: 2)) completed successfully.", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
//                        // perhaps use action.title here
//
//                       // Update user credit
//                    })
//                    self.present(alert, animated: true)
//
//
//            } else if let error = error {
//                MBProgressHUD.hide(for: self.view, animated: true)
//                print(error.localizedDescription)
//
//                // Handle error here...
//            } else {
//                MBProgressHUD.hide(for: self.view, animated: true)
//                print("Buyer Cancel Payment req")
//                Toast(text: "PayPal Payment Cancelled", delay: 1.0, duration: 5.0).show()
//
//
//            }
//        }
        
//        {
//            self.enteredAmount = Double((self.amountTextField.text! as NSString).doubleValue) // Double(self.amountTextField.text!)!
//
//            // Optional: include multiple items
//            let item1 = PayPalItem(name: "Pay for SimX", withQuantity: 1, withPrice: NSDecimalNumber(string: "\(self.enteredAmount.roundTo(places: 2))"), withCurrency: "GBP", withSku: "Hip-0037")
//
//            let items = [item1]
//            let subtotal = PayPalItem.totalPrice(forItems: items)
//
//            // Optional: include payment details
//            let shipping = NSDecimalNumber(string: "0.0")
//            let tax = NSDecimalNumber(string: "0.0")
//            let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
//
//            let total = subtotal.adding(shipping).adding(tax)
//
//            // main point here ...
//            let payment = PayPalPayment(amount: total, currencyCode: "GBP", shortDescription: "SimX", intent: .sale)
//
//            payment.items = items
//            payment.paymentDetails = paymentDetails
//
//            if (payment.processable)
//            {
//                let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
//                present(paymentViewController!, animated: true, completion: nil)
//            }
//            else
//            {
//                // This particular payment will always be processable. If, for
//                // example, the amount was negative or the shortDescription was
//                // empty, this payment wouldn't be processable, and you'd want
//                // to handle that here.
//                print("Payment not processalbe: \(payment)")
//                Toast(text: "Payment not processalbe: \(payment)").show()
//            }
//        }
    
        // Do any additional setup after loading the view.
    }
    
    @IBAction func ApplyCoupen_ButtonTapped(_ sender: Any)
    {
        print("\n ApplyCoupen_ButtonTapped ... \n")
        self.show_enterCoupenCode_Alert()
    }
    
    func show_enterCoupenCode_Alert()
    {
        let alertController = UIAlertController(title: "Coupon code?", message: "Please enter a valid coupon code to apply", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            
            if let field = alertController.textFields?[0]
            {
                // store your data
                if((field.text?.isEmpty)! || field.text?.characters.count == 0 || field.text == "")
                {
                    Toast(text: "Please enter a valid coupon code to proceed").show()
                }
                else
                {
                    // Do what you want to do with coupen code
                }
            }
            else
            {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Coupen Code"
            textField.keyboardType = .numberPad
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    //  ********
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    
    ////////////////////////////////////////||
    //                                      ||
    //   PayPal Payment Delegate Methods    ||
    //                                      ||
    ////////////////////////////////////////||

    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController)
    {
        print("PayPal Payment Cancelled")
        Toast(text: "PayPal Payment Cancelled", delay: 1.0, duration: 5.0).show()
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment)
    {
        print("\nPayPal Payment Success !")
        //Toast(text: "PayPal Payment Success !!", delay: 1.0, duration: 5.0).show()
        
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n ==> \n \(completedPayment.confirmation)\n <== \n Send this to your server for confirmation and fulfillment.")
            print(completedPayment.debugDescription)
            
            DispatchQueue.main.async {
                self.updateUserBalanceWithAmount(amount: Double(completedPayment.amount))
                //self.updateUserBalanceWithAmount(amount: Double(truncating: completedPayment.amount))
            }
            
            let alert = UIAlertController(title: "SUCCESS", message: "Your transaction of \(completedPayment.localizedAmountForDisplay) completed successfully.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                // perhaps use action.title here
                
               // Update user credit
            })
            self.present(alert, animated: true)
        })
    }
    
    // Function to get users detail
    func updateUserBalanceWithAmount(amount: Double)
    {
        let userName = CurrentUser.get_User_username_fromUserDefaults() // "002130578"
        let loggedinUser = CurrentUser.Current_UserObject
        print("Old Balance:: \(loggedinUser.credit)\n")
        let newBalance = loggedinUser.credit + amount
        loggedinUser.credit = newBalance
        print(loggedinUser)
        print("New Balance:: \(loggedinUser.credit)\n")
        loggedinUser.setUserDefaults()
        CurrentUser.setCurrentUser_UserDefaults(user: loggedinUser)
        CurrentUser.Current_UserObject = CurrentUser.getCurrentUser_From_UserDefaults()
        
        let data = ["\(Constants.UserFields.username)": loggedinUser.username as AnyObject, "\(Constants.UserFields.credit)": loggedinUser.credit as AnyObject] as! AnyObject
        
        self.dataAccess.Update_Data_in_UsersTable(data, delegate: self)
    }
    
    func UpdateUser_ResponseSuccess(updated_user: User, status: Bool) {
        print("Balance updated successfully!")
        
        DispatchQueue.global().async {
            self.navigationController?.popViewController(animated: true)
            self.backButton(UIButton())
        }
        
    }
    
    ////////////////////////////////////////||
    //                                      ||
    //      get_Users_Delegate  Methods     ||
    //                                      ||
    ////////////////////////////////////////||
    func showSuccess(inputString: NSObject) {

        print("this is done successfully :) ")
        print("send this to server \(inputString)")
    }
    
    func get_Users_Success(_ users: [User])
    {
        print("\n=> get_Users_Success called in AddCredits PayPal VC \n=> Successfully get User Data from DB!!")
        
        if(users.count > 0)
        {
            let user = users.last
            print("\nUser data before Update credit...")
            CurrentUser.printCurrentUser_Details(user: user!)
            
            CurrentUser.setCurrentUser_UserDefaults(user: user!)
            CurrentUser.Current_UserObject = CurrentUser.getCurrentUser_From_UserDefaults()
            
            let newCredit = CurrentUser.Current_UserObject.credit + self.enteredAmount
            
            CurrentUser.Current_UserObject.credit = newCredit
            CurrentUser.printCurrentUser_Details(user: CurrentUser.Current_UserObject)
            
            self.dataAccess.Update_UserData(CurrentUser.Current_UserObject, delegate: self)
        }
        else
        {
            print("No User exist against this userName => \(CurrentUser.get_User_username_fromUserDefaults())")
        }
    }
    
    func get_Users_Error(_ error: NSError?)
    {
        print("\n get_Users_Error called ... AND Error = \(String(describing: error)) \n")
    }
    
    //////////////////////////////////////////||
    //                                        ||
    //      UpdateUser_Delegate  Methods      ||
    //                                        ||
    //////////////////////////////////////////||
    
    func UpdateUser_ResponseSuccess(isUserUpdated: Bool)
    {
        if (isUserUpdated) {
            print("User Credit Updated Successfully")
        }
        else {
            print("User Credit Updated Failed")
        }
    }
    
    func UpdateUser_ResponseError(_ error: NSError?)
    {
        print("\n UpdateUser_ResponseError called ... AND Error = \(String(describing: error)) \n")
    }
}
extension AddCreditsViewController: PKPaymentAuthorizationViewControllerDelegate {
 
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
 
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        print(controller.description)
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.updateUserBalanceWithAmount(amount: self.enteredAmount.roundTo(places: 2))
            //self.updateUserBalanceWithAmount(amount: Double(truncating: completedPayment.amount))
        }

        let alert = UIAlertController(title: "SUCCESS", message: "Your transaction of \(self.enteredAmount.roundTo(places: 2)) completed successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
            // perhaps use action.title here

           // Update user credit
        })
        self.present(alert, animated: true)
        controller.dismiss(animated: true, completion: nil)
    }
 
}
