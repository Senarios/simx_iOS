//
//  FundsTranferToBroadcasterViewController.swift
//  Cyberscope
//
//  Created by Salman on 02/08/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit

class FundsTranferToBroadcasterViewController: UIViewController, PayPalPaymentDelegate, PayPalFuturePaymentDelegate, PayPalProfileSharingDelegate//, FlipsideViewControllerDelegate
    //PayPalFuturePaymentDelegate, get_Users_Delegate, UpdateUser_Delegate, UpdateUserBalance_Delegate, PayPalProfileSharingDelegate
{
    var environment:String = PayPalEnvironmentSandbox //PayPalEnvironmentSandbox //PayPalEnvironmentNoNetwork //PayPalEnvironmentProduction
    {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    var resultText = "" // empty
    var payPalConfig = PayPalConfiguration() // default
    
    @IBOutlet weak var successView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = "PayPal SimX Payment"
        successView.isHidden = true
        
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = false
        payPalConfig.merchantName = "SimX"
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        // Setting the languageOrLocale property is optional.
        //
        // If you do not set languageOrLocale, then the PayPalPaymentViewController will present
        // its user interface according to the device's current language setting.
        //
        // Setting languageOrLocale to a particular language (e.g., @"es" for Spanish) or
        // locale (e.g., @"es_MX" for Mexican Spanish) forces the PayPalPaymentViewController
        // to use that language/locale.
        //
        // For full details, including a list of available languages and locales, see PayPalPaymentViewController.h.
        
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        
        // Setting the payPalShippingAddressOption property is optional.
        //
        // See PayPalConfiguration.h for details.
        
        payPalConfig.payPalShippingAddressOption = .payPal;
        
        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PayPalMobile.preconnect(withEnvironment: environment)
    }
    
    
    // MARK: Single Payment
    @IBAction func buyClothingAction(_ sender: AnyObject) {
        // Remove our last completed payment, just for demo purposes.
        resultText = ""
        
        // Note: For purposes of illustration, this example shows a payment that includes
        //       both payment details (subtotal, shipping, tax) and multiple items.
        //       You would only specify these if appropriate to your situation.
        //       Otherwise, you can leave payment.items and/or payment.paymentDetails nil,
        //       and simply set payment.amount to your total charge.
        
        // Optional: include multiple items
        let item1 = PayPalItem(name: "Old jeans with holes", withQuantity: 2, withPrice: NSDecimalNumber(string: "0.99"), withCurrency: "GBP", withSku: "Hip-0037")
        let item2 = PayPalItem(name: "Free rainbow patch", withQuantity: 1, withPrice: NSDecimalNumber(string: "0.00"), withCurrency: "GBP", withSku: "Hip-00066")
        let item3 = PayPalItem(name: "Long-sleeve plaid shirt (mustache not included)", withQuantity: 1, withPrice: NSDecimalNumber(string: "1.99"), withCurrency: "GBP", withSku: "Hip-00291")
        
        let items = [item1, item2, item3]
        let subtotal = PayPalItem.totalPrice(forItems: items)
        
        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "1.99")
        let tax = NSDecimalNumber(string: "0.50")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.adding(shipping).adding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: "GBP", shortDescription: "Hipster Clothing", intent: .sale)
        
        payment.items = items
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            present(paymentViewController!, animated: true, completion: nil)
        }
        else {
            // This particular payment will always be processable. If, for
            // example, the amount was negative or the shortDescription was
            // empty, this payment wouldn't be processable, and you'd want
            // to handle that here.
            print("Payment not processalbe: \(payment)")
        }
        
    }
    
    // PayPalPaymentDelegate
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        resultText = ""
        successView.isHidden = true
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            
            self.resultText = completedPayment.description
            self.showSuccess()
        })
    }
    
    // MARK: Future Payments
    
    @IBAction func authorizeFuturePaymentsAction(_ sender: AnyObject) {
        let futurePaymentViewController = PayPalFuturePaymentViewController(configuration: payPalConfig, delegate: self)
        present(futurePaymentViewController!, animated: true, completion: nil)
    }
    
    
    func payPalFuturePaymentDidCancel(_ futurePaymentViewController: PayPalFuturePaymentViewController) {
        print("PayPal Future Payment Authorization Canceled")
        successView.isHidden = true
        futurePaymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalFuturePaymentViewController(_ futurePaymentViewController: PayPalFuturePaymentViewController, didAuthorizeFuturePayment futurePaymentAuthorization: [AnyHashable: Any]) {
        print("PayPal Future Payment Authorization Success!")
        // send authorization to your server to get refresh token.
        futurePaymentViewController.dismiss(animated: true, completion: { () -> Void in
            self.resultText = futurePaymentAuthorization.description
            self.showSuccess()
        })
    }
    
    // MARK: Profile Sharing
    
    @IBAction func authorizeProfileSharingAction(_ sender: AnyObject) {
        let scopes = [kPayPalOAuth2ScopeOpenId, kPayPalOAuth2ScopeEmail, kPayPalOAuth2ScopeAddress, kPayPalOAuth2ScopePhone]
        let profileSharingViewController = PayPalProfileSharingViewController(scopeValues: NSSet(array: scopes) as Set<NSObject>, configuration: payPalConfig, delegate: self)
        present(profileSharingViewController!, animated: true, completion: nil)
    }
    
    // PayPalProfileSharingDelegate
    
    func userDidCancel(_ profileSharingViewController: PayPalProfileSharingViewController) {
        print("PayPal Profile Sharing Authorization Canceled")
        successView.isHidden = true
        profileSharingViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalProfileSharingViewController(_ profileSharingViewController: PayPalProfileSharingViewController, userDidLogInWithAuthorization profileSharingAuthorization: [AnyHashable: Any]) {
        print("PayPal Profile Sharing Authorization Success!")
        
        // send authorization to your server
        
        profileSharingViewController.dismiss(animated: true, completion: { () -> Void in
            self.resultText = profileSharingAuthorization.description
            self.showSuccess()
        })
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
//        if segue.identifier == "pushSettings" {
//            // [segue destinationViewController] setDelegate:(id)self];
//            if let flipSideViewController = segue.destination as? FlipsideViewController {
//                flipSideViewController.flipsideDelegate = self
//            }
//        }
    }
    
    
    // MARK: Helpers
    
    func showSuccess() {
        successView.isHidden = false
        successView.alpha = 1.0
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationDelay(2.0)
        successView.alpha = 0.0
        UIView.commitAnimations()
    }
    
//    func payPalFuturePaymentDidCancel(_ futurePaymentViewController: PayPalFuturePaymentViewController) {
//        <#code#>
//    }
//
//    func payPalFuturePaymentViewController(_ futurePaymentViewController: PayPalFuturePaymentViewController, didAuthorizeFuturePayment futurePaymentAuthorization: [AnyHashable : Any]) {
//        <#code#>
//    }
//
//    let userDefault = UserDefaults.standard
//    fileprivate let dataAccess = DataAccess.sharedInstance
//
//    var payPalConfig = PayPalConfiguration()
//    var enteredAmount = 0.0
//
//
//    @IBOutlet weak var label_titleNote: UITextView!
//    @IBOutlet weak var label_termsAndConditions: UILabel!
//
//    @IBOutlet weak var amountTextField: UITextField!
//
//    @IBOutlet weak var checkBoxButton: UIButton!
//    var checkBox_state: Bool = false
//
//    @IBOutlet weak var button_applyCouponCode: UIButton!
//
//    @IBAction func backButton(_ sender: UIButton) {
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    override func viewDidLoad()
//    {
//        super.viewDidLoad()
//
//        // Set up payPalConfig
//        payPalConfig.acceptCreditCards = false
//        payPalConfig.merchantName = "Senarios_CyberScopeTV" // Name of your company
//
//        // These urls are just Paypal merchant Privacy
//        payPalConfig.merchantPrivacyPolicyURL = URL(string: Constants.PayPal.merchantPrivacyPolicyURL)
//        payPalConfig.merchantUserAgreementURL = URL(string: Constants.PayPal.merchantUserAgreementURL)
//
//        // Language with which PayPal ios sdk will be show to user.Use 0 as default language
//        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
//        payPalConfig.payPalShippingAddressOption = .payPal
//
//        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")
//    }
//
//    override func viewWillAppear(_ animated: Bool)
//    {
//        super.viewWillAppear(animated)
//
//        self.setTextOf_UIElements()
//        PayPalMobile.preconnect(withEnvironment: environment)
//    }
//
//    func setTextOf_UIElements()
//    {
//        let currency = "GBP"
//        let formattedString = NSMutableAttributedString()
//        let font = CGFloat(14.0)
//        formattedString.bold(text: "“", fontSize: font).normal(text: "Please select the amount in ", fontSize: font).bold(text: currency, fontSize: font).normal(text: " you wish to recharge your ", fontSize: font).bold(text: "CHATTERBOX LIVESTREAM ACCOUNT", fontSize: font).normal(text: " with", fontSize: font).bold(text: "”", fontSize: font)
//
//        self.label_titleNote.attributedText = formattedString
//        self.label_titleNote.textColor = UIColor.darkGray
//        self.label_titleNote.textAlignment = .center
//    }
//
//    override func didReceiveMemoryWarning()
//    {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//
//    @IBAction func checkBoxButtonTapped(_ sender: Any)
//    {
//        if checkBox_state == true
//        {
//            checkBox_state = false
//            let img = UIImage(named: "uncheckedImage1")
//            checkBoxButton.setImage(img, for: UIControlState.normal)
//        }
//        else
//        {
//            checkBox_state = true
//            let img = UIImage(named: "checkedImg1")
//            checkBoxButton.setImage(img, for: UIControlState.normal)
//        }
//    }
//
//    @IBOutlet weak var AddCreditButton: UIButton!
//
//    @IBAction func AddCreditsButtonTapped(_ sender: Any)
//    {
//        if(checkBox_state == true)
//        {
//            if(self.amountTextField.text?.isEmpty)! || NSDecimalNumber(string: self.amountTextField.text) == 0 || self.amountTextField.text?.characters.count == 0
//            {
//                Toast(text: "Please enter valid amount to continue.").show()
//            }
//            else
//            {
//
//                self.enteredAmount = Double((self.amountTextField.text! as NSString).doubleValue) // Double(self.amountTextField.text!)!
//
//                // Optional: include multiple items
//                let item1 = PayPalItem(name: "Pay for Chatterbox Livestream", withQuantity: 1, withPrice: NSDecimalNumber(string: "\(self.enteredAmount.roundTo(places: 2))"), withCurrency: "GBP", withSku: "Hip-0037")
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
//                let payment = PayPalPayment(amount: total, currencyCode: "GBP", shortDescription: "Chatterbox Livestream", intent: .sale)
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
//            }
//        }
//        else
//        {
//            Toast(text: "Please accept terms and conditions.").show()
//        }
//    }
//
//    @IBAction func ApplyCoupen_ButtonTapped(_ sender: Any)
//    {
//        print("\n ApplyCoupen_ButtonTapped ... \n")
//        self.show_enterCoupenCode_Alert()
//    }
//
//    func show_enterCoupenCode_Alert()
//    {
//        let alertController = UIAlertController(title: "Coupon code?", message: "Please enter a valid coupon code to apply", preferredStyle: .alert)
//
//        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
//
//            if let field = alertController.textFields?[0]
//            {
//                // store your data
//                if((field.text?.isEmpty)! || field.text?.characters.count == 0 || field.text == "")
//                {
//                    Toast(text: "Please enter a valid coupon code to proceed").show()
//                }
//                else
//                {
//                    // Do what you want to do with coupen code
//                }
//            }
//            else
//            {
//                // user did not fill field
//            }
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
//
//        alertController.addTextField { (textField) in
//            textField.placeholder = "Coupen Code"
//            textField.keyboardType = .numberPad
//        }
//
//        alertController.addAction(confirmAction)
//        alertController.addAction(cancelAction)
//
//        self.present(alertController, animated: true, completion: nil)
//    }
//    //  ********
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
//    {
//        self.view.endEditing(true)
//    }
//
//
//    ////////////////////////////////////////||
//    //                                      ||
//    //   PayPal Payment Delegate Methods    ||
//    //                                      ||
//    ////////////////////////////////////////||
//
//    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController)
//    {
//        print("PayPal Payment Cancelled")
//        Toast(text: "PayPal Payment Cancelled", delay: 1.0, duration: 5.0).show()
//        paymentViewController.dismiss(animated: true, completion: nil)
//    }
//
//    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment)
//    {
//        print("\nPayPal Payment Success !")
//        Toast(text: "PayPal Payment Success !!", delay: 1.0, duration: 5.0).show()
//
//        paymentViewController.dismiss(animated: true, completion: { () -> Void in
//
//            // send completed confirmaion to your server
//            print("Here is your proof of payment:\n ==> \n \(completedPayment.confirmation)\n <== \n Send this to your server for confirmation and fulfillment.")
//            print(completedPayment.debugDescription)
//
//            DispatchQueue.main.async {
//                self.updateUserBalanceWithAmount(amount: Double(completedPayment.amount))
//            }
//
//            let alert = UIAlertController(title: "SUCCESS", message: "Your transaction of \(completedPayment.localizedAmountForDisplay) completed successfully.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
//                // perhaps use action.title here
//
//                // Update user credit
//            })
//            self.present(alert, animated: true)
//        })
//    }
//
//    // Function to get users detail
//    func updateUserBalanceWithAmount(amount: Double)
//    {
//        let userName = CurrentUser.get_User_username_fromUserDefaults() // "002130578"
//        let loggedinUser = CurrentUser.Current_UserObject
//        print("Old Balance:: \(loggedinUser.credit)\n")
//        let newBalance = loggedinUser.credit + amount
//        loggedinUser.credit = newBalance
//        print(loggedinUser)
//        print("New Balance:: \(loggedinUser.credit)\n")
//        loggedinUser.setUserDefaults()
//        CurrentUser.setCurrentUser_UserDefaults(user: loggedinUser)
//        CurrentUser.Current_UserObject = CurrentUser.getCurrentUser_From_UserDefaults()
//
//        let data = ["\(Constants.UserFields.username)": loggedinUser.username as AnyObject, "\(Constants.UserFields.credit)": loggedinUser.credit as AnyObject] as! AnyObject
//
//        self.dataAccess.Update_Data_in_UsersTable(data, delegate: self)
//    }
//
//    func UpdateUser_ResponseSuccess(updated_user: User, status: Bool) {
//        print("Balance updated successfully!")
//    }
//
//    ////////////////////////////////////////||
//    //                                      ||
//    //      get_Users_Delegate  Methods     ||
//    //                                      ||
//    ////////////////////////////////////////||
//
//    func get_Users_Success(_ users: [User])
//    {
//        print("\n=> get_Users_Success called in AddCredits PayPal VC \n=> Successfully get User Data from DB!!")
//
//        if(users.count > 0)
//        {
//            let user = users.last
//            print("\nUser data before Update credit...")
//            CurrentUser.printCurrentUser_Details(user: user!)
//
//            CurrentUser.setCurrentUser_UserDefaults(user: user!)
//            CurrentUser.Current_UserObject = CurrentUser.getCurrentUser_From_UserDefaults()
//
//            let newCredit = CurrentUser.Current_UserObject.credit + self.enteredAmount
//
//            CurrentUser.Current_UserObject.credit = newCredit
//            CurrentUser.printCurrentUser_Details(user: CurrentUser.Current_UserObject)
//
//            self.dataAccess.Update_UserData(CurrentUser.Current_UserObject, delegate: self)
//        }
//        else
//        {
//            print("No User exist against this userName => \(CurrentUser.get_User_username_fromUserDefaults())")
//        }
//    }
//
//    func get_Users_Error(_ error: NSError?)
//    {
//        print("\n get_Users_Error called ... AND Error = \(String(describing: error)) \n")
//    }
//
//    //////////////////////////////////////////||
//    //                                        ||
//    //      UpdateUser_Delegate  Methods      ||
//    //                                        ||
//    //////////////////////////////////////////||
//
//    func UpdateUser_ResponseSuccess(isUserUpdated: Bool)
//    {
//        if (isUserUpdated) {
//            print("User Credit Updated Successfully")
//        }
//        else {
//            print("User Credit Updated Failed")
//        }
//    }
//
//    func UpdateUser_ResponseError(_ error: NSError?)
//    {
//        print("\n UpdateUser_ResponseError called ... AND Error = \(String(describing: error)) \n")
//    }
}
