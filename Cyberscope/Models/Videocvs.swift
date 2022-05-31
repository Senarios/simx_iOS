//
//  Videocvs.swift
//  SimX
//
//  Created by APPLE on 02/07/2020.
//  Copyright © 2020 Agilio. All rights reserved.
//

import Foundation
import Foundation
import UIKit

class Videocvs :Mappable
{
    
    var id: Int
    var title: String // username(P.K) of current user who is going to follow broadcaster
    var username: String // name of current user who is going to follow broadcaster
    var videocv: String // username(P.K) of broadcaster
    
    init()
    {
        id = -1
        title = ""
        username = ""
        videocv = ""
    }
    
    required init?(map: Map)
    {
        id = -1
        title = ""
        username = ""
        videocv = ""
    }
    
    func mapping(map: Map)
    {
        id <- map[Constants.VideoCVs_Fields.id]
        username <- map[Constants.VideoCVs_Fields.username]
        title <- map[Constants.VideoCVs_Fields.title]
        videocv <- map[Constants.VideoCVs_Fields.videocv]
    }
    
    func setQbid(qbid: String)
    {
        //self.qbid = qbid
    }
    
    init?(json: JSON)
    {
        
        id = json.integerValue(Constants.VideoCVs_Fields.id)
        username = json.stringValue(Constants.VideoCVs_Fields.username)
        title = json.stringValue(Constants.VideoCVs_Fields.title)
        videocv = json.stringValue(Constants.VideoCVs_Fields.videocv)
    }
    
    init?(jsonWithoutId: JSON)
    {
        let json = jsonWithoutId as JSON
        id = -1
        username = json.stringValue(Constants.VideoCVs_Fields.username)
        title = json.stringValue(Constants.VideoCVs_Fields.title)
        videocv = json.stringValue(Constants.VideoCVs_Fields.videocv)
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
        
        let json = [Constants.VideoCVs_Fields.id: id as AnyObject,
                    Constants.VideoCVs_Fields.username: username as AnyObject,
                    Constants.VideoCVs_Fields.title: title as AnyObject,
                    Constants.VideoCVs_Fields.videocv: videocv as AnyObject
        ]
        
        let data = json as JSON
        print(data)
        
        return data
    }
    
    func asJSON() -> JSON
    {
        
        let json = [Constants.VideoCVs_Fields.username: username as AnyObject,
                    Constants.VideoCVs_Fields.title: title as AnyObject,
                    Constants.VideoCVs_Fields.videocv: videocv as AnyObject
        ]
        
        let data = json as JSON
        print(data)
        
        return data
    }
}
