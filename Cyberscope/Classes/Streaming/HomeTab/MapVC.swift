//
//  MapVC.swift
//  CyberScope
//
//  Created by Saad Furqan on 05/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import AVKit
import Toaster

class MapVC: UIViewController, VideosDetailsDelegate, UITextFieldDelegate
{
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var button_sideMenu: UIButton!
    @IBOutlet weak var textfield_search: UITextField!
    
    @IBOutlet weak var googleMapsView: GMSMapView!
    @IBOutlet weak var button_createStream: UIButton!
    
    var searchTimer: Timer?
    var isSearching = false
    
    var lat = 52.520736
    var long = 13.409423
    var zoomLevel: Float = 1.0
    
    var streamsArray : [COVideo] = []
    
    var currentUser = User()
    var selectedStream: COVideo?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        if (CurrentUser.Current_UserObject.skills == Constants.userSkillsType.viewer) {
            self.button_createStream.isHidden = true
        }
        else  {
            self.button_createStream.isHidden = true
        }
        
        self.textfield_search.placeholder = "Search for a broadcaster, topic or location" // "Search location"
        
        self.textfield_search.delegate = self
        self.textfield_search.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        // Do any additional setup after loading the view.
        self.setupControls()
        self.getAllStreamsFromDFInstance()
        
        self.currentUser = CurrentUser.Current_UserObject
    }

    func getAllStreamsFromDFInstance ()
    {
        let sessionObject = DataAccess.sharedInstance
        sessionObject.getAllBroadcastsOfSystem(self as VideosDetailsDelegate)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .black
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) { }
    
    func setupControls()
    {
        self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView.delegate = self
        
        self.topView.setBorders(cornerRadius: 0.0, borderWidth: 0.5, borderColor: Constants.Colors.lightBorderColor_forCollectionCELLS.cgColor)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.showMarkers()
        })
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (CurrentUser.Current_UserObject.skills == Constants.userSkillsType.viewer) {
            self.button_createStream.isHidden = true
        }
        else  {
            self.button_createStream.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playThisVideoInPlayer(videoFileURLString: String, videoTitle: String = "", broadcastID: Int, viewerCount: Int) {
        print("about to launch With Player with : \(videoFileURLString)")
        if let url = URL(string: videoFileURLString){
            
            let player = AVPlayer(url: url)
            let vc = AVPlayerViewController()
            vc.player = player
            present(vc, animated: true) {
                vc.player?.play()
            }

        }
        
//        let vc =  UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil).instantiateViewController(withIdentifier: "playerVC") as! playerVC
//        vc.videoUrl = url!
//        vc.videoTitle = videoTitle
//        vc.broadcastID = broadcastID
//        vc.viewerCount = viewerCount
//        vc.modalPresentationStyle = .fullScreen
//         self.present(vc, animated: true, completion: nil)
        // self.navigationController?.pushViewController(vc, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == Constants.Segues.Map_To_MapDetailVC) {
            let viewController = segue.destination as! MapDetailVC
            viewController.selectedStream = self.selectedStream
        }
        

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func moveTo_RootVC()
    {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func moveBack()
    {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func button_sideMenu_Action(_ sender: Any)
    {
        self.moveBack()
    }
    
    @IBAction func button_createStream_Action(_ sender: Any)
    {
        self.performSegue(withIdentifier: Constants.Segues.MapVC_to_CreateStreamVC, sender: self)
    }
    
    //:- ****************
    func showMarkers()
    {
        self.googleMapsView.clear()
        self.googleMapsView.isMyLocationEnabled = true
        
        DispatchQueue.main.async { () -> Void in
            
            for i in 0..<self.streamsArray.count
            {
                let stream = self.streamsArray[i]
                
                print(stream)
                
                let latti = Double(stream.latti) ?? 0.0
                let longi = Double(stream.longi) ?? 0.0
                
                let position = CLLocationCoordinate2DMake(latti, longi)
                print(position)
                
                if(i == (self.streamsArray.count - 1) && self.isSearching) {
                    let camera = GMSCameraPosition.camera(withLatitude: position.latitude, longitude: position.longitude, zoom: self.zoomLevel)
                    self.googleMapsView.animate(to: camera)
                }
                
                let markerView = UIView()
                markerView.frame.size.height = (self.view.frame.size.height * 0.070)
                markerView.frame.size.width  = (self.view.frame.size.width * 0.099)
                markerView.backgroundColor   = UIColor.clear
                
                var imgName = Constants.imagesName.simpleMapMarker_offline
             /*   if(stream.status == "online") {
                    imgName = Constants.imagesName.simpleMapMarker_online
                }
                else {
                    imgName = Constants.imagesName.simpleMapMarker_offline
                }*/
                
                let imgCentralPIN = UIImageView(image: UIImage(named: imgName)!)
                imgCentralPIN.contentMode = UIViewContentMode.scaleAspectFit
                imgCentralPIN.isUserInteractionEnabled = true
                imgCentralPIN.frame = CGRect(x: 0, y: 0, width: markerView.frame.size.width, height: markerView.frame.size.height)
                
//                let count = UILabel()
//                count.textAlignment = .center
//                count.font = UIFont(name: "Raleway-Bold", size: 13) ?? UIFont.systemFont(ofSize: 13)
//                count.minimumScaleFactor = 0.5
//                count.textColor = UIColor.white
//                count.text = "\(i)"
//                count.frame.origin.x = 0
//                count.frame.origin.y = 0
//                count.frame.size.width = imgCentralPIN.frame.size.width
//                count.frame.size.height = imgCentralPIN.frame.size.height * 0.75
//                count.isUserInteractionEnabled = true
                
                markerView.addSubview(imgCentralPIN)
//                markerView.addSubview(count)
                
                let marker = GMSMarker(position: position)
                marker.iconView = markerView
                marker.title = stream.title
                marker.map = self.googleMapsView
                marker.userData = stream
            }
        }
    }
    
    // MARK: - TextField Delegate
    
    @objc func textFieldDidChange(_ textField: UITextField?) {
        // reset the search timer whenever the text field changes
        // if a timer is already active, prevent it from firing
        if self.searchTimer != nil {
            self.searchTimer?.invalidate()
            self.searchTimer = nil
        }
        if (textfield_search.text == nil || textfield_search.text == "") {
            self.isSearching = false // update the check if user us searching or not
             self.getAllStreamsFromDFInstance()
            return
        }
        else {
            self.isSearching = true // update the check if user us searching or not
        }
       
        // reschedule the search: in 2.0 second, call the searchForKeyword: method on the new textfield content
        searchTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.search(forKeyword:)), userInfo: self.textfield_search.text, repeats: false)
    }
    
    @objc func search(forKeyword timer: Timer?) {
        // retrieve the keyword from user info
        let keyword = timer?.userInfo as? String
        if keyword!.count > 0 {
            self.searchOutVideosWith(text: keyword!)
        }
        else
        {
            self.getAllStreamsFromDFInstance()
        }
        
        // perform your search (stubbed here using NSLog)
        print("Searching for keyword \(keyword ?? "")")
    }
    
    func searchOutVideosWith(text: String) {
        
        self.view.endEditing(true)
        Utilities.show_ProgressHud(view: self.view)
        
        let sessionObject = DataAccess.sharedInstance
        sessionObject.filterBroadcastsForMapWithThisText(self, searchString: text)
    }
//
//    // MARK: - unwindSegue to MapVC
//    @IBAction func unwindSegue(segue: UIStoryboardSegue) {}
    
}

extension MapVC: GMSMapViewDelegate
{
    //MARK: Map delegate functions
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition)
    {
       // print("\n did Change Position:- \(position)\n")
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition)
    {
        print("\n idle At Postion:- \(position)\n")
      //  mapView.selectedMarker = myGMSMarker
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool
    {
        mapView.selectedMarker = marker
        if let data = marker.userData
        {
            let stream: COVideo = data as! COVideo
            print("\n Successfully extract stream data from MARKER ... \n Stream name = \(stream.name) && username = \(stream.username) \n")
            
            print(stream.videourl)
            
            if stream.videourl.contains(find: "https://youtu"){
                let videoId = stream.videourl.youtubeID
                let vc = storyboard?.instantiateViewController(withIdentifier: "YouTubeVideoPlayer") as? YouTubeVideoPlayer
                vc!.youTubeId = videoId ?? ""
                vc!.titleStr = stream.title
                vc!.modalPresentationStyle = .fullScreen
                present(vc!, animated: false, completion: nil)
            }else{
                var videoURLString = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if stream.isJob && self.currentUser.skills == Constants.userSkillsType.client{
                        self.selectedStream = stream
                        self.performSegue(withIdentifier: Constants.Segues.Map_To_MapDetailVC, sender: self)
                    }
                    else
                    {
                        if (stream.isOffline) {
                            let videoURLString = "\(Constants.Stream_URLs.videoBaseLink)offlineVideos/\(stream.broadcast).mp4"
                            print("about to launch Player with 8888 : \(videoURLString)")
                            self.playThisVideoInPlayer(videoFileURLString: videoURLString, videoTitle: stream.title, broadcastID: stream.id, viewerCount: stream.viewers)
                        }
                        else
                        {
                            let videoURLString = "\(Constants.Stream_URLs.videoBaseLink)recordedvideos/\(stream.broadcast).mp4"
                            print("about to launch Player with 8888 : \(videoURLString)")
                            self.playThisVideoInPlayer(videoFileURLString: videoURLString, videoTitle: stream.title, broadcastID: stream.id, viewerCount: stream.viewers)
                        }
                    }
                }
            }
            
        }
        else
        {
            print("\n Failed to extract stream data from MARKER !!! \n")
        }
        
        return true
    }
    
    // MARK: - - GetVideosDelegate Methods
    func setVideosRecieved(_ videos: [COVideo])
    {
        
        var filtered1 = videos
        var filteredData = videos
        
        if filtered1[0].jobPostStatus == "Approved"{
            filteredData = filtered1.filter({(ele)-> Bool in
                ele.jobPostStatus.lowercased() == "approved"
                })
            filtered1 = filteredData
        }else{
            print(filtered1)
        }
        
        print(filtered1[0].jobPostStatus)
        
        if self.isSearching {
            
            Utilities.hide_ProgressHud(view: self.view)
            if (videos.count == 0) {
                Toast(text: " No streams found in searched Location ").show()
                return
            }
            
//            let filtered1 = videos[0]
            let latti = Double(filtered1[0].latti) ?? 0.0
            let longi = Double(filtered1[0].longi) ?? 0.0
            
            let position = CLLocationCoordinate2DMake(latti, longi)
            let camera = GMSCameraPosition.camera(withLatitude: position.latitude, longitude: position.longitude, zoom: 7.0)
            
            self.googleMapsView.animate(to: camera)
        //    return
        }
        print("\n setVideosRecieved called ... AND videos count: \(videos.count) \n")
        self.streamsArray.removeAll()
        self.streamsArray = filtered1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.textfield_search.resignFirstResponder()
            self.showMarkers()
        })
    }
    
    func set_n_VideosRecieved(_ videos: [COVideo])
    {
        
    }
    
    func dataAccessError(_ error:NSError?)
    {
        print("\n dataAccessError called ... AND error = \(String(describing: error?.localizedDescription)) \n")
    }
    
}



