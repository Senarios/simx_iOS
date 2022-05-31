//
//  UserInfoObj.swift
//  SimX
//
//  Created by Hashmi on 18/03/2022.
//  Copyright © 2022 Agilio. All rights reserved.
//

import Foundation

class UserInfoObj:NSObject{
   
    var name: String?
    var username: String?
    var password: String?
    var email: String?
    var arn: String?
    var credit: Double = 0.0
    var picture: String?
    var skills: String?
    var linkedin: String?
    var qbid: String?
    var paypal: Bool?
    var broadcasts: Int?
    var link: String?
    var rate: String?
    var isNew_object: Bool?
    var status: Int32?
    var total_ratings: String?
    var user_ratings: String?
   
   override init() {
       
   }
   
   
    init(name : String?, userName : String?, password : String?, email: String?, arn: String?, credit: Double?, picture: String?, skills: String?, linkedin: String?, qbid: String?, paypal: Bool?, broadcasts: Int?, link: String?, rate: String?, isNew_object: Bool?, status: Int32?, total_ratings: String?, user_ratings: String?){
        
        
        self.name = name
        self.password = password
        self.email = email
        self.arn = arn
        self.credit = credit ?? 0.0
        self.picture = picture
        self.skills = skills
        self.linkedin = linkedin
        self.qbid = qbid
        self.paypal = paypal
        self.broadcasts = broadcasts
        self.link = link
        self.rate = rate
        self.isNew_object = isNew_object
        self.status = status
        self.total_ratings = total_ratings
        self.user_ratings = user_ratings
    }
}

