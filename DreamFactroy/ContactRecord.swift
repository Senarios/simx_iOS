//
//  ContactRecord.swift
//  SampleAppSwift
//
//  Created by Timur Umayev on 1/4/16.
//  Copyright © 2016 dreamfactory. All rights reserved.
//
//  Refactored by Eric Elfner 2016-05-04


//import ObjectMapper
import UIKit

class RawData : Mappable{
    var list : [COVideo]?
    
    required init?(map: Map){
        list <- map["resource"]
    }
    
    func mapping(map: Map) {
        list <- map["resource"]
    }
}


class COVideo :Mappable{

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
    var title: String // 12
    var username: String // 13
    var location: String // 14
    var broadcastTags: [Tag] = [Tag]()
    var isJob: Bool
    var isOffline: Bool
    var jobDescriptionURL: String
    var rate: String
    var Applyonvideo: Bool
    var Applyonjobsite: Bool
    var messageonly : Bool
    var callonly : Bool
    var bothmsgcall : Bool
    var videourl: String
    var isApproved : Bool
    var jobSiteLink : String
    var jobPostStatus: String
    
    
//	var id: Int
//	var name: String
//	var password: String
//	var email: String
//	var doj: String
//	var mobile: String
//	var country_code: String
//	var freelancer_status: Int
//	var prefered_currency: String
//	var user_rating: Int
//	var arn: String
//	var qbid: String
//	var banned: Int
//	var con_rating: Int
//	var freelancer_progress: Int
//	var credit : String
//	var latitude : String
//	var longitude : String

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
        broadcastTags = [Tag]()
        isJob = false
        isOffline = false
        jobDescriptionURL = ""
        rate = ""
        Applyonvideo = false
        Applyonjobsite = false
        messageonly = false
        callonly = false
        bothmsgcall = false
        videourl = ""
        isApproved = false
        jobSiteLink = ""
        jobPostStatus = ""
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
        broadcastTags = [Tag]()
        isJob = false
        isOffline = false
        jobDescriptionURL = ""
        rate = ""
        Applyonvideo = false
        Applyonjobsite = false
        messageonly = false
        callonly = false
        bothmsgcall = false
        videourl = ""
        isApproved = false
        jobSiteLink = ""
        jobPostStatus = ""
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
        isJob <- map["isjob"]
        isOffline <- map["isOffline"]
        jobDescriptionURL <- map["jobDescription"]
        rate <- map["rate"]
        Applyonvideo <- map["applyonvideo"]
        Applyonjobsite <- map["applyonjobsite"]
        messageonly <- map["messageonly"]
        callonly <- map["callonly"]
        bothmsgcall <- map["bothmsgcall"]
        videourl <- map["videourl"]
        isApproved <- map["isApproved"]
        jobSiteLink <- map["jobSiteLink"]
        jobPostStatus <- map["jobPostStatus"]
        isOffline = (map.JSON["isOffline"] as? String == "1")
        print("isOffline - \(isOffline)")
    }
    
	func setQbid(qbid: String){
		//self.qbid = qbid
	}
    
	init?(json: JSON)
    {
        // //print("\(json)")
        
        id = (json["id"] as! Int)
        name = json.stringValue("name")
        broadcast = json.stringValue("broadcast")
        arn = json.stringValue("arn")
        imglink = json.stringValue("imglink")
        status = json.stringValue("status")
        viewers = (json["viewers"] as! Int)
        time = json.stringValue("time")
        skill = json.stringValue("skill")
        latti = json.stringValue("latti")
        longi = json.stringValue("longi")
        title = json.stringValue("title")
        username = json.stringValue("username")
        location = json.stringValue("location")
        isJob = json.boolValue("isJob")
        isOffline = json.boolValue("isOffline")
        jobDescriptionURL = json.stringValue("jobDescription")
        Applyonvideo = json.boolValue("applyonvideo")
        Applyonjobsite = json.boolValue("applyonjobsite")
        messageonly = json.boolValue("messageonly")
        callonly = json.boolValue("callonly")
        bothmsgcall = json.boolValue("bothmsgcall")
        videourl = json.stringValue("videourl")
        isApproved = json.boolValue("isApproved")
        jobSiteLink = json.stringValue("jobSiteLink")
        jobPostStatus = json.stringValue("jobPostStatus")
        
        userSkill = ""
        rate = ""
        let users_by_username = json["users_by_username"]
        if (users_by_username != nil && !(users_by_username is NSNull))
        {
            let skills = (users_by_username as! [String: AnyObject])["skills"]
            userSkill = skills != nil ? skills as! String : ""
            
            let lRate = (users_by_username as! [String: AnyObject])["rate"]
            rate = lRate != nil ? lRate as! String : ""
            
        }
        let tags_by_broadcast = json["tags_by_broadcast"]
        if (tags_by_broadcast != nil && !(tags_by_broadcast is NSNull))
        {
            var tags = (tags_by_broadcast as! [[String: Any]])
            for tag in tags{
                let tagObj = tag as! [String : Any]
                let lTag = Tag(JSON: tagObj)
                self.broadcastTags.append(lTag!)
            }
        }
	}
	static func fromJsonArray(_ jsonArray:JSONArray)->[COVideo] {
		var contacts = [COVideo]()
		for json in jsonArray {
			if let contact = COVideo(json: json) {
				contacts.append(contact)
			}
		}
		return contacts
	}
	func asJSONWithID() -> JSON {
        let llocation = location == nil ? "" : location
        let json = ["id": id as AnyObject,
                    "name": name as AnyObject,
                    "broadcast": broadcast as AnyObject,
                    "arn": (arn == nil ? "" : arn) as AnyObject,
                    "imglink": imglink as AnyObject,
                    "status": status as AnyObject,
                    "viewers": viewers as AnyObject,
                    "time": time as AnyObject,
                    "skill": skill as AnyObject,
                    "latti": latti as AnyObject,
                    "longi": longi as AnyObject,
                    "title": title as AnyObject,
                    "username": username as AnyObject,
                    "location": llocation as AnyObject,
                    "isjob": isJob  as AnyObject,
                    "isoffline": isOffline  as AnyObject,
                    "jobDescription": jobDescriptionURL as AnyObject,
                    "applyonvideo" : Applyonvideo as AnyObject,
                    "applyonjobsite": Applyonjobsite as AnyObject,
                    "messageonly": messageonly as AnyObject,
                    "callonly": callonly as AnyObject,
                    "bothmsgcall": bothmsgcall as AnyObject,
                    "videourl": videourl as AnyObject,
                    "isApproved": isApproved as AnyObject,
                    "jobSiteLink": jobSiteLink as AnyObject,
                    "jobPostStatus": jobPostStatus as AnyObject
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

        var tagsArray: [[String: String]] = [[String: String]]()
        for value in broadcastTags {
            let json = (["broadcast": value.broadcast, "tag": value.tag])
            tagsArray.append(json as! [String : String])
        }
            
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
            "location": location as AnyObject,
            "isjob": isJob as AnyObject,
            "isoffline": isOffline as AnyObject,
            "tags_by_broadcast": tagsArray as AnyObject,
            "jobDescription": jobDescriptionURL as AnyObject,
            "applyonvideo" : Applyonvideo as AnyObject,
            "applyonjobsite": Applyonjobsite as AnyObject,
            "messageonly" : messageonly as AnyObject,
            "callonly": callonly as AnyObject,
            "bothmsgcall": bothmsgcall as AnyObject,
            "videourl": videourl as AnyObject,
            "isApproved": isApproved as AnyObject,
            "jobSiteLink": jobSiteLink as AnyObject,
            "jobPostStatus": jobPostStatus as AnyObject
            
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
