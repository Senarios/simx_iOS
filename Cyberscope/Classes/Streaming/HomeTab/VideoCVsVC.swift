//
//  VideoCVsVC.swift
//  SimX
//
//  Created by APPLE on 01/07/2020.
//  Copyright © 2020 Agilio. All rights reserved.
//

import UIKit
import AVKit
import Toaster
import Alamofire
import Firebase
import FirebaseStorage
import FirebaseDatabase

import MBProgressHUD
import AWSS3
import YoutubeKit
//import FirebaseStorage

protocol VideoCVsVCDelegate: class {
    func setJobTitle(broadcastID: String)
}

class VideoCVsVC: UIViewController {
    
    @IBOutlet weak var videoCVsTV: UITableView!
    
    @IBOutlet weak var btnUploadCV: UIButton!
    @IBOutlet weak var btnAddVideo: UIButton!
    @IBOutlet weak var tfCVTitle: UITextField!
    @IBOutlet weak var viewAddVideoCV: UIView!
    @IBOutlet weak var viewCVTitle: UIView!
    @IBOutlet weak var imgSelectedVideo: UIImageView!
    
    
    @IBOutlet weak var applyCvImg: UIImageView!
    
    @IBOutlet weak var applyCvBtn: UIButton!
    @IBAction func applyCvBtn(_ sender: Any) {
        checkBoxBtn(btn: applyCvBtn)
       
    }
    
    @IBOutlet weak var applyCvVideo: UIImageView!
    
    @IBOutlet weak var applyCvVideoBtn: UIButton!
    @IBAction func applyCvVideoBtn(_ sender: Any) {
        checkBoxBtn(btn: applyCvVideoBtn)
        
    }
    
    var checkString = "IMAGE"
    var videocvsArray : [Videocvs] = []
   
    
    var broadcastData: COVideo = COVideo()
    var isFromHome: Bool = false
    var selectedStreamIndex: Int = -1
    
    var imagePickerController = UIImagePickerController()
    var videoURL : NSURL?
    var selectedVideoPath: String = ""
    
    var delegate: VideoCVsVCDelegate?
    
    var mp4VideoURL = URL(fileURLWithPath: "")
    var callDone: Bool = false
    var nameForVideo = ""
    var videoObject = Videocvs()
    var imageObj  = ImageCvModel()
    
    
    private let storage = Storage.storage().reference()
    var ref = DatabaseReference.init()
    var fireBaseUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        self.setUpControls()
        self.getVideoCVs_Data()
        applyCvImg.image = UIImage(named: "radioCheck")
     //   print(broadcastData)
        
//        let button = UIButton(type: .roundedRect)
//        button.frame = CGRect(x: 20, y: 400, width: 100, height: 30)
//        button.setTitle("Crash", for: [])
//        button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), for: .touchUpInside)
//        view.addSubview(button)
    }
    
//    @IBAction func crashButtonTapped(_ sender: AnyObject) {
//        fatalError()
//    }
    func setUpControls()
    {
        self.videoCVsTV.delegate = self
        self.videoCVsTV.dataSource = self
        
        self.btnAddVideo.imageView?.contentMode = .scaleAspectFit
        self.btnAddVideo.layer.cornerRadius = 18
        self.btnAddVideo.layer.borderWidth = 1
        self.btnAddVideo.layer.borderColor = UIColor.green.cgColor
        
        self.viewCVTitle.layer.cornerRadius = 10
        self.viewCVTitle.layer.borderWidth = 1
        self.viewCVTitle.layer.borderColor = UIColor.lightGray.cgColor
        self.viewCVTitle.backgroundColor = .white
        
        self.btnUploadCV.layer.cornerRadius = 21
        self.viewAddVideoCV.layer.cornerRadius = 10
        self.viewAddVideoCV.layer.borderWidth = 1
        self.viewAddVideoCV.layer.borderColor = UIColor.lightGray.cgColor

        self.viewAddVideoCV.isHidden = true
        self.videoCVsTV.backgroundColor = UIColor.white
    }
    
    @objc func getVideoCVs_Data()
    {
        let sessionObject = DataAccess.sharedInstance
        sessionObject.getVideoCVs_Data(delegate: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .black
    }
    
    func submitVideoCV_Data(jobcandidate: JobCandidates)
    {
        let sessionObject = DataAccess.sharedInstance
        sessionObject.add_JobCandidates(jobcandidate: jobcandidate, delegate: self)
    }
    
    func deleteVideoCV(){
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        let vidoeCVs = self.videocvsArray[self.selectedStreamIndex]

        let shSingeltonObject = DataAccess.sharedInstance
        shSingeltonObject.removeVideoCV(videoCVId: vidoeCVs.id, resultDelegate: self as RemoveVideoCVDelegate)
    }

    @IBAction func backClicked(_ sender: Any) {
        if !self.viewAddVideoCV.isHidden
        {
            self.viewAddVideoCV.isHidden = true
        }
        else
        {
            self.closeView()
        }
    }
    
    @IBAction func addVideoCvClicked(_ sender: Any) {
        
        if checkString == "IMAGE"{
            
            let alertController = UIAlertController(title: "Upload Image", message: "Choose Image to Upload", preferredStyle: .actionSheet)
            
            let cameraButton = UIAlertAction(title: "Take a Photo", style: .default, handler: { (action) -> Void in
                print("take photo pressed")
                self.imagePickerController = UIImagePickerController()
                self.imagePickerController.delegate = self
                self.imagePickerController.sourceType = .camera
    //            self.imagePickerController.mediaTypes = [kUTTypeMovie as String]
               self.imagePickerController.allowsEditing = true
                self.present(self.imagePickerController, animated: true, completion: nil)
            })
            
            let  galleryButton = UIAlertAction(title: "Choose from Gallery", style: .default, handler: { (action) -> Void in
                print("choose from gallery tapped")
                print("Choose picture pressed")
                self.imagePickerController = UIImagePickerController()
                self.imagePickerController.delegate = self
                self.imagePickerController.sourceType = .photoLibrary
                
    //            self.imagePickerController.mediaTypes = [kUTTypeMovie as String]
               self.imagePickerController.allowsEditing = true
                self.present(self.imagePickerController, animated: true, completion: nil)
            })
            
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                print("Cancel button tapped")
            })
            
            alertController.addAction(cameraButton)
            alertController.addAction(galleryButton)
            alertController.addAction(cancelButton)
            
            self.present(alertController,animated: true, completion: nil)
        }else{
                    UIView.animate(withDuration: 0.4, animations: {
                         () -> Void in
                          self.viewAddVideoCV.isHidden = false
                    }, completion: nil)
        }

        
    }

    @IBAction func addVideoClicked(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Upload Image", message: "Choose Image to Upload", preferredStyle: .actionSheet)
        
        let cameraButton = UIAlertAction(title: "Take a Photo", style: .default, handler: { (action) -> Void in
            print("take photo pressed")
            self.imagePickerController = UIImagePickerController()
            self.imagePickerController.delegate = self
            self.imagePickerController.sourceType = .camera
            if self.checkString == "VIDEO"{
                self.imagePickerController.mediaTypes = [kUTTypeMovie as String]
            }else if self.checkString == "IMAGE"{
                print("nothing")
            }
           self.imagePickerController.allowsEditing = true
            self.present(self.imagePickerController, animated: true, completion: nil)
        })
        
        let  galleryButton = UIAlertAction(title: "Choose from Gallery", style: .default, handler: { (action) -> Void in
            print("choose from gallery tapped")
            print("Choose picture pressed")
            self.imagePickerController = UIImagePickerController()
            self.imagePickerController.delegate = self
            self.imagePickerController.sourceType = .photoLibrary
            
            if self.checkString == "VIDEO"{
                self.imagePickerController.mediaTypes = [kUTTypeMovie as String]
            }else if self.checkString == "IMAGE"{
                print("nothing")
            }
           self.imagePickerController.allowsEditing = true
            self.present(self.imagePickerController, animated: true, completion: nil)
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        
        alertController.addAction(cameraButton)
        alertController.addAction(galleryButton)
        alertController.addAction(cancelButton)
        
        self.present(alertController,animated: true, completion: nil)
    }
    
    @IBAction func playSelectedVideoClicked(_ sender: Any) {
        
        print("kuch nahi yar")
        if self.selectedVideoPath.count > 5 {
            self.playThisVideoInPlayer(videoFileURLString: self.selectedVideoPath)
        }
    }
    
    @IBAction func uploadCVClicked(_ sender: Any) {
        if (!self.checkTitleValidity()) {
            return
        }
        
        self.UploadCV()
          
    }
    
    func closeView() {
        DispatchQueue.main.async {
            if self.isModal {
                self.dismiss(animated: true, completion: nil)
            }
            else
            {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //MARK: Check box
    func checkBoxBtn(btn: UIButton){
        if btn == applyCvBtn{
            applyCvImg.image = UIImage(named: "radioCheck")
            applyCvVideo.image = UIImage(named: "circleIcone")
            checkString = "IMAGE"
        }else if btn == applyCvVideoBtn{
            applyCvImg.image = UIImage(named: "circleIcone")
            applyCvVideo.image = UIImage(named: "radioCheck")
            checkString = "VIDEO"
            
        }
    }
    
    func nameForNewStreamVideoObject() {
        var ticks = NSDate().timeIntervalSince1970
        ticks = ticks * 10000
        let nameForNewVideo = String(format: "%10.0f", ticks)
        let uniqueVideoName = nameForNewVideo
        self.nameForVideo = CurrentUser.Current_UserObject.username + uniqueVideoName
    }
    
    func UploadCV(){
        self.callDone = false
        DispatchQueue.main.async {
            self.videoObject.title = self.tfCVTitle.text!
        }
        self.nameForNewStreamVideoObject()
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        self.encodeVideoToMP4(at: self.videoURL as! URL, completionHandler: { url, error in
            print("encodeVideoToMP4 completed")
            if let url = url {
                self.mp4VideoURL = url
                self.AWSS3TransferUtilityUploadFunction(with: self.nameForVideo , type: "mp4")
                
            }
            print(error)
            if let error = error {
                  // handle error
            }
        })
    }
    func uploadCvImage(){
        self.callDone = false
//        DispatchQueue.main.async {
//            self.videoObject.title = "Picture CV"
//        }
        self.nameForNewStreamVideoObject()
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
       
        addCvObject()
    }
    
    
  
    
    func checkTitleValidity() -> Bool {
        
        if (self.tfCVTitle.text == nil || self.tfCVTitle.text == "") {
            
            self.showAlert("Alert", message: "Please put a title for new CV.")
            return false
        }
        else if ((self.tfCVTitle.text?.count)! < 2) {
            self.showAlert("Title Strength", message: "Too short.")
            return false
        }
//        else if (self.selectedVideoPath.count < 10) {
//            self.showAlert("Video missing", message: "Please select video CV")
//            return false
//        }
        else {
            //self.titleTextContainer.isHidden = true
            return true
        }
        
    }
    
    func showAlert(_ title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
    }

    let bucketName = "simx/videoCvs"
    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    
    func AWSS3TransferUtilityUploadFunction(with resource: String, type: String){
        
        let key = "\(resource).\(type)"
        print("Video Key", key)
        
        let expression  = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task: AWSS3TransferUtilityTask, progress: Progress) -> Void in
         //   print("expression.progressBlock")
            print(progress.fractionCompleted)
            //do any changes once the upload is finished here
            if progress.isFinished{
                print("Upload Finished...")
                if !self.callDone{
                    self.callDone = true
                    self.addVideoCVObject()
                }
            }
        }
         
        expression.setValue("public-read-write", forRequestHeader: "x-amz-acl")
        expression.setValue("public-read-write", forRequestParameter: "x-amz-acl")

        completionHandler = { (task:AWSS3TransferUtilityUploadTask, error:NSError?) -> Void in
            if(error != nil){
                print("Failure uploading file")
                
            }else{
                print("Success uploading file")
            }
        } as? AWSS3TransferUtilityUploadCompletionHandlerBlock
       
        let filePath = self.mp4VideoURL.path
        if FileManager.default.fileExists(atPath: filePath) {
            if let fileData = FileManager.default.contents(atPath: filePath) {
                // process the file data
                print("Data avilable :", fileData.count)
                AWSS3TransferUtility.default().uploadData(fileData, bucket: bucketName, key: String(key), contentType: resource, expression: expression, completionHandler: self.completionHandler).continueWith(block: { (task:AWSTask) -> AnyObject? in
                    if(task.error != nil){
                        print("Error uploading file: \(String(describing: task.error?.localizedDescription))")
                    }
                    if(task.result != nil){
                        print("Starting upload...")
                    }
                    return nil
                })
            } else {
                print("Could not parse the file")
            }
        } else {
            print("File not exists")
        }
    }
    
    
/*
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {

            AWSS3TransferUtility.interceptApplication(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
        }*/
    
    
    //MARK: Upload Image
    
    func compressImage (_ image: UIImage) -> Data {
        let compressionQuality:CGFloat = 0.5
        
        let rect:CGRect = CGRect(x: 0, y: 0, width: 100, height: 80)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        let imageData:Data = UIImageJPEGRepresentation(img, compressionQuality)!//! as Data
        return imageData
    }
    
    
    func postThumbNailImage(imageData: UIImage) {
        
        //let imageData = self.convert(cmage: image)
        let image_data = self.compressImage(imageData)
        let image : String = (image_data.base64EncodedString())
        var name : String = "abc" + self.nameForVideo
        name = name + ".png"
        
        print(name)
        self.videoCVsTV.reloadData()
        
        uploadImage(url:Constants.API_URLs.uploadThumbnailAPI_URL, withParams:["base64": image , "ImageName" : name ])
        {
            (succeeded: Bool, msg: String?) -> () in
            if succeeded == true
            {
                if msg == nil
                {
                    DispatchQueue.main.async {
                        print("Uploading Failed")
                    }
                    print("\n\nMessage is nil ::: \(String(describing: msg))")
                }
                else
                {
                    // SwiftSpinner.hide()
                    DispatchQueue.main.async{
                        print("Image Uploaded")
                      
                    }
                    print("\n\nMessage is ::: \(String(describing: msg))")
                }
            }
            else
            {
                print("Uploading Failed")
                print("\n\nError fetching Data !!! ")
            }
        }
    }
    
    //MARK: API to upload image
    func uploadImage(url:String, withParams params: [String : String?] , postCompleted : @escaping (_ succeeded: Bool, _ msg: String?) -> ())
    {
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        let session = URLSession.shared
        request.httpMethod = "POST"
        var bodyData = ""
        for (key,value) in params
        {
            if (value == nil){ continue }
            let scapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let scapedValue = value?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            bodyData += "\(scapedKey!)=\(scapedValue!)&"
        }
        request.httpBody = bodyData.data(using: String.Encoding.utf8, allowLossyConversion: true)
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            if data != nil
            {
                print("\n\ndata is ::: \(data).\n\nresponse is \(response)")
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                postCompleted(true, dataString! as String)
                print(dataString)
            }
            else
            {
                Alert.showOfflineAlert()
                print("\n\nERROR !!! NO INTERNET CONNECTION...DATA IS NIL")
            }
        })
        task.resume()
    }
    
    // Encode video from .mov to .mp4
    func encodeVideoToMP4(at videoURL: URL, completionHandler: ((URL?, Error?) -> Void)?)  {
        let avAsset = AVURLAsset(url: videoURL, options: nil)

        let startDate = Date()

        //Create Export session
        guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough) else {
            completionHandler?(nil, nil)
            return
        }

        //Creating temp path to save the converted video
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath = documentsDirectory.appendingPathComponent("rendered-Video.mp4")

        //Check if the file already exists then remove the previous file
        if FileManager.default.fileExists(atPath: filePath.path) {
            do {
                try FileManager.default.removeItem(at: filePath)
            } catch {
                completionHandler?(nil, error)
            }
        }

        exportSession.outputURL = filePath
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0.0, 0)
        let range = CMTimeRangeMake(start, avAsset.duration)
        exportSession.timeRange = range

        exportSession.exportAsynchronously(completionHandler: {() -> Void in
            switch exportSession.status {
            case .failed:
                print(exportSession.error ?? "NO ERROR")
                completionHandler?(nil, exportSession.error)
            case .cancelled:
                print("Export canceled")
                completionHandler?(nil, nil)
            case .completed:
                //Video conversion finished
                let endDate = Date()

                let time = endDate.timeIntervalSince(startDate)
                print(time)
                print("Successful!")
                print(exportSession.outputURL ?? "NO OUTPUT URL")
                completionHandler?(exportSession.outputURL, nil)

                default: break
            }

        })
    }
    
    func addCvObject() {

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.imageCreatationAPI(videoName: self.nameForVideo)
        }
        videoObject.username = CurrentUser.Current_UserObject.username

        //videoObject.asJSON()
        let shSingeltonObject = DataAccess.sharedInstance
        shSingeltonObject.addOrUpdateVideoCV(videoObject, delegate: self as AddUpdateVideo_Protocol)
    }
    
    
    func addVideoCVObject() {

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.imageCreatationAPI(videoName: self.nameForVideo)
        }
        
        videoObject.videocv = self.nameForVideo
        videoObject.username = CurrentUser.Current_UserObject.username

        //videoObject.asJSON()
        let shSingeltonObject = DataAccess.sharedInstance
        shSingeltonObject.addOrUpdateVideoCV(videoObject, delegate: self as AddUpdateVideo_Protocol)
    }
    
    func imageCreatationAPI(videoName: String){
        var name : String = videoName
        let videoLink : String = "https://simx.s3-us-west-2.amazonaws.com/videoCvs/\(videoName).mp4"
        // let videoLink : String = "https://simx.s3-us-west-2.amazonaws.com/offlineVideos/_fZj2Zds8J15943515249107.mp4"

        let parameters = [
            "imageName": name,
            "videoLink": videoLink
        ]
        print(Constants.API_URLs.uploadVideoThumbnailAPI_URL)
        print(parameters)
        Alamofire.upload(multipartFormData: { multipartFormData in
                //loop this "multipartFormData" and make the key as array data
            
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            } //Optional for extra parameters
        },
        to: Constants.API_URLs.uploadVideoThumbnailAPI_URL)
        { (result) in
            switch result {
            case .success(let upload, _, _):

                upload.uploadProgress(closure: { (progress) in
                 //   print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseString{ response in
                print("response.result.value")
                    let JsonResponseData = response.result.value
                    print(response.result.value)
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        }// End
    }
    
    func playThisVideoInPlayer(videoFileURLString: String, videoTitle: String = "") {
        print("about to launch With Player with : \(videoFileURLString)")
        if let url = URL(string: videoFileURLString){
            
            let player = AVPlayer(url: url)
            let vc = AVPlayerViewController()
            vc.player = player
            present(vc, animated: true) {
                vc.player?.play()
            }

        }
//        let url = URL(string: videoFileURLString)
//
//        let vc =  UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil).instantiateViewController(withIdentifier: "playerVC") as! playerVC
//        vc.videoUrl = url!
//        vc.videoTitle = videoTitle
//        vc.modalPresentationStyle = .fullScreen
//         self.present(vc, animated: true, completion: nil)
        // self.navigationController?.pushViewController(vc, animated: false)
    }
    
}

extension VideoCVsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if checkString == "IMAGE"{
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
           
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            
            
            let randomName = randomStringWithLength(length: 36)
            print(randomName)
            
            let uploadRef = Storage.storage().reference().child("images/"+"\(randomName)")
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"

            videoObject.videocv = randomName as String
            videoObject.title = "Picture CV"
          
            
            let imageData = UIImageJPEGRepresentation(image, 0.1)
            
            let uploadTask = uploadRef.putData(imageData!, metadata: metaData) { metaData, error in
                if error == nil {
                    uploadRef.downloadURL { url, error in
                        print(url, error)
                       
                        let url1 = url?.absoluteString
                       
                        let randomId = String(randomName)
                        let dict = [randomId: url1]

                        self.ref.child("images/"+"\(randomName)").setValue(url1)
                        
                       
                     //MARK: CV Upload
                        
                        do {
//                            let asset = AVURLAsset(url: videoURL as! URL , options: nil)
//                            let imgGenerator = AVAssetImageGenerator(asset: asset)
//                            imgGenerator.appliesPreferredTrackTransform = true
                            //let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                         
                            self.postThumbNailImage(imageData: image)
                            
                            
                            //self.selectedVideoPath = "asbdsbchbsdalcbhdsabvhsbavjhlbfajh vjh afjh"
                            self.uploadCvImage()
                            
                            
                            
                        } catch let error {
                            print("*** Error generating thumbnail: \(error.localizedDescription)")
                        }
                        
                    }
                       } else {
                           //error
                           print("error uploading image")
                       }
                
            }

                

            
            
            
            
            
          //  self.imgSelectedVideo.image = image
//            nameForNewStreamVideoObject()
//            postThumbNailImage(imageData: image)
        }else{
            videoURL = info[UIImagePickerControllerMediaURL] as? URL as NSURL?
            print(videoURL)
            self.selectedVideoPath = self.videoURL?.absoluteString as! String
            print("videoURL:\(String(describing: videoURL))", self.selectedVideoPath)
            do {
                let asset = AVURLAsset(url: videoURL as! URL , options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                self.imgSelectedVideo.image = thumbnail
                self.postThumbNailImage(imageData: self.imgSelectedVideo.image!)
                
//                if (!self.checkTitleValidity()) {
//                    return
//                }
                
                self.UploadCV()
                
                
                
            } catch let error {
                print("*** Error generating thumbnail: \(error.localizedDescription)")
            }
        }
       
//        if (!self.checkTitleValidity()) {
//            return
//        }
//
//        self.UploadCV()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func randomStringWithLength(length: Int) -> NSString {
        let characters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString: NSMutableString = NSMutableString(capacity: length)

        for i in 0..<length {
            var len = UInt32(characters.length)
            var rand = arc4random_uniform(len)
            randomString.appendFormat("%C", characters.character(at: Int(rand)))
        }
        return randomString
    }
    
}

extension VideoCVsVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.videocvsArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableView_Cells.VideoCVsCell, for: indexPath) as! VideoCVsCell
        cell.index = indexPath
        let vidoeCVs = self.videocvsArray[indexPath.row]
     
        cell.lblVideoTitle.text = vidoeCVs.title
        
        let url1 = Utilities.getUserImage_URL(username: vidoeCVs.videocv)
      
        print(url1)
        
        if vidoeCVs.title == "Picture CV"{
            cell.playVideoImg.isHidden = true
            let ref = Database.database().reference().child("images/\(vidoeCVs.videocv)")
            ref.observeSingleEvent(of: .value, with: { (snap : DataSnapshot)  in
                let url = URL(string: snap.value as! String)
                
                if let data = try? Data(contentsOf: url!) {
                    cell.imgVideoThumb.image = UIImage(data: data)
                }
                
            }) { (err: Error) in
                
                
                print("\(err.localizedDescription)")
                
            }
            
        }else{
            cell.playVideoImg.isHidden = false
            cell.imgVideoThumb.sd_setImage(with: url1, placeholderImage: UIImage(named: Constants.imagesName.broadcastThumbNail_image3))
        }
       
       
      //  cell.imgVideoThumb.image = vidoeCVs.videocv
        cell.imgVideoThumb.layer.cornerRadius = cell.imgVideoThumb.frame.size.height / 2.0
        cell.videoCV = vidoeCVs.videocv
        cell.cellDelegate = self
        cell.backgroundColor = UIColor.white
        return cell
    }
}

extension VideoCVsVC: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let vidoeCVs = self.videocvsArray[indexPath.row]
        
        print(vidoeCVs.title)
        if vidoeCVs.title == "Picture CV"{
            let vc = storyboard?.instantiateViewController(withIdentifier: "CvImageShowVc") as? CvImageShowVc
            
            
            let ref = Database.database().reference().child("images/\(vidoeCVs.videocv)")


                ref.observeSingleEvent(of: .value, with: { (snap : DataSnapshot)  in

                    let url = URL(string: snap.value as! String)
                    if let data = try? Data(contentsOf: url!) {
                        vc!.cvImageView.image = UIImage(data: data)
                    }

                }) { (err: Error) in

                    print("\(err.localizedDescription)")

                }
//           print(fireBaseUrl)
//            vc?.url = fireBaseUrl
            vc?.modalPresentationStyle = .fullScreen
            present(vc!, animated: true, completion: nil)
        }
        
//        let vidoeCVs = self.videocvsArray[indexPath.row]
//        tableView.deselectRow(at: indexPath, animated: true)
//        if self.isFromHome {
//            Utilities.show_ProgressHud(view: self.view)
//        
//            let jobCandidate = JobCandidates()
//            jobCandidate.broadcast = self.broadcastData.broadcast
//            jobCandidate.broadcastid = self.broadcastData.id
//            jobCandidate.videocvid = vidoeCVs.id
//            jobCandidate.username = CurrentUser.get_User_username_fromUserDefaults()
//            self.submitVideoCV_Data(jobcandidate: jobCandidate)
//        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let vidoeCVs = self.videocvsArray[indexPath.row]
        self.selectedStreamIndex = indexPath.row
        
            let editAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
                print("Edit tapped")
                let refreshAlert = UIAlertController(title: "Alert!", message: "Do you really want to delete the CV?", preferredStyle: UIAlertControllerStyle.alert)

                refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    self.deleteVideoCV()
                  }))

                refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                  print("Handle No Logic here")
                  }))

                self.present(refreshAlert, animated: true, completion: nil)
            })
        editAction.backgroundColor = UIColor.red
        return [editAction]
    }
    
    
}

extension VideoCVsVC: getVideoCVs_Data_Delegate {
    func getVideoCVs_Data_ResponseError(_ error: NSError?) {
        print(error?.description)
    }
    
    func getVideoCVs_Data_ResponseSuccess(videocvs: [Videocvs]) {
      //  if videocvs.count > 0 {
            print(videocvs)
            self.videocvsArray = videocvs
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.videoCVsTV.reloadData()
            }
            
    //    }
    }
}
extension VideoCVsVC: VideoCVCellDelegate{
    func applyCVideo(indexPath : IndexPath) {
        let vidoeCVs = self.videocvsArray[indexPath.row]
      //  tableView.deselectRow(at: indexPath, animated: true)
        if self.isFromHome {
            Utilities.show_ProgressHud(view: self.view)
        
            let jobCandidate = JobCandidates()
            jobCandidate.broadcast = self.broadcastData.broadcast
            jobCandidate.broadcastid = self.broadcastData.id
            jobCandidate.videocvid = vidoeCVs.id
            jobCandidate.username = CurrentUser.get_User_username_fromUserDefaults()
            self.submitVideoCV_Data(jobcandidate: jobCandidate)
        }

    }
    
    func playCVVideo(videoCV: String) {
        print(videoCV)
//        let videoURLString = Constants.Stream_URLs.videoCVsStreamUrl + videoCV + Constants.Stream_URLs.directServerLinkURLPostfix
        
        let videoURLString = "\(Constants.Stream_URLs.videoBaseLink)videoCvs/\(videoCV).mp4"
         print(videoURLString)
      //  self.playThisVideoInAVPlayer(videoFileURLString: videoURLString)
        self.playThisVideoInPlayer(videoFileURLString: videoURLString)
        /* var videoView = COVideo()
        videoView.broadcast = videoCV
        let vc =  UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil).instantiateViewController(withIdentifier: Constants.ViewControllers.VODWowzaViewController) as! VODWowzaViewController
       // vc.videoUrlString = videoURLString
        vc.currentVideo = videoView
        self.present(vc, animated: true, completion: nil)*/
    }
    
    
    
    func playThisVideoInAVPlayer(videoFileURLString: String) {
            
            print("about to launch Player with : \(videoFileURLString)")
            let url = URL(string: videoFileURLString)
            let asset = AVURLAsset(url: url!)
            let playerItem = AVPlayerItem(asset: asset)
            let player = AVPlayer(playerItem: playerItem)

            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            player.play()
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
    //        // to overcome .stalled state
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
    //            playerViewController.player!.play()
    //        })
    }
}

extension  VideoCVsVC: Add_jobCandidates_Delegate{
    func Add_jobCandidates_ResponseSuccess(id: Int) {
        print("Success", id)
        self.delegate?.setJobTitle(broadcastID: self.broadcastData.broadcast)
        DispatchQueue.main.async {
            Utilities.hide_ProgressHud(view: self.view)
            
            let alert = UIAlertController(title: "", message: "You have successfully applied with your chosen video", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.closeView()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func Add_jobCandidates_ResponseError(error: NSError) {
        print(error)
    }
    
}
extension VideoCVsVC: AddUpdateVideo_Protocol {
    func updatedResponse(isSuccess: Bool , error: String, id: Int)
    {
        print("Broadcast created with", id)
        
        DispatchQueue.main.async {
            let messageToast = Toast(text: "New CV created", duration: Delay.short)
            messageToast.show()
            self.viewAddVideoCV.isHidden = true
            self.tfCVTitle.text = ""
            self.getVideoCVs_Data()
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
       /* if self.isFromHome{
            Utilities.show_ProgressHud(view: self.view)
        
            let jobCandidate = JobCandidates()
            jobCandidate.broadcast = self.broadcastData.broadcast
            jobCandidate.broadcastid = self.broadcastData.id
            jobCandidate.videocvid = id
            jobCandidate.username = CurrentUser.get_User_username_fromUserDefaults()
            self.submitVideoCV_Data(jobcandidate: jobCandidate)
        }*/
    }
}

extension VideoCVsVC: RemoveVideoCVDelegate {
    func removeVideoCVResponse()
    {
        self.getVideoCVs_Data()
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func removeVideoCV_Error(_ error: String)
    {
        print(error)
    }

}
