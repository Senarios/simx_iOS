//
//  User.swift
//  CRYOUT
//
//  Created by Saad Furqan on 09/06/2017.
//  Copyright © 2017 com.senarios. All rights reserved.
//

import Foundation
import UIKit



class User :Mappable
{
    //var id: Int
    var name: String
    var username: String
    var password: String
    var email: String
    var arn: String
    var credit: Double = 0.0
    var picture: String
    var skills: String
    var linkedin: String
    var qbid: String
    var paypal: Bool
    var broadcasts: Int
    var link: String
    var rate: String
    var isNew_object: Bool
    var status: Int32
    var total_ratings: String
    var user_ratings: String
    
    init()
    {
        //id = -1
        name = ""
        username = ""
        password = ""
        email = ""
        arn = ""
        credit = 0.0
        picture = ""
        skills = ""
        linkedin = "NA"
        qbid = ""
        paypal = false
        broadcasts = 0
        link = ""
        rate = ""
        status = 0
        isNew_object = true
        total_ratings = "0"
        user_ratings = "0"
    }
    
    required init?(map: Map)
    {
        //id = -1
        name = ""
        username = ""
        password = ""
        email = ""
        arn = ""
        credit = 0.0
        picture = ""
        skills = ""
        linkedin = "NA"
        qbid = ""
        paypal = false
        broadcasts = 0
        link = ""
        rate = ""
        status = 0
        isNew_object = true
        total_ratings = ""
        user_ratings = ""
    }
    
    func mapping(map: Map)
    {
        //id <- map[Constants.UserFields.id]
        name <- map[Constants.UserFields.name]
        username <- map[Constants.UserFields.username]
        password <- map[Constants.UserFields.password]
        email <- map[Constants.UserFields.email]
        credit <- map[Constants.UserFields.credit]
        arn <- map[Constants.UserFields.arn]
        picture <- map[Constants.UserFields.picture]
        skills <- map[Constants.UserFields.skills]
        linkedin <- map[Constants.UserFields.linkedin]
        qbid <- map[Constants.UserFields.qbid]
        paypal <- map[Constants.UserFields.paypal]
        broadcasts <- map[Constants.UserFields.broadcasts]
        link <- map[Constants.UserFields.link]
        rate <- map[Constants.UserFields.rate]
        status <- map[Constants.UserFields.status]
        isNew_object = false
        total_ratings <- map[Constants.UserFields.total_ratings]
        user_ratings <- map[Constants.UserFields.user_ratings]
    }
    
    func setQbid(qbid: String)
    {
        //self.qbid = qbid
    }
    
    init?(json: JSON)
    {
        //id = json.integerValue(Constants.UserFields.id)//stringValue(Constants.UserFields.id)
        name = json.stringValue(Constants.UserFields.name)
        username = json.stringValue(Constants.UserFields.username)
        password = json.stringValue(Constants.UserFields.password)
        email = json.stringValue(Constants.UserFields.email)
        credit = (json[Constants.UserFields.credit] as? Double) ?? 0.0
        //Double(String(describing: json[Constants.UserFields.credit]))!//Double(json[Constants.UserFields.credit] as! String)!
        // Double(json.integerValue(Constants.UserFields.credit))
        arn = json.stringValue(Constants.UserFields.arn)
        
        picture = json.stringValue(Constants.UserFields.picture)
        skills = json.stringValue(Constants.UserFields.skills)
        linkedin = json.stringValue(Constants.UserFields.linkedin)
        qbid = json.stringValue(Constants.UserFields.qbid)
        paypal = json.boolValue(Constants.UserFields.paypal)
        broadcasts = json.integerValue(Constants.UserFields.broadcasts)
        link = json.stringValue(Constants.UserFields.link)
        rate = json.stringValue(Constants.UserFields.rate)
        status = (json[Constants.UserFields.status] as? NSString)?.intValue ?? 0
        user_ratings = json.stringValue(Constants.UserFields.user_ratings)
        total_ratings = json.stringValue(Constants.UserFields.total_ratings)
        isNew_object = false
    }
    
    init?(jsonWithoutId: JSON)
    {
        let json = jsonWithoutId as JSON
        //id = json.integerValue(Constants.UserFields.id)
        name = json.stringValue(Constants.UserFields.name)
        username = json.stringValue(Constants.UserFields.username)
        password = json.stringValue(Constants.UserFields.password)
        email = json.stringValue(Constants.UserFields.email)
        credit = json[Constants.UserFields.credit] as! Double
            // Double(json.integerValue(Constants.UserFields.credit))
        arn = json.stringValue(Constants.UserFields.arn)
        
        picture = json.stringValue(Constants.UserFields.picture)
        skills = json.stringValue(Constants.UserFields.skills)
        linkedin = json.stringValue(Constants.UserFields.linkedin)
        qbid = json.stringValue(Constants.UserFields.qbid)
        paypal = json.boolValue(Constants.UserFields.paypal)
        broadcasts = json.integerValue(Constants.UserFields.broadcasts)
        link = json.stringValue(Constants.UserFields.link)
        rate = json.stringValue(Constants.UserFields.rate)
        status = (json[Constants.UserFields.status] as? NSString)?.intValue ?? 0
        isNew_object = false
        user_ratings = json.stringValue(Constants.UserFields.user_ratings)
        total_ratings = json.stringValue(Constants.UserFields.total_ratings)
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
        
        let json = [//Constants.UserFields.id: id as AnyObject,
            Constants.UserFields.name: name as AnyObject,
            Constants.UserFields.username: username as AnyObject,
            Constants.UserFields.password: password as AnyObject,
            Constants.UserFields.email: email as AnyObject,
            Constants.UserFields.credit: credit as AnyObject,
            Constants.UserFields.arn: arn as AnyObject,
            
            Constants.UserFields.picture:picture as AnyObject,
            Constants.UserFields.skills: skills as AnyObject,
            Constants.UserFields.linkedin: linkedin as AnyObject,
            Constants.UserFields.qbid: qbid as AnyObject,
            Constants.UserFields.paypal: paypal as AnyObject,
            Constants.UserFields.broadcasts: broadcasts as AnyObject,
            Constants.UserFields.link: link as AnyObject,
            Constants.UserFields.rate: rate as AnyObject,
            //Constants.UserFields.status: status as AnyObject
            Constants.UserFields.total_ratings: total_ratings as AnyObject,
            Constants.UserFields.user_ratings: user_ratings as AnyObject
            
        ]
       
        let data = json as JSON
        print(data)
        
        return data
    }
    
    func asJSON() -> JSON
    {
        
        let json = [Constants.UserFields.name: name as AnyObject,
                    Constants.UserFields.username: username as AnyObject,
                    Constants.UserFields.password: password as AnyObject,
                    Constants.UserFields.email: email as AnyObject,
                    Constants.UserFields.credit: credit as AnyObject,
                    Constants.UserFields.arn: arn as AnyObject,
                    
                    Constants.UserFields.picture:picture as AnyObject,
                    Constants.UserFields.skills: skills as AnyObject,
                    Constants.UserFields.linkedin: linkedin as AnyObject,
                    Constants.UserFields.qbid: qbid as AnyObject,
                    Constants.UserFields.paypal: paypal as AnyObject,
                    Constants.UserFields.broadcasts: broadcasts as AnyObject,
                    Constants.UserFields.link: link as AnyObject,
                    Constants.UserFields.rate: rate as AnyObject,
                    Constants.UserFields.status: status as AnyObject,
                    Constants.UserFields.total_ratings: total_ratings as AnyObject,
                    Constants.UserFields.user_ratings: user_ratings as AnyObject
        ]
        
        let data = json as JSON
        print(data)
        
        return data
    }
    
    func isNew() -> Bool
    {
        return (isNew_object == true) //(username == "" || username == "0")
    }
    
    func setUserDefaults()
    {
        
        
        UserDefaults.standard.set(name, forKey: Constants.UserFields.name)
        UserDefaults.standard.set(username, forKey: Constants.UserFields.username)
        UserDefaults.standard.set(password, forKey: Constants.UserFields.password)
        UserDefaults.standard.set(email, forKey: Constants.UserFields.email)
        UserDefaults.standard.set(credit, forKey: Constants.UserFields.credit)
        UserDefaults.standard.set(arn, forKey: Constants.UserFields.arn)
        
        UserDefaults.standard.set(picture, forKey: Constants.UserFields.picture)
        UserDefaults.standard.set(skills, forKey: Constants.UserFields.skills)
        UserDefaults.standard.set(linkedin, forKey: Constants.UserFields.linkedin)
        UserDefaults.standard.set(qbid, forKey: Constants.UserFields.qbid)
        UserDefaults.standard.set(paypal, forKey: Constants.UserFields.paypal)
        UserDefaults.standard.set(broadcasts, forKey: Constants.UserFields.broadcasts)
        UserDefaults.standard.set(link, forKey: Constants.UserFields.link)
        UserDefaults.standard.set(rate, forKey: Constants.UserFields.rate)
        UserDefaults.standard.set(status, forKey: Constants.UserFields.status)
        UserDefaults.standard.set(user_ratings, forKey: Constants.UserFields.user_ratings)
        UserDefaults.standard.set(total_ratings, forKey: Constants.UserFields.total_ratings)
        UserDefaults.standard.synchronize()
    }
}

