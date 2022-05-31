//
//  JobApplication.swift
//  SimX
//
//  Created by APPLE on 06/07/2020.
//  Copyright © 2020 Agilio. All rights reserved.
//

//import ObjectMapper
import UIKit


class JobApplication :Mappable{

    var id: Int // 1
    var name: String // 2
    var broadcast: String // 3
    var arn: String // 4
    var imglink: String // 5
    var status: String // 6
    var viewers : Int // 7
    var time: String // 8
    var skill: String // 9
    var userSkill: String // 9
    var latti: String // 10
    var longi: String // 11
    var title: String = "" // 12
    var username: String // 13
    var location: String // 14
    var qbid: String
    var Isshortlisted: Bool
    var isOffline: Bool
    var VideocvID: Int
    var broadcastId: Int
    
    init() {
        
        id = -1
        name = ""
        broadcast = ""
        arn = ""
        imglink = ""
        status = ""
        viewers = 0
        time = ""
        skill = ""
        userSkill = ""
        latti = ""
        longi = ""
        title = ""
        username = ""
        location = ""
        Isshortlisted = false
        isOffline = false
        VideocvID = -1
        broadcastId = -1
        qbid = ""
        
    }
    required init?(map: Map){

        id = -1
        name = ""
        broadcast = ""
        arn = ""
        imglink = ""
        status = ""
        viewers = 0
        time = ""
        skill = ""
        latti = ""
        longi = ""
        title = ""
        username = ""
        location = ""
        userSkill = ""
        Isshortlisted = false
        isOffline = false
        VideocvID = -1
        broadcastId = -1
        qbid = ""
    }
    
    func mapping(map: Map) {
        
        print("\(map)")
        
        id <- map["id"]
        name <- map["name"]
        broadcast <- map["broadcast"]
        arn <- map["arn"]
        imglink <- map["imglink"]
        status <- map["status"]
        viewers <- map["viewers"]
        time <- map["time"]
        skill <- map["skill"]
        latti <- map["latti"]
        longi <- map["longi"]
        title <- map["title"]
        username <- map["username"]
        location <- map["location"]
        userSkill  <- map["skill"]
        Isshortlisted  <- map["Isshortlisted"]
        isOffline  <- map["isOffline"]
        VideocvID <- map["VideocvID"]
        broadcastId <- map["BroadcastID"]
        qbid <- map["qbid"]
    }
    
    func setQbid(qbid: String){
        //self.qbid = qbid
    }
    
    init?(json: JSON)
    {
        // //print("\(json)")
        
        id = (json["id"] as! Int)
        username = json.stringValue("username")
        Isshortlisted = json.boolValue("isshortlisted")
        VideocvID = json.integerValue("videocvID")
        broadcastId = json.integerValue("broadcast_id")
        time = ""
        name = ""
        skill = ""
        latti = ""
        longi = ""
        location = ""
        userSkill = ""
        broadcast = json.stringValue("broadcast")
        imglink = ""
        arn = ""
        status = ""
        qbid = ""
        viewers = -1
      //  Isshortlisted = false
        isOffline = false
         
        let users_by_username = json["users_by_username"]
        if (users_by_username != nil)
        {
            let lusers_by_username = (users_by_username as! [String: AnyObject])
            let testing = lusers_by_username
            let skills = lusers_by_username["skills"]
            userSkill = skills != nil ? skills as! String : ""
            
            let lname = lusers_by_username["name"]
            name = lname != nil ? lname as! String : ""
            
            let lqbid = lusers_by_username["qbid"]
            qbid = lqbid != nil ? lqbid as! String : ""
        }
        
        let broadcasts_by_broadcast = json["broadcasts_by_broadcast"]
        if (broadcasts_by_broadcast != nil && !(broadcasts_by_broadcast is NSNull))
        {
            let lbroadcasts_by_broadcast = (broadcasts_by_broadcast as! [String: AnyObject])
            let limglink = lbroadcasts_by_broadcast["imglink"]
            imglink = limglink != nil ? limglink as! String : ""
            
            let lId = lbroadcasts_by_broadcast["id"]
            broadcastId = lId != nil ? lId as! Int : -1
            
            let ltitle = lbroadcasts_by_broadcast["title"]
            title = ltitle != nil ? ltitle as! String : ""

            let lbroadcast = lbroadcasts_by_broadcast["broadcast"]
            broadcast = lbroadcast != nil ? lbroadcast as! String : ""
            
            if let larn = lbroadcasts_by_broadcast["arn"] {
                arn = larn is NSNull ? "" : larn as! String
            }
            else
            {
                arn = ""
            }
            
            let lstatus = lbroadcasts_by_broadcast["status"]
            status = lstatus != nil ? lstatus as! String : ""
            
            let lviewers = lbroadcasts_by_broadcast["viewers"]
            viewers = lviewers != nil ? lviewers as! Int : -1
            
            let lisOffline = lbroadcasts_by_broadcast["isOffline"]
            isOffline = lisOffline != nil ? lisOffline as! Bool : false
            
//            latti = json.stringValue("latti")
//            longi = json.stringValue("longi")
//            location = json.stringValue("location")
        }
        
        let videocvs_by_videocvID = json["videocvs_by_videocvID"]
        if (videocvs_by_videocvID != nil)
        {
            
        }
    }
    static func fromJsonArray(_ jsonArray:JSONArray)->[COVideo] {
        var contacts = [COVideo]()
        for json in jsonArray {
            if let contact = COVideo(json: json) {
                print(contact)
                contacts.append(contact)
            }
        }
        return contacts
    }
    func asJSONWithID() -> JSON {

        let json = ["id": id as AnyObject,
                    "name": name as AnyObject,
                    "broadcast": broadcast as AnyObject,
                    "arn": arn as AnyObject,
                    "imglink": imglink as AnyObject,
                    "status": status as AnyObject,
                    "viewers": viewers as AnyObject,
                    "time": time as AnyObject,
                    "skill": skill as AnyObject,
                    "latti": latti as AnyObject,
                    "longi": longi as AnyObject,
                    "title": title as AnyObject,
                    "username": username as AnyObject,
                    "location": location as AnyObject,
                    "VideocvID": VideocvID as AnyObject
        ]
        let data = json as JSON
        print(data)

        return data
    }
    
    func jsonObject_forUpdateVideoAPI() -> JSON
    {
        
        let json = ["action": "updatestatus" as AnyObject,
                    "videoid": id as AnyObject,
                    "status": status as AnyObject
        ]
        
        let data = json as JSON
        print(data)
        
        return data
    }
    func jsonObject_forUploadVideoAPI() -> JSON {
        

        
        let json = [
            "action": "uploadvideo" as AnyObject,
            "videoname": name as AnyObject,
//            "filename": file as AnyObject,
//            "thumb": thumb as AnyObject,
//            "playid": playId as AnyObject,
//            "status": status as AnyObject,
//            "numvideo": numvideos as AnyObject,
//            "userid": userid as AnyObject,
//            "user_name": user_name as AnyObject,
//            "description": "" as AnyObject,
//            "category": category as AnyObject
        ]
        
        let data = json as JSON
        print(data)
        
        return data
    }
    func asJSON() -> JSON {

        let json = [
            "name": name as AnyObject,
            "broadcast": broadcast as AnyObject,
            "arn": arn as AnyObject,
            "imglink": imglink as AnyObject,
            "status": status as AnyObject,
            "viewers": viewers as AnyObject,
            "time": time as AnyObject,
            "skill": skill as AnyObject,
            "latti": latti as AnyObject,
            "longi": longi as AnyObject,
            "title": title as AnyObject,
            "username": username as AnyObject,
            "location": location as AnyObject
        ]
        let data = json as JSON
        print(data)

        return data
    }
    
    func isNew() -> Bool {
        return id == -1
    }

    func setUserDefaults() {
//        UserDefaults.standard.set(name, forKey: "name")
//        UserDefaults.standard.set(banned, forKey: "banned")
//        UserDefaults.standard.set(con_rating, forKey: "con_rating")
//        UserDefaults.standard.set(email, forKey: "email")
//        UserDefaults.standard.set(mobile, forKey: "mobile")
//        UserDefaults.standard.set(arn, forKey: "arn")
    }
}

