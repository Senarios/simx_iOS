//
//  Tag.swift
//  SimX
//
//  Created by APPLE on 01/07/2020.
//  Copyright © 2020 Agilio. All rights reserved.
//

import Foundation
import UIKit

class Tag :Mappable
{
    
    var id: String
    var broadcast: String // username(P.K) of current user who is going to follow broadcaster
    var tag: String // name of current user who is going to follow broadcaster
    
    init()
    {
        id = "-1"
        broadcast = ""
        tag = ""
    }
    
    required init?(map: Map)
    {
        id = "-1"
        broadcast = ""
        tag = ""
    }
    
    func mapping(map: Map)
    {
        id <- map[Constants.Tag_Fields.id]
        broadcast <- map[Constants.Tag_Fields.broadcast]
        tag <- map[Constants.Tag_Fields.tag]
    }
    
    func setQbid(qbid: String)
    {
        //self.qbid = qbid
    }
    
    init?(json: JSON)
    {
        
        id = json.stringValue(Constants.Tag_Fields.id)
        broadcast = json.stringValue(Constants.Tag_Fields.broadcast)
        tag = json.stringValue(Constants.Tag_Fields.tag)
    }
    
    init?(jsonWithoutId: JSON)
    {
        let json = jsonWithoutId as JSON
        id = "-1"
        broadcast = json.stringValue(Constants.Tag_Fields.broadcast)
        tag = json.stringValue(Constants.Tag_Fields.tag)
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
        
        let json = [Constants.Tag_Fields.id: id as AnyObject,
                    Constants.Tag_Fields.broadcast: broadcast as AnyObject,
                    Constants.Tag_Fields.tag: tag as AnyObject]
        
        let data = json as JSON
        print(data)
        
        return data
    }
    
    func asJSON() -> JSON
    {
        
        let json = [Constants.Tag_Fields.id: id as AnyObject,
                    Constants.Tag_Fields.broadcast: broadcast as AnyObject,
                    Constants.Tag_Fields.tag: tag as AnyObject
        ]
        
        let data = json as JSON
        print(data)
        
        return data
    }
}

