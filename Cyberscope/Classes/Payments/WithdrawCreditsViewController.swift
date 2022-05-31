//
//  WithdrawCreditsViewController.swift
//  Cyberscope
//
//  Created by Salman on 03/08/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import Toaster
import Alamofire
import CountryPickerView
class WithdrawCreditsViewController: UIViewController, UpdateUser_Delegate, UITextFieldDelegate {
    
    @IBOutlet weak var bankName: UITextField!
    @IBOutlet weak var txtPayeeName: UITextField!
    @IBOutlet weak var accountNumber: UITextField!
    @IBOutlet weak var ibanNumber: UITextField!
    @IBOutlet weak var sortcodetext: UITextField!
    @IBOutlet weak var bicCodeText: UITextField!
    @IBOutlet weak var phoneNumberText: UITextField!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    
    @IBOutlet weak var viewConfrimEmail: UIView!
    @IBOutlet weak var viewEmail: UIView!
    
    @IBOutlet weak var btnSendPayment: UIButton!
    let kGmailAccount   = "colinjohn563@gmail.com"
    let kGmailPassword  = "Lisaco563gmail"
    var access_token = ""
    weak var cpvTextField: CountryPickerView!
    
    @IBAction func sendRequestAction(_ sender: UIButton) {
         if (currentUser.credit <= 49.0) {
            Alert.showAlertWithMessageAndTitle(message: "Balance shoud be Greater then £ 50", title: "Info!")
        }
        else if (self.bankName.text == "") {
            Alert.showAlertWithMessageAndTitle(message: "Please Enter Bank Name", title: "Info!")
        }
        
        else if (self.accountNumber.text == "") {
            Alert.showAlertWithMessageAndTitle(message: "Please Enter Bank Account ", title: "Info!")
        }
        else if (self.accountNumber.text?.count ?? 0 > 18 || self.accountNumber.text?.count ?? 0 < 9 ) {
            Alert.showAlertWithMessageAndTitle(message: "Please Enter Correct Bank Account , Account Number must be Between 9 To 18", title: "Info!")
        }
        else if (self.accountNumber.text?.count ?? 0 > 18 || self.accountNumber.text?.count ?? 0 < 9 ) {
            Alert.showAlertWithMessageAndTitle(message: "Please Enter Correct Bank Account , Account Number must be Between 9 To 18", title: "Info!")
        }
        else {

            print("\nabout to send money to USER!\n")
            let alert = UIAlertController(title: "Confirm!", message: "Are you sure your provided Bank name And Account  is  correct.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes I Confirm", style: .default) { action in
                DispatchQueue.main.async {
                    Utilities.show_ProgressHud(view: self.view)
                    //self.sendEmail_toADMIN(HtmlString: "Test SimX Email", payment_mode: "PayPal")
                    self.sendPaymentToUser()
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .default) { action in
                // perhaps use action.title here
            })
            self.present(alert, animated: true)
        }
    }
    
    var currentUser = CurrentUser.getCurrentUser_From_UserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cp = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        phoneNumberText.leftView = cp
        phoneNumberText.leftViewMode = .always
        self.cpvTextField = cp
        
//        self.viewEmail.layer.cornerRadius = 10
//        self.viewEmail.layer.borderWidth = 1
//        self.viewEmail.layer.borderColor = UIColor.lightGray.cgColor
//        self.viewEmail.backgroundColor = .white
//        self.viewConfrimEmail.layer.cornerRadius = 10
//        self.viewConfrimEmail.layer.borderWidth = 1
//        self.viewConfrimEmail.layer.borderColor = UIColor.lightGray.cgColor
//        self.viewConfrimEmail.backgroundColor = .white
        self.btnSendPayment.layer.cornerRadius = 30
        
//        if #available(iOS 11.0, *) {
//           let guide = self.view.safeAreaLayoutGuide
//           self.view.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
//           self.view.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
//           self.view.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
//           self.view.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
//       } else {
//           // Fallback on earlier versions
//       }

    }

    override func viewDidAppear(_ animated: Bool) {
        self.rateLabel.text = "Current Credit : £\(currentUser.credit)"
       // self.getAccessToken()
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        self.moveBack()
    }
    @IBAction func btnBackClicked(_ sender: Any) {
        self.moveBack()
    }
    
    func moveBack()
    {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
            self.navigationController?.popViewController(animated: true)
        }
    }
    // MARK: - Genrate Random Code
    
    func randomNumberWith(digits:Int) -> Int {
        let min = Int(pow(Double(10), Double(digits-1))) - 1
        let max = Int(pow(Double(10), Double(digits))) - 1
        return Int(Range(uncheckedBounds: (min, max)))
    }
    


    
    func getAccessToken() {
//        let PAYPAL_CLIENT_ID = Constants.SandboxPayPal.sandbox_ClientId
//        let PAYPAL_SECRET = Constants.SandboxPayPal.sandBoxSectret
        let urlString = "https://api.sandbox.paypal.com/v1/oauth2/token"
        let PAYPAL_CLIENT_ID = Constants.SandboxPayPal.sandbox_ClientId
        let PAYPAL_SECRET = Constants.SandboxPayPal.sandBoxSectret
//        let urlString = "https://api.paypal.com/v1/oauth2/token"
        let loginString = String(format: "%@:%@", PAYPAL_CLIENT_ID, PAYPAL_SECRET)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        let bodyStr = "grant_type=client_credentials"
        let bodyData = bodyStr.data(using: String.Encoding.utf8, allowLossyConversion: true)
        request.httpBody = bodyData
        request.addValue("application/x-www-form-urlencoded",forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(base64LoginString)",forHTTPHeaderField: "Authorization")
        print ("hitting api")
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        { data, response, error in
            
            if error != nil {
                print("Error -> \(error)")
                return
            }
            do {
                let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                print("Response data \(result)")
                
                if let accessToken = result["access_token"] as? String {
                    self.access_token = accessToken
                    print("success in response")
                }
                else {
                   print("error in response")
                }
            } catch {
                print("Error -> \(error)")
            }
        }
        task.resume()
    }
    
    func sendPaymentToUser(){
        DispatchQueue.main.async {
            Utilities.show_ProgressHud(view: self.view)
        }
        let url:String = Constants.API_URLs.Base_URL + "admin/payments.php"
        
        Alamofire.upload(multipartFormData: { multipartFormData in
           
            multipartFormData.append(CurrentUser.get_User_username_fromUserDefaults().data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "username")
            multipartFormData.append(self.bankName.text!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "bank_name")
            multipartFormData.append(self.accountNumber.text!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "account_no")
            multipartFormData.append("\(self.currentUser.credit)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "pending_credit")
            multipartFormData.append(self.txtPayeeName.text!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "payee_name")
            multipartFormData.append(self.bicCodeText.text!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "bic")
            multipartFormData.append(self.sortcodetext.text!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "sort_code")
            multipartFormData.append(self.ibanNumber.text!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "iban")
            multipartFormData.append(self.phoneNumberText.text!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "phone_no")
            
        }, to: url, encodingCompletion: { result in
            switch result {
            case .success(request: let request, streamingFromDisk: false, streamFileURL: nil):
                request.responseJSON(completionHandler: {(response) in
                    
                    Utilities.hide_ProgressHud(view: self.view)
                    do{
                        Utilities.hide_ProgressHud(view: self.view)
                        let decodedata = try JSONDecoder().decode(WithdrawPayment.self, from: response.data!)
                        if (decodedata.data.emailStatus == "1") {
                            self.rateLabel.text = "Current Credit : £0.0)"
                            let refreshAlert = UIAlertController(title: "Payment", message: decodedata.data.msg, preferredStyle: UIAlertControllerStyle.alert)
                            
                            refreshAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
                                // self.deleteVideoCV()
                                print("Handle CANCEL Logic here")
                                
                            }))
                            self.present(refreshAlert, animated: true, completion: nil)
                            //print(batchHeader)
                        }
                        else if (decodedata.data.emailStatus == "0") {
                            self.rateLabel.text = "Current Credit : £0.0)"
                            let refreshAlert = UIAlertController(title: "Payment", message: decodedata.data.msg, preferredStyle: UIAlertControllerStyle.alert)
                            
                            refreshAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
                                // self.deleteVideoCV()
                                print("Handle CANCEL Logic here")
                                
                            }))
                            self.present(refreshAlert, animated: true, completion: nil)
                            //print(batchHeader)
                        }
                        
                        
                    } catch let err
                    {
                        print(err)
                    }
                })
                    break

                case .failure:
                    print("failed api calling")
                    break


                case .success(let request, true, _):
                    //Code here
                    break

                case .success(let request, _, _):
                    // Code here
                    break
                }
            })
        
//        let parameters: Parameters = [
//
//            "username": CurrentUser.get_User_username_fromUserDefaults(),
//            "bank_name": self.bankName.text!,
//            "account_no": self.accountNumber.text!,
//            "credit":  "\(currentUser.credit)",
//            "payee_name": self.txtPayeeName.text!,
//            "bic": self.bicCodeText.text!,
//            "sort_code": self.sortcodetext.text!,
//            "iban": self.ibanNumber.text!,
//            "phone_no": self.phoneNumberText.text!
//        ]
//
//        Alamofire.request(url ,method: .post , parameters: parameters,encoding: JSONEncoding.default).responseJSON{
//            (response) in
//            switch response.result
//            {
//            case .success:
//                print(response)
//                do{
//                    Utilities.hide_ProgressHud(view: self.view)
//                    let decodedata = try JSONDecoder().decode(WithdrawPayment.self, from: response.data!)
//                    if (decodedata.emailStatus == "1") {
//                        self.rateLabel.text = "Current Credit : £0.0)"
//                        let refreshAlert = UIAlertController(title: "Payment", message: decodedata.data.msg, preferredStyle: UIAlertControllerStyle.alert)
//
//                            refreshAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
//                                       // self.deleteVideoCV()
//                                        print("Handle CANCEL Logic here")
//
//                            }))
//                        self.present(refreshAlert, animated: true, completion: nil)
//                        //print(batchHeader)
//                    }
//                    else if (decodedata.emailStatus == "0") {
//                        self.rateLabel.text = "Current Credit : £0.0)"
//                        let refreshAlert = UIAlertController(title: "Payment", message: decodedata.data.msg, preferredStyle: UIAlertControllerStyle.alert)
//
//                            refreshAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
//                                       // self.deleteVideoCV()
//                                        print("Handle CANCEL Logic here")
//
//                            }))
//                        self.present(refreshAlert, animated: true, completion: nil)
//                        //print(batchHeader)
//                    }
//
//
//                } catch let err
//                {
//                    print(err)
//                }
//
//                break
//            default:
//                break
//            }
//
//        }
        
        
        
    }
    
//    func sendPaymentToUser() {
//        if (self.access_token == "") {
//            print("No access token found")
//            return
//        }
//        let timeStamp = Date().timeIntervalSince1970
//        let batchRequestIdentifier = "\(self.currentUser.name)\(timeStamp)"
//        let urlString = "https://api.sandbox.paypal.com/v1/payments/payouts"
//        //let urlString = "https://api.paypal.com/v1/payments/payouts"
//        let url = NSURL(string: urlString)!
//        let request = NSMutableURLRequest(url: url as URL)
//        let decimalCredit = String(format: "%.2f", self.currentUser.credit)
//        print("decimal credit: \(decimalCredit)")
//        request.httpMethod = "POST"
//        let jsonObject = [
//            "sender_batch_header" : [
//                "sender_batch_id" : "\(batchRequestIdentifier)",
//                "email_subject": "You have a payout!",
//                "email_message": "You have received a payout by SimX! Thanks for using our service!"
//            ],
//            "items": [
//                [
//                    "recipient_type": "EMAIL",
//                    "amount": [
//                        "value": "\(decimalCredit)",
//                        "currency": "GBP"
//                    ],
//                    "note": "Thanks for your patronage!",
//                    "sender_item_id": "187876756513457",
//                    //"receiver": self.emailField.text!
//                ]
//            ]
//        ] as [String : Any]
//        var jsonData233 = ""
//        if let theJSONData = try? JSONSerialization.data(
//            withJSONObject: jsonObject,
//            options: []) {
//            let theJSONText = String(data: theJSONData,
//                                     encoding: .ascii)
//            print("JSON string = \(theJSONText!)")
//            jsonData233 = theJSONText!
//        }
//
//        let jsonObjectString = jsonData233//jsonObject.description // string conversion of [String : Any]
//        let bodyData = jsonObjectString.data(using: String.Encoding.utf8, allowLossyConversion: true)
//        request.httpBody = bodyData
//        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
//        request.addValue("Bearer \(self.access_token)",forHTTPHeaderField: "Authorization")
//        let task = URLSession.shared.dataTask(with: request as URLRequest)
//        { data, response, error in
//
//            if error != nil {
//                DispatchQueue.main.async {
//                    Utilities.hide_ProgressHud(view: self.view)
//                }
//                //SwiftSpinner.hide()
//                NSLog("\nError sending emailwith error:  \(String(describing: error))\n")
//                Alert.showAlertWithMessageAndTitle(message: String(describing: error), title: "Error sending email!")
//                return
//            }
//            do {
//                let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
//                print("Response data \(result)")
//                if let batchHeader = result["batch_header"] {
//                    self.updateUserBalanceWithAmount(amount: 0.0)
//                    Toast(text: "Payment request sent Successfully through PayPal").show()
//                    //print(batchHeader)
//                }
//                else {
//                    print("\nFound some error in here!\n")
//                    var rsponseMessage = "PayOut Error\n"
//                    if let message = result["message"] {
//                        rsponseMessage = rsponseMessage + "message: \(message as! String)\n"
//                    }
//                    if let debug_id = result["debug_id"] {
//                        rsponseMessage = rsponseMessage + "debug_id: \(debug_id as! String)\n"
//                    }
//                    if let information_link = result["information_link"] {
//                        rsponseMessage = rsponseMessage + "info_link: \(information_link as! String)\n"
//                    }
//                    DispatchQueue.main.async {
//                        Utilities.hide_ProgressHud(view: self.view)
//                        Alert.showAlertWithMessageAndTitle(message: rsponseMessage, title: "Error")
//                    }
//                }
//
//
////                if (!statusVal) {
////                    return
////                } else {
////
////                }
//            } catch {
//                print("Error -> \(error)")
//            }
//        }
//        task.resume()
//    }
//    let dic = ["key1":"value1", "key2":"value2"]
//
//    let cookieHeader = (dic.flatMap({ (key, value) -> String in
//        return "\(key)=\(value)"
//    }) as Array).joined(separator: ";")
//
//    print(cookieHeader)
    ///======================
//    let dictionary = ["aKey": "aValue", "anotherKey": "anotherValue"]
//    if let theJSONData = try? JSONSerialization.data(
//        withJSONObject: dictionary,
//        options: []) {
//            let theJSONText = String(data: theJSONData,
//                                     encoding: .ascii)
//            print("JSON string = \(theJSONText!)")
//    }
    func sendEmail_toUSER(payment_mode: String)
    {
        let confirmationMSG = "Withdraw request through \(payment_mode) transfer has been sent to admin, successfully.\n\nBest Regards \nSimX Team. \nContact: colinjohn563@gmail.com"
        
        let smtpSession = MCOSMTPSession() 
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username = kGmailAccount
        smtpSession.password = kGmailPassword
        smtpSession.port = 465
        smtpSession.authType = MCOAuthType.saslPlain
        smtpSession.connectionType = MCOConnectionType.TLS
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                {
                    NSLog("Connectionlogger: \(string)")
                }
            }
        }
        
        var emailReciever = self.currentUser.email
        
        if !(self.isValid(emailReciever)) {
            //emailReciever = emailField.text!
        }
        
        
        let builder = MCOMessageBuilder()
        print("Email to User :: \(self.currentUser.email)")
        builder.header.to = [MCOAddress(displayName: self.currentUser.name, mailbox: emailReciever)]
        builder.header.from = MCOAddress(displayName: "SimX", mailbox: kGmailAccount)
        builder.header.subject = "SimX Withdraw Request"
        builder.textBody = confirmationMSG
        
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        sendOperation?.start { (error) -> Void in
            DispatchQueue.main.async {
                Utilities.hide_ProgressHud(view: self.view)
            }
            if (error != nil)
            {
                //SwiftSpinner.hide()
                NSLog("\nError sending emailwith error:  \(String(describing: error))\n")
                Alert.showAlertWithMessageAndTitle(message: String(describing: error), title: "Error sending email!")
            }
            else
            {
                //SwiftSpinner.hide()
                NSLog("\nSuccessfully sent email to USER!\n")
                let alert = UIAlertController(title: "Request Sent Successfully!", message: "Request Email to withdraw amount sent successfully", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                    //self.getUserData_fromDB_andUpdate_credit()
                })
                self.present(alert, animated: true)
            }
        }
    }
    
    func sendEmail_toADMIN(HtmlString: String, payment_mode: String)
    {
        //SwiftSpinner.show("Sending Request..")
        
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username = kGmailAccount
        smtpSession.password = kGmailPassword
        smtpSession.port = 465
        smtpSession.authType = MCOAuthType.saslPlain
        smtpSession.connectionType = MCOConnectionType.TLS
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                {
                    print("Connectionlogger: \(string)")
                }
            }
        }
        
        var emailReciever = self.currentUser.email
        
        if !(self.isValid(emailReciever)) {
           // emailReciever = emailField.text!
        }
        
        //"mscsf15m012@pucit.edu.pk"
        let builder = MCOMessageBuilder()
        print("Email to Admin :: \(kGmailAccount)")
        builder.header.to = [MCOAddress(displayName: "ADMIN", mailbox: kGmailAccount)]
        builder.header.from = MCOAddress(displayName: "SimX user: \(self.currentUser.name) username: \(self.currentUser.username)", mailbox: emailReciever)
        builder.header.subject = "SimX Withdraw Request :: \(self.currentUser.username)"
        //builder.htmlBody = HtmlString
        //builder.textBody = "SimX user: \(emailReciever) username in table: \(self.currentUser.username)\nWith Email: \(self.emailField.text!),\nBalance to Tranfer: £\(self.currentUser.credit)"
        
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        sendOperation?.start { (error) -> Void in
            
            if (error != nil) {
                DispatchQueue.main.async {
                    Utilities.hide_ProgressHud(view: self.view)
                }
                //SwiftSpinner.hide()
                NSLog("\nError sending emailwith error:  \(String(describing: error))\n")
                Alert.showAlertWithMessageAndTitle(message: String(describing: error), title: "Error sending email!")
            }
            else
            {
                NSLog("\nSuccessfully sent email to ADMIN!\n")
                self.sendEmail_toUSER(payment_mode: payment_mode)
                self.updateUserBalanceWithAmount(amount: 0.0)
            }
        }
    }
    
    func isValid(_ email: String) -> Bool {
        let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
        "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
        "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
        "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
        "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
        "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    // Function to get users detail
    func updateUserBalanceWithAmount(amount: Double)
    {
        let loggedinUser = CurrentUser.Current_UserObject
        print("Old Balance:: \(loggedinUser.credit)\n")
        let newBalance = 0.0
        loggedinUser.credit = newBalance
        print(loggedinUser)
        print("New Balance:: \(loggedinUser.credit)\n")
        loggedinUser.setUserDefaults()
        CurrentUser.setCurrentUser_UserDefaults(user: loggedinUser)
        CurrentUser.Current_UserObject = CurrentUser.getCurrentUser_From_UserDefaults()
        
        let data = ["\(Constants.UserFields.username)": loggedinUser.username as AnyObject, "\(Constants.UserFields.credit)": loggedinUser.credit as AnyObject] as! AnyObject
        DispatchQueue.main.async {
            
           DataAccess.sharedInstance.Update_Data_in_UsersTable(data, delegate: self)
        
        }
    }
    
    func UpdateUser_ResponseSuccess(updated_user: User, status: Bool) {
        print("Balance updated successfully!")
        self.moveBack()
        DispatchQueue.main.async {
            Utilities.hide_ProgressHud(view: self.view)
        }
    }
    
    func UpdateUser_ResponseError(_ error: NSError?) {
        print("Balance update failed with error :: \(error?.description)")
        Alert.showAlertWithMessageAndTitle(message: "Request Failed with error, please check your internet and try again in a moment.", title: "Error!")
        DispatchQueue.main.async {
            Utilities.hide_ProgressHud(view: self.view)
        }
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

}


struct WithdrawPayment: Codable {
    let data: DataClass
    enum CodingKeys: String, CodingKey {
        case data
    }
}

// MARK: - DataClass
struct DataClass: Codable {
    let msg, emailStatus,username, bankName, accountNo: String

    enum CodingKeys: String, CodingKey {
        case username = "username"
        case bankName = "bank_name"
        case accountNo = "account_no"
        case msg = "msg"
        case emailStatus = "email_status"
    }
}
extension UITextField {
    func showDoneButtonOnKeyboard() {
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resignFirstResponder))
        
        var toolBarItems = [UIBarButtonItem]()
        toolBarItems.append(flexSpace)
        toolBarItems.append(doneButton)
        
        let doneToolbar = UIToolbar()
        doneToolbar.items = toolBarItems
        doneToolbar.sizeToFit()
        
        inputAccessoryView = doneToolbar
    }
}
