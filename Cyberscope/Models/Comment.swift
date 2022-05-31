//
//  Comment.swift
//  CyberScope
//
//  Created by Salman on 18/05/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import Foundation

class Comment: Mappable {

    var id: String = UUID().uuidString
    var name: String // user(P.K) of current user who is going to follow broadcaster
    var user: String // name of current user who is going to follow broadcaster
    var text: String // user(P.K) of broadcaster
    var arn: String // name of broadcaster
    var type: String

    init()
    {
        id = "-1"
        name = ""
        user = ""
        text = ""
        arn = ""
        type = ""
    }

    required init?(map: Map)
    {
        id = "-1"
        name = ""
        user = ""
        text = ""
        arn = ""
        type = ""
    }

    func mapping(map: Map) {
        id <- map[Constants.CommentField.id]
        name <- map[Constants.CommentField.name]
        user <- map[Constants.CommentField.user]
        text <- map[Constants.CommentField.text]
        arn <- map[Constants.CommentField.arn]
        type <- map[Constants.CommentField.type]
    }
}


struct StreamComment {
    
    let image : UIImage
    let name : String
    let comment : String
}
