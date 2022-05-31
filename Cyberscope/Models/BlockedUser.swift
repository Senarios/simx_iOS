//
//  BlockedUser.swift
//  CyberScope
//
//  Created by Saad Furqan on 11/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import Foundation
import UIKit

class BlockedUser :Mappable
{
    var id: String
    var userid: String
    var username: String
    var blockedid: String
    var blockedname: String
    var isNew_object: Bool
    
    init()
    {
        id = "-1"
        userid = ""
        username = ""
        blockedid = ""
        blockedname = ""
        isNew_object = true
    }
    
    required init?(map: Map)
    {
        id = "-1"
        userid = ""
        username = ""
        blockedid = ""
        blockedname = ""
        isNew_object = true
    }
    
    func mapping(map: Map)
    {
        id <- map[Constants.BlockedUser_Fields.id]
        username <- map[Constants.BlockedUser_Fields.username]
        userid <- map[Constants.BlockedUser_Fields.userid]
        blockedid <- map[Constants.BlockedUser_Fields.blockedid]
        blockedname <- map[Constants.BlockedUser_Fields.blockedname]
    }
    
    init?(json: JSON)
    {
        
        id = json.stringValue(Constants.BlockedUser_Fields.id)
        username = json.stringValue(Constants.BlockedUser_Fields.username)
        userid = json.stringValue(Constants.BlockedUser_Fields.userid)
        blockedid = json.stringValue(Constants.BlockedUser_Fields.blockedid)
        blockedname = json.stringValue(Constants.BlockedUser_Fields.blockedname)
        isNew_object = false
    }
    
    init?(jsonWithoutId: JSON)
    {
        let json = jsonWithoutId as JSON
        id = "-1"
        username = json.stringValue(Constants.BlockedUser_Fields.username)
        userid = json.stringValue(Constants.BlockedUser_Fields.userid)
        blockedid = json.stringValue(Constants.BlockedUser_Fields.blockedid)
        blockedname = json.stringValue(Constants.BlockedUser_Fields.blockedname)
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
    
    func asJSONWithID() -> JSON {
        let json = [Constants.BlockedUser_Fields.id: id as AnyObject,
                    Constants.BlockedUser_Fields.username: username as AnyObject,
                    Constants.BlockedUser_Fields.userid: userid as AnyObject,
                    Constants.BlockedUser_Fields.blockedid: blockedid as AnyObject,
                    Constants.BlockedUser_Fields.blockedname: blockedname as AnyObject
        ]
        
        let data = json as JSON
        print(data)
        
        return data
    }
    
    func asJSON() -> JSON
    {
        
        let json = [Constants.BlockedUser_Fields.username: username as AnyObject,
                    Constants.BlockedUser_Fields.userid: userid as AnyObject,
                    Constants.BlockedUser_Fields.blockedid: blockedid as AnyObject,
                    Constants.BlockedUser_Fields.blockedname: blockedname as AnyObject
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
