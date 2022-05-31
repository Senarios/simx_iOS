//
//  WebViewController.swift
//  LISignIn
//
//  Created by Gabriel Theodoropoulos on 21/12/15.
//  Copyright © 2015 Appcoda. All rights reserved.
//

import UIKit

//static let AppId = "4737953" //"5231345"
//static let clientId = "7790uo0ed4wjr4" //"81pcgio6h3rhn8"
//static let clientSecret = "CfCLCdalxtiRRu4Y" //"tiAHTe2t3pHluOEp"



protocol MyLITokenRequestDelegate {
    func success(accessToken: String)
    func error(message: String)
}

class WebViewController: UIViewController, UIWebViewDelegate {

    // MARK: IBOutlet Properties
    
    @IBOutlet weak var webView: UIWebView!
    var accessDelegate : MyLITokenRequestDelegate?
    
    // MARK: Constants
    
    let linkedInKey = Constants.LinkedIn.clientId //"7790uo0ed4wjr4"
    
    let linkedInSecret = Constants.LinkedIn.clientSecret //"CfCLCdalxtiRRu4Y"
    
    let authorizationEndPoint = "https://www.linkedin.com/oauth/v2/authorization"
                              //"https://www.linkedin.com/uas/oauth2/authorization"
    
    let accessTokenEndPoint = "https://www.linkedin.com/oauth/v2/accessToken"
    //"https://www.linkedin.com/uas/oauth2/accessToken"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        webView.delegate = self
        startAuthorization()
        //requestForAccessToken(authorizationCode: "abcd")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: IBAction Function
    
    
    @IBAction func dismiss(sender: AnyObject) {
        self.accessDelegate?.error(message: "You cancelled the process")
        dismiss(animated: true, completion: nil)
    }
 
    
    // MARK: Custom Functions
    
    func startAuthorization() {
        // Specify the response type which should always be "code".
        let responseType = "code"
        
        // Set the redirect URL. Adding the percent escape characthers is necessary.
        let redirectURL = "https://www.cyberjobscope.com/signin-linkedin".addingPercentEncoding(withAllowedCharacters:.alphanumerics)
        // Create a random string based on the time intervale (it will be in the form linkedin12345679).
        let state = Constants.LinkedIn.state
        
        // Set preferred scope.
        let scope = "r_liteprofile%20r_emailaddress"//%20w_member_social%20rw_company_admin"
        
        // Create the authorization URL string.
        var authorizationURL = "\(authorizationEndPoint)?"
        authorizationURL += "response_type=\(responseType)&"
        authorizationURL += "client_id=\(linkedInKey)&"
        authorizationURL += "redirect_uri=\(redirectURL!)&"
        authorizationURL += "state=\(state)&"
        authorizationURL += "scope=\(scope)"
        
        print(authorizationURL)
        
        // Create a URL request and load it in the web view.
        let request = NSURLRequest(url: URL(string: authorizationURL)!)
        webView.loadRequest(request as URLRequest)
    }
    
    
    func requestForAccessToken(authorizationCode: String) {
        let grantType = "authorization_code"
        
        let redirectURL = "https://www.cyberjobscope.com/signin-linkedin".addingPercentEncoding(withAllowedCharacters:.alphanumerics)
        // Set the POST parameters.
        var postParams = "grant_type=\(grantType)&"
        postParams += "code=\(authorizationCode)&"
        postParams += "redirect_uri=\(redirectURL!)&"
        postParams += "client_id=\(linkedInKey)&"
        postParams += "client_secret=\(linkedInSecret)"
        
        // Convert the POST parameters into a NSData object.
        let postData = postParams.data(using: .utf8)
        //let postData = postParams.data(usingEncoding: NSUTF8StringEncoding)
        
        
        // Initialize a mutable URL request object using the access token endpoint URL string.
        let request = NSMutableURLRequest(url: NSURL(string: accessTokenEndPoint)! as URL)
        
        // Indicate that we're about to make a POST request.
        request.httpMethod = "POST"
        
        // Set the HTTP body using the postData object created above.
        request.httpBody = postData
        
        // Add the required HTTP header field.
        request.addValue("application/x-www-form-urlencoded;", forHTTPHeaderField: "Content-Type")
        
        // Initialize a NSURLSession object.
        let session = URLSession(configuration: URLSessionConfiguration.default)
        print("about to hit request getAccessToken")
        print("Auth Code: ", authorizationCode)
        // Make the request.
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            // Get the HTTP status code of the request.
            let statusCode = (response as! HTTPURLResponse).statusCode
            
            if statusCode == 200 {
                // Convert the received JSON data into a dictionary.
                do {
                    let responseData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    let dataDictionary = responseData as! Dictionary<String, Any>
                    let accessToken = dataDictionary["access_token"] as! String
                    
                    UserDefaults.standard.set(accessToken, forKey: "LIAccessToken")
                    UserDefaults.standard.synchronize()
                    
                    DispatchQueue.main.async {
                        self.accessDelegate?.success(accessToken: accessToken)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                catch {
                    self.accessDelegate?.error(message: "JSON data is malformed")
                    print("Could not convert JSON data into a dictionary.")
                }
            }
        }
        
        task.resume()
    }
    
    
    // MARK: UIWebViewDelegate Functions
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.url!
        print(url)
        ////////Utilities.show_ProgressHud(view: self.view)
        if url.host == "www.cyberjobscope.com" {
            if (url.absoluteString.range(of: "code") != nil) {
                // Extract the authorization code.
                let urlParts = url.absoluteString.components(separatedBy: "?")
                let code = urlParts[1].components(separatedBy: "=")[1]
                
                requestForAccessToken(authorizationCode: code)
            }
        }
        
        return true
    }

//    func webViewDidFinishLoad(_ webView: UIWebView) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
//            Utilities.hide_ProgressHud(view: self.view)
//        })
//    }
    
    private func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.url!
        print(url)
        
        if url.host == "www.cyberjobscope.com" {
            if (url.absoluteString.range(of: "code") != nil) {
                // Extract the authorization code.
                let urlParts = url.absoluteString.components(separatedBy: "?")
                let code = urlParts[1].components(separatedBy: "=")[1]
                
                requestForAccessToken(authorizationCode: code)
            }
            else {
                self.accessDelegate?.error(message: "You cancelled the process")
                dismiss(animated: true, completion: nil)
            }
        }
        
        return true
    }
    
}
