//
//  ViewController.swift
//  StreamaxiaDemo2
//
//  Created by Roland Tolnay on 9/21/16.
//  Copyright © 2016 Streamaxia. All rights reserved.
//

import UIKit
import StreamaxiaSDK
import AVFoundation

// Modify this to your desired stream name
// Playback will be available at play.streamaxia.com/<your-stream-name>
/// View controller that displays some basic UI for capturing and streaming
/// live video and audio media.
class ViewController: UIViewController {
    
    // MARK: - Private Constants -
    
    fileprivate let kStartButtonTag: NSInteger = 0
    
    fileprivate let kStopButtonTag: NSInteger = 1
    
    // MARK: - Private Properties -
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var rightLabel: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var recorderView: UIView!
    
    @IBOutlet weak var overlayView: UIView!
    
    @IBOutlet weak var titleTextContainer: UIView!
    @IBOutlet weak var broadcastTitleField: UITextField!
    var nameForVideo = ""
    
    /// The recorder
    fileprivate var recorder: AXRecorder!
    
    /// The stream info
    fileprivate var streamInfo: AXStreamInfo!
    
    /// The recorder settings
    fileprivate var recorderSettings: AXRecorderSettings!
    
    var videoObject = COVideo()
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "StreamaxiaSDK Demo"
        
        self.nameForNewStreamVideoObject()
        LiveStreamingViewController.kStreamaxiaStreamName = self.nameForVideo
        self.setupUI()
        self.setupStreamaxiaSDK()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.recorder.isActive {
            self.recorder.stopStreaming()
        }
    }
    
    // MARK: - Public methods -
    
    // MARK: - Actions -
    
    @IBAction func startButtonPressed(_ button: UIButton) {
        print("*** DEMO *** Recorder button pressed.")
        
        if (self.broadcastTitleField.text == nil || self.broadcastTitleField.text == "") {
            
            self.showAlert("Alert", message: "Please put a title for new broadcast.")
            return;
        }
        else if ((self.broadcastTitleField.text?.characters.count)! < 3) {
            self.showAlert("Title Strength", message: "Too short.")
            return;
        }
        else {
            self.titleTextContainer.isHidden = true
        }
        //self.nameForNewStreamVideoObject()
        self.streamInfo.customStreamURLString = "\(Constants.Stream_URLs.liveStreamBrodacsterUrl)\(videoObject.broadcast)"
        
        if (self.recorder == nil) {
            print("*** DEMO *** The recorder was not properly initialized.")
            return;
        }
        
        if (button.tag == self.kStartButtonTag) {
            print("*** DEMO *** START button pressed.")
            
            self.addNewStreamVideoObject()
            self.checkOrientation()
            
            self.recorder.startStreaming(completion: { (success, error) in
                print("*** DEMO *** The stream started with success: %@", success ? "YES" : "NO")
                if (success) {
                    DispatchQueue.main.async {
                        self.startButton.tag = self.kStopButtonTag
                        self.startButton.setTitle("Stop", for: .normal)
                    }
                } else {
                    print("*** DEMO *** Error: %@", error ?? "")
                }
            })
        }
        else if (button.tag == self.kStopButtonTag) {
            print("*** DEMO *** STOP button pressed.")
            
            videoObject.status = Constants.VideoStatus.offline
            
            let shSingeltonObject = DataAccess.sharedInstance
            shSingeltonObject.addOrUpdateVideo(videoObject, delegate: self as AddUpdateVideo_Protocol)
            
            self.startButton.tag = self.kStartButtonTag
            self.startButton.setTitle("Start", for: .normal)
            self.recorder.stopStreaming()
            self.updateLabel(time: 0.0)
        }
    }
}

// MARK: - Private methods -

fileprivate extension ViewController {
    //#pragma mark - Private methods
    
    fileprivate func defaultStreamInfo() -> AXStreamInfo {
        let info = AXStreamInfo.init()
        info.useSecureConnection = false
        
        info.customStreamURLString = "\(Constants.Stream_URLs.liveStreamBrodacsterUrl)\(LiveStreamingViewController.kStreamaxiaStreamName)"
        
//      // Alternatively you can split the URL into its corresponding RTMP parts
//      info.serverAddress = "rtmp.streamaxia.com"
//      info.applicationName = "streamaxia"
//      info.streamName = kStreamaxiaStreamName;
        
        info.username = "" //"cryout"
        info.password = "" //"Salman101"
        
        return info
    }
    
    fileprivate func defaultRecorderSettings() -> AXRecorderSettings {
        let utils = AXUtils.init()
        let settings = AXRecorderSettings.init()
        
        settings.videoFrameResolution = .standard1080p
        settings.videoBitrate = utils.bitrate(for: settings.videoFrameResolution)
        settings.keyFrameInterval = Int(0.5 * Double(settings.frameRate))
        
        return settings
    }
    
    fileprivate func setupStreamaxiaSDK() {
        let sdk = AXStreamaxiaSDK.sharedInstance()!
        
                // Load the configuration certificate from the main bundle, standard URL
        
                // NOTE: the .config and .key must be added to the project, with the name unchanged
                sdk.setupSDK(completion: { (success, error) in
                    print("*** Streamaxia SDK *** Setup was completed with success: %@ \n*** error: %@", success ? "YES" : "NO", error ?? "")
        
                    // Printing StreamaxiaSDK status
                    sdk.debugPrintStatus()
        
                    if (success) {
                        DispatchQueue.main.async {
                            self.setupStreaming()
                        }
                    }
                })
        
//        // Alternatively, a custom bundle can be used to load the certificate:
//        let bundleURL = Bundle.main.url(forResource: "demo-certificate", withExtension: "bundle")
//        let bundle = Bundle.init(url: bundleURL!)
//
//        sdk.setupSDK(with: bundle?.bundleURL) { (success, error) in
//            sdk.debugPrintStatus()
//
//            if (success) {
//                DispatchQueue.main.async {
//                    self.setupStreaming()
//                }
//            }
//        }
    }
    
    fileprivate func setupStreaming() {
        self.streamInfo = self.defaultStreamInfo()
        self.recorderSettings = self.defaultRecorderSettings()
        
        if let recorder = AXRecorder.init(streamInfo: self.streamInfo, settings: self.recorderSettings) {
            recorder.recorderDelegate = self
            recorder.setup(with: self.recorderView)
            recorder.prepareToRecord()
            
            var error: AXError?
            
            // Enable adaptive bitrate
            // Video quality will be adjusted based on available network and hardware resources
            recorder.activateFeatureAdaptiveBitRateWithError(&error)
            if error != nil {
                print("*** ERROR activating feature adaptive bitrate: \(error!.message)")
                error = nil
            }
            
//            // Enable local save
//            // The broadcast will be saved to the users camera roll when finished
//            recorder.activateFeatureSaveLocallyWithError(&error)
//            if error != nil {
//                print("*** ERROR activating feature save locally: \(error!.message)")
//            }
            
            self.recorder = recorder
        }
        
        // Printing some debug info about the initialiation settings
        let debugRecorderSettings = AXDebug.init().string(from: self.recorderSettings)
        let debugStreamInfo = AXDebug.init().string(from: self.streamInfo)
        
        print("*** DEMO **** Did set up the recorder with the following settings:\n%@\n%@", debugRecorderSettings!, debugStreamInfo!)
    }
    
    fileprivate func updateLabel(time: TimeInterval) {
        let t = Int(time)
        let s = t % 60
        let m = (t / 60) % 60
        let h = t / 3600
        
        let text = String.init(format: "T: %.2ld:%.2ld:%.2ld", Int(h), Int(m), Int(s))
        
        DispatchQueue.main.async {
            self.rightLabel.text = text
        }
    }
    
    fileprivate func checkOrientation() {
        let currentOrientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
        var error: AXError? = nil
        if currentOrientation == .portrait {
            recorder.changeResolutionInversion(true, withError: &error)
        } else if currentOrientation != .portraitUpsideDown {
            recorder.changeResolutionInversion(false, withError: &error)
        }
        if error != nil {
            // Handle error
        }
    }
    
    func nameForNewStreamVideoObject() {
        var ticks = NSDate().timeIntervalSince1970
        ticks = ticks * 10000
        let nameForNewVideo     = String(format: "%10.0f", ticks)
        let uniqueVideoName     = nameForNewVideo
        self.nameForVideo = uniqueVideoName
        // -> goCoder?.config.streamName = kStreamaxiaStreamName
    }
    
    func addNewStreamVideoObject()
    {
        videoObject.id = -1
        videoObject.name = "My Name"
        videoObject.broadcast = "DEVilEtdPT1495012303"
        videoObject.arn = "MySampleArn21200212"
        videoObject.imglink = self.nameForVideo
        videoObject.status = Constants.VideoStatus.online
        videoObject.viewers = 0
        videoObject.time = "2017-05-17 09:11:47"
        videoObject.skill = "abc"
        videoObject.latti = "22.00"
        videoObject.longi = "74.00"
        videoObject.title = self.broadcastTitleField.text!
        videoObject.username = "Pakistani101"
        videoObject.location = "Lahore"
        
        //videoObject.asJSON()
        let shSingeltonObject = DataAccess.sharedInstance
        shSingeltonObject.addOrUpdateVideo(videoObject, delegate: self as AddUpdateVideo_Protocol)
    }
    
    // MARK: - Thumbnail-Image Handling Methods
    
    func image(with view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        if let aContext = UIGraphicsGetCurrentContext() {
            view.layer.render(in: aContext)
        }
        self.recorder.currentCamera
        let img: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img ?? UIImage()
    }

    
    func takeSnapshotAndLoadItToServer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
            // Your code with delay
            //let screenshot = self.recorderView.screenShot
        
            let screenshot = self.image(with: self.recorderView)
            self.postThumbNailImage(imageData: screenshot)
        }
    }
    
    func postThumbNailImage(imageData: UIImage) {
        
        //let imageData = self.convert(cmage: image)
        let image_data = self.compressImage(imageData)
        let image : String = (image_data.base64EncodedString())
        var name : String = "abc" + self.nameForVideo
        name = name + ".png"
        
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
            }
            else
            {
                Alert.showOfflineAlert()
                print("\n\nERROR !!! NO INTERNET CONNECTION...DATA IS NIL")
            }
        })
        task.resume()
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    func compressImage (_ image: UIImage) -> Data {
        
        //        let actualHeight:CGFloat = image.size.height
        //        let actualWidth:CGFloat = image.size.width
        //        let imgRatio:CGFloat = actualWidth/actualHeight
        //        let maxWidth:CGFloat = 180.0
        //        let resizedHeight:CGFloat = maxWidth/imgRatio
        let compressionQuality:CGFloat = 0.5
        
        let rect:CGRect = CGRect(x: 0, y: 0, width: 100, height: 80)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        let imageData:Data = UIImageJPEGRepresentation(img, compressionQuality)!//! as Data
        return imageData
    }
}


extension ViewController : AddUpdateVideo_Protocol {
    //MARK: - New BroadCast Handling
    
    func updatedResponse(isSuccess: Bool , error: String, id: Int)
    {
        
        DispatchQueue.main.async {
            //MBProgressHUD.hide(for: self.view, animated: true)
        }
        //broadcastButton.isEnabled    = true
        
        if isSuccess
        {
            if videoObject.status == Constants.VideoStatus.offline//"offline"
            {
                //self.goCoder?.cameraPreview?.stop()
                //self.receivedGoCoderEventCodes.removeAll()
                //self.stopBroadcastTimer()
                
                //self.performSegue(withIdentifier: "backToPlayList", sender: nil)
                self.navigationController?.popViewController(animated: true)
            }
            else {
                if id != 0 && videoObject.id == -1
                {
                    videoObject.id = id
                    //self.startStreaming()
                    print("Streaming Started with videoId = \(videoObject.id)")
                    //self.startBroadcastTimer()
                    
                    //self.takeSnapshotAndLoadItToServer()
                }
                else
                {
                    print("Object Creation Error")
                }
            }
        }
        else
        {
            print("isSuccess : ", isSuccess)
            //returnButton.isEnabled = true
            //let messageToast = Toast(text: "Failed To Create New BroadCast, Please Check Your Connection and retry in a moment!", duration: Delay.short)
            //messageToast.show()
            //self.broadcastTitleContainer.isHidden = false
        }
    }
    
    func startStreaming() {
        
        //    receivedGoCoderEventCodes.removeAll()
        //    goCoder?.startStreaming(self)
        //    let audioMuted = goCoder?.isAudioMuted ?? false
        //    micButton.setImage(UIImage(named: audioMuted ? "mic_off_button" : "mic_on_button"), for: UIControlState())
    }
}

// MARK: - AXRecorderDelegate -

extension ViewController: AXRecorderDelegate {
    func recorder(_ recorder: AXRecorder!, didChange state: AXRecorderState) {
        print("*** DEMO *** Recorder State Changed to: \(state)")
        
        var string = "N/A"
        
        switch state {
        case .stopped:
            string = "[Stopped]"
        case .recording:
            string = "[Recording]"
            self.takeSnapshotAndLoadItToServer()
        case .starting:
            string = "[Starting...]"
        case .stopping:
            string = "[Stopping...]"
        case .collectingExtraData:
            string = "[Get Extra Data]"
        case .processingExtraData:
            string = "[Proc. Extra Data]"
        default:
            string = "[Unknown state]"
        }
        
        DispatchQueue.main.async {
            self.leftLabel.text = string
        }
    }
    
    func recorder(_ recorder: AXRecorder!, didUpdateStreamTime deltaTime: TimeInterval) {
        // Show the recording time in the right label
        DispatchQueue.main.async {
            self.updateLabel(time: deltaTime)
        }
    }
    
    func recorder(_ recorder: AXRecorder!, didChange status: AXNetworkStatus) {
        print("*** DEMO *** did change network status: \(status)")
        
        var string = "Unknown network status"
        
        switch status {
        case .notReachable:
            string = "Lost internet connection"
        case .reachableViaWiFi:
            string = "Internet is reachable on wifi"
        case .reachableViaWWAN:
            string = "Internet is reachabale on Cellular"
        }
        
        DispatchQueue.main.async {
            self.infoLabel.text = string
        }
    }
    
    func recorder(_ recorder: AXRecorder!, didReceive info: AXInfo!) {
        print("*** DEMO *** did receive info: %@", info)
    }
    
    func recorder(_ recorder: AXRecorder!, didReceive warning: AXWarning!) {
        print("*** DEMO *** did receive warning: %@", warning)
    }
    
    func recorder(_ recorder: AXRecorder!, didReceiveError error: AXError!) {
        print("*** DEMO *** did receive error: %@", error)
    }
    
    func recorder(_ recorder: AXRecorder!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from captureOutput: AVCaptureOutput!) {
        
//        if videoObject.id == -1 {
//            return
//        }
//        if recorder.isStreaming {
//            var stillImageOutput: AVCaptureStillImageOutput!
//
//            //...Initialize stillImageOutput
//
//            stillImageOutput.captureStillImageAsynchronouslyFromConnection(captureOutput, completionHandler: {(imageSampleBuffer, error) in
//                if imageSampleBuffer {
//                    var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer as CMSampleBuffer) // I get error on this line saying: 'Use of module ' CMSampleBuffer' as a type'
//                    self.processImage(UIImage(data: imageData))
//                }
//            })
//        }
        
// ==============================================================================
//        print("Abc Info")
//        let buff = captureOutput            // Have you have CMSampleBuffer
//        if #available(iOS 10.0, *) {
//            if let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buff as! CMSampleBuffer, previewPhotoSampleBuffer: nil) {
//                let image = UIImage(data: imageData) //  Here you have UIImage
//                if (image != nil) {
//                    print("Image FOUND 8****")
//                }
//            }
//        } else {
//            // Fallback on earlier versions
//            print("for older iOS this feature is  not available")
//        }
    }
}

// MARK: - UI Setup -

fileprivate extension ViewController {
    
    private func infoFont() -> UIFont? {
        return UIFont.init(name: "AvenirNextCondensed-UltraLight", size: 14.0)
    }
    
    private func labelFont() -> UIFont? {
        return UIFont.init(name: "AvenirNextCondensed-Regular", size: 16.0)
    }
    
    private func buttonFont() -> UIFont? {
        return UIFont.init(name: "AvenirNextCondensed-Medium", size: 20.0)
    }
    
    fileprivate func setupUI() {
        self.setupMain()
        self.setupStartButton()
        self.setupLeftLabel()
        self.setupRightLabel()
        self.setupInfoLabel()
    }
    
    private func setupMain() {
        self.recorderView.backgroundColor = UIColor.orange
        self.overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        self.view.backgroundColor = UIColor.lightGray
    }
    
    private func setupStartButton() {
        let button: UIButton = self.startButton!
        
        button.layer.cornerRadius = self.startButton.frame.size.height * 0.5
        button.backgroundColor = UIColor.black
        button.tintColor = UIColor.white
        button.tag = self.kStartButtonTag
        button.titleLabel?.font = self.buttonFont()
        button.setTitle("Start", for: .normal)
    }
    
    private func setupLeftLabel() {
        let label = self.leftLabel!
        
        label.font = self.labelFont()
        label.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        label.text = "[N/A]"
        label.textColor = UIColor.white
    }
    
    private func setupRightLabel() {
        let label = self.rightLabel!
        
        label.font = self.labelFont()
        label.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        label.text = "T: 00:00:00"
        label.textColor = UIColor.white
    }
    
    private func setupInfoLabel() {
        let label = self.infoLabel!
        
        label.font = self.infoFont()
        label.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        label.text = ""
        label.textColor = UIColor.white
    }
    
    func showAlert(_ title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
