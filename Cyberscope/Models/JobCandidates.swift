//
//  JobCandidates.swift
//  SimX
//
//  Created by APPLE on 02/07/2020.
//  Copyright © 2020 Agilio. All rights reserved.
//

import Foundation
import Foundation
import UIKit

class JobCandidates :Mappable
{
    
    var id: Int
    var broadcast: String // username(P.K) of current user who is going to follow broadcaster
    var username: String // name of current user who is going to follow broadcaster
    var videocvid: Int // username(P.K) of broadcaster
    var broadcastid: Int
    var Isshortlisted: Bool
  //  var isShortlisted: String
    
    init()
    {
        id = -1
        broadcast = ""
        username = ""
        videocvid = 0
        broadcastid = 0
        Isshortlisted = false
    }
    
    required init?(map: Map)
    {
        id = -1
        broadcast = ""
        username = ""
        videocvid = 0
        broadcastid = 0
        Isshortlisted = false
    }
    
    func mapping(map: Map)
    {
        id <- map[Constants.JobCandidate_Fields.id]
        username <- map[Constants.JobCandidate_Fields.username]
        broadcast <- map[Constants.JobCandidate_Fields.broadcast]
        videocvid <- map[Constants.JobCandidate_Fields.videocvid]
        broadcastid <- map[Constants.JobCandidate_Fields.broadcastid]
        Isshortlisted <- map[Constants.JobCandidate_Fields.Isshortlisted]
    }
    
    func setQbid(qbid: String)
    {
        //self.qbid = qbid
    }
    
    init?(json: JSON)
    {
        
        id = json.integerValue(Constants.JobCandidate_Fields.id)
        username = json.stringValue(Constants.JobCandidate_Fields.username)
        broadcast = json.stringValue(Constants.JobCandidate_Fields.broadcast)
        videocvid = json.integerValue(Constants.JobCandidate_Fields.videocvid)
        broadcastid = json.integerValue(Constants.JobCandidate_Fields.broadcastid)
        Isshortlisted = json.boolValue(Constants.JobCandidate_Fields.Isshortlisted)
    }
    
    init?(jsonWithoutId: JSON)
    {
        let json = jsonWithoutId as JSON
        id = -1
        username = json.stringValue(Constants.JobCandidate_Fields.username)
        broadcast = json.stringValue(Constants.JobCandidate_Fields.broadcast)
        videocvid = json.integerValue(Constants.JobCandidate_Fields.videocvid)
        broadcastid = json.integerValue(Constants.JobCandidate_Fields.broadcastid)
        Isshortlisted = json.boolValue(Constants.JobCandidate_Fields.Isshortlisted)
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
        let json = [Constants.JobCandidate_Fields.id: id as AnyObject,
                    Constants.JobCandidate_Fields.username: username as AnyObject,
                    Constants.JobCandidate_Fields.broadcast: broadcast as AnyObject,
                    Constants.JobCandidate_Fields.videocvid: videocvid as AnyObject,
                    Constants.JobCandidate_Fields.broadcastid: broadcastid as AnyObject,
                    Constants.JobCandidate_Fields.Isshortlisted: Isshortlisted as AnyObject
        ]
        
        let data = json as JSON
        print(data)
        
        return data
    }
    
    func asJSON() -> JSON
    {
        
        let json = [Constants.JobCandidate_Fields.username: username as AnyObject,
                    Constants.JobCandidate_Fields.broadcast: broadcast as AnyObject,
                    Constants.JobCandidate_Fields.videocvid: videocvid as AnyObject,
                    Constants.JobCandidate_Fields.broadcastid: broadcastid as AnyObject,
                    Constants.JobCandidate_Fields.Isshortlisted: Isshortlisted as AnyObject
        ]
        
        let data = json as JSON
        print(data)
        
        return data
    }
}

