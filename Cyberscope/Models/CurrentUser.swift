//
//  CurrentUser.swift
//  CRYOUT
//
//  Created by Saad Furqan on 15/06/2017.
//  Copyright © 2017 com.senarios. All rights reserved.
//

import Foundation
class CurrentUser
{
    public static var updated_FCM = ""
    public static var Current_UserObject = CurrentUser.getCurrentUser_From_UserDefaults()
    
    public static var CurrentUser_Followers_List: [Follower] = [Follower]() // current user k followers
    public static var CurrentUser_FollowersID_List: [String] = [String]()
    
    public static var CurrentUser_Followings_List: [Follower] = [Follower]() // current user jin ko follow kar rha ha
    public static var CurrentUser_FollowingsID_List: [String] = [String]()
    
    public static var BlockedUsers_List_whichAreBlocked_byCurrentUser: [BlockedUser] = [BlockedUser]()
    public static var BlockedUsers_IDList_whichAreBlocked_byCurrentUser: [String] = [String]()
    
    public static var BlockedUsers_List_whoBlocked_CurrentUser: [BlockedUser] = [BlockedUser]()
    public static var BlockedUsers_IDList_whoBlocked_CurrentUser: [String] = [String]()
    
    public static var CurrentUser_All_Appointments_List: [Appointment] = [Appointment]()
    public static var Appointments_List_whichAreMade_byCurrentUser: [Appointment] = [Appointment]()
    public static var Appointments_List_whoAppoint_CurrentUser: [Appointment] = [Appointment]()
    
    static func isUserLogedIn() -> Bool
    {
        var isUserSignIn = false
        if let status = UserDefaults.standard.object(forKey: Constants.userStatus_keys.isUserLoggedIntoCyberscopeTV_2333_key)
        {
            isUserSignIn = status as! Bool
        }
        
        return isUserSignIn
    }
    
    static func setCurrentUserStatus_as_Login()
    {
        UserDefaults.standard.set(true, forKey: Constants.userStatus_keys.isUserLoggedIntoCyberscopeTV_2333_key)
        UserDefaults.standard.synchronize()
    }
    
    static func setCurrentUserStatus_as_LogOut()
    {
        UserDefaults.standard.set(false, forKey: Constants.userStatus_keys.isUserLoggedIntoCyberscopeTV_2333_key)
        UserDefaults.standard.synchronize()
    }
    
    static func setCurrentUser_FCM(newFCM: String)
    {
        UserDefaults.standard.set("\(newFCM)", forKey: Constants.UserFields.arn)
        UserDefaults.standard.synchronize()
    }
    
    static func getCurrentUser_FCM() -> String
    {
        var fcm = ""
        if let FCM = UserDefaults.standard.object(forKey: Constants.UserFields.arn)
        {
            fcm = FCM as! String
        }
        print("\nCurrently Saved FCM = \(fcm)\n")
        return fcm
    }
  
    
    static func get_User_username_fromUserDefaults() -> String
    {
        let userName = UserDefaults.standard.value(forKey: Constants.CurrentUser_UserDefaults.CurrentUser_username) as? String ?? ""
        return userName
    }
    
    static func get_User_useremail_fromUserDefaults() -> String
    {
        let email = UserDefaults.standard.value(forKey: Constants.CurrentUser_UserDefaults.CurrentUser_email) as? String ?? ""
        return email
    }
    
    static func get_User_status_fromUserDefaults() -> Int32
    {
        let userName = UserDefaults.standard.value(forKey: Constants.CurrentUser_UserDefaults.CurrentUser_status) as? Int32 ?? 0
        return userName
    }
    // :- ****************
    
    static func printCurrentUser_Details(user: User)
    {
        print("\n\t\t********************\n")
        
        print("\(Constants.UserFields.name): \(user.name)")
        print("\(Constants.UserFields.username): \(user.username)")
        print("\(Constants.UserFields.password): \(user.password)")
        print("\(Constants.UserFields.email): \(user.email)")
        print("\(Constants.UserFields.credit): \(user.credit)")
        print("\(Constants.UserFields.arn): \(user.arn)")
        
        print("\(Constants.UserFields.picture): \(user.picture)")
        print("\(Constants.UserFields.skills): \(user.skills)")
        print("\(Constants.UserFields.linkedin): \(user.linkedin)")
        print("\(Constants.UserFields.qbid): \(user.qbid)")
        print("\(Constants.UserFields.paypal): \(user.paypal)")
        print("\(Constants.UserFields.broadcasts): \(user.broadcasts)")
        print("\(Constants.UserFields.link): \(user.link)")
        print("\(Constants.UserFields.rate): \(user.rate)")
        
        print("\n\t\t********************\n")
    }
    
    static func setCurrentUser_UserDefaults(user: User)
    {
        UserDefaults.standard.set(user.name, forKey: Constants.CurrentUser_UserDefaults.CurrentUser_name)
        UserDefaults.standard.set(user.username, forKey: Constants.CurrentUser_UserDefaults.CurrentUser_username)
        UserDefaults.standard.set(user.password, forKey: Constants.CurrentUser_UserDefaults.CurrentUser_password)
        UserDefaults.standard.set(user.email, forKey: Constants.CurrentUser_UserDefaults.CurrentUser_email)
        UserDefaults.standard.set(user.credit, forKey: Constants.CurrentUser_UserDefaults.CurrentUser_credit)
        UserDefaults.standard.set(user.arn, forKey: Constants.CurrentUser_UserDefaults.CurrentUser_arn)
        
        UserDefaults.standard.set(user.picture, forKey: Constants.CurrentUser_UserDefaults.picture)
        UserDefaults.standard.set(user.skills, forKey: Constants.CurrentUser_UserDefaults.skills)
        UserDefaults.standard.set(user.linkedin, forKey: Constants.CurrentUser_UserDefaults.linkedin)
        UserDefaults.standard.set(user.qbid, forKey: Constants.CurrentUser_UserDefaults.qbid)
        UserDefaults.standard.set(user.paypal, forKey: Constants.CurrentUser_UserDefaults.paypal)
        UserDefaults.standard.set(user.broadcasts, forKey: Constants.CurrentUser_UserDefaults.broadcasts)
        UserDefaults.standard.set(user.link, forKey: Constants.CurrentUser_UserDefaults.link)
        UserDefaults.standard.set(user.rate, forKey: Constants.CurrentUser_UserDefaults.rate)
        UserDefaults.standard.set(user.status, forKey:Constants.CurrentUser_UserDefaults.CurrentUser_status)
        UserDefaults.standard.set(user.total_ratings, forKey:Constants.CurrentUser_UserDefaults.total_ratings)
        UserDefaults.standard.set(user.user_ratings, forKey:Constants.CurrentUser_UserDefaults.user_ratings)
        
        UserDefaults.standard.synchronize()
    }
    
    static func update_currentUser_UserDefaults_Password(newPassword: String)
    {
        UserDefaults.standard.set(newPassword, forKey: Constants.CurrentUser_UserDefaults.CurrentUser_password)
        UserDefaults.standard.synchronize()
    }
    
    static func deSetCurrentUser_UserDefaults()
    {
        UserDefaults.standard.set("", forKey: Constants.CurrentUser_UserDefaults.CurrentUser_name)
        UserDefaults.standard.set("", forKey: Constants.CurrentUser_UserDefaults.CurrentUser_username)
        UserDefaults.standard.set("", forKey: Constants.CurrentUser_UserDefaults.CurrentUser_password)
        UserDefaults.standard.set("", forKey: Constants.CurrentUser_UserDefaults.CurrentUser_email)
        UserDefaults.standard.set("", forKey: Constants.CurrentUser_UserDefaults.CurrentUser_credit)
        UserDefaults.standard.set("", forKey: Constants.CurrentUser_UserDefaults.CurrentUser_arn)
        
        UserDefaults.standard.set("", forKey: Constants.CurrentUser_UserDefaults.picture)
        UserDefaults.standard.set("", forKey: Constants.CurrentUser_UserDefaults.skills)
        UserDefaults.standard.set("", forKey: Constants.CurrentUser_UserDefaults.linkedin)
        UserDefaults.standard.set("", forKey: Constants.CurrentUser_UserDefaults.qbid)
        UserDefaults.standard.set("", forKey: Constants.CurrentUser_UserDefaults.paypal)
        UserDefaults.standard.set("", forKey: Constants.CurrentUser_UserDefaults.broadcasts)
        UserDefaults.standard.set("", forKey: Constants.CurrentUser_UserDefaults.link)
        UserDefaults.standard.set("", forKey: Constants.CurrentUser_UserDefaults.rate)
        UserDefaults.standard.set("", forKey:Constants.CurrentUser_UserDefaults.CurrentUser_status)
        UserDefaults.standard.set("", forKey:Constants.CurrentUser_UserDefaults.total_ratings)
        UserDefaults.standard.set("", forKey:Constants.CurrentUser_UserDefaults.user_ratings)
        UserDefaults.standard.synchronize()
        
        UserDefaults.standard.removeObject(forKey: Constants.CurrentUser_UserDefaults.CurrentUser_id)
        UserDefaults.standard.removeObject(forKey: Constants.CurrentUser_UserDefaults.CurrentUser_name)
        UserDefaults.standard.removeObject(forKey: Constants.CurrentUser_UserDefaults.CurrentUser_username)
        UserDefaults.standard.removeObject(forKey: Constants.CurrentUser_UserDefaults.CurrentUser_password)
        UserDefaults.standard.removeObject(forKey: Constants.CurrentUser_UserDefaults.CurrentUser_mobile)
        UserDefaults.standard.removeObject(forKey: Constants.CurrentUser_UserDefaults.CurrentUser_email)
        UserDefaults.standard.removeObject(forKey: Constants.CurrentUser_UserDefaults.CurrentUser_credit)
        UserDefaults.standard.removeObject(forKey: Constants.CurrentUser_UserDefaults.CurrentUser_status)
        UserDefaults.standard.removeObject(forKey: Constants.CurrentUser_UserDefaults.CurrentUser_attatchment)
        UserDefaults.standard.removeObject(forKey: Constants.CurrentUser_UserDefaults.CurrentUser_devicetype)
        UserDefaults.standard.removeObject(forKey: Constants.CurrentUser_UserDefaults.total_ratings)
        UserDefaults.standard.removeObject(forKey: Constants.CurrentUser_UserDefaults.user_ratings)
        UserDefaults.standard.removeObject(forKey: Constants.CurrentUser_UserDefaults.IsApproved)
        UserDefaults.standard.removeObject(forKey: Constants.CurrentUser_UserDefaults.JobPostStatus)
        UserDefaults.standard.removeObject(forKey: Constants.CurrentUser_UserDefaults.jobSiteLink)
        UserDefaults.standard.removeObject(forKey: Constants.CurrentUser_UserDefaults.messageOnly)
        UserDefaults.standard.removeObject(forKey: Constants.CurrentUser_UserDefaults.callOnly)
        UserDefaults.standard.removeObject(forKey: Constants.CurrentUser_UserDefaults.bothmsgcall)
        
        
        
        
        //username
        
        UserDefaults.standard.synchronize()
    }
    
    static func getCurrentUser_From_UserDefaults() -> User
    {
        let user = User()
        
        user.name = UserDefaults.standard.value(forKey: Constants.CurrentUser_UserDefaults.CurrentUser_name) as? String ?? ""
        user.username = UserDefaults.standard.value(forKey: Constants.CurrentUser_UserDefaults.CurrentUser_username) as? String ?? ""
        user.password = UserDefaults.standard.value(forKey: Constants.CurrentUser_UserDefaults.CurrentUser_password) as? String ?? ""
        user.email = UserDefaults.standard.value(forKey: Constants.CurrentUser_UserDefaults.CurrentUser_email) as? String ?? ""
        user.credit = UserDefaults.standard.value(forKey: Constants.CurrentUser_UserDefaults.CurrentUser_credit) as? Double ?? 0.0
        user.arn = UserDefaults.standard.value(forKey: Constants.CurrentUser_UserDefaults.CurrentUser_arn) as? String ?? ""

        user.picture = UserDefaults.standard.value(forKey: Constants.CurrentUser_UserDefaults.picture) as? String ?? ""
        user.skills = UserDefaults.standard.value(forKey: Constants.CurrentUser_UserDefaults.skills) as? String ?? ""
        user.linkedin = UserDefaults.standard.value(forKey: Constants.CurrentUser_UserDefaults.linkedin) as? String ?? ""
        user.qbid = UserDefaults.standard.value(forKey: Constants.CurrentUser_UserDefaults.qbid) as? String ?? ""
        user.paypal = UserDefaults.standard.value(forKey: Constants.CurrentUser_UserDefaults.paypal) as? Bool ?? false
        user.broadcasts = UserDefaults.standard.value(forKey: Constants.CurrentUser_UserDefaults.broadcasts) as? Int ?? 0
        user.link = UserDefaults.standard.value(forKey: Constants.CurrentUser_UserDefaults.link) as? String ?? ""
        user.rate = UserDefaults.standard.value(forKey: Constants.CurrentUser_UserDefaults.rate) as? String ?? ""
        user.total_ratings = UserDefaults.standard.value(forKey: Constants.CurrentUser_UserDefaults.total_ratings) as? String ?? ""
        user.user_ratings = UserDefaults.standard.value(forKey: Constants.CurrentUser_UserDefaults.user_ratings) as? String ?? ""
        
        return user
    }
    
    /////////
    
    static func set_CurrentDevice_Arn(deviceArn: String)
    {
        UserDefaults.standard.set(deviceArn, forKey: Constants.current_device.currentDevice_pushCredentials_deviceArn)
        UserDefaults.standard.set(deviceArn, forKey: Constants.CurrentUser_UserDefaults.CurrentUser_arn)
        
        UserDefaults.standard.synchronize()
    }
    
    static func set_CurrentDevice_Arn()
    {
        if (UserDefaults.standard.object(forKey: Constants.current_device.currentDevice_pushCredentials_deviceArn) == nil) {
            return
        }
        let arnData = UserDefaults.standard.object(forKey: Constants.current_device.currentDevice_pushCredentials_deviceArn) as! String
        UserDefaults.standard.set(arnData, forKey: Constants.CurrentUser_UserDefaults.CurrentUser_arn)
        
        UserDefaults.standard.synchronize()
    }
    
    static func set_CurrentDevice_deviceToken(deviceToken: Data)
    {
        UserDefaults.standard.set(deviceToken, forKey: Constants.current_device.currentDevice_deviceToken)
        UserDefaults.standard.synchronize()
    }
    
    static func get_CurrentDevice_deviceToken() -> Data?
    {
        let token = UserDefaults.standard.value(forKey: Constants.current_device.currentDevice_deviceToken) as? Data ?? nil
        return token
    }
    
    static func set_CurrentDevice_pushCredentials_deviceToken(deviceToken: Data)
    {
        UserDefaults.standard.set(deviceToken, forKey: Constants.current_device.currentDevice_pushCredentials_deviceToken)
        UserDefaults.standard.synchronize()
    }
    
    static func get_CurrentDevice_pushCredentials_deviceToken() -> Data?
    {
        let token = UserDefaults.standard.value(forKey: Constants.current_device.currentDevice_pushCredentials_deviceToken) as? Data ?? nil
        return token
    }
    
}
