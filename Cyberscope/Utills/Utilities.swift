//
//  Utilities.swift
//  SmartHome
//
//  Created by Saad Furqan on 27/02/2018.
//  Copyright © 2018 Senarios. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

class Utilities
{
    static func show_ProgressHud(view: UIView)
    {
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: view, animated: true)
        }
    }
    
    static func hide_ProgressHud(view: UIView)
    {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: view, animated: false)
        }
    }
    
    // HELPING METHODS
    static func check_isCurrentUser_AlreadyFollowing_Broadcaster(broadcaster_username: String) -> Bool
    {
        var isFollowing = false
        
        for id in CurrentUser.CurrentUser_FollowingsID_List
        {
            if(id == broadcaster_username)
            {
                isFollowing = true
                break
            }
        }
        
        return isFollowing
    }
    
    static func check_isBroadcaster_AlreadyBlocked(broadcaster_username: String) -> Bool
    {
        var isBlocked = false
        
        for id in CurrentUser.BlockedUsers_IDList_whichAreBlocked_byCurrentUser
        {
            if(id == broadcaster_username)
            {
                isBlocked = true
                break
            }
        }
        for id in CurrentUser.BlockedUsers_IDList_whoBlocked_CurrentUser
        {
            if(id == broadcaster_username)
            {
                isBlocked = true
                break
            }
        }
        
        return isBlocked
    }
    
    static func get_RequiredFollowerObject_fromFollowingList_using_followerid(id: String) -> Follower?
    {
        var follow: Follower?
        for follower in CurrentUser.CurrentUser_Followings_List
        {
            if(follower.followerid == id)
            {
                follow = follower
                break
            }
        }
        
        return follow ?? nil
    }
    
    static func get_Required_BlockedUser_Object_fromList_using_blockedid(id: String) -> BlockedUser?
    {
        var b: BlockedUser?
        for user in CurrentUser.BlockedUsers_List_whichAreBlocked_byCurrentUser
        {
            if(user.blockedid == id)
            {
                b = user
                break
            }
        }
        
        return b ?? nil
    }
    
    static func getUserImage_URL(username: String) -> URL
    {
        //return URL(string: "http://www.chattterbox.co.uk/picture/Photos/\(username).png")!
        let usernameWithNoSpaces = username.replacingOccurrences(of: " ", with: "%20")
        print(username)
        return URL(string: "https://web.scottishhealth.live/picture/Photos/\(usernameWithNoSpaces).png")!
    }
    
    static func getUserImage_URLString(username: String) -> String
    {
        //return "http://www.chattterbox.co.uk/picture/Photos/\(username).png"
        return "https://web.scottishhealth.live/picture/Photos/\(username).png"
        //https://web.simx.tv/
    }
    
    static func getShareableLink(broadcastName: String, imageLink:String) -> String
    {
        if (imageLink == "") {
            //https://www.simx.tv/stream/index.php
            //return "http://www.chattterbox.co.uk/stream/index.php?q=\(broadcastName)&i=\(broadcastName)"
            return "https://web.scottishhealth.live/stream/index2.php?v=\(broadcastName)"
        }
        return "https://web.scottishhealth.live/stream/index2.php?v=\(broadcastName)"
        //https://web.simx.tv/
        
    }
    
    static func getBroadcasts_queryFilter_forBlockedUsers() -> String
    {
        var q = ""
        
        for i in 0..<CurrentUser.BlockedUsers_IDList_whichAreBlocked_byCurrentUser.count
        {
            let id = CurrentUser.BlockedUsers_IDList_whichAreBlocked_byCurrentUser[i]
            
            if(i == 0)
            {
                q = q + "(username!=\(id))"
            }
            else
            {
                q = q + "AND(username!=\(id))"
            }
        }
        
        return q
    }
    
    static func getLinkedinLink(linkedinLInk: String) -> String
    {
        var link = "https://linkedin.com/in/"
        
        let string = "hello Swift"
        if linkedinLInk.contains("linkedin.com") {
            return linkedinLInk
        }
        link = link + linkedinLInk
        return link
    }
    
    static func getQB_ErrorMessage_andTitle_fromErrorCode(error_StatusCode: Int) -> (title: String, message: String)
    {
        print("QB error status code is: \(error_StatusCode)")
        
        var title = "Failure!"
        var message = "An error occured.Please try later."
        
        switch error_StatusCode
        {
        case 400:
            title = "Bad Request"
            message = "Missing or invalid parameter. Possible causes: \n * malformed request parameters."
            break;
        case 401:
            title = "Unauthorized"
            message = "Authorization missing or incorrect. Possible causes: \n * a user tries to authorise with wrong login and password. \n * a user uses invalid session token."
            break;
        case 403:
            title = "Forbidden"
            message = "Access has been refused. Possible causes: \n * a user tries to retrieve chat messages for chat dialog he is not in occupants list."
            break;
        case 404:
            title = "Not Found"
            message = "The requested resource could not be found. Possible causes: \n * a user tries to retrieve chat messages for invalid chat dialog id. \n * a user tries to retrieve a custom object record with invalid id."
            break;
        case 422:
            title = "Unprocessable Entity"
            message = "The request was well-formed but was unable to be followed due to validation errors. Possible causes: \n * create a user with existent login or email. \n * provide values in wrong format to create some object."
            break;
        case 429:
            title = "Too Many Requests"
            message = "Rate limit for your current plan is exceeded"
            break;
        case 500:
            title = "Internal Server Error"
            message = "Server encountered an error, try again later"
            break;
        case 503:
            title = "Service Unavailable"
            message = "Server is at capacity, try again later"
            break;
        default:
            title = "Failure!"
            message = "An error occured.Please try later."
        }
        
        return (title, message)
    }
    
    // :-- *****************************
    
    static func generate_UniqueToken_string() -> String
    {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in 0..<10
        {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        let id = Int(Date().timeIntervalSince1970/7)
        let str = "\(randomString)TOKEN\(id)"
        print("New Generated UniqueToken string = \(str)")
        
        return str
    }
    
    // Helper methods for DATE
    static func currentTimeStamp_withoutMS() -> Int64
    {
        let nowDouble = NSDate().timeIntervalSince1970
        return Int64(nowDouble/1000)
    }
    
    static func currentTimeMillis() -> Int64
    {
        let nowDouble = NSDate().timeIntervalSince1970
        return Int64(nowDouble*1000)
    }
    
    static func TimeMillis_fromDate(date: Date) -> Int64
    {
        let nowDouble = date.timeIntervalSince1970
        return Int64(nowDouble*1000)
    }
    
    static func getDate_afterSubtractingDAYS(daysToSubtract: Int, fromDate: Date) -> Date
    {
        let day = (24*60*60)
        let sub = daysToSubtract * -1
        let d = fromDate.addingTimeInterval(Double(sub*day))
        
        return d
    }
    
    static func getDate_afterAddingDAYS(daysToAdd: Int, inDate: Date) -> Date
    {
        let day = (24*60*60)
        let sub = daysToAdd * 1
        let d = inDate.addingTimeInterval(Double(sub*day))
        
        return d
    }
    
    static func check_ifBothDates_haveSameDay(date1: Date, date2: Date) -> Bool
    {
        let components1 = NSCalendar.current.dateComponents([.year, .month, .day], from: date1)
        let components2 = NSCalendar.current.dateComponents([.year, .month, .day], from: date2)
        
        if components1.year == components2.year && components1.month == components2.month && components1.day == components2.day
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    static func getUTC_day_month_year_string_ofDate_with_UnderScore(date: Date) -> String
    {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date.addingTimeInterval((-5*60*60)))
        components.timeZone = TimeZone(abbreviation: "UTC")
        
        return "\(components.day!)_\(components.month!)_\(components.year!)"
    }
    
    static func getUTC_day_month_year_string_ofDate_with_Dash(date: Date) -> String
    {
//        let dateFormatterPrint = DateFormatter()
//        dateFormatterPrint.dateFormat = "MM/dd/yyyy"
        
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date.addingTimeInterval((-5*60*60)))
        components.timeZone = TimeZone(abbreviation: "UTC")
        
        return "\(components.day!)-\(components.month!)-\(components.year!)"
    }
    
    static func getImageNameForCurrentUserProfileWithLinkString(linkString: String) -> String {
        
        if (linkString == "") {
            return ""
        }
        
        if (linkString.contains(find: "linkedin.com")) {
            return Constants.imagesName.in_icon
        }
        // we did not used else if // because here is return in each case
        if (linkString.contains(find: "twitter.com")) {
            return Constants.imagesName.twtr_icon
        }
        
        if (linkString.contains(find: "facebook.com")) {
            return Constants.imagesName.fb_icon
        }
        
        return Constants.imagesName.in_icon
    }
}

extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}

