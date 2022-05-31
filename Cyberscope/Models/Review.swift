//
//  Review.swift
//  SimX
//
//  Created by Senarios on 23/06/2021.
//  Copyright © 2021 Agilio. All rights reserved.
//

import UIKit
import Foundation
class Review:NSObject {
    
    var toUserId: String?
    var id: Int?
    var review: String?
    var rating: Int?
    var userId: String?
    var user: User?
    
    func saveReview(dict: NSDictionary?) -> NSMutableArray? {
        
        let arrReview: NSMutableArray = []
        let objReview = Review.init(dict: dict!)
        arrReview.add(objReview!)
        
        return arrReview
    }

    func getReview(responseArray: NSMutableArray?) -> NSMutableArray?
    {
        let arr: NSMutableArray = []
        for dict in responseArray!
        {
            let objReview = Review.init(dict: dict as! NSDictionary)
            arr.add(objReview!)
        }
        return arr
    }
    
    convenience init?(dict dictReview: NSDictionary)
    {
        self.init()
        self.toUserId = dictReview["toUserId"] as? String
        self.id = dictReview["id"] as? Int
        self.review = dictReview["review"] as? String
        self.rating = dictReview["rating"] as? Int
        self.userId = dictReview["userId"] as? String
        self.user = User.init(json: dictReview["users_by_userId"] as! JSON)
    }
}
