//
//  DataAccess.swift
//  DreamFactoryEZ
//
//  Created by Eric Elfner on 2016-05-05.
//  Copyright © 2016 Eric Elfner. All rights reserved.
//
// This class handles server data calls by mapping between domain data
// and the RESTClient generic data. Server calls are made asynchronously and callbacks
// are by delegate protocols and always made on the main thread.
//
// This is implemented as a singleton to simplify code and only access a specific server.
// A more generic implementation would have server instance injected.

import Foundation
import Alamofire

/*
 String INSTANCE_URL = "http://www.chattterbox.co.uk:90/api/v2";
 String DB_SVC = "mysql/_table";
 // API key for your app goes here, see apps tab in admin console
 String API_KEY = "b0a363a985c7a2ddf5057789adad5fe0dd47c8a38eaee82a963e3d3d6353ed1e";
 */


private let kApiKey = "" //"b0a363a985c7a2ddf5057789adad5fe0dd47c8a38eaee82a963e3d3d6353ed1e"

// //let kBaseInstanceUrl = "http://www.chattterbox.co.uk:90/api/v2"
let kBaseInstanceUrl = ""
//"http://www.simx.tv:90/api/v2"


// -  - // "mysql/_table"
//private let coRestVideos = "/mysql/_table/broadcasts"
private let coRestRatings = "/mysql/_table/ratings"
private let coRestVideos = "/mysql/_table/broadcasts"
private let coRestVideosWithUser = "/mysql/_table/broadcasts?related=users_by_username"
private let coRestFollowers = "/mysql/_table/followers"
private let coRestAppointments = "/mysql/_table/appointments"
private let coRestJobcandidates = "/mysql/_table/jobcandidates"
private let coRestVideoCVs = "/mysql/_table/videocvs"

private let kRestContact =      "/mysql/_table/users"
private let kRestMobileUsers =  "/mysql/_table/users"
private let kRestCallRecords =  "/mysql/_table/calls_records"
private let kRestBlockedUsers = "/mysql/_table/blockedusers"

private let kRestFreelancer = "/mysql/_table/freelancer"
private let kRestTransaction = "/mysql/_table/transaction"
private let kRestCharges = "/mysql/_table/charges"
private let kRestCall = "/mysql/_table/calls"
private let kRestCurrency = "/mysql/_table/currency"
private let kRestContactGroupRelationship = "/db/_table/contact_group_relationship"
private let kRestGroup = "mysql/_table"
private let kRestContactDetail = "/db/_table/contact_info"
/*
 String INSTANCE_URL = "http://52.66.176.216:90/api/v2";
 String DB_SVC = "mysql/_table";
 // API key for your app goes here, see apps tab in admin console
 String API_KEY = "241924a44b09afbef481fb01705475eff896549d0a628f1824e10c37e666e2bf";
 */
typealias GetContactsHandler = ([String], NSError?)->Void

protocol RegistrationDelegate {
    func userIsRegisteredSuccess(_ bSignedIn:Bool, message:String?)
}

protocol GetReviewsSuccessDelegate {
    func recievedReviews(_ reviewsArray: [Review])
}

protocol RatingAndReviewDelegate {
    func ratedSuccessfully(_ totalRating: String, _ userRating: String)
}

protocol SignInDelegate {
    func userIsSignedInSuccess(_ bSignedIn:Bool, message:String?)
    func userIsSignedOut()
}

protocol ContactDetailDelegate {
    //    func setContactGroups(_ groups: [GroupRecord])
    func setContactDetails(_ details: [COVideo])
    func dataAccessError(_ error:NSError?)
}

protocol RemoveJobApplicationDelegate {
    //    func setContactGroups(_ groups: [GroupRecord])
    func removeJobApplicationResponse()
    func dataAccessError(_ error: String)
}

protocol RemoveVideoCVDelegate {
    //    func setContactGroups(_ groups: [GroupRecord])
    func removeVideoCVResponse()
    func removeVideoCV_Error(_ error: String)
}

protocol get_Users_Delegate
{
    func get_Users_Success(_ users: [User])
    func get_Users_Error(_ error:NSError?)
}

protocol UpdateUser_Delegate
{
    func UpdateUser_ResponseSuccess(updated_user: User, status: Bool)
    func UpdateUser_ResponseError(_ error:NSError?)
}

protocol UpdateUserBalance_Delegate
{
    func UpdateUser_ResponseSuccess(isUserUpdated: Bool)
    func UpdateUser_ResponseError(_ error:NSError?)
}

protocol UpdateUserBroadcastsCount_Delegate
{
    func UpdateUser_ResponseSuccess(isUserUpdated: Bool)
    func UpdateUser_ResponseError(_ error:NSError?)
}

protocol UpdateJobAplication_Delegate
{
    func UpdateJobApplication_ResponseSuccess(isUserUpdated: Bool)
}

// Login
protocol UserDetailDelegate {
    
    func setRecievedUserStatus(_ status: Bool, statusString: String, userData: User)
    func dataAccessError(_ error:NSError?)
}

// Login
protocol get_UserData_Delegate
{
    func get_UserData_ResponseSuccess(isExist: Bool, requiredUser: User)
    func get_UserData_ResponseError(_ error:NSError?)
}

protocol UserStatusDelegate
{
    func recievedUserStatus(_ status: Bool, statusString: String, requiredUser: User)
    func dataAccessError(_ error:NSError?)
}

protocol IsTwitter_Facebook_IdAlready_Exist_Delegate
{
    func IsTwitter_Facebook_IdAlready_Exist_Respnse(_ isExist: Bool,statusString: String ,requiredUser: User)
    func Twitter_Facebook_Account_AccessError(_ error:String)
}
protocol UserSignInWithEmailGoCoderDelegate {
    // func setContactGroups(_ groups: [GroupRecord])
    func setContactDetails(_ user: JSON)
    func dataAccessError(_ error:NSError?)
}

protocol VideosDetailsDelegate
{
    func setVideosRecieved(_ videos: [COVideo])
    func set_n_VideosRecieved(_ videos: [COVideo])
    func dataAccessError(_ error:NSError?)
}

protocol MyJobApplicationsDelegate
{
    func setMyJobApplicationsRecieved(_ videos: [JobApplication])
    func dataAccessError(_ error:NSError?)
}

protocol DeleteBroadcastDelegate
{
    func deleteBroadcastSuccess(_ status: String)
    func deleteBroadcastError(_ error:NSError?)
}

protocol FollowersDetailDelegate {
    func getFollowersData_ResponseSuccess(_ followers: [Follower])
    func getFollowersData_ResponseError(_ error:NSError?)
}

protocol getBlockedUsers_Data_Delegate
{
    func getBlockedUsers_Data_ResponseSuccess(blockedUsers: [BlockedUser])
    func getBlockedUsers_Data_ResponseError(_ error:NSError?)
}

protocol getAppointments_Data_Delegate
{
    func getAppointments_Data_ResponseSuccess(appointments: [Appointment])
    func getAppointments_Data_ResponseError(_ error:NSError?)
}

protocol getVideoCVs_Data_Delegate
{
    func getVideoCVs_Data_ResponseSuccess(videocvs: [Videocvs])
    func getVideoCVs_Data_ResponseError(_ error:NSError?)
}

protocol AddMobileUserDelegate {
    func updatedResponse(isSuccess: Bool , error: String)
}

protocol getFollowers_Data_Delegate
{
    func getFollowers_Data_ResponseSuccess(followers: [Follower])
    func getFollowers_Data_ResponseError(_ error:NSError?)
}

protocol getUsers_Data_Delegate
{
    func getUsers_Data_ResponseSuccess(users: [User])
    func getUsers_Data_ResponseError(_ error:NSError?)
}

protocol SignUpUser_Delegate {
    func SignUpUser_Delegate_Response(isSuccess: Bool , error: String, id: Int)
}

protocol AddCallRecord_Delegate {
    func AddCallRecord_Delegate_Response(isSuccess: Bool , error: String, id: String)
}

protocol ContactUpdateDelegate {
    func dataAccessSuccessfullyUpdated()
    
    func setContact(_ contact:COVideo)
    func dataAccessError(_ error:NSError?)
}
protocol AddUpdateVideo_Protocol {
    func updatedResponse(isSuccess: Bool , error: String, id: Int)
}
protocol UploadVideo_API_call_Protocol {
    func updatedResponse(isSuccess: Bool , error: String, id: Int)
}
protocol UpdateUser_FCM_Protocol {
    func updated_FCM_Response(isSuccess: Bool , error: String, id: Int)
}
protocol UpdateUser_Password_Protocol {
    func updated_Password_Response(isSuccess: Bool , error: String, id: Int)
}
protocol addFollower_Delegate {
    func addFollower_Delegate_Response(isSuccess: Bool , error: String, senderTag: Int, id: Int)
}

protocol Add_Follower_Delegate
{
    func Add_Follower_ResponseSuccess(senderTag: Int, id: String)
    func Add_Follower_ResponseError(error: NSError)
}

protocol removeFollower_Delegate {
    func removeFollower_Delegate_Response(isSuccess: Bool , error: String, senderTag: Int, id: String)
}

protocol Add_BlockedUser_Delegate
{
    func Add_BlockedUser_ResponseSuccess(senderTag: Int, id: String)
    func Add_BlockedUser_ResponseError(error: NSError)
}

protocol Add_Appointment_Delegate
{
    func Add_Appointment_ResponseSuccess(senderTag: Int, id: Int)
    func Add_Appointment_ResponseError(error: NSError)
}

protocol Add_jobCandidates_Delegate
{
    func Add_jobCandidates_ResponseSuccess(id: Int)
    func Add_jobCandidates_ResponseError(error: NSError)
}

protocol Delete_Appointment_Delegate
{
    func Delete_Appointment_ResponseSuccess(senderTag: Int, id: Int)
    func Delete_Appointment_ResponseError(error: NSError)
}

protocol Add_Or_Update_User_Delegate
{
    func Add_Or_Update_User_ResponseSuccess(userName: String)
    func Add_Or_Update_User_ResponseError(error: NSError)
}

protocol Remove_BlockedUser_Delegate
{
    func Remove_BlockedUser_ResponseSuccess(senderTag: Int, id: String)
    func Remove_BlockedUser_ResponseError(error: NSError)
}

protocol verify_isEmail_alreadyExist_Delegate
{
    func verify_isEmail_alreadyExist_Response(isExist: Bool, statusString: String)
}
protocol verify_isMobileNumber_alreadyExist_Delegate
{
    func verify_isMobileNumber_alreadyExist_Response(isExist: Bool, mobile: String)
}
protocol get_userData_usingMobile_Delegate
{
    func get_userData_usingMobile_Response(isExist: Bool, requiredUser: User)
}

protocol send_Appointment_Notification_Delegate
{
    func send_Appointment_Notification_Success(msg: String)
    func send_Appointment_Notification_Error(error: String)
}

//  :--- ****************************************************************************

class DataAccess
{
    
    static let sharedInstance = DataAccess()
    fileprivate(set) var allGroups = [GroupRecord]() // Groups will be cached here.
    
    var currentGroupID: NSNumber? = nil
    fileprivate var restClient = RESTClient(apiKey: kApiKey, instanceUrl: kBaseInstanceUrl)
    
    func isSignedIn() -> Bool {
        return restClient.isSignedIn
    }
    
    func signedInUser() -> String? {
        return restClient.sessionEmail
    }
    
    func registerWithEmail(_ email:String, password:String, registrationDelegate: RegistrationDelegate) {
        restClient.registerWithEmail(email, password: password) { (bSuccess, message) in
            DispatchQueue.main.async {
                registrationDelegate.userIsRegisteredSuccess(bSuccess, message: message)
            }
        }
    }
    
    func signInWithEmail(_ email:String, password:String, signInDelegate: SignInDelegate) {
        
        
        restClient.signInWithEmail(email, password: password) { (bSignedIn, message) in
            
            print(bSignedIn, message)
            
            DispatchQueue.main.async {
                if bSignedIn {
                    
                }
                signInDelegate.userIsSignedInSuccess(bSignedIn, message: message)
            }
        }
    }
    
    func signOut(_ signInDelegate: SignInDelegate)
    {
        restClient.signOut()
        DispatchQueue.main.async
            {
                signInDelegate.userIsSignedOut()
        }
    }
    
    func getContact(_ id:Int, resultDelegate: ContactUpdateDelegate) {
        restClient.callRestService(kRestContact + "/\(id)", method: .GET, queryParams: nil, body: nil) { restResult in
            var contact:COVideo?
            if restResult.bIsSuccess {
                if let contactJson = restResult.json {
                    contact = COVideo(json:contactJson)
                }
            }
            if let contact = contact {
                DispatchQueue.main.async {
                    resultDelegate.setContact(contact)
                }
            }
            else {
                let error = restResult.error ?? NSError(domain: "DreamFactory API", code: 500, userInfo: [NSLocalizedDescriptionKey : "Could not create Contact from API result."])
                DispatchQueue.main.async {
                    resultDelegate.dataAccessError(error)
                }
            }
        }
    }
    
    //    func getContacts(_ group:GroupRecord?, resultDelegate: ContactsDelegate) {
    //        if let groupId = group?.id {
    //            getContactsForGroup(NSNumber.init(value: groupId), resultDelegate: resultDelegate)
    //        }
    //        else {
    //            getContactsAll(resultDelegate)
    //        }
    //    }
    
    func getContactDetails(_ contactId:Int, resultDelegate: ContactDetailDelegate) {
        getContactDetailsInfo(contactId, resultDelegate: resultDelegate)
        getContactDetailsGroups(contactId, resultDelegate: resultDelegate)
    }
    
    func getUserForSignIn(_ email:String, _ password: String, resultDelegate: UserDetailDelegate)
    {
        getUserForrSignIn(email, password, resultDelegate: resultDelegate)
        //getContactDetailsGroups(contactId, resultDelegate: resultDelegate)
    }
    
    func getUserByAttribute(_ attributeName:String, _ attributeValue: String, resultDelegate: UserDetailDelegate)
    {
        getUserByAttributeData(attributeName, attributeValue, resultDelegate: resultDelegate)
    }
    
    func getVideoDetailsList(_ videoDelegate: VideosDetailsDelegate)
    {   
        getVideoDetails(videoDelegate)
    }
    
    func getMyJobApplicationList(_ videoDelegate: MyJobApplicationsDelegate)
    {
        getMyJobApplications(videoDelegate)
    }
    
    func getMyJobApplicationListByBroadcast(_ videoDelegate: MyJobApplicationsDelegate, broadcastName: String)
    {
        getMyJobApplicationsByBroadcast(videoDelegate, broadcastName: broadcastName)
    }
    
    func getMyFollowersList(_ videoDelegate: MyJobApplicationsDelegate, broadcastName: String)
    {
        getMyJobApplicationsByBroadcast(videoDelegate, broadcastName: broadcastName)
    }
    
    fileprivate func getContactDetailsInfo(_ contactId:Int, resultDelegate: ContactDetailDelegate) {
        let queryParams = ["filter" : "contact_id=\(contactId)"]
        restClient.callRestService(kRestContactDetail, method: .GET, queryParams: queryParams, body: nil) { restResult in
            if restResult.bIsSuccess {
                var details = [ContactDetailRecord]()
                if let detailArray = restResult.json?["resource"] as? JSONArray {
                    for detailJSON in detailArray {
                        if let detail = ContactDetailRecord(json:detailJSON) {
                            details.append(detail)
                        }
                    }
                }
                //                DispatchQueue.main.async {
                //                    //resultDelegate.setContactDetails(details)
                //                }
            }
            else {
                DispatchQueue.main.async {
                    resultDelegate.dataAccessError(restResult.error)
                }
            }
        }
    }
    //
    //    func getUserWithEmail(_ email:String, _ password: String, resultDelegate: UserSignInWithEmailGoCoderDelegate) {
    //        let queryParams = ["filter" : "email=\(email)"]
    //        restClient.callRestService(kRestContactDetail, method: .GET, queryParams: queryParams, body: nil) { restResult in
    //            if restResult.bIsSuccess {
    //                var details = [ContactDetailRecord]()
    //                if let detailArray = restResult.json?["resource"] as? JSONArray {
    //                    for detailJSON in detailArray {
    //                        if let detail = ContactDetailRecord(json:detailJSON) {
    //                            details.append(detail)
    //                        }
    //                    }
    //                }
    //                //                DispatchQueue.main.async {
    //                //                    //resultDelegate.setContactDetails(details)
    //                //                }
    //            }
    //            else {
    //                DispatchQueue.main.async {
    //                    resultDelegate.dataAccessError(restResult.error)
    //                }
    //            }
    //        }
    //    }
    
    func removeContact(_ contact: COVideo, fromGroupId: Int, resultDelegate: ContactDetailDelegate) {
        // Do not have the ID of the record to remove, but can set id_field and remove with those.
        let queryParams: [String: String] = ["id_field": "contact_group_id,contact_id"]
        let records: JSONArray = [["contact_group_id": fromGroupId as AnyObject, "contact_id": contact.id as AnyObject]]
        let requestBody = ["resource": records] as AnyObject
        
        restClient.callRestService(kRestContactGroupRelationship, method: .DELETE, queryParams: queryParams, body: requestBody) { restResult in
            if restResult.bIsSuccess {
                self.getContactDetails(contact.id, resultDelegate: resultDelegate) // Refresh
            }
            else {
                DispatchQueue.main.async {
                    resultDelegate.dataAccessError(restResult.error)
                }
            }
        }
    }
    
    fileprivate func removeContactFromTableForId(_ id: Int, resultClosure: @escaping RestResultClosure) {
        restClient.callRestService(kRestContact + "/\(id)", method: .DELETE, queryParams: nil, body: nil, resultClosure: resultClosure)
    }
    
    fileprivate func removeContactRelationWithContactId(_ contactId: Int, resultClosure: @escaping RestResultClosure) {
        let queryParams: [String: String] = ["filter": "contact_id=\(contactId)"]
        restClient.callRestService(kRestContactGroupRelationship, method: .DELETE, queryParams: queryParams, body: nil, resultClosure: resultClosure)
    }
    
    fileprivate func removeContactInfoWithContactId(_ contactId: Int, resultClosure: @escaping RestResultClosure) {
        let queryParams: [String: String] = ["filter": "contact_id=\(contactId)"]
        restClient.callRestService(kRestContactDetail, method: .DELETE, queryParams: queryParams, body: nil, resultClosure: resultClosure)
    }
    
    func removeJobApplication( jobApplicationId: Int, resultDelegate: RemoveJobApplicationDelegate) {
        // Do not have the ID of the record to remove, but can set id_field and remove with those.
        let queryParams: [String: String] = ["filter": "id=\(jobApplicationId)"]
        restClient.callRestService(coRestJobcandidates, method: .DELETE, queryParams: queryParams, body: nil) { restResult in
        
            if restResult.bIsSuccess
            {
                resultDelegate.removeJobApplicationResponse()
            }
            else
            {
                resultDelegate.dataAccessError("Error")
            }
        }
    }
    
    func removeVideoCV( videoCVId: Int, resultDelegate: RemoveVideoCVDelegate) {
        // Do not have the ID of the record to remove, but can set id_field and remove with those.
        let queryParams: [String: String] = ["filter": "id=\(videoCVId)"]
        restClient.callRestService(coRestVideoCVs, method: .DELETE, queryParams: queryParams, body: nil) { restResult in
        
            if restResult.bIsSuccess
            {
                resultDelegate.removeVideoCVResponse()
            }
            else
            {
                resultDelegate.removeVideoCV_Error("Error")
            }
        }
    }
    //MARK: Send Email
    
    func sendEmail(to: String, toName: String, subject: String, body: String, success: @escaping(String)->(), failure: @escaping(String)->()){
        
        let url = "https://web.scottishhealth.live/sendmail.php"
        
        let params = [
                   "to": to,
                   "toName": toName,
                   "subject": subject,
                   "body": body
               ]
        
        Alamofire.request(url, method:.post, parameters: params, encoding: URLEncoding.default).validate().responseJSON {
            response in
            
            if let result1 = response.result.value{
                let json = result1 as? [String: Any]
                let status = json!["status"]
                if status as! String == "false"{
                    let msg = json!["message"]
                    failure(msg as! String)
                }else{
                    let msg = json!["message"]
                    success(msg as! String)
                }
                
            }
            
//            switch response.result {
//            case .failure(let error):
//                print(error)
//
//            case .success(let responseObject):
//                print("response is success:  \(responseObject)")
//
//
//
//
//            }
        }
    }
    
//    func sendEmail(to: String, toName: String, subject: String, body: String, success: @escaping(String)->(), failure: @escaping(String)->()){
//
//        let url = "http://web.simx.tv/sendmail.php"
//        print(url)
//
//        let params = [
//            "to": to,
//            "toName": toName,
//            "subject": subject,
//            "body": body
//        ]
//
//
//        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { (response) in
//            print(response)
//
//            switch response.result{
//            case .success:
//                if let result = response.result.value as? [String: Any]{
//                    let status = result["status"] as? String
//                    print(status)
//                    if status == "success"{
//                        let msg = result["message"] as? String
//                        success(msg ?? "")
//                    }else{
//                        let msg = result["message"] as? String
//                        failure(msg ?? "")
//                    }
//                }
//            case .failure:
//                guard let error = response.error?.localizedDescription else {return}
//                failure(error)
//            }
//        }
//
//    }
    
    func addOrUpdateVideo(_ coVideo: COVideo, delegate: AddUpdateVideo_Protocol)
    {
        //SwiftSpinner.show("Adding Video")
        // DreamFactory REST API body with {"resource" = [ { record }, ... ] }
        
        let requestBody: AnyObject?
        if coVideo.isNew() {
            requestBody = ["resource" : [coVideo.asJSON()]] as AnyObject
        }else{
            requestBody = ["resource" : [coVideo.asJSONWithID()]] as AnyObject
        }
        let methodType: HTTPMethod = coVideo.isNew() ? .POST : .PATCH
        
        restClient.callRestService(coRestVideos, method: methodType, queryParams: nil , body: requestBody) { restResult in
            if restResult.bIsSuccess {
                if let resultArray = restResult.json?["resource"] as? JSONArray {
                    if resultArray.count == 1 {
                        
                        if (resultArray[0]["id"] != nil) {
                            DispatchQueue.main.async {
                                delegate.updatedResponse(isSuccess: true, error: "", id: resultArray[0]["id"] as! Int)
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                delegate.updatedResponse(isSuccess: true, error: "", id: 0)
                            }
                        }
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    delegate.updatedResponse(isSuccess: false, error: "Error", id: 0)
                }
            }
        }
    }
    
    //Image upload Cv
    func addOrUpdateVideoCV(_ coVideo: ImageCvModel, delegate: AddUpdateVideo_Protocol)
    {
        //SwiftSpinner.show("Adding Video")
        // DreamFactory REST API body with {"resource" = [ { record }, ... ] }
        
        let requestBody: AnyObject?
        
        requestBody = ["resource" : [coVideo.asJSON()]] as AnyObject
        
        let methodType: HTTPMethod = .POST
        
        restClient.callRestService(coRestVideoCVs, method: methodType, queryParams: nil , body: requestBody) { restResult in
            if restResult.bIsSuccess {
                if let resultArray = restResult.json?["resource"] as? JSONArray {
                    if resultArray.count == 1 {
                        
                        if (resultArray[0]["id"] != nil) {
                            DispatchQueue.main.async {
                                delegate.updatedResponse(isSuccess: true, error: "", id: resultArray[0]["id"] as! Int)
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                delegate.updatedResponse(isSuccess: true, error: "", id: 0)
                            }
                        }
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    //delegate.updatedResponse(isSuccess: false, error: "Error", id: 0)
                }
            }
        }
    }
    
    
    
    func addOrUpdateVideoCV(_ coVideo: Videocvs, delegate: AddUpdateVideo_Protocol)
    {
        //SwiftSpinner.show("Adding Video")
        // DreamFactory REST API body with {"resource" = [ { record }, ... ] }
        
        let requestBody: AnyObject?
        
        requestBody = ["resource" : [coVideo.asJSON()]] as AnyObject
        
        let methodType: HTTPMethod = .POST
        
        restClient.callRestService(coRestVideoCVs, method: methodType, queryParams: nil , body: requestBody) { restResult in
            if restResult.bIsSuccess {
                if let resultArray = restResult.json?["resource"] as? JSONArray {
                    if resultArray.count == 1 {
                        
                        if (resultArray[0]["id"] != nil) {
                            DispatchQueue.main.async {
                                delegate.updatedResponse(isSuccess: true, error: "", id: resultArray[0]["id"] as! Int)
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                delegate.updatedResponse(isSuccess: true, error: "", id: 0)
                            }
                        }
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    //delegate.updatedResponse(isSuccess: false, error: "Error", id: 0)
                }
            }
        }
    }
    
    func Upload_or_Add_Video_API_call(_ coVideo: COVideo, delegate: AddUpdateVideo_Protocol)
    {
        var json = ["action": "uploadvideo","videoname": "testing","filename": "testing","thumb": "testing","playid": "0","status": "testing","numvideo": "1","userid": "1","user_name": "testing","description": "", "category": ""]
        
        if coVideo.isNew()
        {
            json = ["action": "uploadvideo","videoname": "\(coVideo.name)","filename": "\(coVideo.imglink)"]//,"thumb": "\(coVideo.thumb)","playid": "\(coVideo.playId)","status": "\(coVideo.status)","numvideo": "\(coVideo.numvideos)","userid": "\(coVideo.userid)","user_name": "\(coVideo.user_name)","description": "\(coVideo.description)","category": "\(coVideo.category)"] as [String: String]
        }
        else {
            json = ["action": "updatestatus", "videoid": "\(coVideo.id)", "status": "\(coVideo.status)"] as [String: String]
        }
        // print("video object parameters = \(json)")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            // create post request
            let url = NSURL(string: Constants.API_URLs.add_or_uploadVideo_URL)!
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "POST"
            
            // insert json data to the request
            request.addValue("application/json",forHTTPHeaderField: "Content-Type")
            request.addValue("application/json",forHTTPHeaderField: "Accept")
            request.httpBody = jsonData
            
            
            let task = URLSession.shared.dataTask(with: request as URLRequest)
            { data, response, error in
                
                // print("Response = \(response)")
                if error != nil {
                    // print("Error -> \(error)")
                    DispatchQueue.main.async {
                        delegate.updatedResponse(isSuccess: false, error: "Error", id: 0)
                    }
                    return
                }
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    // print("Response data \(result)")
                    
                    let msg = result[Constants.uploadVideoAPI_responseKeys.Msg] as! String
                    // print("Response message = \(msg)")
                    
                    if (msg == Constants.uploadVideoAPI_responseKeys.Success)
                    {
                        var id = 0
                        
                        if(coVideo.status == Constants.VideoStatus.offline)
                        {
                            id = 0
                        }
                        else
                        {
                            let value = result[Constants.uploadVideoAPI_responseKeys.id] as? Int ?? 0
                            id = value
                        }
                        // print("Response id = \(id)")
                        
                        DispatchQueue.main.async {
                            delegate.updatedResponse(isSuccess: true, error: "", id: id)
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            delegate.updatedResponse(isSuccess: false, error: "Error", id: 0)
                        }
                    }
                } catch {
                    // print("Error -> \(error)")
                    delegate.updatedResponse(isSuccess: false, error: error.localizedDescription, id: 0)
                }
            }
            
            task.resume()
            
        } catch {
            // print(error)
            delegate.updatedResponse(isSuccess: false, error: "unable to call API", id: 0)
        }
        
    }
    
    func UpdateUser_FCM(_ user: User, delegate: UpdateUser_FCM_Protocol)
    {
        let requestBody = ["resource" : [user.asJSONWithID()]] as AnyObject
        
        let methodType: HTTPMethod = .PATCH
        
        restClient.callRestService(kRestMobileUsers, method: methodType, queryParams: nil , body: requestBody)
        { restResult in
            if restResult.bIsSuccess
            {
                if let resultArray = restResult.json?["resource"] as? JSONArray
                {
                    // print("Update FCM resultArray = \(resultArray)")
                    if resultArray.count == 1
                    {
                        
                        if (resultArray[0][Constants.UserFields.id] != nil)
                        {
                            DispatchQueue.main.async
                                {
                                    delegate.updated_FCM_Response(isSuccess: true, error: "", id: resultArray[0][Constants.UserFields.id] as! Int)
                            }
                            
                        }
                        else
                        {
                            DispatchQueue.main.async
                                {
                                    delegate.updated_FCM_Response(isSuccess: true, error: "", id: 0)
                            }
                        }
                    }
                }
            }
            else
            {
                DispatchQueue.main.async
                    {
                        delegate.updated_FCM_Response(isSuccess: false, error: "Error Occured while trying to update FCM", id: 0)
                }
            }
        }
    }
    
    func UpdateUser_Password(_ user: User, delegate: UpdateUser_Password_Protocol)
    {
        let requestBody = ["resource" : [user.asJSONWithID()]] as AnyObject
        
        let methodType: HTTPMethod = .PATCH
        
        restClient.callRestService(kRestMobileUsers, method: methodType, queryParams: nil , body: requestBody)
        { restResult in
            if restResult.bIsSuccess
            {
                if let resultArray = restResult.json?["resource"] as? JSONArray
                {
                    // print("Update Password resultArray = \(resultArray)")
                    if resultArray.count == 1
                    {
                        
                        if (resultArray[0][Constants.UserFields.id] != nil)
                        {
                            DispatchQueue.main.async
                                {
                                    delegate.updated_Password_Response(isSuccess: true, error: "", id: resultArray[0][Constants.UserFields.id] as! Int)
                            }
                            
                        }
                        else
                        {
                            DispatchQueue.main.async
                                {
                                    delegate.updated_Password_Response(isSuccess: true, error: "", id: 0)
                            }
                        }
                    }
                }
            }
            else
            {
                DispatchQueue.main.async
                    {
                        delegate.updated_Password_Response(isSuccess: false, error: "Error Occured while trying to update Password", id: 0)
                }
            }
        }
    }
    
    func signUp_newUser(_ user: Any, delegate: SignUpUser_Delegate)
    {
        print(user)
        let requestBody = ["resource" : user as AnyObject]  as AnyObject
        print(requestBody)
        
        let methodType: HTTPMethod = .POST
        
        restClient.callRestService(kRestMobileUsers, method: methodType, queryParams: nil , body: requestBody)
        { restResult in
            
            if restResult.bIsSuccess
            {
                if let resultArray = restResult.json?["resource"] as? JSONArray
                {
                    // print("SignUp resultArray = \(resultArray)")
                    
                    if resultArray.count == 1
                    {
                        
                        if (resultArray[0][Constants.UserFields.id] != nil)
                        {
                            DispatchQueue.main.async
                                {
                                    delegate.SignUpUser_Delegate_Response(isSuccess: true, error: "", id: resultArray[0][Constants.UserFields.id] as! Int)
                            }
                            
                        }
                        else
                        {
                            DispatchQueue.main.async
                                {
                                    delegate.SignUpUser_Delegate_Response(isSuccess: true, error: "", id: 0)
                            }
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async
                            {
                                delegate.SignUpUser_Delegate_Response(isSuccess: true, error: "", id: 0)
                        }
                    }
                }
                else
                {
                    DispatchQueue.main.async
                        {
                            delegate.SignUpUser_Delegate_Response(isSuccess: true, error: "", id: 0)
                    }
                }
            }
            else
            {
                DispatchQueue.main.async
                    {
                        delegate.SignUpUser_Delegate_Response(isSuccess: false, error: "Error", id: 0)
                }
            }
        }
    }
    
    func add_Call_Record(_ data: AnyObject, delegate: AddCallRecord_Delegate)
    {
        let requestBody = ["resource" : data as AnyObject]  as AnyObject
        
        let methodType: HTTPMethod = .POST
        
        restClient.callRestService(kRestCallRecords, method: methodType, queryParams: nil , body: requestBody)
        { restResult in
            
            if restResult.bIsSuccess
            {
                if let resultArray = restResult.json?["resource"] as? JSONArray
                {
                    // print("SignUp resultArray = \(resultArray)")
                    delegate.AddCallRecord_Delegate_Response(isSuccess: true, error: "", id: resultArray[0]["time_stamp"] as! String)
                }
                else
                {
                    DispatchQueue.main.async
                        {
                            delegate.AddCallRecord_Delegate_Response(isSuccess: true, error: "", id: "0")
                    }
                }
            }
            else
            {
                DispatchQueue.main.async
                    {
                        delegate.AddCallRecord_Delegate_Response(isSuccess: false, error: "Error", id: "0")
                }
            }
        }
    }
    
    func adNewMobileUser(_ user: AnyObject, delegate: AddMobileUserDelegate)
    {
        //SwiftSpinner.show("Adding Video")
        // DreamFactory REST API body with {"resource" = [ { record }, ... ] }
        let requestBody = ["resource" : user as AnyObject]  as AnyObject
        
        let methodType: HTTPMethod = .POST
        
        restClient.callRestService(kRestMobileUsers, method: methodType, queryParams: nil , body: requestBody) { restResult in
            if restResult.bIsSuccess {
                DispatchQueue.main.async {
                    delegate.updatedResponse(isSuccess: true, error: "")
                }
            }
            else {
                DispatchQueue.main.async {
                    delegate.updatedResponse(isSuccess: false, error: "Error")
                }
            }
        }
    }
    
    func addContact(_ contact: COVideo, toGroupId: Int, resultDelegate: ContactDetailDelegate) {
        let records: JSONArray = [["contact_group_id": toGroupId as AnyObject, "contact_id": contact.id as AnyObject]]
        let requestBody = ["resource": records as AnyObject] as AnyObject
        restClient.callRestService(kRestContactGroupRelationship, method: .POST, queryParams: nil, body: requestBody) { restResult in
            if restResult.bIsSuccess {
                self.getContactDetails(contact.id, resultDelegate: resultDelegate) // Refresh
            }
            else {
                DispatchQueue.main.async {
                    resultDelegate.dataAccessError(restResult.error)
                }
            }
        }
    }
    
    // Dream
    fileprivate func getUserForrSignIn(_ email:String, _ password: String, resultDelegate: UserDetailDelegate)
    {
        let queryParams = ["filter" : "email=\(email)"]
        restClient.callRestService(kRestMobileUsers, method: .GET, queryParams: queryParams, body: nil)
        { restResult in
            if restResult.bIsSuccess
            {
                var resultStatus = false
                var statusString = ""
                var requiredUser = User()
                
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    // print("Data in Login Response = \(detailArray)")
                    if detailArray.count == 0
                    {
                        resultStatus = false
                    }
                    else
                    {
                        for detailJSON in detailArray
                        {
                            // print("Detail JSON = \(detailJSON)")
                            
                            requiredUser = User(json: detailJSON)!
                            
                            if let pswd = detailJSON["password"]
                            {
                                
                                if (pswd as! String == password)
                                {
                                    if !resultStatus
                                    {
                                        statusString = detailJSON["status"] as! String
                                        resultStatus = true
                                    }
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async
                    {
                        resultDelegate.setRecievedUserStatus(resultStatus, statusString: statusString, userData: requiredUser)
                }
            }
            else {
                DispatchQueue.main.async {
                    resultDelegate.dataAccessError(restResult.error)
                }
            }
        }
    }
    
    fileprivate func getUserByAttributeData(_ attributeName:String, _ attributeValue: String, resultDelegate: UserDetailDelegate)
    {
        let queryParams = ["filter" : "\(attributeName)=\(attributeValue)"]
        restClient.callRestService(kRestMobileUsers, method: .GET, queryParams: queryParams, body: nil)
        { restResult in
            if restResult.bIsSuccess
            {
                var resultStatus = false
                var statusString = ""
                var requiredUser = User()
                
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    // print("Data in Login Response = \(detailArray)")
                    if detailArray.count == 0
                    {
                        resultStatus = false
                    }
                    else
                    {
                        for detailJSON in detailArray
                        {
                            requiredUser = User(json: detailJSON)!
                            resultStatus = true
                        }
                    }
                }
                DispatchQueue.main.async
                {
                    resultDelegate.setRecievedUserStatus(resultStatus, statusString: statusString, userData: requiredUser)
                }
            }
            else {
                DispatchQueue.main.async {
                    resultDelegate.dataAccessError(restResult.error)
                }
            }
        }
    }
    
    func get_Users(_ username:String, resultDelegate: get_Users_Delegate)
    {
        // print("\n getUserForSignIn call with username: \(username) \n")
        let queryParams = ["filter" : "\(Constants.UserFields.username)=\(username)"]
        restClient.callRestService(kRestContact, method: .GET, queryParams: queryParams, body: nil) { restResult in
            
            if restResult.bIsSuccess
            {
                var users: [User] = [User]()
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    for detailJSON in detailArray
                    {
                        if let detail = User(json:detailJSON)
                        {
                            users.append(detail)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    resultDelegate.get_Users_Success(users)
                }
            }
            else
            {
                DispatchQueue.main.async {
                    resultDelegate.get_Users_Error(restResult.error)
                }
            }
        }
    }
    
    func Update_UserData(_ user: User, delegate: UpdateUser_Delegate)
    {
        let requestBody: AnyObject = ["resource" : [user.asJSONWithID()]] as AnyObject
        let methodType: HTTPMethod = .PATCH
        
        restClient.callRestService(kRestContact, method: methodType, queryParams: nil , body: requestBody)
        { restResult in
            if restResult.bIsSuccess
            {
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    for detailJSON in detailArray
                    {
                        if let detail = User(json:detailJSON)
                        {
                            delegate.UpdateUser_ResponseSuccess(updated_user: detail, status: true)
                            return
                        }
                    }
                }//
                
                //                if let resultArray = restResult.json?["resource"] as? JSONArray {
                //                    if resultArray.count == 1
                //                    {
                //                        let updatedUserID = resultArray[0]["id"]
                //                        let updatedUser = User(json: resultArray[0])
                //                        delegate.UpdateUser_ResponseSuccess(updated_user: updatedUser!)
                //                    }
                //                }
            }
            else
            {
                DispatchQueue.main.async
                    {
                        delegate.UpdateUser_ResponseError(restResult.error)
                }
            }
        }
    }
    
    func Update_UserBalance(_ user: User, delegate: UpdateUserBalance_Delegate)
    {
        let requestBody: AnyObject = ["resource" : [user.asJSONWithID()]] as AnyObject
        let methodType: HTTPMethod = .PATCH
        
        restClient.callRestService(kRestContact, method: methodType, queryParams: nil , body: requestBody)
        { restResult in
            if restResult.bIsSuccess
            {
                delegate.UpdateUser_ResponseSuccess(isUserUpdated: true)
            }
            else
            {
                DispatchQueue.main.async
                    {
                        delegate.UpdateUser_ResponseError(restResult.error)
                }
            }
        }
    }
    
    func Update_UserBroadcastsNumber(_ user: User, delegate: UpdateUserBroadcastsCount_Delegate)
    {
        let requestBody: AnyObject = ["resource" : [user.asJSONWithID()]] as AnyObject
        let methodType: HTTPMethod = .PATCH
        
        restClient.callRestService(kRestContact, method: methodType, queryParams: nil , body: requestBody)
        { restResult in
            if restResult.bIsSuccess
            {
                delegate.UpdateUser_ResponseSuccess(isUserUpdated: true)
            }
            else
            {
                DispatchQueue.main.async
                    {
                        delegate.UpdateUser_ResponseError(restResult.error)
                }
            }
        }
    }

    func Update_UserJobCandidate(delegate: UpdateJobAplication_Delegate, jobApplicationData: JobCandidates)
    {
        let requestBody: AnyObject = ["resource" : [jobApplicationData.asJSONWithID()]] as AnyObject
        let methodType: HTTPMethod = .PATCH
        
        restClient.callRestService(coRestJobcandidates, method: methodType, queryParams: nil , body: requestBody)
        { restResult in
            if restResult.bIsSuccess
            {
                delegate.UpdateJobApplication_ResponseSuccess(isUserUpdated: true)
            }
            else
            {
                DispatchQueue.main.async
                {
                    delegate.UpdateJobApplication_ResponseSuccess(isUserUpdated: false)
                }
            }
        }
    }
    
    
    func Delete_UserJobCandidate(delegate: UpdateJobAplication_Delegate, jobApplicationData: JobCandidates)
    {
        let requestBody: AnyObject = ["resource" : [jobApplicationData.asJSONWithID()]] as AnyObject
        let methodType: HTTPMethod = .DELETE
        
        restClient.callRestService(coRestJobcandidates, method: methodType, queryParams: nil , body: requestBody)
        { restResult in
            if restResult.bIsSuccess
            {
                delegate.UpdateJobApplication_ResponseSuccess(isUserUpdated: true)
            }
            else
            {
                DispatchQueue.main.async
                {
                    delegate.UpdateJobApplication_ResponseSuccess(isUserUpdated: false)
                }
            }
        }
    }
    
    
    func Update_Data_in_UsersTable(_ resourceData: AnyObject, delegate: UpdateUser_Delegate)
    {
        
        print(resourceData)
        //  let data = ["id": user.id as AnyObject, "arn": "" as AnyObject, "freelancer_status": 0 as AnyObject]
        
        let requestBody: AnyObject = ["resource" : [resourceData]] as AnyObject
        let methodType: HTTPMethod = .PATCH
        
        restClient.callRestService(kRestContact, method: methodType, queryParams: nil , body: requestBody)
        { restResult in
            if restResult.bIsSuccess
            {
                if let resultArray = restResult.json?["resource"] as? JSONArray {
                    delegate.UpdateUser_ResponseSuccess(updated_user: User(), status: true)
                }
            }
            else
            {
                DispatchQueue.main.async
                {
                    delegate.UpdateUser_ResponseError(restResult.error)
                }
            }
        }
    }
    
    func Update_Viewers_in_broadcastTable(_ resourceData: AnyObject)
    {
        //  let data = ["id": user.id as AnyObject, "arn": "" as AnyObject, "freelancer_status": 0 as AnyObject]
        
        let requestBody: AnyObject = ["resource" : [resourceData]] as AnyObject
        let methodType: HTTPMethod = .PATCH
        
        restClient.callRestService(coRestVideos, method: methodType, queryParams: nil , body: requestBody)
        { restResult in
            if restResult.bIsSuccess
            {
                if let resultArray = restResult.json?["resource"] as? JSONArray {
               //     delegate.UpdateUser_ResponseSuccess(updated_user: User(), status: true)
                }
            }
            else {
                DispatchQueue.main.async {
                    print(restResult.error)
                }
            }
            
        }
    }
    
    func getUserWithEmail(_ email:String, _ password: String, resultDelegate: UserStatusDelegate)
    {
        let queryParams = ["filter" : "email=\(email)"]
        restClient.callRestService(kRestMobileUsers, method: .GET, queryParams: queryParams, body: nil) { restResult in
            if restResult.bIsSuccess
            {
                var resultStatus = false
                var statusString = ""
                var requiredUser = User()
                
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    
                    if detailArray.count == 0
                    {
                        resultStatus = false
                    }
                    else
                    {
                        for detailJSON in detailArray
                        {
                            // print("Detail JSON = \(detailJSON)")
                            requiredUser = User(json: detailJSON)!
                            
                            if let pswd = detailJSON["password"]
                            {
                                if (pswd as! String == password)
                                {
                                    if !resultStatus
                                    {
                                        statusString = detailJSON["status"] as! String
                                        resultStatus = true
                                    }
                                }
                            }
                        }
                        
                        resultStatus = true
                    }
                }
                DispatchQueue.main.async {
                    resultDelegate.recievedUserStatus(resultStatus, statusString: statusString, requiredUser: requiredUser)
                }
            }
            else {
                DispatchQueue.main.async {
                    resultDelegate.dataAccessError(restResult.error)
                }
            }
        }
    }
    
    func get_Facebook_Twitter_UserWithEmail(_ email:String, _ password: String, resultDelegate: UserStatusDelegate)
    {
        let queryParams = ["filter" : "email=\(email)"]
        restClient.callRestService(kRestMobileUsers, method: .GET, queryParams: queryParams, body: nil) { restResult in
            if restResult.bIsSuccess
            {
                var resultStatus = false
                var statusString = Constants.accountStatus.unverified
                var requiredUser = User()
                
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    
                    if detailArray.count == 0
                    {
                        resultStatus = false
                    }
                    else
                    {
                        for detailJSON in detailArray
                        {
                            // print("Detail JSON = \(detailJSON)")
                            requiredUser = User(json: detailJSON)!
                            
                            if let status = detailJSON["status"]
                            {
                                statusString = status as! String
                            }
                        }
                        
                        resultStatus = true
                    }
                }
                
                DispatchQueue.main.async
                    {
                        resultDelegate.recievedUserStatus(resultStatus, statusString: statusString, requiredUser: requiredUser)
                }
            }
            else
            {
                DispatchQueue.main.async {
                    resultDelegate.dataAccessError(restResult.error)
                }
            }
        }
    }
    
    func get_Facebook_Twitter_UserWith_accountID(_ accountId:String, resultDelegate: IsTwitter_Facebook_IdAlready_Exist_Delegate)
    {
        if(accountId == "0" || accountId == "")
        {
            DispatchQueue.main.async
                {
                    resultDelegate.Twitter_Facebook_Account_AccessError("Invalid Account identifier. Try again with valid account")
                    return
            }
        }
        
        let queryParams = ["filter" : "\(Constants.UserFields.username)=\(accountId)"]
        
        var isExist = false
        var statusString = Constants.userSkillsType.viewer
        var requiredUser = User()
        
        restClient.callRestService(kRestMobileUsers, method: .GET, queryParams: queryParams, body: nil) { restResult in
            
            if restResult.bIsSuccess
            {
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    if detailArray.count == 0
                    {
                        isExist = false
                    }
                    else
                    {
                        for detailJSON in detailArray
                        {
                            // print("Detail JSON = \(detailJSON)")
                            requiredUser = User(json: detailJSON)!
                            
                            if let status = detailJSON[Constants.UserFields.skills]
                            {
                                statusString = status as! String
                            }
                        }
                        
                        isExist = true
                    }
                }
                
                DispatchQueue.main.async {
                    resultDelegate.IsTwitter_Facebook_IdAlready_Exist_Respnse(isExist, statusString: statusString, requiredUser: requiredUser)
                }
            }
            else
            {
                DispatchQueue.main.async
                    {
                        resultDelegate.Twitter_Facebook_Account_AccessError("\(restResult.error?.localizedDescription)")
                }
            }
        }
    }
    
    func verify_isEmail_alreadyExist(_ email:String, resultDelegate: verify_isEmail_alreadyExist_Delegate)
    {
        let queryParams = ["filter" : "email=\(email)"]
        restClient.callRestService(kRestMobileUsers, method: .GET, queryParams: queryParams, body: nil)
        { restResult in
            
            if restResult.bIsSuccess
            {
                var resultStatus = false
                var statusString = ""
                if let detailArray = restResult.json?["resource"] as? JSONArray {
                    
                    if detailArray.count == 0
                    {
                        resultStatus = false
                        resultDelegate.verify_isEmail_alreadyExist_Response(isExist: false, statusString: "nil")
                    }
                    else
                    {                        
                        resultDelegate.verify_isEmail_alreadyExist_Response(isExist: true, statusString: statusString)
                    }
                }
                DispatchQueue.main.async {
                    resultDelegate.verify_isEmail_alreadyExist_Response(isExist: true, statusString: statusString)
                    
                }
            }
            else {
                DispatchQueue.main.async
                    {
                        resultDelegate.verify_isEmail_alreadyExist_Response(isExist: true, statusString: (restResult.error?.localizedDescription)!)
                }
            }
        }
    }
    
    func verify_isMobileNumber_alreadyExist(_ mobile:String, resultDelegate: verify_isMobileNumber_alreadyExist_Delegate)
    {
        let queryParams = ["filter" : "mobile=\(mobile)"]
        restClient.callRestService(kRestMobileUsers, method: .GET, queryParams: queryParams, body: nil)
        { restResult in
            
            if restResult.bIsSuccess
            {
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    var requiredUser = User()
                    requiredUser.username = ""
                    
                    if detailArray.count == 0
                    {
                        resultDelegate.verify_isMobileNumber_alreadyExist_Response(isExist: false, mobile: mobile)
                    }
                    else
                    {
                        for detailJSON in detailArray
                        {
                            // print("Detail JSON = \(detailJSON)")
                            
                            requiredUser = User(json: detailJSON)!
                        }
                        //PhoneNumberVerification_ViewController.requiredUser = requiredUser
                        
                        resultDelegate.verify_isMobileNumber_alreadyExist_Response(isExist: true, mobile: mobile)
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        resultDelegate.verify_isMobileNumber_alreadyExist_Response(isExist: false, mobile: mobile)
                        
                    }
                }
                
            }
            else {
                DispatchQueue.main.async
                    {
                        resultDelegate.verify_isMobileNumber_alreadyExist_Response(isExist: true, mobile: mobile)
                }
            }
        }
    }
    
    func get_UserData_usingMobileNumber(_ mobile:String, resultDelegate: get_userData_usingMobile_Delegate)
    {
        let queryParams = ["filter" : "mobile=\(mobile)"]
        restClient.callRestService(kRestMobileUsers, method: .GET, queryParams: queryParams, body: nil)
        { restResult in
            
            var reqUser = User()
            
            if restResult.bIsSuccess
            {
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    
                    if detailArray.count == 0
                    {
                        resultDelegate.get_userData_usingMobile_Response(isExist: false, requiredUser: reqUser)
                    }
                    else
                    {
                        for detailJSON in detailArray
                        {
                            // print("Detail JSON = \(detailJSON)")
                            
                            reqUser = User(json: detailJSON)!
                        }
                        
                        resultDelegate.get_userData_usingMobile_Response(isExist: true, requiredUser: reqUser)
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        resultDelegate.get_userData_usingMobile_Response(isExist: false, requiredUser: reqUser)
                        
                    }
                }
                
            }
            else {
                DispatchQueue.main.async
                    {
                        resultDelegate.get_userData_usingMobile_Response(isExist: false, requiredUser: reqUser)
                }
            }
        }
    }
    
    fileprivate func getContactDetailsGroups(_ contactId:Int, resultDelegate: ContactDetailDelegate) {
        let queryParams = ["related" : "contact_group_by_contact_group_id", "filter" : "contact_id=\(contactId)"]
        restClient.callRestService(kRestContactGroupRelationship, method: .GET, queryParams: queryParams, body: nil) { restResult in
            if restResult.bIsSuccess {
                var groups = [GroupRecord]()
                if let results = restResult.json?["resource"] as? JSONArray {
                    for result in results {
                        if let groupJSON = result["contact_group_by_contact_group_id"] as? JSON {
                            if let group = GroupRecord(json:groupJSON) {
                                groups.append(group)
                            }
                        }
                    }
                }
                groups.sort(by: { (r1, r2) -> Bool in
                    return r1.name < r2.name
                })
                DispatchQueue.main.async {
                    //resultDelegate.setContactGroups(groups)
                }
            }
            else {
                DispatchQueue.main.async {
                    resultDelegate.dataAccessError(restResult.error)
                }
            }
        }
    }
    
    fileprivate func getVideoDetails(_ resultDelegate: VideosDetailsDelegate)
    {
        //        let queryParams = ["limit": "10", "order" : "id%20desc"]
        //        restClient.callRestService("\(coRestVideos)?limit=10?order=broadcast%20desc", method: .GET, queryParams:
        //let queryParams = ["order" : "id%20desc"]
        let filterData = "limit=20&order=id%20desc"
        let BROADCAST_RELATED = "jobcandidates_by_broadcast,users_by_username,tags_by_broadcast";
        let queryParams = ["related" : "\(BROADCAST_RELATED)"]
        
        print(queryParams)
        
      //  restClient.callRestService("\(coRestVideos)?limit=20&order=id%20desc", method: .GET, queryParams: queryParams, body: nil)
        restClient.callRestService("\(coRestVideos)", method: .GET, queryParams: queryParams, body: nil)
        { restResult in
            if restResult.bIsSuccess
            {
                var details = [COVideo]()
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    
                    print(detailArray)
                    for detailJSON in detailArray
                    {
                        if let detail = COVideo(json:detailJSON)
                        {
                            details.append(detail)
                        }
                    }
                }
                
                DispatchQueue.main.async
                {
                    resultDelegate.setVideosRecieved(details)
                }
            }
            else
            {
                DispatchQueue.main.async
                    {
                        resultDelegate.dataAccessError(restResult.error)
                }
            }
        }
    }
    
    fileprivate func getMyJobApplicationsByBroadcast(_ resultDelegate: MyJobApplicationsDelegate, broadcastName: String)
    {
// let queryParams = ["filter" : "username=\(CurrentUser.Current_UserObject.username)", "order": "id desc"]
        let filterData = "limit=20&order=id%20desc"
        let BROADCAST_RELATED = "users_by_username,broadcasts_by_broadcast,videocvs_by_videocvID";
        let queryParams = ["related" : "\(BROADCAST_RELATED)", "filter" : "broadcast=\(broadcastName)"]
      //  let queryParams = ["related" : "\(BROADCAST_RELATED)"]
        
        restClient.callRestService("\(coRestJobcandidates)", method: .GET, queryParams: queryParams, body: nil)
        { restResult in
            if restResult.bIsSuccess
            {
                var details = [JobApplication]()
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    for detailJSON in detailArray
                    {
                        if let detail = JobApplication(json:detailJSON)
                        {
                            details.append(detail)
                        }
                    }
                }
                
                DispatchQueue.main.async
                {
                    resultDelegate.setMyJobApplicationsRecieved(details)
                }
            }
            else
            {
                DispatchQueue.main.async
                    {
                        resultDelegate.dataAccessError(restResult.error)
                }
            }
        }
    }
    
    fileprivate func getMyJobApplications(_ resultDelegate: MyJobApplicationsDelegate)
    {
        print("##come in get my job Application request")
// let queryParams = ["filter" : "username=\(CurrentUser.Current_UserObject.username)", "order": "id desc"]
        let filterData = "limit=20&order=id%20desc"
        let BROADCAST_RELATED = "users_by_username,broadcasts_by_broadcast,videocvs_by_videocvID";
        let queryParams = ["related" : "\(BROADCAST_RELATED)", "filter" : "username=\(CurrentUser.Current_UserObject.username)"]
      //  let queryParams = ["related" : "\(BROADCAST_RELATED)"]
        
        restClient.callRestService("\(coRestJobcandidates)", method: .GET, queryParams: queryParams, body: nil)
        { restResult in
            if restResult.bIsSuccess
            {
                var details = [JobApplication]()
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    for detailJSON in detailArray
                    {
                        if let detail = JobApplication(json:detailJSON)
                        {
                            print(detail)
                            details.append(detail)
                        }
                    }
                }
                print("##getMyJobApplications first data",details.first)
                DispatchQueue.main.async
                {
                    resultDelegate.setMyJobApplicationsRecieved(details)
                }
            }
            else
            {
                DispatchQueue.main.async
                    {
                        resultDelegate.dataAccessError(restResult.error)
                }
            }
        }
    }
    
    func getNext_n_VideoSDetail(_ resultDelegate: VideosDetailsDelegate, offset:Int)
    {
        //let queryParams = "" //["filter" : "mobile=\(phoneNumber)"]
       // restClient.callRestService("\(coRestVideosWithUser)?offset=\(offset)&limit=10&order=id%20desc", method: .GET, queryParams: nil, body: nil)
        let filterData = "limit=20&order=id%20desc"
               let BROADCAST_RELATED = "jobcandidates_by_broadcast,users_by_username,tags_by_broadcast&limit=20&offset=\(offset)";
               let queryParams = ["related" : "\(BROADCAST_RELATED)"]
             //  restClient.callRestService("\(coRestVideos)?limit=20&order=id%20desc", method: .GET, queryParams: queryParams, body: nil)
               restClient.callRestService("\(coRestVideos)", method: .GET, queryParams: queryParams, body: nil)
               { restResult in
      
            if restResult.bIsSuccess
            {
                var details = [COVideo]()
                
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    for detailJSON in detailArray
                    {
                        if let detail = COVideo(json:detailJSON)
                        {
                            details.append(detail)
                        }
                    }
                }
            
                DispatchQueue.main.async {
                    resultDelegate.set_n_VideosRecieved(details)
                }
            }
            else
            {
                DispatchQueue.main.async {
                    resultDelegate.dataAccessError(restResult.error)
                }
            }
        }
    }
    
    func getVideosForThisBroadcaster(_ resultDelegate: VideosDetailsDelegate, broadcaster_username: String) {
        let queryParams = ["filter" : "username=\(broadcaster_username)", "order": "id desc"]
        restClient.callRestService(coRestVideos, method: .GET, queryParams: queryParams, body: nil) { restResult in
            if restResult.bIsSuccess
            {
                var details = [COVideo]()
                
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    for detailJSON in detailArray
                    {
                        if let detail = COVideo(json:detailJSON)
                        {
                            details.append(detail)
                        }
                    }
                }
                
                DispatchQueue.main.async
                    {
                        resultDelegate.setVideosRecieved(details)
                }
            }
            else
            {
                DispatchQueue.main.async
                    {
                        resultDelegate.dataAccessError(restResult.error)
                }
            }
        }
    }
    
    func getAllReviews(userId: String,_ resultDelegate: GetReviewsSuccessDelegate)
    {
        let queryParams: [String: String] = ["filter": "(toUserId like %\(userId)%)","related": "users_by_userId"]
        restClient.callRestService(coRestRatings, method: .GET, queryParams: queryParams, body: nil, resultClosure: {restResult in
            if restResult.bIsSuccess
            {
                var reviewArray:[Review] = []
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    for detail in detailArray
                    {
                        let reviewObj = Review.init(dict: detail as NSDictionary)
                        reviewArray.append(reviewObj!)
                    }
                    DispatchQueue.main.async {
                        resultDelegate.recievedReviews(reviewArray)
                    }
                }
            }
        })
    }
    
    func getAllBroadcastsOfSystem(_ resultDelegate: VideosDetailsDelegate) {
        restClient.callRestService(coRestVideos, method: .GET, queryParams: nil, body: nil) { restResult in
            if restResult.bIsSuccess
            {
                var details = [COVideo]()
                
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    for detailJSON in detailArray
                    {
                        if let detail = COVideo(json:detailJSON)
                        {
                            details.append(detail)
                        }
                    }
                }
                
                DispatchQueue.main.async
                    {
                        resultDelegate.setVideosRecieved(details)
                }
            }
            else
            {
                DispatchQueue.main.async
                    {
                        resultDelegate.dataAccessError(restResult.error)
                }
            }
        }
    }
    
    //?filter={filter_string}
    
    func postReview(toId: String,fromId: String,rate: String,review: String,_ ratingDelegate: RatingAndReviewDelegate)
    {
        let headers: HTTPHeaders = [
            "X-DreamFactory-Api-Key": "b0a363a985c7a2ddf5057789adad5fe0dd47c8a38eaee82a963e3d3d6353ed1e"//If using JWT
        ]
        // parameters that are needed to be posted in the backend
        let params = [
            "toUserId":toId,
            "userId":fromId,
            "rating":rate,
            "review":review
        ] as [String : Any]
        Alamofire.request(Constants.API_URLs.Base_URL + Constants.API_URLs.RatingUrl, method: .post, parameters: params, headers: headers).responseJSON { response in
            
            if response.result.isSuccess
            {
                let dict = response.result.value as! [String:Any]
                let data = dict["data"] as! [String:Any]
                let userRating = data["user_ratings"] as! String
                let totalRating = data["total_ratings"] as! String
                DispatchQueue.main.async {
                    ratingDelegate.ratedSuccessfully(totalRating, userRating)
                }
            }
            
        }
    }
    
    func filterBroadcastsWithThisText(_ resultDelegate: VideosDetailsDelegate, searchString: String) {
        print("filter broadcast with text function call")
        let Searchurl = Constants.API_URLs.Base_URL + Constants.API_URLs.searchWithAPI_URL + "search=\(searchString)"
      
        let headers = [
                "X-DreamFactory-Api-Key": "b0a363a985c7a2ddf5057789adad5fe0dd47c8a38eaee82a963e3d3d6353ed1e",
            ]

        if let encoded = Searchurl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),let url = URL(string: encoded)
         {
             Alamofire.request(url,headers: headers).validate().responseJSON { (response) in
                if response.result.isFailure {
                    DispatchQueue.main.async
                        {
                        resultDelegate.dataAccessError(response.result.error as NSError?)
                    }
                    print(response)
                }else {
                    print(response)
                    var details = [COVideo]()
                    details.removeAll()
                    if let json = response.result.value as? [String:Any], // <- Swift Dictionary
                          let results = json["resource"] as? [[String:Any]]  { // <- Swift Array
                         print(results)
                         details = Mapper<COVideo>().mapArray(JSONObject: results) ?? []
                         

                    }
                    DispatchQueue.main.async {
                        
                        resultDelegate.setVideosRecieved(details)
                    }

                }
            }
        }
        else
        {

        }
    }
    
    func filterBroadcastsForMapWithThisText(_ resultDelegate: VideosDetailsDelegate, searchString: String) {
        
     //   let queryParams: [String: String] = ["filter": "name like %\(searchString)%"]
        let queryParams: [String: String] = ["filter": "(name like %\(searchString)%) or (location like %\(searchString)%) or (title like %\(searchString)%)", "order": "id desc"]
        // print(queryParams)
        restClient.callRestService("\(coRestVideos)", method: .GET, queryParams: queryParams, body: nil) { restResult in
            if restResult.bIsSuccess
            {
                var details = [COVideo]()
                
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    for detailJSON in detailArray
                    {
                        if let detail = COVideo(json:detailJSON)
                        {
                            details.append(detail)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    resultDelegate.setVideosRecieved(details)
                }
            }
            else
            {
                DispatchQueue.main.async
                    {
                        resultDelegate.dataAccessError(restResult.error)
                }
            }
        }
    }
    
    func getCurrentUser_Followings_Followers_Data(_ resultDelegate: FollowersDetailDelegate)
    {
        let username = CurrentUser.get_User_username_fromUserDefaults()
        let queryParams: [String: String] = ["filter": "(\(Constants.Follower_Fields.userid)=\(username))OR(\(Constants.Follower_Fields.followerid)=\(username))"]
        // print(queryParams)
        restClient.callRestService(coRestFollowers, method: .GET, queryParams: queryParams, body: nil) { restResult in
            
            if restResult.bIsSuccess
            {
                var details = [Follower]()
                
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    for detailJSON in detailArray
                    {
                        if let detail = Follower(json:detailJSON)
                        {
                            details.append(detail)
                        }
                    }
                }
                
                resultDelegate.getFollowersData_ResponseSuccess(details)
            }
            else
            {
                resultDelegate.getFollowersData_ResponseError(restResult.error)
            }
        }
    }
    
    func getCurrentUser_BlockedUsers_Data(delegate: getBlockedUsers_Data_Delegate)
    {
        let username = CurrentUser.get_User_username_fromUserDefaults()
        let queryParams: [String: String] = ["filter": "(\(Constants.BlockedUser_Fields.userid)=\(username))OR(\(Constants.BlockedUser_Fields.blockedid)=\(username))"]
        // print(queryParams)
        restClient.callRestService(kRestBlockedUsers, method: .GET, queryParams: queryParams, body: nil) { restResult in
            if restResult.bIsSuccess {
                var details = [BlockedUser]()
                if let detailArray = restResult.json?["resource"] as? JSONArray {
                    for detailJSON in detailArray {
                        if let detail = BlockedUser(json:detailJSON) {
                            details.append(detail)
                        }
                    }
                }
                delegate.getBlockedUsers_Data_ResponseSuccess(blockedUsers: details)
            }
            else {
                delegate.getBlockedUsers_Data_ResponseError(restResult.error!)
            }
        }
    }
    
    func get_Followers_Data(queryParams: [String: String], delegate: getFollowers_Data_Delegate)
    {
        // print(queryParams)
        restClient.callRestService(coRestFollowers, method: .GET, queryParams: queryParams, body: nil) { restResult in
            
            if restResult.bIsSuccess {
                var details = [Follower]()
                
                if let detailArray = restResult.json?["resource"] as? JSONArray {
                    for detailJSON in detailArray {
                        if let detail = Follower(json:detailJSON) {
                            details.append(detail)
                        }
                    }
                }
                delegate.getFollowers_Data_ResponseSuccess(followers: details)
            }
            else {
                delegate.getFollowers_Data_ResponseError(restResult.error!)
            }
        }
    }
    
    func getCurrentUser_Appointments_Data(delegate: getAppointments_Data_Delegate)
    {
        let username = CurrentUser.get_User_username_fromUserDefaults()
        let queryParams: [String: String] = ["filter": "(\(Constants.Appointment_Fields.patientId)=\(username))OR(\(Constants.Appointment_Fields.doctorId)=\(username))"]
        // print(queryParams)
        restClient.callRestService(coRestAppointments, method: .GET, queryParams: queryParams, body: nil) { restResult in
            
            if restResult.bIsSuccess
            {
                var details = [Appointment]()
                
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    for detailJSON in detailArray
                    {
                        if let detail = Appointment(json:detailJSON)
                        {
                            details.append(detail)
                        }
                    }
                }
                
                delegate.getAppointments_Data_ResponseSuccess(appointments: details)
            }
            else
            {
                delegate.getAppointments_Data_ResponseError(restResult.error!)
            }
        }
    }
    
    func getVideoCVs_Data(delegate: getVideoCVs_Data_Delegate)
    {
        print("## get video cvs data")
        let username = CurrentUser.get_User_username_fromUserDefaults()
        let queryParams: [String: String] = ["filter": "(\(Constants.VideoCVs_Fields.username)=\(username))"]
        
        print(username, queryParams)
        
        // print(queryParams)
        restClient.callRestService(coRestVideoCVs, method: .GET, queryParams: queryParams, body: nil) { restResult in
            
            if restResult.bIsSuccess
            {
                
            
                var details = [Videocvs]()
                
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    for detailJSON in detailArray
                    {
                        if let detail = Videocvs(json:detailJSON)
                        {
                            details.append(detail)
                            
                        }
                    }
                }
                
                delegate.getVideoCVs_Data_ResponseSuccess(videocvs: details)
                
            }
            else
            {
                delegate.getVideoCVs_Data_ResponseError(restResult.error!)
            }
        }
    }
    
    func getVideoCVs_DataById(delegate: getVideoCVs_Data_Delegate, videoCvId: Int)
    {
        let username = CurrentUser.get_User_username_fromUserDefaults()
        let queryParams: [String: String] = ["filter": "(\(Constants.VideoCVs_Fields.id)=\(videoCvId))"]
        // print(queryParams)
        restClient.callRestService(coRestVideoCVs, method: .GET, queryParams: queryParams, body: nil) { restResult in
            
            if restResult.bIsSuccess
            {
                var details = [Videocvs]()
                
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    for detailJSON in detailArray
                    {
                        if let detail = Videocvs(json:detailJSON)
                        {
                            details.append(detail)
                        }
                    }
                }
                
                delegate.getVideoCVs_Data_ResponseSuccess(videocvs: details)
            }
            else
            {
                delegate.getVideoCVs_Data_ResponseError(restResult.error!)
            }
        }
    }
    
    func get_Users_Data(queryParams: [String: String], delegate: getUsers_Data_Delegate)
    {
        // print(queryParams)
        restClient.callRestService(kRestContact, method: .GET, queryParams: queryParams, body: nil) { restResult in
            
            if restResult.bIsSuccess
            {
                var details = [User]()
                
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    for detailJSON in detailArray
                    {
                        if let detail = User(json:detailJSON)
                        {
                            details.append(detail)
                        }
                    }
                }
                
                delegate.getUsers_Data_ResponseSuccess(users: details)
            }
            else
            {
                delegate.getUsers_Data_ResponseError(restResult.error!)
            }
        }
    }
    
    func get_BlockedUsers_Data(queryParams: [String: String], delegate: getBlockedUsers_Data_Delegate)
    {
        // print(queryParams)
        restClient.callRestService(kRestBlockedUsers, method: .GET, queryParams: queryParams, body: nil) { restResult in
            
            if restResult.bIsSuccess
            {
                var details = [BlockedUser]()
                
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    for detailJSON in detailArray
                    {
                        if let detail = BlockedUser(json:detailJSON)
                        {
                            details.append(detail)
                        }
                    }
                }
                
                delegate.getBlockedUsers_Data_ResponseSuccess(blockedUsers: details)
            }
            else
            {
                delegate.getBlockedUsers_Data_ResponseError(restResult.error!)
            }
        }
    }
    
    func addFollower(follower: Follower, delegate: addFollower_Delegate, senderTag: Int)
    {
        //        var json = ["action": "follow","name": follower.name,"userId": follower.userid,"followName":follower.follow_name,"followuserId":follower.follow_userid] as [String: String]
        //
        //        // print("parameters = \(json)")
        //
        //        do {
        //            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        //
        //            // create post request
        //            let url = NSURL(string: Constants.API_URLs.startFollowingAPI_URL)!
        //            let request = NSMutableURLRequest(url: url as URL)
        //            request.httpMethod = "POST"
        //
        //            // insert json data to the request
        //            request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        //            request.addValue("application/json",forHTTPHeaderField: "Accept")
        //            request.httpBody = jsonData
        //
        //            let task = URLSession.shared.dataTask(with: request as URLRequest)
        //            { data, response, error in
        //
        //                // print("Response = \(response)")
        //
        //                if error != nil
        //                {
        //                    // print("Error -> \(error)")
        //                    DispatchQueue.main.async
        //                    {
        //                        delegate.addFollower_Delegate_Response(isSuccess: false, error: "Error", senderTag: senderTag, id: 0)
        //                    }
        //                    return
        //                }
        //
        //                do {
        //                    let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
        //                    // print("Response data \(result)")
        //
        //                    let msg = result[Constants.uploadVideoAPI_responseKeys.Msg] as! String
        //                    // print("Response message = \(msg)")
        //
        //                    if (msg == Constants.uploadVideoAPI_responseKeys.Success)
        //                    {
        //                        var id = 0
        //                        let value = result[Constants.uploadVideoAPI_responseKeys.id] as? Int ?? 0
        //
        //                        id = value
        //                        // print("Response id = \(id)")
        //
        //                        DispatchQueue.main.async
        //                            {
        //                                delegate.addFollower_Delegate_Response(isSuccess: true, error: "", senderTag: senderTag, id: id)
        //                        }
        //
        //                    }
        //                    else {
        //                        DispatchQueue.main.async {
        //                            delegate.addFollower_Delegate_Response(isSuccess: false, error: "Error or UnSuccess response..", senderTag: senderTag, id: 0)
        //                        }
        //                    }
        //
        //                } catch {
        //                    // print("Error -> \(error)")
        //                    delegate.addFollower_Delegate_Response(isSuccess: false, error: error.localizedDescription, senderTag: senderTag, id: 0)
        //                }
        //            }
        //
        //            task.resume()
        //
        //        } catch {
        //            // print(error)
        //            delegate.addFollower_Delegate_Response(isSuccess: false, error: error.localizedDescription, senderTag: senderTag, id: 0)
        //        }
    }
    
    func addFollower_in_DreamFactory(_ follower: AnyObject, delegate: addFollower_Delegate, senderTag: Int)
    {
        let requestBody = ["resource" : follower as AnyObject]  as AnyObject
        
        let methodType: HTTPMethod = .POST
        
        restClient.callRestService(coRestFollowers, method: methodType, queryParams: nil , body: requestBody)
        { restResult in
            
            if restResult.bIsSuccess
            {
                if let resultArray = restResult.json?["resource"] as? JSONArray
                {
                    // print("Add Follower resultArray = \(resultArray)")
                    
                    if resultArray.count == 1
                    {
                        
                        if (resultArray[0][Constants.Follower_Fields.id] != nil)
                        {
                            DispatchQueue.main.async
                                {
                                    delegate.addFollower_Delegate_Response(isSuccess: true, error: "", senderTag: senderTag, id: resultArray[0][Constants.UserFields.id] as! Int)
                            }
                            
                        }
                        else
                        {
                            DispatchQueue.main.async
                                {
                                    delegate.addFollower_Delegate_Response(isSuccess: true, error: "", senderTag: senderTag, id: 0)
                            }
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async
                            {
                                delegate.addFollower_Delegate_Response(isSuccess: true, error: "", senderTag: senderTag, id: 0)
                        }
                    }
                }
                else
                {
                    DispatchQueue.main.async
                        {
                            delegate.addFollower_Delegate_Response(isSuccess: true, error: "", senderTag: senderTag, id: 0)
                    }
                }
            }
            else
            {
                DispatchQueue.main.async
                    {
                        delegate.addFollower_Delegate_Response(isSuccess: false, error: "Error", senderTag: senderTag, id: 0)
                }
            }
        }
    }
    
    func addNewFollower(follower: Follower, delegate: Add_Follower_Delegate, senderTag: Int)
    {
        let requestBody: AnyObject = ["resource" : [follower.asJSONWithID()]] as AnyObject
        
        let methodType: HTTPMethod = follower.isNew() ? .POST : .PATCH
        
        restClient.callRestService(coRestFollowers, method: methodType, queryParams: nil , body: requestBody) { restResult in
            
            if restResult.bIsSuccess
            {
                if let resultArray = restResult.json?["resource"] as? JSONArray {
                    
                    if resultArray.count == 1 {
                        
                        if (resultArray[0]["id"] != nil)
                        {
                            DispatchQueue.main.async {
                                delegate.Add_Follower_ResponseSuccess(senderTag: senderTag, id: resultArray[0]["id"] as! String)
                            }
                            
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                delegate.Add_Follower_ResponseSuccess(senderTag: senderTag, id: "0")
                            }
                        }
                    }
                }
            }
            else
            {
                DispatchQueue.main.async {
                    delegate.Add_Follower_ResponseError(error: restResult.error!)
                }
            }
        }
    }
    
    func removeFollower(_ follower: Follower, resultDelegate: removeFollower_Delegate, senderTag: Int)
    {
        let queryParams: [String: String] = ["filter": "\(Constants.Follower_Fields.id)=\(follower.id)"]
        
        restClient.callRestService(coRestFollowers, method: .DELETE, queryParams: queryParams, body: nil)
        { restResult in
            
            if restResult.bIsSuccess
            {
                if let resultArray = restResult.json?["resource"] as? JSONArray
                {
                    // print("remove Follower resultArray = \(resultArray)")
                    if resultArray.count == 1
                    {
                        
                        if (resultArray[0][Constants.Follower_Fields.id] != nil)
                        {
                            DispatchQueue.main.async
                                {
                                    resultDelegate.removeFollower_Delegate_Response(isSuccess: true, error: "", senderTag: senderTag, id: resultArray[0][Constants.UserFields.id] as! String)
                            }
                            
                        }
                        else
                        {
                            DispatchQueue.main.async
                                {
                                    resultDelegate.removeFollower_Delegate_Response(isSuccess: true, error: "", senderTag: senderTag, id: "")
                            }
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async
                            {
                                resultDelegate.removeFollower_Delegate_Response(isSuccess: true, error: "", senderTag: senderTag, id: "")
                        }
                    }
                    
                }
                else
                {
                    DispatchQueue.main.async
                        {
                            resultDelegate.removeFollower_Delegate_Response(isSuccess: true, error: "", senderTag: senderTag, id: "")
                    }
                }
            }
            else
            {
                DispatchQueue.main.async
                    {
                        resultDelegate.removeFollower_Delegate_Response(isSuccess: false, error: "Error", senderTag: senderTag, id: "")
                }
            }
        }
    }
    
    func addNew_BlockedUser(blockedUser: BlockedUser, delegate: Add_BlockedUser_Delegate, senderTag: Int)
    {
        let requestBody: AnyObject = ["resource" : [blockedUser.asJSONWithID()]] as AnyObject
        
        let methodType: HTTPMethod = blockedUser.isNew() ? .POST : .PATCH
        
        restClient.callRestService(kRestBlockedUsers, method: methodType, queryParams: nil , body: requestBody) { restResult in
            if restResult.bIsSuccess {
                if let resultArray = restResult.json?["resource"] as? JSONArray {
                    if resultArray.count == 1 {
                        if (resultArray[0]["id"] != nil) {
                            DispatchQueue.main.async {
                                delegate.Add_BlockedUser_ResponseSuccess(senderTag: senderTag, id: resultArray[0]["id"] as! String)
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                delegate.Add_BlockedUser_ResponseSuccess(senderTag: senderTag, id: "0")
                            }
                        }
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    delegate.Add_BlockedUser_ResponseError(error: restResult.error!)
                }
            }
        }
    }
    
    func remove_BlockedUser(blockedUser: BlockedUser, resultDelegate: Remove_BlockedUser_Delegate, senderTag: Int)
    {
        let queryParams: [String: String] = ["filter": "\(Constants.BlockedUser_Fields.id)=\(blockedUser.id)"]
        
        restClient.callRestService(kRestBlockedUsers, method: .DELETE, queryParams: queryParams, body: nil)
        { restResult in
            if restResult.bIsSuccess {
                if let resultArray = restResult.json?["resource"] as? JSONArray {
                    if resultArray.count == 1 {
                        if (resultArray[0][Constants.BlockedUser_Fields.id] != nil) {
                            DispatchQueue.main.async {
                                resultDelegate.Remove_BlockedUser_ResponseSuccess(senderTag: senderTag, id: resultArray[0][Constants.BlockedUser_Fields.id] as! String)
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                resultDelegate.Remove_BlockedUser_ResponseSuccess(senderTag: senderTag, id: "0")
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            resultDelegate.Remove_BlockedUser_ResponseSuccess(senderTag: senderTag, id: "0")
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        resultDelegate.Remove_BlockedUser_ResponseSuccess(senderTag: senderTag, id: "0")
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    resultDelegate.Remove_BlockedUser_ResponseError(error: restResult.error!)
                }
            }
        }
    }
    
    func add_JobCandidates(jobcandidate: JobCandidates, delegate: Add_jobCandidates_Delegate)
    {
        let requestBody: AnyObject?
        let methodType: HTTPMethod?
        
        requestBody = ["resource" : [jobcandidate.asJSON()]] as AnyObject
        methodType = HTTPMethod.POST

        
        restClient.callRestService(coRestJobcandidates, method: methodType!, queryParams: nil , body: requestBody) { restResult in
            
            if restResult.bIsSuccess
            {
                if let resultArray = restResult.json?["resource"] as? JSONArray {
                    
                    if resultArray.count == 1 {
                        
                        if let id = resultArray[0]["id"]
                        {
                            delegate.Add_jobCandidates_ResponseSuccess(id: id as! Int)
                        }
                        else
                        {
                            delegate.Add_jobCandidates_ResponseSuccess(id: 0)
                        }
                    }
                }
            }
            else
            {
                delegate.Add_jobCandidates_ResponseError(error: restResult.error!)
            }
        }
    }
    
    func add_OR_update_Appointment(appointment: Appointment, delegate: Add_Appointment_Delegate, senderTag: Int)
    {
        let requestBody: AnyObject?
        let methodType: HTTPMethod?
        
        if appointment.isNew()
        {
            requestBody = ["resource" : [appointment.asJSON()]] as AnyObject
            methodType = HTTPMethod.POST
        }
        else
        {
            requestBody = ["resource" : [appointment.asJSONWithID()]] as AnyObject
            methodType = HTTPMethod.PATCH
        }
        
        restClient.callRestService(coRestAppointments, method: methodType!, queryParams: nil , body: requestBody) { restResult in
            
            if restResult.bIsSuccess
            {
                if let resultArray = restResult.json?["resource"] as? JSONArray {
                    
                    if resultArray.count == 1 {
                        
                        if let id = resultArray[0]["id"]
                        {
                            delegate.Add_Appointment_ResponseSuccess(senderTag: senderTag, id: id as! Int)
                        }
                        else
                        {
                            delegate.Add_Appointment_ResponseSuccess(senderTag: senderTag, id: 0)
                        }
                    }
                }
            }
            else
            {
                delegate.Add_Appointment_ResponseError(error: restResult.error!)
            }
        }
    }
    
//    protocol Delete_Appointment_Delegate
//    {
//        func Delete_Appointment_ResponseSuccess(senderTag: Int, id: Int)
//        func Delete_Appointment_ResponseError(error: NSError)
//    }
    
    func delete_Appointment(appointment: Appointment, delegate: Delete_Appointment_Delegate, senderTag: Int)
    {
//        let requestBody: AnyObject?
//        let methodType: HTTPMethod?
//
//        if appointment.isNew()
//        {
//            requestBody = ["resource" : [appointment.asJSON()]] as AnyObject
//            methodType = HTTPMethod.POST
//        }
//        else
//        {
//            requestBody = ["resource" : [appointment.asJSONWithID()]] as AnyObject
//            methodType = HTTPMethod.PATCH
//        }
//
        let queryParams: [String: String] = ["filter": "\(Constants.Appointment_Fields.id)=\(appointment.id)"]
        
        restClient.callRestService(coRestAppointments, method: .DELETE, queryParams: queryParams, body: nil)
        { restResult in
            if restResult.bIsSuccess {
                if let resultArray = restResult.json?["resource"] as? JSONArray {
                    if resultArray.count == 1 {
                        if (resultArray[0][Constants.BlockedUser_Fields.id] != nil) {
                            DispatchQueue.main.async {
                                delegate.Delete_Appointment_ResponseSuccess(senderTag: senderTag, id: resultArray[0][Constants.Appointment_Fields.id] as? Int ?? 0)
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                delegate.Delete_Appointment_ResponseSuccess(senderTag: senderTag, id: 0)
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            delegate.Delete_Appointment_ResponseSuccess(senderTag: senderTag, id: 0)
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        delegate.Delete_Appointment_ResponseSuccess(senderTag: senderTag, id: 0)
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    delegate.Delete_Appointment_ResponseError(error: restResult.error!)
                }
            }
        }
//        restClient.callRestService(coRestAppointments, method: methodType!, queryParams: nil , body: requestBody) { restResult in
//
//            if restResult.bIsSuccess
//            {
//                if let resultArray = restResult.json?["resource"] as? JSONArray {
//
//                    if resultArray.count == 1 {
//
//                        if let id = resultArray[0]["id"]
//                        {
//                            delegate.Delete_Appointment_ResponseSuccess(senderTag: senderTag, id: id as! Int)
//                        }
//                        else
//                        {
//                            delegate.Delete_Appointment_ResponseSuccess(senderTag: senderTag, id: 0)
//                        }
//                    }
//                }
//            }
//            else
//            {
//                delegate.Delete_Appointment_ResponseError(error: restResult.error!)
//            }
//        }
    }
    
    func add_OR_update_User(user: User, delegate: Add_Or_Update_User_Delegate)
    {
        let requestBody: AnyObject?
        let methodType: HTTPMethod?
        
        if(user.isNew())
        {
            requestBody = ["resource" : [user.asJSON()]] as AnyObject
            methodType = HTTPMethod.POST
        }
        else
        {
            requestBody = ["resource" : [user.asJSONWithID()]] as AnyObject
            methodType = HTTPMethod.PATCH
        }
        
        restClient.callRestService(kRestContact, method: methodType!, queryParams: nil , body: requestBody) { restResult in
            
            if restResult.bIsSuccess
            {
                if let resultArray = restResult.json?["resource"] as? JSONArray
                {
                    if resultArray.count == 1
                    {
                        if let id = resultArray[0][Constants.UserFields.username]
                        {
                            delegate.Add_Or_Update_User_ResponseSuccess(userName: id as! String)
                        }
                        else
                        {
                            delegate.Add_Or_Update_User_ResponseSuccess(userName: "0")
                        }
                    }
                }
            }
            else
            {
                delegate.Add_Or_Update_User_ResponseError(error: restResult.error!)
            }
        }
    }
    
    func deleteThisBroadcast(broadcast: COVideo, delegate: DeleteBroadcastDelegate)
    {
        let id = broadcast.id
        let image = broadcast.broadcast
        let broadcast = broadcast.broadcast
        
        //https://www.chattterbox.co.uk/admin/deletefromserver.php
        //parameters: id, image, broadcast
        
        //let str = "https://www.chattterbox.co.uk/admin/deletefromserver.php?id=\(id)&image=\(image)&broadcast=\(broadcast)";
        let str = "https://web.scottishhealth.live/admin/deletefromserver.php?id=\(id)&image=\(image)&broadcast=\(broadcast)"
        //"https://web.simx.tv/admin/deletefromserver.php?id=\(id)&image=\(image)&broadcast=\(broadcast)"
        print (str)
        //let urlStr : NSString = str.stringByAddingPercentEncodingForURLQueryValue() as! NSString//str.addingPercentEscapes(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))! as NSString
        let url : NSURL = NSURL(string: str)!//NSURL(string: urlStr as String)!
        
        var request = URLRequest(url: url as URL)
        request.httpMethod = "POST"
        let session = URLSession.shared
        
        session.dataTask(with: request)
        {data, response, error in
            
            if error != nil
            {
                DispatchQueue.main.async {
                    //delegate.deleteBroadcastSuccess("true")
                    delegate.deleteBroadcastError(error as NSError?)
                    //delegate.send_Appointment_Notification_Error(error: (error?.localizedDescription)!)
                }
                return
            }
            
            do {
                // print(data)// as NSDictionary)
                let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                // print("send_Appointment_Notification API Response data = \(result)")
                
                delegate.deleteBroadcastSuccess("true")
                //delegate.send_Appointment_Notification_Success(msg: "SUCCESS!!")
                
            } catch {
                print("Error occured while trying to extract appointment data -> \(String(describing: error))")
                DispatchQueue.main.async {
                    //delegate.deleteBroadcastSuccess("false")
                    delegate.deleteBroadcastSuccess("false")
                    //delegate.send_Appointment_Notification_Error(error: (error.localizedDescription))
                }
            }
        }.resume()
    }
    
    func send_Appointment_Notification(patient: User, doctor: User, delegate: send_Appointment_Notification_Delegate)
    {
        let alphaNumericName = patient.name.withoutSpecialCharacters
        let name = alphaNumericName.replacingOccurrences(of: " ", with: "%20")
        let patientID = patient.username
        let doctorID = doctor.username
        let status1 = "pending"
        
        //        let str = "http://www.chattterbox.co.uk/notification/appointnotify.php?name=\(name)&patientID=\(patientID)&doctorID=\(doctorID)&status1=\(status1)";
        let str = "https://web.scottishhealth.live/notification/appointnotify.php?name=\(name)&patientID=\(patientID)&doctorID=\(doctorID)&status1=\(status1)"
        //"https://web.simx.tv/notification/appointnotify.php?name=\(name)&patientID=\(patientID)&doctorID=\(doctorID)&status1=\(status1)"
        
        //let urlStr : NSString = str.stringByAddingPercentEncodingForURLQueryValue() as! NSString//str.addingPercentEscapes(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))! as NSString
        //        let url : NSURL = NSURL(string: str)!//NSURL(string: urlStr as String)!
        
        print("URL fromstring: " + str)
        guard let url = URL(string: str) else {
            print("Throwing error, Not generating url for sending appointment notification!")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let session = URLSession.shared
        
        session.dataTask(with: request) { data, response, error in
            
            if error != nil
            {
                // print("Error occured while trying to send appointment notification -> \(String(describing: error))")
                DispatchQueue.main.async {
                    delegate.send_Appointment_Notification_Error(error: (error?.localizedDescription)!)
                }
                return
            }
            
            do {
                let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                // print("send_Appointment_Notification API Response data = \(result)")
                
                //                if result["resource"] != nil
                //                {
                //                    let response = result["resource"]
                //                    // print("\nReceived response = \(response!)\n")
                //                    delegate.ApplyCoupenCode_Success(msg: "\(response!)")
                //                }
                //                else {
                //                    DispatchQueue.main.async
                //                        {
                //                            delegate.ApplyCoupenCode_Error(error: "Something went wrong! Please try again")
                //                    }
                //                }
                
                delegate.send_Appointment_Notification_Success(msg: "SUCCESS!!")
                
            } catch {
                // print("Error occured while trying to extract appointment data -> \(String(describing: error))")
                DispatchQueue.main.async
                    {
                        delegate.send_Appointment_Notification_Error(error: (error.localizedDescription))
                }
            }
            
        }.resume()
    }
    
    func get_UserData_using_UserName(userName:String, resultDelegate: get_UserData_Delegate)
    {
        print("### get_UserData_using_UserName")
        let queryParams = ["filter" : "username=\(userName)"]
        restClient.callRestService(kRestMobileUsers, method: .GET, queryParams: queryParams, body: nil) {
            restResult in
            print("### get_UserData_using_UserName response",restResult)
            if restResult.bIsSuccess
            {
                var requiredUser = User()
                var found = false
                
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    if(detailArray.count > 0)
                    {
                        found = true
                        requiredUser = User(json: detailArray.first!)!
                    }
                    else
                    {
                        found = false
                    }
                }
                
                DispatchQueue.main.async {
                    resultDelegate.get_UserData_ResponseSuccess(isExist: found, requiredUser: requiredUser)
                }
            }
            else
            {
                DispatchQueue.main.async {
                    resultDelegate.get_UserData_ResponseError(restResult.error!)
                }
            }
        }
    }
    
    /*
     ||||||||||||||||||||||||||||||||||||||||||||||||||
     ||                                              ||
     ||           SULMAN Bhai Work Area :)           ||
     ||                                              ||
     ||||||||||||||||||||||||||||||||||||||||||||||||||
     */
    
    // Sulman Adding New Methods
    func getUserWithPhoneNumber(_ phone:String, resultDelegate: UserStatusDelegate)
    {
        let queryParams = ["filter" : "username=\(phone)"]
        restClient.callRestService(kRestMobileUsers, method: .GET, queryParams: queryParams, body: nil) { restResult in
            if restResult.bIsSuccess
            {
                var resultStatus = false
                var statusString = Constants.accountStatus.unverified
                var requiredUser = User()
                
                if let detailArray = restResult.json?["resource"] as? JSONArray
                {
                    
                    if detailArray.count == 0
                    {
                        resultStatus = false
                    }
                    else
                    {
                        for detailJSON in detailArray
                        {
                            // print("Detail JSON = \(detailJSON)")
                            requiredUser = User(json: detailJSON)!
                            
                            if let status = detailJSON["status"]
                            {
                                statusString = status as! String
                            }
                        }
                        
                        resultStatus = true
                    }
                }
                
                DispatchQueue.main.async {
                    resultDelegate.recievedUserStatus(resultStatus, statusString: statusString, requiredUser: requiredUser)
                }
            }
            else {
                DispatchQueue.main.async {
                    resultDelegate.dataAccessError(restResult.error)
                }
            }
        }
    }
    
} // Class Ending bracket

extension String {
    var withoutSpecialCharacters: String {
        let regex = "[^A-Za-z0-9 ]+"
        return self.replacingOccurrences(of: regex, with: "", options: [.regularExpression])
    }
}
extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
