//
//  Follower.swift
//  CRYOUT
//
//  Created by Saad Furqan on 21/06/2017.
//  Copyright © 2017 com.senarios. All rights reserved.
//

import Foundation
import UIKit

class Follower :Mappable
{
    
    var id: String
    var userid: String // username(P.K) of current user who is going to follow broadcaster
    var username: String // name of current user who is going to follow broadcaster
    var followerid: String // username(P.K) of broadcaster
    var followername: String // name of broadcaster
    var isNew_object: Bool
    
    init()
    {
        id = "-1"
        userid = ""
        username = ""
        followerid = ""
        followername = ""
        isNew_object = true
    }
    
    required init?(map: Map)
    {
        id = "-1"
        userid = ""
        username = ""
        followerid = ""
        followername = ""
        isNew_object = true
    }
    
    func mapping(map: Map)
    {
        id <- map[Constants.Follower_Fields.id]
        username <- map[Constants.Follower_Fields.username]
        userid <- map[Constants.Follower_Fields.userid]
        followerid <- map[Constants.Follower_Fields.followerid]
        followername <- map[Constants.Follower_Fields.followername]
    }
    
    func setQbid(qbid: String)
    {
        //self.qbid = qbid
    }
    
    init?(json: JSON)
    {
        
        id = json.stringValue(Constants.Follower_Fields.id)
        username = json.stringValue(Constants.Follower_Fields.username)
        userid = json.stringValue(Constants.Follower_Fields.userid)
        followerid = json.stringValue(Constants.Follower_Fields.followerid)
        followername = json.stringValue(Constants.Follower_Fields.followername)
        isNew_object = false
    }
    
    init?(jsonWithoutId: JSON)
    {
        let json = jsonWithoutId as JSON
        id = "-1"
        username = json.stringValue(Constants.Follower_Fields.username)
        userid = json.stringValue(Constants.Follower_Fields.userid)
        followerid = json.stringValue(Constants.Follower_Fields.followerid)
        followername = json.stringValue(Constants.Follower_Fields.followername)
        isNew_object = false
    }
    
    static func fromJsonArray(_ jsonArray:JSONArray)->[User]
    {
        var objects = [User]()
        for json in jsonArray
        {
            if let object = User(json: json)
            {
                objects.append(object)
            }
        }
        
        return objects
    }
    
    func asJSONWithID() -> JSON
    {
        
        let json = [Constants.Follower_Fields.id: id as AnyObject,
                    Constants.Follower_Fields.username: username as AnyObject,
                    Constants.Follower_Fields.userid: userid as AnyObject,
                    Constants.Follower_Fields.followerid: followerid as AnyObject,
                    Constants.Follower_Fields.followername: followername as AnyObject
        ]
        
        let data = json as JSON
        print(data)
        
        return data
    }
    
    func asJSON() -> JSON
    {
        
        let json = [Constants.Follower_Fields.username: username as AnyObject,
                    Constants.Follower_Fields.userid: userid as AnyObject,
                    Constants.Follower_Fields.followerid: followerid as AnyObject,
                    Constants.Follower_Fields.followername: followername as AnyObject
        ]
        
        let data = json as JSON
        print(data)
        
        return data
    }
    
    func isNew() -> Bool
    {
        return isNew_object == true
        //id == "-1"
    }
}
