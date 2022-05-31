//
//  Constants.swift
//  CRYOUT
//
//  Created by Saadi on 24/02/2017.
//  Copyright © 2017 com.senarios. All rights reserved.
//

import Foundation

let kChatPresenceTimeInterval:TimeInterval = 45
let kDialogsPageLimit:UInt = 100
let kMessageContainerWidthPadding:CGFloat = 40.0

struct Constants
{
    struct Calling_Keys
    {
        static let uuid_str_for_call = "uuid_str_for_call"
        static let is_call_coming_from_background = "is_call_coming_from_background"
    }
    
    struct Notification_Payload_Keys
    {
        static let UUID = "UUID"
        static let handle = "handle"
        static let hasVideo = "hasVideo"
        static let Push_Notification_Type = "Push_Notification_Type"
        
        static let title_string = "title_string"
        static let message_string = "message_string"
    }
    
    struct UserData
    {
        static var lastBroadcastId = ""
        static var IsApproved = ""
        static var JobPostStatus = ""
    }
    
    struct current_device
    {
        static let device_uuidString: String = UIDevice.current.identifierForVendor!.uuidString
        static let currentDevice_deviceToken = "currentDevice_deviceToken"
        static let currentDevice_pushCredentials_deviceToken = "currentDevice_pushCredentials_deviceToken"
        static let currentDevice_pushCredentials_deviceArn = "currentDevice_pushCredentials_deviceTokenArn"
    }
    
    struct SandboxPayPal
    {
        //https://www.cyberscopeacademy.com/
        // // cjr@utsimx.co.uk // -> email
        static let merchantPrivacyPolicyURL = "https://www.paypal.com/webapps/mpp/ua/privacy-full"
        static let merchantUserAgreementURL = "https://www.paypal.com/webapps/mpp/ua/useragreement-full"
        
        static let production_ClientId = ""
        static let sandbox_ClientId = "-"
//
//
        static let sandBoxSectret = ""
        
        static let productionSecret = ""
//        static let productionSecret = "EGvEXzqAZA1H1vz9cwZUJzR1rDbbmcC29tjdQ4cAUCisPyuZMaE8hB0qPw62HGvpPfBSrlUbDXXIVmze"
        
        
//        static let production_ClientId = "AcUp4UFWpn-Hx4H_ZVO1RCxPinHqNi2XQWRnDf6pSRfVzU_ClNIWxkg7C685qKXpIecvF3sM0LQBHvaf"
//        static let sandbox_ClientId = "AdVZf-30_iJVYCsDwD_XzyY0RZcfk_btGfd-GVRD_UdM9oo496aQduocNFv-1jgqbxoT6QLSLZZuNFqd"
        
//        static let sandbox_ClientId = "AXV8h7J7ul-kSliytI6Ao0Sh2_U9RYrfqoKicex74aKmVO30tilrtjgg82SmMxheQsGuM4EPC-82av_c"
//        static let production_ClientId = "AZ39GzkBvS63mnrBjeeMX_N0CavdsuxJLEhxyfVReNIp0RzYFJ6P6HytKrAaUHwzot2kExoEsGVfJePV"

        //Ac_byhpKVI__6rE3ZScvMS3DiFZ_PByE-gbdlA_EQh3a2LFED6oBc7kMzWpV7E3pCztrRzkiC1NpRjv5
    //    static let sandBoxSectret = "EBGbFj9lnNX5MAFocOvDKvmdvZt3ZGrl4Fh5UQpc31_kin64B-rJ47FXF_tJnhSmVndB3vV-jmytUIrB"

        
        // Ac_byhpKVI__6rE3ZScvMS3DiFZ_PByE-gbdlA_EQh3a2LFED6oBc7kMzWpV7E3pCztrRzkiC1NpRjv5
        //        static let production_ClientId = "AY48hAA0YA9bMtX85SmVKO8ljhy4gGu95i05RBhGtPV2mesgiBbvQCWzvWqnHhN-TyppGhUYQM-slVRm"
        //        static let sandbox_ClientId = "AXV8h7J7ul-kSliytI6Ao0Sh2_U9RYrfqoKicex74aKmVO30tilrtjgg82SmMxheQsGuM4EPC-82av_c"
//        static let sandBoxSectret = "EBGbFj9lnNX5MAFocOvDKvmdvZt3ZGrl4Fh5UQpc31_kin64B-rJ47FXF_tJnhSmVndB3vV-jmytUIrB"
//        static let productionSecret = "ENECnQDDAlrhIFwUwXdMV5bJCmt_TdXSauyExEJtNdktG6OWkdhSmbkNuEsFSH8XDJcoreidcErtRtnq"
        
        static let sandbox_account_email = "@.co"
        static let sandbox_account_password = "12345678"
    }
    
    struct GoogleMaps
    {
        static let API_Key = ""
    }
    
    struct FaceBook
    {
        static let FACEBOOK_SCHEME = "fb157300111470623"//"fb377880392846759"//"fb157300111470623"
    }
    
    struct Twitter
    {
        static let consumerKey      = ""
        static let consumerSecret   = ""
        static let TWITTER_USER_ID  = "TWITTER_USER_ID"
        static let TWITTER_Token  = "twitter_token_555"
        static let TWITTER_TokenSecret  = "twitter_token_secret_555"
        static let CallBackURL      = "https://www.simx.live?source=twitter" //"https://www.cyberjobscope.com?source=twitter"
    }
    
    struct LinkedIn
    {
        //static let AppId = "4737953" //"5231345"
        static let clientId = ""//"86vp3erah7512t"//"86ld41cejbmt12" //"7790uo0ed4wjr4" //"81pcgio6h3rhn8"
        static let clientSecret = ""//"jIQKHKfWKMOSYgQT" //"CfCLCdalxtiRRu4Y" //"tiAHTe2t3pHluOEp"
        static let state = ""
        static let permissions = ["r_basicprofile", "r_emailaddress", "rw_company_admin", "w_share", "r_fullprofile"]
        static let redirectUrl = "https://www.cyberjobscope.com/signin-linkedin"
        //https://www.cyberjobscope.com/signin-linkedin //https://www.cyberjobscope.com/
        static let requestURL = "https://api.linkedin.com/v1/people/~:(id,first-name,last-name,email-address,picture-url,picture-urls::(original),positions,date-of-birth,phone-numbers,location,public-profile-url)?format=json"
    }
    
    struct QuickBlox
    {
        static let ApplicationID:UInt = 93413 //72412 //45149
        static let AuthKey      = ""
        static let AuthSecret   = ""
        static let AccountKey   = ""
        // ==================== || ====================
        static let QB_User_Default_Password = ""
    }
    
    struct DreamFactory
    {
        static let DF_User_Default_Password = ""
    }
    
    struct LocalDefaults
    {
        static let Local_User_Default_arn = ""
    }
    
	struct Links
	{
		static let RadioLink        = "http://s2.voscast.com:9842/;stream1490108724001/1"
		static let TvLink           = "https://www.ustream.tv/embed/23072606?html5ui"
		
        static let webLink          = "http://www.cryoutradio.tv/"
        
        static let facebookWebLink  = "https://www.facebook.com/CryOut-RadioTv-1883727135173361/"
        static let facebookAppLink  = "fb://profile/CryOut-RadioTv-1883727135173361/"
        
		static let twiterWebLink    = "https://twitter.com/CryOutRadioTv"
        static let twiterAppLink    = "twitter:///user?screen_name=CryOutRadioTv"
        
        static let instagramLink    = "https://www.instagram.com/cryoutradiotv/"
        static let whatsAppLink     = ""
        
        static let playStoreLink    = "https://play.google.com/store/apps/details?id=com.senarios.cryoutradiotv"
        static let appStoreLink     = "https://itunes.apple.com/us/app/cryoutradio-tv/id1232297624?ls=1&mt=8"
        
        static let periscopeLink    = "https://www.pscp.tv/CryOutRadioTv"
        static let getSongInfoLink  = "http://s2.voscast.com:9842/stats?sid=1"
	}

    struct Stream {
        static let id = "id"
        static let name = "name"
        static let username = "username"
        static let password = "password"
        static let mobile = "mobile"
        static let email = "email"
        static let status = "status"
        static let attatchment = "attatchment"
        static let devicetype = "devicetype"
        static let arn = "arn"
        static let broadcast = "broadcast"
        static let viewers = "viewers"
    }
    
	struct Orientation {
		static let landscape = "landscape"
		static let portrait = "portrait"
	}
    
    struct deviceType {
        static let iOS = "iOS"
    }
    
    struct  userStatus_keys {
        static let isUserLoggedIntoCyberscopeTV_2333_key = "isUserLoggedIntoCyberscopeTV_2333_key"
    }
    
    struct UserFields {
        static let id = "id"
        static let name = "name"
        static let username = "username"
        static let password = "password"
        static let mobile = "mobile"
        static let email = "email"
        static let status = "status"
        static let attatchment = "attatchment"
        static let devicetype = "devicetype"
        static let arn = "arn"
        static let credit = "credit"
        
        static let picture = "picture"
        static let skills = "skills"
        static let linkedin = "linkedin"
        static let qbid = "qbid"
        static let paypal = "paypal"
        static let broadcasts = "broadcasts"
        static let link = "link"
        static let rate = "rate"
        static let user_ratings = "user_ratings"
        static let total_ratings = "total_ratings"
        static let IsApproved = "IsApproved"
        static let JobPostStatus = "JobPostStatus"
        static let jobSiteLink = "jobSiteLink"
        static let messageOnly = "messageonly"
        static let callOnly = "callonly"
        static let bothmsgcall = "bothmsgcall"
        
    }
    
    struct CommentField {
        
        static let id = "id"
        static let name = "name"
        static let user = "user"
        static let text = "text"
        static let arn = "arn"
        static let type = "type"
    }
    
    struct accountStatus {
        static let verified = "verified"
        static let unverified = "unverified"
    }
    
    struct userSkillsType {
        static let broadcaster = "Recruiter" //"Broadcaster", "Client"
        static let viewer = "OpenForWork" // "Viewer" , "RemoteWorker" , "Coach/Trainer"
        static let freelancer = "OpenForWork"  //"Freelancer", "Coach/Trainer"
        static let client = "Recruiter"
        //static let client = "RemoteWorker"
    }
    
    struct Follower_Fields {
        static let id = "id"
        static let userid = "userid"
        static let username = "username"
        static let followerid = "followerid"
        static let followername = "followername"
    }
    
    struct VideoCVs_Fields {
        static let id = "id"
        static let title = "title"
        static let username = "username"
        static let videocv = "videocv"
    }
    
    struct JobCandidate_Fields {
        static let id = "id"
        static let broadcast = "broadcast"
        static let username = "username"
        static let Isshortlisted = "Isshortlisted"
        static let videocvid = "videocvid"
        static let broadcastid = "broadcast_id"
    }
    
    struct Tag_Fields {
        static let id = "id"
        static let tag = "tag"
        static let broadcast = "broadcast"
    }
    
    struct BlockedUser_Fields {
        static let id = "id"
        static let userid = "userid"
        static let username = "username"
        static let blockedid = "blockedid"
        static let blockedname = "blockedname"
    }
    
    struct Appointment_Fields {
        static let id = "id"
        static let time = "time"
        static let message = "message"
        static let status = "status"
        static let date = "date"
        static let patientName = "patientName"
        static let patientQbId = "patientQbId"
        static let patientId = "patientId"
        static let doctorName = "doctorName"
        static let doctorQbId = "doctorQbId"
        static let doctorId = "doctorId"
    }
    
    struct CurrentUser_UserDefaults {
        static let CurrentUser_id = "CurrentUser_id"
        static let CurrentUser_name = "CurrentUser_name"
        static let CurrentUser_username = "CurrentUser_username"
        static let CurrentUser_password = "CurrentUser_password"
        static let CurrentUser_mobile = "CurrentUser_mobile"
        static let CurrentUser_email = "CurrentUser_email"
        static let CurrentUser_credit = "CurrentUser_credit"
        static let CurrentUser_status = "CurrentUser_status"
        static let CurrentUser_attatchment = "CurrentUser_attatchment"
        static let CurrentUser_devicetype = "CurrentUser_devicetype"
        static let CurrentUser_arn = "CurrentUser_arn"
        static let authVerificationID = "authVerificationID"

        static let picture = "picture"
        static let skills = "skills"
        static let linkedin = "linkedin"
        static let qbid = "qbid"
        static let paypal = "paypal"
        static let broadcasts = "broadcasts"
        static let link = "link"
        static let rate = "rate"
        static let user_ratings = "user_ratings"
        static let total_ratings = "total_ratings"
        static let IsApproved = "IsApproved"
        static let JobPostStatus = "JobPostStatus"
        static let jobSiteLink = "jobSiteLink"
        static let messageOnly = "messageonly"
        static let callOnly = "callonly"
        static let bothmsgcall = "bothmsgcall"
        
    }
    
    struct VideoUserId {
        static let Admin = "Admin"
    }
    
    struct VideoStatus {
        static let online = "online"
        static let offline = "offline"
    }
    
    struct ViewControllers {
        static let splashScreenViewController = "splashScreenViewController"
        static let containerView = "containerView"
        static let sideBarScreen = "leftScreen"
        
        static let LoginViewController = "COLoginViewController"
        static let SignUpViewController = "COSignUpViewController"
        
        static let playList_ViewController = "playList_ViewController"
        static let RadioViewController = "RadioViewController"
        
        static let VideoStreamingHandlerAndViewController = "VideoStreamingHandlerAndViewController"
        static let tvScreenVC = "tvScreenVC"
        
        static let follwers_ViewController = "follwers_ViewController"
        static let follwing_ViewController = "follwing_ViewController"
        
        static let HomeVC = "HomeVC"
        static let MapVC = "MapVC"
        static let CreateStreamVC = "CreateStreamVC"
        static let BroadCaster_ProfileVC = "BroadCaster_ProfileVC"
        static let Request_AppointmentVC = "RequestAppointmentViewController"
        
        static let ProfileVC = "ProfileVC"
        static let EditProfileVC = "EditProfileVC"
        static let FollowersList_VC = "FollowersList_VC"
        static let FollowingsList_VC = "FollowingsList_VC"
        static let AccountSettingsVC = "AccountSettingsVC"
        
        static let NotificationsVC = "NotificationsVC"
        static let LoginWith_LinkedIn_VC = "LoginWith_LinkedIn_VC"
        
        static let IncomingCallVC = "IncomingCallVC"
        static let selectCallTypeVC = "selectCallTypeVC"
        static let CallingVC = "CallingVC"
        static let OfflineVideoPlayerViewController = "OfflineVideoPlayerViewController"
        static let OfflineAVPlayerLauncherViewController = "OfflineAVPlayerLauncherViewController"
        static let VODWowzaViewController = "VODWowzaViewController"
    }
    
    struct sideBarNavigationControllers {
        static let videoPlaylistScreen = "videoPlaylistScreen"
        static let radioScreen = "radioScreen"
        static let follwersScreen = "follwersScreen"
        static let follwingScreen = "follwingScreen"
        static let contactUsScreen = "contactUsScreen"
    }
    
    struct sideBarMenuImages {
        static let radio = "radioImage_icon"
        static let tv = "tvImage_icon"
        static let whistleblowing = "whistleblowinglogo"
        static let sign_in = "sign_in"
        static let followers = "followers"
        static let following = "following"
        static let sign_out = "sign_out"
        static let invite = "invite"
        static let contactUs = "ContactUs"
    }
    
    struct sideBarMenuItems {
        static let Radio = "Radio"
        static let TV = "Television"
        static let whistleBlowing = "Whistleblowers"
        static let Login = "Login"
        static let Follwers = "Followers"
        static let Following = "Following"
        static let Logout = "Logout"
        static let Invite = "Invite Now"
        static let ContactUs = "Contact Us"
    }
    
    struct contactUsList_Items {
        static let Facebook = "Facebook"
        static let Periscope = "Periscope"
        static let Twitter = "Twitter"
        static let Instagram = "Instagram"
        static let PhoneNumber = "+13464008337"
        static let Web = "Web"
    }
    
    struct contactUsList_Images {
        static let FacebookPic = "facebooklogo"
        static let Periscopeicon = "periscopeicon"
        static let TwitterPic = "twitterlogo"
        static let InstagramPic = "instagramlogo"
        static let WhatsAppPic = "whatsapplogo"
        static let weblogo = "weblogo"
    }
    
    struct remoteNotification_keys {
        static let body = "body"
        static let from = "from"
        static let sound = "sound"
    }
    
    struct remoteNotification_bodyDataKeys {
        static let Msg = "Msg"
        static let Title = "Title"
        static let type = "type"
    }
    
    struct remoteNotification_bodyType {
        static let panel = "panel"
        static let newvideo = "newvideo"
        static let newvideo1 = "newvideo1"
        static let update = "update"
    }
    
    struct Notifications_name {
        static let updateVideoList = "updateVideoList"
        static let stopMoviePlayer = "stopMoviePlayer"
        static let logoutFrom_facebook = "logoutFrom_facebook"
        static let logoutFrom_twitter = "logoutFrom_twitter"
        
        static let getCurrentUser_Followings_Followers_Data = "getCurrentUser_Followings_Followers_Data"
        static let getCurrentUser_BlockedUsers_Data = "getCurrentUser_BlockedUsers_Data"
        static let getCurrentUser_Appointments_Data = "getCurrentUser_Appointments_Data"
        static let update_appointments_tableView_data = "update_appointments_tableView_data"
    }
    
    struct uploadVideoAPI_responseKeys {
        static let Msg = "Msg"
        static let id = "id"
        static let Success = "Success"
        static let Failure = "Failure"
    }
    
    struct VideoCellButtons_Title {
        static let Live = "Live"
        static let Follow = "Follow"
        static let Unfollow = "Unfollow"
    }
    
    struct API_URLs {
        static let add_or_uploadVideo_URL = "http://54.91.237.19/cryout/cryoutapi.php"
        static let startFollowingAPI_URL = "http://54.91.237.19/cryout/cryoutapi.php"
        static let uploadThumbnailAPI_URL = "https://web.scottishhealth.live/picture/test.php"
        static let uploadProfileImage_URL = "https://web.scottishhealth.live/picture/upload_ios.php"
        // http://simx.tv:90/s3test.php
        // static let uploadVideoThumbnailAPI_URL = "http://www.simx.tv/s3thumbnail.php"
        static let uploadVideoThumbnailAPI_URL = "https://web.scottishhealth.live/s3test.php"
        static let searchWithAPI_URL = "searchbytags.php?"
        static let Base_URL = ""
        static let RatingUrl = "admin/ratings.php"
    }
    
    struct Stream_URLs {
        static let baseLinkForStreamThmbNails = "https://web.scottishhealth.live/picture/Photos/"
        static let liveStreamViewerUrl = "https://web.scottishhealth.live/"
        static let liveStreamBrodacsterUrl = "rtmp://54.70.143.84:1935/live/"
        static let savedStreamUrl = "https://web.simx.tv:1935/vod/"
        static let videoCVsStreamUrl = "https://web.simx.tv:1935/videocvs/"
        static let savedStreamHLSUrl = "https://web.simx.tv:1935/vod/mp4:"
        
        static let directUploadServerURLPrefix = "https://web.scottishhealth.live/uploads/"
        //https://web.simx.tv/
        static let videoBaseLink = "https://simx.s3-us-west-2.amazonaws.com/"
                                   
        static let directServerLinkURLPostfix = ".mp4"
        static let savedStreamPostFix = ".mp4/playlist.m3u8"
        static let liveStreamPostFix = "/playlist.m3u8"
       
    }
    
    struct Segues
    {
        static let followFollowingVC_to_Rating_VC = "followFollowingVC_to_Rating_VC"
        static let BroadcasterVC_to_Rating_VC = "BroadcasterVC_to_Rating_VC"
        static let profileVC_to_Rating_VC = "profileVC_to_Rating_VC"
        static let goTo_PhoneNumberVerification_VC      = "goTo_PhoneNumberVerification_VC"
        static let goTo_EnterVerificationCode_VC        = "goTo_EnterVerificationCode_VC"
        static let signUp_to_EnterPhoneNumber_VC        = "signUp_to_EnterPhoneNumber_VC"
        static let signIn_to_EnterPhoneNumber_VC        = "signIn_to_EnterPhoneNumber_VC"
        static let verificationCode_to_newPasswordVC    = "verificationCode_to_newPasswordVC"
        
        static let blockedToBroadcasterProfile         = "blockedToBroadcasterProfile"
        static let followerToBroadcasterProfile         = "followerToBroadcasterProfile"
        static let followingsToBroadcasterProfile       = "follwingsToBroadcasterProfile"
        
        static let SignInVC_to_MoreUserDetails1VC = "SignInVC_to_MoreUserDetails1VC"
        static let SignUpVC_to_MoreUserDetails1VC = "SignUpVC_to_MoreUserDetails1VC"
        
        static let PhoneNumberVC_to_MoreUserDetails1VC = "PhoneNumberVC_to_MoreUserDetails1VC"
        static let MoreUserDetails1VC_to_EnableLocationVC = "MoreUserDetails1VC_to_EnableLocationVC"
        static let EnableLocationVC_to_MoreUserDetails2_VC = "EnableLocationVC_to_MoreUserDetails2_VC"
        static let SignupDetail_to_SignUPDetail2 = "SignupDetail_to_SignUPDetail2"
        
        
        static let HomeVC_to_MapVC = "HomeVC_to_MapVC"
        static let HomeVC_to_VideoCVs = "HomeVC_to_VideoCVs"
        static let HomeVC_to_CreateStreamVC = "HomeVC_to_CreateStreamVC"
        static let HomeTo_CreateOfflineStream = "HomeTo_CreateOfflineStream"
        static let MyProfile_to_MyVideoCvs = "MyProfile_to_MyVideoCvs"
        static let HomeVC_to_BroadCaster_ProfileVC = "HomeVC_to_BroadCaster_ProfileVC"
        static let MapVC_to_CreateStreamVC = "MapVC_to_CreateStreamVC"
        static let BroadCaster_ProfileVC_to_Request_AppointmentVC = "BroadCaster_ProfileVC_to_Request_AppointmentVC"
        static let FollowerFollowings_to_Request_AppointmentVC = "FollowerFollowings_to_Request_AppointmentVC"
        
        
        static let ProfileVC_to_EditProfileVC = "ProfileVC_to_EditProfileVC"
        static let ProfileVC_to_AccountSettingsVC = "ProfileVC_to_AccountSettingsVC"
        static let ProfileVC_to_FollowersList_VC = "ProfileVC_to_FollowersList_VC"
        static let ProfileVC_to_FollowingsList_VC = "ProfileVC_to_FollowingsList_VC"
        static let BroadcastVC_to_FollowersList_VC = "BroadcastVC_to_FollowersList_VC"
        static let BroadcastVC_to_FollowingsList_VC = "BroadcastVC_to_FollowingsList_VC"
        static let Map_To_MapDetailVC = "Map_To_MapDetailVC"
        static let ProfileVC_To_MapDetailVC = "ProfileVC_To_MapDetailVC"
        static let BoardingViewController_to_StreamingStoryboard = "BoardingViewController_to_StreamingStoryboard"
        
        static let selectCallTypeVC_to_callingVC = "selectCallTypeVC_to_callingVC"
    }
    
    struct StoryBoards
    {
        static let LaunchScreen = "LaunchScreen"
        static let Main = "Main"
        static let Payments = "Payments"
        static let StreamBoard = "StreamBoard"
    }
    
    struct TableView_Cells
    {
        static let user_Appointment_Cell = "user_Appointment_Cell"
        static let user_AcceptedAppointment_Cell = "user_AcceptedAppointment_Cell"
        static let user_RejectedAppointment_Cell = "user_RejectedAppointment_Cell"
        static let messagesTableCell = "messagesTableCell"
        static let streamsTableViewCell = "streamsTableViewCell"
        static let followersTableViewCell = "followersTableViewCell"
        static let messagesTableViewCell = "messagesTableViewCell"
        static let followingsTableViewCell = "followingsTableViewCell"
        static let settingsSimpleCell = "settingsSimpleCell"
        static let settingsWithIconCell = "settingsWithIconCell"
        static let Appointment_simpleCell = "Appointment_simpleCell"
        static let Appointment_hourlyRateCell = "Appointment_hourlyRateCell"
        static let VideoCVsCell = "VideoCVsCell"
        static let jobCandidateCell = "jobCandidateCell"
    }
    
    struct Device
    {
        static let deviceFrame = UIScreen.main.bounds
    }
    
    struct ScreenSize
    {
        static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
        static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
        static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    }
    
    struct DeviceType
    {
        static let IS_IPHONE_5_OR_LESS          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH <= 568.0
        static let IS_IPHONE_6_7          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
        static let IS_IPHONE_6P_7P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
        static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
        static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
    }
    
    struct imagesName
    {
        static let in_icon = "in_icon"
        static let fb_icon = "fb_icon"
        static let twtr_icon = "twtr_icon"
        
        static let simpleMapMarker_offline = "simpleMapMarker_offline"
        static let simpleMapMarker_online = "simpleMapMarker_online"
        static let default_UserImage = "profile" // "home_tab_unselectedIcon"
        static let broadcaster_image = "profile_tab_unselectedIcon"
        static let broadcaster_image2 = "home_tab_unselectedIcon"
        static let broadcastThumbNail_image = "broadcastThumbNail_image"
        static let broadcastThumbNail_image2 = "broadcastThumbNail_image2"
        static let broadcastThumbNail_image3 = "scootishHealth"
    }
    
    struct Colors
    {
        static let lightBorderColor_forCollectionCELLS = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16)
        static let acceptAppointment_cellColor = UIColor(red: 44/255, green: 172/255, blue: 93/255, alpha: 1.0)
        static let declineAppointment_cellColor = UIColor(red: 255/255, green: 70/255, blue: 70/255, alpha: 1.0)
        static let darkBlue_headings_themeColor = UIColor(red: 10/255, green: 73/255, blue: 122/255, alpha: 1.0)
    }
    
    struct appColors {
        static let colorBlue = UIColor(red: 10/255, green: 73/255, blue: 122/255, alpha: 1.0)
        static let colorGrey = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1.0)
        static let colorGreyText = UIColor.lightGray
    }
    
    struct strings
    {
        static let CyberScopeTV = "SimX"
        static let Live = "Live"
        static let Follow = "Follow"
        static let Unfollow = "Unfollow"
        static let Block_User = "Block User"
        static let Unblock_User = "Unblock User"
        
        static let ViewerDetailString = "Apply for jobs with video . Simply Share authentic video clips on social media and get hired in the app .Get paid for coaching or expert video consultations, No CV required."
        static let BroadcasterDetailString = "Post Job Videos or video interview SimX job hunters."
    }
    
    struct OS
    {
        static let android = "android"
        static let ios = "ios"
    }
}

class ConstantsC {
    
    class var QB_USERS_ENVIROMENT: String {
        
        #if DEBUG
        return "ios"
        #elseif QA
        return "qbqa"
        #else
        assert(false, "Not supported build configuration")
        return ""
        #endif
        
    }
}


