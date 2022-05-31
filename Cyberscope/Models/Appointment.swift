//
//  Appointment.swift
//  CyberScope
//
//  Created by Saad Furqan on 12/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import Foundation
import UIKit

class Appointment :Mappable
{
    
    var id: Int
    var time: String
    var message: String
    var status: String
    var date: String
    
    var patientName: String
    var patientQbId: String
    var patientId: String
    
    var doctorName: String
    var doctorQbId: String
    var doctorId: String
    
    init()
    {
        id = -1
        time = ""
        message = ""
        status = ""
        date = ""
        
        patientName = ""
        patientQbId = ""
        patientId = ""
        
        doctorName = ""
        doctorQbId = ""
        doctorId = ""
    }
    
    required init?(map: Map)
    {
        id = -1
        time = ""
        message = ""
        status = ""
        date = ""
        
        patientName = ""
        patientQbId = ""
        patientId = ""
        
        doctorName = ""
        doctorQbId = ""
        doctorId = ""
    }
    
    func mapping(map: Map)
    {
        id <- map[Constants.Appointment_Fields.id]
        time <- map[Constants.Appointment_Fields.time]
        message <- map[Constants.Appointment_Fields.message]
        status <- map[Constants.Appointment_Fields.status]
        date <- map[Constants.Appointment_Fields.date]
        
        patientName <- map[Constants.Appointment_Fields.patientName]
        patientQbId <- map[Constants.Appointment_Fields.patientQbId]
        patientId <- map[Constants.Appointment_Fields.patientId]
        
        doctorName <- map[Constants.Appointment_Fields.doctorName]
        doctorQbId <- map[Constants.Appointment_Fields.doctorQbId]
        doctorId <- map[Constants.Appointment_Fields.doctorId]
    }
    
    init?(json: JSON)
    {
        id = json.integerValue(Constants.Appointment_Fields.id)
        time = json.stringValue(Constants.Appointment_Fields.time)
        message = json.stringValue(Constants.Appointment_Fields.message)
        status = json.stringValue(Constants.Appointment_Fields.status)
        date = json.stringValue(Constants.Appointment_Fields.date)
        
        patientName = json.stringValue(Constants.Appointment_Fields.patientName)
        patientQbId = json.stringValue(Constants.Appointment_Fields.patientQbId)
        patientId = json.stringValue(Constants.Appointment_Fields.patientId)
        
        doctorName = json.stringValue(Constants.Appointment_Fields.doctorName)
        doctorQbId = json.stringValue(Constants.Appointment_Fields.doctorQbId)
        doctorId = json.stringValue(Constants.Appointment_Fields.doctorId)
    }
    
    init?(jsonWithoutId: JSON)
    {
        let json = jsonWithoutId as JSON
        
        id = -1
        time = json.stringValue(Constants.Appointment_Fields.time)
        message = json.stringValue(Constants.Appointment_Fields.message)
        status = json.stringValue(Constants.Appointment_Fields.status)
        date = json.stringValue(Constants.Appointment_Fields.date)
        
        patientName = json.stringValue(Constants.Appointment_Fields.patientName)
        patientQbId = json.stringValue(Constants.Appointment_Fields.patientQbId)
        patientId = json.stringValue(Constants.Appointment_Fields.patientId)
        
        doctorName = json.stringValue(Constants.Appointment_Fields.doctorName)
        doctorQbId = json.stringValue(Constants.Appointment_Fields.doctorQbId)
        doctorId = json.stringValue(Constants.Appointment_Fields.doctorId)
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
        
        let json = [
            Constants.Appointment_Fields.id: id as AnyObject,
            Constants.Appointment_Fields.time: time as AnyObject,
            Constants.Appointment_Fields.message: message as AnyObject,
            Constants.Appointment_Fields.status: status as AnyObject,
            Constants.Appointment_Fields.date: date as AnyObject,
            Constants.Appointment_Fields.patientName: patientName as AnyObject,
            Constants.Appointment_Fields.patientQbId: patientQbId as AnyObject,
            Constants.Appointment_Fields.patientId: patientId as AnyObject,
            Constants.Appointment_Fields.doctorName: doctorName as AnyObject,
            Constants.Appointment_Fields.doctorQbId: doctorQbId as AnyObject,
            Constants.Appointment_Fields.doctorId: doctorId as AnyObject
        ]
        
        let data = json as JSON
        print(data)
        
        return data
    }
    
    func asJSON() -> JSON
    {
        
        let json = [
            Constants.Appointment_Fields.time: time as AnyObject,
            Constants.Appointment_Fields.message: message as AnyObject,
            Constants.Appointment_Fields.status: status as AnyObject,
            Constants.Appointment_Fields.date: date as AnyObject,
            Constants.Appointment_Fields.patientName: patientName as AnyObject,
            Constants.Appointment_Fields.patientQbId: patientQbId as AnyObject,
            Constants.Appointment_Fields.patientId: patientId as AnyObject,
            Constants.Appointment_Fields.doctorName: doctorName as AnyObject,
            Constants.Appointment_Fields.doctorQbId: doctorQbId as AnyObject,
            Constants.Appointment_Fields.doctorId: doctorId as AnyObject
        ]
        
        let data = json as JSON
        print(data)
        
        return data
    }
    
    func isNew() -> Bool
    {
        return id == -1
    }
}
