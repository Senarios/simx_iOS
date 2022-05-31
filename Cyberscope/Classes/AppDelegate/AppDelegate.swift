//
//  AppDelegate.swift
//  StreamaxiaDemo2
//
//  Created by Roland Tolnay on 9/21/16.
//  Copyright © 2016 Streamaxia. All rights reserved.
//

import UIKit
import Braintree
import Foundation
import IQKeyboardManagerSwift
import Firebase
import FirebaseCore
import FBSDKCoreKit
import TwitterKit
import GoogleMaps
import GooglePlaces
import LinkedinSwift
import Quickblox
import QuickbloxWebRTC

import PushKit
import CallKit
import Toaster
import AWSSNS
import AWSS3
import AWSCognito
import SwiftyStoreKit
import UserNotifications


let kRefreshTimeInterval: TimeInterval = 1.0;

//com.senarios.CyberScopeTV
//com.senarios.CyberScopeTest
//com.senarios.iOSCyberScopeTV

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PKPushRegistryDelegate
{
    class var shared_instance: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    //    let AWSAppAccessKey = "AKIAIU4JH4JE4AQLO2KQ"
    //    let AWSAppAccessSecretKey = "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"
    
    let AWSAppAccessKey          = "AKIA4T3ODZPABGM2W25B"
    let AWSAppAccessSecretKey    = "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"
    

    let SNSPlatFormApplicationArnAPNS_SANDBOX = "arn:aws:sns:us-west-2:867277458368:app/APNS_SANDBOX/H2StartupiOS" // "arn:aws:sns:us-west-2:867277458368:app/APNS_SANDBOX/subscibeiOSDevelopmentCyberscope"
    let SNSPlatFormApplicationArnAPNS = "arn:aws:sns:us-west-2:867277458368:app/APNS/H2StartupiOS"
  //  let SNSPlatformApplicationVOIPSandbox = "arn:aws:sns:us-west-2:867277458368:app/APNS/H2StartupiOS"
    // // // //"arn:aws:sns:us-west-2:867277458368:app/APNS_SANDBOX/SNSVoipNewChatterbox"
    //  ********** START QB video chat stuff here ********** \\
    
    static var QB_VideoChat_opponetUser: User?
    static var QB_VideoChat_session: QBRTCSession?
    static var QB_VideoChat_current_CallType: QBRTCConferenceType?
    static var QB_VideoChat_connectedTo_UserID: NSNumber?
    
    //  ********** END QB video chat stuff here ********** \\
    
    // MARK: - Properties -
    var popupWindow: UIWindow?
    var window: UIWindow?
    var providerDelegate: ProviderDelegate!
    let callManager = CallManager()
    
    // incoming call timer
    var incomingCall_timer: Timer?
    
    // MARK: - UIApplicationDelegate -
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
//        if #available(iOS 13.0, *){
//            
//            if UIScreen.main.traitCollection.userInterfaceStyle == .dark{
//                window?.overrideUserInterfaceStyle = .dark
//            }else{
//                window?.overrideUserInterfaceStyle = .light
//            }
//           
//        }
        
        
        BTAppSwitch.setReturnURLScheme("com.senarios.iOSCyberScopeTV.payments")
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        center.requestAuthorization(options: options) { (granted, error) in
            if granted {
                DispatchQueue.main.sync {
                    application.registerForRemoteNotifications()
                }
            }
        }
        // code from => // https://stackoverflow.com/questions/26974852/amazon-aws-how-do-i-subscribe-an-endpoint-to-sns-topic
        // -> code converted to swift using => // https://objectivec2swift.com/
        
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: AWSAppAccessKey, secretKey: AWSAppAccessSecretKey)
        let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        // self.initializeS3()
        
        FirebaseApp.configure()
        
        
        //      ***********************************     \\
        
        // Socail sdks settings here
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        TWTRTwitter.sharedInstance().start(withConsumerKey:Constants.Twitter.consumerKey, consumerSecret:Constants.Twitter.consumerSecret)
        //TWTRTwitter.sharedInstance().start(withConsumerKey: <#T##String#>, consumerSecret: <#T##String#>, accessGroup: <#T##String?#>)
        // Google Maps Key setting
        GMSServices.provideAPIKey(Constants.GoogleMaps.API_Key)
        GMSPlacesClient.provideAPIKey(Constants.GoogleMaps.API_Key)
        
        // Override point for customization after application launch.
        
        let audioSession = AVAudioSession.sharedInstance()
        print("33456 : ", audioSession.category)
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeMoviePlayback)
            //try audioSession.setCategory(.playback, mode: .moviePlayback)
        }
        
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        // :-   ****************
        
        //TODO: - Enter PayPal credentials
        //  PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: Constants.PayPal.production_ClientId, PayPalEnvironmentSandbox: Constants.PayPal.sandbox_ClientId])
        
        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: Constants.SandboxPayPal.production_ClientId, PayPalEnvironmentSandbox: Constants.SandboxPayPal.sandbox_ClientId])
        
        
        // Set QUICK-BLOX credentials (You must create application in admin.quickblox.com).
        QBSettings.applicationID = Constants.QuickBlox.ApplicationID;
        QBSettings.authKey = Constants.QuickBlox.AuthKey
        QBSettings.authSecret = Constants.QuickBlox.AuthSecret
        QBSettings.accountKey = Constants.QuickBlox.AccountKey
        
        // Enable IQKeyboardManager
        IQKeyboardManager.sharedManager().enable = true
        //IQKeyboardManager.sharedManager().enable = true
        
        // initialization of variable
        providerDelegate = ProviderDelegate(callManager: callManager)
        
        // Registration for VOIP and PUSH notifications
        self.voipRegistration()
        
        NSSetUncaughtExceptionHandler { exception in
            //Log.error(with: Thread.callStackSymbols)
            print("didFinishLaunchingWithOptions: ", Thread.callStackSymbols)
        }
        
        signal(SIGABRT) { _ in
            print("didFinishLaunchingWithOptions: ", Thread.callStackSymbols)
        }
        
        signal(SIGILL) { _ in
            print("didFinishLaunchingWithOptions: ", Thread.callStackSymbols)
        }
        
        signal(SIGSEGV) { _ in
            print("didFinishLaunchingWithOptions: ", Thread.callStackSymbols)
        }
        
        signal(SIGFPE) { _ in
            print("didFinishLaunchingWithOptions: ", Thread.callStackSymbols)
        }
        
        signal(SIGBUS) { _ in
            print("didFinishLaunchingWithOptions: ", Thread.callStackSymbols)
        }
        
        signal(SIGPIPE) { _ in
            print("didFinishLaunchingWithOptions: ", Thread.callStackSymbols)
        }
        
        setupIAP()
        
        return true
    }
    
    func setupIAP() {
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break // do nothing
                }
            }
        }
        
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            
            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.compactMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                print("Saving: \(contentURLs)")
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    {
        print("Inside AppDelegate open URL Method:\n Going to open url => \(url)")
        if LISDKCallbackHandler.shouldHandle(url) {
            return LISDKCallbackHandler.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        else if (url.scheme == Constants.FaceBook.FACEBOOK_SCHEME)
        {
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        else // // //if (url.scheme == Constants.FaceBook.FACEBOOK_SCHEME)
        {
            return TWTRTwitter.sharedInstance().application(application, open: url, options: [:])
        }
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        print("Inside AppDelegate open URL Method:\n Going to open url => \(url)")
        
        if url.scheme == "fbxxxxx"
        {
            //xxxxx is your APP ID
            // checks code snippet source found from https://stackoverflow.com/questions/35311454/fbsdkaccesstoken-currentaccesstoken-found-nil-every-time?answertab=votes#tab-top
            
        }
        
        let appId = FBSDKSettings.appID()
        if url.scheme != nil && url.scheme!.hasPrefix("fb\(appId ?? "121212")") && url.host ==  "authorize" { // facebook
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: "", annotation: nil)
        }
        
        if TWTRTwitter.sharedInstance().application(application, open:url, options: [:]) {
            return true
        }
        
        return false
    }
    
    // Swift
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        if url.scheme?.localizedCaseInsensitiveCompare("com.senarios.iOSCyberScopeTV.payments") == .orderedSame {
            return BTAppSwitch.handleOpen(url)
        }
        let appId = FBSDKSettings.appID()
        if url.scheme != nil && url.scheme!.hasPrefix("fb\(appId ?? "121212")") && url.host ==  "authorize" { // facebook
            let handled: Bool = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation])
            // Add any custom logic here.
            return handled
        }
        // Linkedin sdk handle redirect
        if LinkedinSwiftHelper.shouldHandle(url)
        {
            return LinkedinSwiftHelper.application(app, open: url, sourceApplication: nil, annotation: nil)
        }
        
        
        return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
    }
    
    func applicationWillResignActive(_ application: UIApplication)
    {
        print("\n applicationWillResignActive called ... \n")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication)
    {
        print("\n applicationDidEnterBackground called ... \n")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication)
    {
        print("\n applicationWillEnterForeground called ... \n")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        print("\n applicationDidBecomeActive called ... \n")
        self.check_and_login_to_QBChat()
    }
    
    func applicationWillTerminate(_ application: UIApplication)
    {
        print("\n applicationWillTerminate called ... \n")
        let session = AVAudioSession.sharedInstance()
        do {
            // 1) Configure your audio session category, options, and mode
            // 2) Activate your audio session to enable your custom configuration
            try session.setActive(false)
        } catch let error as NSError {
            print("Unable to activate audio session:  \(error.localizedDescription)")
        }
    }
    
    //          ************************   VOIP   ****************************  \\
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any])
    {
        print("### didReceiveRemoteNotification called ... 1\n")
        Alert.showAlertWithMessageAndTitle(message: "didReceiveRemoteNotification called ...", title: self.extractMessage(fromPushNotificationUserInfo: userInfo as NSDictionary))
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        print("### didReceiveRemoteNotification called 2 ... \n")
        //Alert.showAlertWithMessageAndTitle(message: "didReceiveRemoteNotification called ... with fetchCompletionHandler !!!", title: "Alert!!")
        let messageText = self.extractMessage(fromPushNotificationUserInfo: userInfo as NSDictionary)
        if (messageText.contains("{")) {
            let jsonString = messageText
            let jsonData = jsonString.data(using: .utf8)
            let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
            print(dictionary!)
            let newDictionary = dictionary as! Dictionary<String, String>
            NotificationCenter.default.post(name: .commentReachedThisDevice, object: newDictionary)
            return
        }
        Alert.showAlertWithMessageAndTitle(message: "", title: messageText)
    }
    
    private func extractMessage(fromPushNotificationUserInfo userInfo:NSDictionary) -> String {
        var message: String?
        if let aps = userInfo["aps"] as? NSDictionary {
            if let resources = userInfo["resource"] as? NSDictionary { // trying to get appointment message from userInfo Dicitonary
                if let status = resources["status1"] as? String {
                    message = (self.extractAppoitmentMessage(dictionary: resources, status: status))
                    return message!
                }
            }
            if let alert = aps["alert"] as? NSDictionary {
                if let alertMessage = alert["body"] as? String {
                    message = alertMessage
                }
                else {
                    message = aps["alert"] as? String ?? "DefaultString333"
                }
            }
            else {
                message = aps["alert"] as? String ?? "DefaultString333"
            }
        }
        return message!
    }
    
    private func extractAppoitmentMessage(dictionary:NSDictionary, status: String) -> String {
        
        let userName = dictionary["name"] as! String
        let messageType = dictionary["status"] as! String
        
        var appointmentMesssage = ""
        
        switch status {
        case "pending":
            appointmentMesssage = "You have one pending \(messageType) request from \(userName)"
            break
        case "accepted":
            appointmentMesssage = "Your appointment has been accepted by \(userName)"
            break
            
        case "rejected":
            appointmentMesssage = "Your appointment request has been rejected, \(userName) is might be busy at that time! Better luck next time."
            break
            
        default:
            appointmentMesssage = "Unspecified appointment message from \(userName), please check your appointments to see the updates in there."
            break
        }
        
        return appointmentMesssage
    }
    
    //      ++++++++++++++++++++++
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings)
    {
        print("\n didRegister notificationSettings called ... \n")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        print("\n didRegisterForRemoteNotificationsWithDeviceToken  called ... \n AND deviceToken = \(deviceToken) \n")
        CurrentUser.set_CurrentDevice_deviceToken(deviceToken: deviceToken)
        
        // Register device on QB to receive notification from QuickBloX
        //      [ ------  START  ------ ]
        //self.subscribe_for_APNS()             // -> important
        //self.subscribe_for_APNSVOIP()         // -> important
        //      [ ------  END  ------ ]
        
        /// Attach the device token to the user defaults
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        print("deviceTokenString: \(token)")
        
        print(token)
        UserDefaults.standard.set(token, forKey: "deviceTokenForSNS")
        let sns = AWSSNS.default()
        let request = AWSSNSCreatePlatformEndpointInput()
        request?.token = token
        request?.platformApplicationArn = SNSPlatFormApplicationArnAPNS_SANDBOX
     //   request?.platformApplicationArn = SNSPlatFormApplicationArnAPNS
        //SNSPlatFormApplicationArnAPNS_SANDBOX, SNSPlatFormApplicationArnAPNS
        sns.createPlatformEndpoint(request!).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("%% come in aws error")
                print("Error: \(String(describing: task.error))")
            } else {
                print("%% come in end point success")
                let createEndpointResponse = task.result! as AWSSNSCreateEndpointResponse
                if let endpointArnForSNS = createEndpointResponse.endpointArn {
                    print("endpointArn: \(endpointArnForSNS)")
                    UserDefaults.standard.set(endpointArnForSNS as String, forKey: "endpointArnForSNSCyberScope787")
                    CurrentUser.set_CurrentDevice_Arn(deviceArn: endpointArnForSNS as String)
                }
            }
            return nil
        })
    }
    
    func subscribe_for_APNS()
    {
        let subscription: QBMSubscription! = QBMSubscription()
        subscription.notificationChannel = QBMNotificationChannel.APNS
        subscription.deviceUDID = Constants.current_device.device_uuidString
        
        if let token = CurrentUser.get_CurrentDevice_deviceToken()
        {
            let deviceTokenString = extractTokenFromData(deviceToken: token)
            print("QB APNS Device Token :: ", deviceTokenString)
            
            subscription.deviceToken = token
            QBRequest.createSubscription(subscription, successBlock: { (response: QBResponse!, objects: [QBMSubscription]?) -> Void in
                //
                print(response.error?.description ?? "APNS QB ERROR 1st block-- NIL")
                if (objects != nil && objects!.count > 0) {
                    var array:[UInt] = []
                    for subscription in objects! {
                        array.append(subscription.id)
                    }
                    UserDefaults.standard.set(array, forKey: "apns_subsciptionarray_simx_786")
                }
            }) { (response: QBResponse!) -> Void in
                //
                print(response.error?.description ?? "APNS QB ERROR 2nd block-- NIL")
            }
        }
    }
    
    func subscribe_for_APNSVOIP()
    {
        let subscription: QBMSubscription! = QBMSubscription()
        subscription.notificationChannel = QBMNotificationChannel.APNSVOIP
        subscription.deviceUDID = Constants.current_device.device_uuidString
        
        if let token = CurrentUser.get_CurrentDevice_pushCredentials_deviceToken()
        {
            let deviceTokenString = extractTokenFromData(deviceToken: token)
            print("QB VOIP Device Token :: ", deviceTokenString)
            
            subscription.deviceToken = token
            QBRequest.createSubscription(subscription, successBlock: { (response: QBResponse!, objects: [QBMSubscription]?) -> Void in
                //
                print(response.error?.description ?? "APNS VOIP QB ERROR 1st block-- NIL")
                if (objects != nil && objects!.count > 0) {
                    var array:[UInt] = []
                    for subscription in objects! {
                        array.append(subscription.id)
                    }
                    UserDefaults.standard.set(array, forKey: "apnsVoip_subsciptionarray_simx_786")
                }
            }) { (response: QBResponse!) -> Void in
                //
                print(response.error?.description ?? "APNS VOIP QB ERROR 2nd block-- NIL")
                //Toast(text: "APNS VOIP subscription FAILED.").show()
            }
        }
    }
    
    func get_subscriptions()
    {
        QBRequest.subscriptions(successBlock: ({ (response: QBResponse!, objects: [QBMSubscription]?) -> Void in
            //
            print("get subscriptions SUCCESSFULL.")
            
        }), errorBlock: { (response: QBResponse!) -> Void in
            
            print(response.error?.description ?? "get subscriptions ERROR")
        })
    }
    
    func extractTokenFromData(deviceToken:Data) -> String {
        let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        return token.uppercased();
    }
    // Register for VoIP notifications method
    var voipRegistry : PKPushRegistry?
    func voipRegistration()
    {
        if (self.voipRegistry == nil) {
            self.voipRegistry = PKPushRegistry(queue: .main)
        }
        self.voipRegistry!.desiredPushTypes = [.voIP]
        self.voipRegistry!.delegate = self
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let token = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
        print("voip token = \(token)")
        
        print("\n didUpdate pushCredentials forType '\(type)' called....\n")
        let deviceTokenString = extractTokenFromData(deviceToken: pushCredentials.token)
        print("\n deviceTokenString for VOIP: \(deviceTokenString) \n")
        print("\n VOIP credentials.token = \(pushCredentials.token) \n")
        
        CurrentUser.set_CurrentDevice_pushCredentials_deviceToken(deviceToken: pushCredentials.token)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType)
    {
        print("\n didInvalidatePushTokenForType '\(type)' called....\n")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        
        print("\n didReceiveIncomingPushWith payload forType '\(type)' called....\n iOS >= 11.0")
        guard type == .voIP else {
            return
        }
        _ = payload.dictionaryPayload[Constants.Notification_Payload_Keys.UUID] as? String ?? "NIL"
        
        let handle  = payload.dictionaryPayload[Constants.Notification_Payload_Keys.handle] as? String ?? "NIL"
        let str     = payload.dictionaryPayload[Constants.Notification_Payload_Keys.hasVideo] as? String ?? "NIL"
        var hasVideo = false
        if(str == "true")
        {
            hasVideo = true
        }
        let llhandle = payload.dictionaryPayload[Constants.Notification_Payload_Keys.handle]
        print(llhandle)
        print(payload)
        // <- handle Incoming call
        let uuid = UUID()
        let uuid_str = uuid.uuidString
        
        UserDefaults.standard.removeObject(forKey: Constants.Calling_Keys.uuid_str_for_call)
        UserDefaults.standard.set(uuid_str, forKey: Constants.Calling_Keys.uuid_str_for_call)
        UserDefaults.standard.synchronize()
        
        AppDelegate.shared_instance.displayIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo, completion: nil)
        return
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType)
    {
        print("\n didReceiveIncomingPushWith payload forType '\(type)' called....\n iOS < 11.0")
        guard type == .voIP else {
            return
        }
        
        _ = payload.dictionaryPayload[Constants.Notification_Payload_Keys.UUID] as? String ?? "NIL"
        let handle  = payload.dictionaryPayload[Constants.Notification_Payload_Keys.handle] as? String ?? "NIL"
        let str     = payload.dictionaryPayload[Constants.Notification_Payload_Keys.hasVideo] as? String ?? "NIL"
        var hasVideo = false
        if(str == "true")
        {
            hasVideo = true
        }
        
        if UIApplication.shared.applicationState == UIApplicationState.active
        {
            // do work for foreground mode
            print("\n App is ACTIVE :) \n")
            self.handleIncomingCall()
        }
        else
        {
            print("\n App is NOT ACTIVE :( \n")
            DispatchQueue.main.async
            {
                let uuid = UUID()
                let uuid_str = uuid.uuidString
                
                UserDefaults.standard.removeObject(forKey: Constants.Calling_Keys.uuid_str_for_call)
                UserDefaults.standard.set(uuid_str, forKey: Constants.Calling_Keys.uuid_str_for_call)
                UserDefaults.standard.synchronize()
                
                AppDelegate.shared_instance.displayIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo, completion: nil)
            }
        }
    }
    
    // Display the incoming call to the user
    func displayIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)? = nil)
    {
        providerDelegate?.reportIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo, completion: completion)
    }
    //          ************************   VOIP   ****************************  \\
    
    static func send_VOIP_PUSH_Notification(toUsers: String)
    {
        var payLoad: [String: String] = [:]
        payLoad[Constants.Notification_Payload_Keys.UUID] = Constants.current_device.device_uuidString
        payLoad[Constants.Notification_Payload_Keys.handle] = CurrentUser.getCurrentUser_From_UserDefaults().name
        payLoad[Constants.Notification_Payload_Keys.hasVideo] = ((AppDelegate.QB_VideoChat_current_CallType == QBRTCConferenceType.video) ? "true": "false")
        
        let payLoad2 = ["ios_voip": "1", "VOIPCall": "1", "handle":CurrentUser.getCurrentUser_From_UserDefaults().name,"hasVideo":((AppDelegate.QB_VideoChat_current_CallType == QBRTCConferenceType.video) ? "true": "false")]
        
        let data = try? JSONSerialization.data(withJSONObject: payLoad2,
                                               options: .prettyPrinted)
        var message2 = ""
        if let data = data {
            message2 = String(data: data, encoding: .utf8) ?? ""
        }
        let event = QBMEvent()
        event.notificationType = QBMNotificationType.push //QBMNotificationType.push
        let arrayUserIDs = [toUsers]//opponentsIDs.map({"\($0)"})
        event.usersIDs = arrayUserIDs.joined(separator: ",")
        event.type = QBMEventType.oneShot
        event.message = message2
        
        QBRequest.createEvent(event, successBlock: { response, events in
            debugPrint("[UsersViewController] Send voip push - Success 555")
            debugPrint(response)
        }, errorBlock: { response in
            debugPrint("[UsersViewController] Send voip push - Error 555")
            debugPrint(response.error as Any)
        })
    }
    
    static func send_PUSH_Notification(notification_type: Push_Notification_Type, toUsers: String, message: String)
    {
        let user  = CurrentUser.getCurrentUser_From_UserDefaults()
        
        var payLoad: [String: String] = [:]
        payLoad = ["message": message,
                   "ios_badge": "5",
                   "ios_sound": "mysound.wav",
                   "user_id": user.qbid,
                   "thread_id": "10"]
        
        let data: Data? = try? JSONSerialization.data(withJSONObject: payLoad, options: .prettyPrinted)
        var pmessage: String? = nil
        if let aData = data {
            pmessage = String(data: aData, encoding: .utf8)
        }
        
        let event = QBMEvent()
        event.pushType = .APNS
        event.notificationType = .push
        event.usersIDs = toUsers
        event.type = .oneShot
        event.message = message //"New message from '\(user.name.capitalized)' "
        
        QBRequest.createEvent(event, successBlock: {(_ response: QBResponse?, _ events: [QBMEvent]?) -> Void in
            
            // Successful response with event
            print("\n Apple PUSH Notification sent successfully to users: \(toUsers) !!! \n")
            //Toast(text: "PUSH Notification sent successfully to users: \(toUsers) !!!").show()
            
        }, errorBlock: {(_ response: QBResponse?) -> Void in
            
            // Handle error
            print("\n Apple Failed to sent PUSH Notification to users: \(toUsers) \n Error = \(String(describing: response?.error?.error?.localizedDescription)) ")
            //Toast(text: "Failed to sent PUSH Notification to users: \(toUsers)").show()
        })
        
        let gEvent = QBMEvent()
        gEvent.pushType = .GCM
        gEvent.notificationType = .push
        gEvent.usersIDs = toUsers
        gEvent.type = .oneShot
        gEvent.message = message //"New message from '\(user.name.capitalized)' "
        
        QBRequest.createEvent(gEvent, successBlock: {(_ response: QBResponse?, _ events: [QBMEvent]?) -> Void in
            
            // Successful response with event
            print("\n GCM PUSH Notification sent successfully to users: \(toUsers) !!! \n")
            //Toast(text: "PUSH Notification sent successfully to users: \(toUsers) !!!").show()
            
        }, errorBlock: {(_ response: QBResponse?) -> Void in
            
            // Handle error
            print("\n GCM Failed to sent PUSH Notification to users: \(toUsers) \n Error = \(String(describing: response?.error?.error?.localizedDescription)) ")
            //Toast(text: "Failed to sent PUSH Notification to users: \(toUsers)").show()
            
        })
    }
    
    // Sulman adding new functions
    func setStreamBoardInitialViewControllerToRoot()
    {   
        let storyboard = UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil)
        
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainTabBarVC")
        self.window?.rootViewController = nil
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }
    
    func goTo_Main_StoryBoard_afterLogout()
    {
        let storyboard = UIStoryboard(name: Constants.StoryBoards.Main, bundle: nil)
        self.window?.rootViewController = nil
        self.window?.rootViewController = storyboard.instantiateInitialViewController()
        self.window?.makeKeyAndVisible()
    }
    
    func check_and_login_to_QBChat()
    {
        if(CurrentUser.isUserLogedIn())
        {
            let current_user = CurrentUser.getCurrentUser_From_UserDefaults()
            let password = Constants.QuickBlox.QB_User_Default_Password
            //QBRequest.user
            QBRequest.logIn(withUserLogin: current_user.email, password: password, successBlock:{ r, user in
                
                print("\n Login to QUICKBLOX SUCCESSFULLY !!! \n")
                
                let user    = QBUUser()
                user.id = UInt(current_user.qbid) ?? 0
                user.login = current_user.email
                user.password = Constants.QuickBlox.QB_User_Default_Password
                user.fullName = current_user.name
                
                QBCore.instance().setCurrentUser(user)
                
                if QBChat.instance.isConnected
                {
                    print("\n Already LogedIn to the chat... \n")
                    QBRTCClient.initializeRTC()
                    QBRTCClient.instance().add(self)
                    
                    self.subscribe_for_APNS()
                    self.subscribe_for_APNSVOIP()
                }
                else
                {
                    QBChat.instance.connect(withUserID: user.id, password: user.password!, completion: { (error) in
                        if error == nil
                        {
                            print("\n Successfully LogIn to QB chat ... \n")
                            QBRTCClient.initializeRTC()
                            QBRTCClient.instance().add(self)
                        }
                        else {
                            print("\n Got an error while connecting with QB chat && error = \(String(describing: error?.localizedDescription)) \n")
                        }
                        
                        self.subscribe_for_APNS()
                        self.subscribe_for_APNSVOIP()
                    })
                }
                
            }, errorBlock: { (error) -> Void in
                
                let e = Utilities.getQB_ErrorMessage_andTitle_fromErrorCode(error_StatusCode: error.status.rawValue)
                print("\n Login to QB failed with error .... \n AND title = \(e.title) AND message = \(e.message) \n")
                if(error.status.rawValue == 401){
                    self.SignUp_QB_User()
                }
            })
        }
    }
    
    func SignUp_QB_User()
    {
        let current_user = CurrentUser.getCurrentUser_From_UserDefaults()
        let password = Constants.QuickBlox.QB_User_Default_Password
        let dataAccess = DataAccess.sharedInstance
        
        let user = QBUUser()
        user.fullName = current_user.name
        user.login = current_user.email
        user.password = Constants.QuickBlox.QB_User_Default_Password
        user.tags = [Constants.OS.ios]
        
        
        QBRequest.signUp(user, successBlock: { (response, user) in
            
            print("\n => QB SIGNUP SUCCESSFULL ... \n New User Details are: ")
            print("\n \(user.id) \n \((user.fullName)!) \n \((user.login)!) \n")
            
            current_user.qbid = String(describing: user.id)
            if (UserDefaults.standard.object(forKey: "endpointArnForSNSCyberScope787") != nil) {
                current_user.arn = UserDefaults.standard.object(forKey: "endpointArnForSNSCyberScope787") as! String
            }
            
            dataAccess.add_OR_update_User(user: current_user, delegate: self)
            
        }, errorBlock: { (error) in
            
            print("\n => QB SIGNUP FAILED ... \n error = \(error)")
            
            let e = Utilities.getQB_ErrorMessage_andTitle_fromErrorCode(error_StatusCode: error.status.rawValue)
            Alert.showAlertWithMessageAndTitle(message: e.message, title: e.title)
        })
    }
}
extension AppDelegate: Add_Or_Update_User_Delegate{
    func Add_Or_Update_User_ResponseSuccess(userName: String) {
        print("Add_Or_Update_User_Delegate Add_Or_Update_User_ResponseSuccess", userName)
        self.check_and_login_to_QBChat()
    }
    
    func Add_Or_Update_User_ResponseError(error: NSError) {
        print("Add_Or_Update_User_Delegate Add_Or_Update_User_ResponseError", error)
    }
    
    
}


extension AppDelegate: QBRTCClientDelegate
{
    @objc func goto_incomingCallVC()
    {
        if(AppDelegate.QB_VideoChat_session != nil)
        {
            self.incomingCall_timer?.invalidate()
            self.incomingCall_timer = nil
            
            let vc =  UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil).instantiateViewController(withIdentifier: Constants.ViewControllers.IncomingCallVC) as! IncomingCallVC
            
            vc.topTitle = "Incoming Call"
            switch AppDelegate.QB_VideoChat_current_CallType!
            {
            case .audio:
                vc.topTitle = "Incoming Audio Call"
            case .video:
                vc.topTitle = "Incoming Video Call"
            }
            
            vc.modalPresentationCapturesStatusBarAppearance = true
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            
            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()//vc//UIViewController()
            alertWindow.backgroundColor = .clear
            alertWindow.windowLevel = UIWindowLevelAlert + 1
            alertWindow.makeKeyAndVisible()
            alertWindow.rootViewController?.present(vc, animated: true, completion: nil)
            self.popupWindow = alertWindow
            //            }
        }
    }
    
    func handleIncomingCall() {
        print("\n handleIncomingCall tapped ... \n")
        
        self.incomingCall_timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.goto_incomingCallVC), userInfo: nil, repeats: true)
        self.initiate_AVAudioSession()
    }
    
    func initiate_AVAudioSession()
    {
        let session = AVAudioSession.sharedInstance()
        if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:))))
        {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("AVAudioSession permission granted")
                    
                    do {
                        //try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
                        try session.setActive(true)
                        //Toast(text:"AVAudioSession permission granted and set AVAudioSession category SUCCESS...").show()
                    }
                    catch {
                        print("Couldn't set Audio session category")
                        //Toast(text: "Couldn't set AVAudioSession category  ...").show()
                    }
                }
                else {
                    print("AVAudioSession permission not granted")
                    //Toast(text: "AVAudioSession permission not granted ...").show()
                }
            })
        }
    }
    
    // *********************        DELEGATE METHODS        ************************** \\
    // QBRTCClientDelegate methods
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil)
    {
        print("\n ** AppDelegate ** didReceiveNewSession called ... \n")
        
        if AppDelegate.QB_VideoChat_session == nil
        {
            AppDelegate.QB_VideoChat_current_CallType = session.conferenceType
            AppDelegate.QB_VideoChat_session = session
        }
    }
    
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber)
    {
        print("\n ** AppDelegate ** connectedToUser called with userID = \(userID) \n")
        AppDelegate.QB_VideoChat_connectedTo_UserID = userID
    }
    
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        
        print("\n ** AppDelegate ** hungUpByUser called and userID = \(userID) \n")
    }
    
    func session(_ session: QBRTCBaseSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {
        
        print("\n ** AppDelegate ** receivedRemoteVideoTrack called fromUser userID \(userID) \n")
    }
    
    func sessionDidClose(_ session: QBRTCSession)
    {
        print("\n ** AppDelegate ** sessionDidClose called ...\n")
        
        if ProviderDelegate.accepted {
            ProviderDelegate.accepted = false // to be made false when ever closing the call
            ProviderDelegate.CloseCallKIT()
        }
        
        if (true) //AppDelegate.QB_VideoChat_session != nil
        {
            AppDelegate.QB_VideoChat_session?.hangUp(nil)
            
            AppDelegate.QB_VideoChat_connectedTo_UserID = nil
            AppDelegate.QB_VideoChat_current_CallType = nil
            AppDelegate.QB_VideoChat_session = nil
            
            ProviderDelegate.CloseCallKIT()
        }
    }
    
    func initializeS3() {
        let poolId = "us-west-2:fe6f90de-19ba-4786-8846-6303cc079268"
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: .USWest2, //other regionType according to your location.
            identityPoolId: poolId
        )
        let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
}

