//
//  TWTRWebViewController.swift
//  SimX
//
//  Created by Apple on 31/01/2020.
//  Copyright © 2020 Agilio. All rights reserved.
//

import UIKit

protocol MyTWTRTokenRequestDelegate {
    func twtrSuccess(accessToken: String)
    func twtrError(message: String)
}

class TWTRWebViewController: UIViewController, UIWebViewDelegate {
    
    // MARK: IBOutlet Properties
    
    @IBOutlet weak var webView: UIWebView!
    var accessDelegate : MyTWTRTokenRequestDelegate?
    
    // MARK: Constants
    
    let twitterConsumerKey = Constants.Twitter.consumerKey //"7790uo0ed4wjr4"
    
    let twitterConsumerSecret = Constants.Twitter.consumerSecret //"CfCLCdalxtiRRu4Y"
    
    var intermideiateToken = ""
    
    let authorizationEndPoint = "https://api.twitter.com/oauth/authorize"
    //"https://api.twitter.com/oauth/"
    //"https://api.twitter.com/oauth/authorize?"
    
    let accessTokenEndPoint = "https://www.linkedin.com/oauth/v2/accessToken"
    //"https://www.linkedin.com/uas/oauth2/accessToken"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        webView.delegate = self
        
        startTwtrAuthorization()
//        startAuthorization()
        //requestForAccessToken(authorizationCode: "abcd")
    }
    
    func startTwtrAuthorization () {
        let semaphore = DispatchSemaphore (value: 0)

        var request = URLRequest(url: URL(string: "https://api.twitter.com/oauth/request_token?oauth_callback=https://www.cyberjobscope.com?source=twitter&oauth_consumer_key=L0L0uFZnt0H2PSZWvW2NL9Yje")!,timeoutInterval: Double.infinity)
        request.addValue("Bearer AAAAAAAAAAAAAAAAAAAAAFr%2F0QAAAAAATBy%2FxRYJnmLSV76552NmBroles8%3DtdgM3z8nRVoKmYRkQNcDkjKStuMcTScndN9Zr9DCB03DoT8VJg", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
          print(String(data: data, encoding: .utf8)!)
            DispatchQueue.main.async {
                let s = String(data: data, encoding: .utf8)!
                let token = s.split(separator: "&")[0].split(separator: "=")[1];
                print ("token 555: ", token)
                self.intermideiateToken = String(token)
                self.startAuthorization()
            }
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()
    }
    
    func getAuthTokenAndSecret() {
        var semaphore = DispatchSemaphore (value: 0)

        var request = URLRequest(url: URL(string: "https://api.twitter.com/oauth/request_token?oauth_callback=https://www.cyberjobscope.com?source=twitter&oauth_consumer_key=L0L0uFZnt0H2PSZWvW2NL9Yje")!,timeoutInterval: Double.infinity)
        request.addValue("Bearer AAAAAAAAAAAAAAAAAAAAAFr%2F0QAAAAAATBy%2FxRYJnmLSV76552NmBroles8%3DtdgM3z8nRVoKmYRkQNcDkjKStuMcTScndN9Zr9DCB03DoT8VJg", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
          print(String(data: data, encoding: .utf8)!)
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()

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
        self.accessDelegate?.twtrError(message: "You cancelled the process")
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Custom Functions
    
    func startAuthorization() {
        
//               Authorization:
//                       OAuth oauth_callback="https://www.cyberjobscope.com?source=twitter",
//                             oauth_consumer_key="cChZNFj6T5R0TigYB9yd1w",
//                             oauth_nonce="ea9ec8429b68d6b77cd5600adbbb0456",
//                             oauth_signature="F1Li3tvehgcraF8DMJ7OyxO4w9Y%3D",
//                             oauth_signature_method="HMAC-SHA1",
//                             oauth_timestamp="1318467427",
//                             oauth_version="1.0"
//
//
        // Specify the response type which should always be "code".
        let responseType = "code"
        
        // Set the redirect URL. Adding the percent escape characthers is necessary.
        let redirectURL = "https://www.cyberjobscope.com?source=twitter".addingPercentEncoding(withAllowedCharacters:.alphanumerics)
        // Create a random string based on the time intervale (it will be in the form linkedin12345679).
        let state = Constants.LinkedIn.state
        
        // Set preferred scope.
        let scope = "r_liteprofile%20r_emailaddress%20w_member_social%20rw_company_admin"
        
        // Create the authorization URL string.
        var authorizationURL = "\(authorizationEndPoint)?"
        authorizationURL += "oauth_callback=\(redirectURL!)&"
        authorizationURL += "oauth_consumer_key=\(twitterConsumerKey)&"
        authorizationURL += "oauth_nonce=ea9ec8429b68d6b77cd5600adbbb0456&"
        authorizationURL += "oauth_signature=F1Li3tvehgcraF8DMJ7OyxO4w9Y%3D&"
        authorizationURL += "oauth_signature_method=HMAC-SHA1&"
        authorizationURL += "oauth_token=\(self.intermideiateToken)&"
        authorizationURL += "oauth_timestamp=\(NSDate().timeIntervalSince1970)&"
        authorizationURL += "oauth_version=1.0"
        
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
        postParams += "client_id=\(twitterConsumerKey)&"
        postParams += "client_secret=\(authorizationEndPoint)"
        
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
                        self.accessDelegate?.twtrSuccess(accessToken: accessToken)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                catch {
                    self.accessDelegate?.twtrError(message: "JSON data is malformed")
                    print("Could not convert JSON data into a dictionary.")
                }
            }
        }
        
        task.resume()
    }
    
    
    // MARK: UIWebViewDelegate Functions
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.url!
        print("url 555", url)
        ////////Utilities.show_ProgressHud(view: self.view)
        if url.host == "www.cyberjobscope.com" {
//            if (url.absoluteString.range(of: "code") != nil) {
//                 Extract the authorization code.
            let absoluteUrlString = url.absoluteString
            if (absoluteUrlString.contains("oauth_verifier")) {
                let urlParts = absoluteUrlString.components(separatedBy: "&")
                let authToken = urlParts[1].components(separatedBy: "=")[1]
                let authVerifier = urlParts[2].components(separatedBy: "=")[1]
                
                UserDefaults.standard.set(authToken, forKey: "twitter_token_555")
                UserDefaults.standard.set(authVerifier, forKey: "twitter_token_secret_555")
                DispatchQueue.main.async {
                    self.accessDelegate?.twtrSuccess(accessToken: authToken)
                    self.dismiss(animated: true, completion: nil)
                }
//                param["twitter_token"] = "\(twitterSession.authToken)"
//                param["twitter_token_secret"] = "\(twitterSession.authTokenSecret)"
            }
                //requestForAccessToken(authorizationCode: code)
//            }
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
                let urlParts = url.absoluteString.components(separatedBy: "&")
                let authToken = urlParts[1].components(separatedBy: "=")[1]
                let authVerifier = urlParts[2].components(separatedBy: "=")[1]
                //requestForAccessToken(authorizationCode: code)
            }
            else {
                self.accessDelegate?.twtrError(message: "You cancelled the process")
                dismiss(animated: true, completion: nil)
            }
        }
        
        return true
    }
    
}
