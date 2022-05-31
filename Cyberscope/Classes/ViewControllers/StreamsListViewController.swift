//
//  StreamsListViewController.swift
//  CyberScope
//
//  Created by Salman on 08/03/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SDWebImage

class StreamsListViewController: UIViewController, VideosDetailsDelegate, SignInDelegate, UITableViewDelegate, UITableViewDataSource {
//UITableViewDelegate, UITableViewDataSource
    
    static var videoStreamingController: ViewController!
    static var isComingFrom_PlayList_ViewController = false
    static var isPresentVC_PlaylistViewController = false

    let dfUserEmail                 = "abc@xyz.com"
    let dfUserPassword              = "123456"
    
    var streamsArray : [COVideo] = []    //= NSMutableArray()
    
    @IBOutlet weak var streamsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let sessionObject = DataAccess.sharedInstance
        sessionObject.signInWithEmail(dfUserEmail, password: dfUserPassword, signInDelegate: self as SignInDelegate)
        
        streamsTableView.delegate = self
        streamsTableView.dataSource = self
        //self.getStreamsListFromDFInstance()
    }

    // MARK: - - TableView Delegates
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "" //"Related Videos"
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 125.0;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print ("8989898989 total: ", self.streamsArray.count)
        return self.streamsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath.row + 1 <= self.streamsArray.count)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CSStreamCell") as! StreamCell
            
            let objAtIndexPathDotRow = self.streamsArray[indexPath.row] as! COVideo
            let addressStr = String(format:"%@%@.png", Constants.Stream_URLs.baseLinkForStreamThmbNails, objAtIndexPathDotRow.imglink)
            
            print("Image Address : ", addressStr, " at Index: ", indexPath.row)
            cell.streamThumbnailImage.sd_setImage(with: URL(string: addressStr))
            //print("Image Address : ", addressStr, " at Index: ", indexPath.row)
            cell.selectionStyle = .none
            //cell.streamThumbnailImage.image = #imageLiteral(resourceName: "mera_peer")
            cell.streamTitle.text = objAtIndexPathDotRow.title as String
            
            print("\n Streamtitle : ", cell.streamTitle.text, " ", objAtIndexPathDotRow.title as String)
            
            if objAtIndexPathDotRow.status == Constants.VideoStatus.online {
                
            }
            else
            {
                
            }
            return cell
        }
        else
        {
            let cell = UITableViewCell()
            //self.getMore_n_VideosListFromDFInstance(offset: (self.videosArray.count + 1))
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let stream = self.streamsArray[indexPath.row] as! COVideo
        print ("8989898989: ", indexPath.row)
        var videoURLString = ""
        if (stream.status as String == Constants.VideoStatus.offline) {
            
            print("video url 4444", videoURLString)
            let vc =  UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil).instantiateViewController(withIdentifier: Constants.ViewControllers.VODWowzaViewController) as! VODWowzaViewController
            //vc.videoUrlString = videoURLString
            vc.currentVideo = stream
            self.present(vc, animated: true, completion: nil)
        }
        else if (stream.status as String == Constants.VideoStatus.online) {
            let storyboard = UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil)
            let liveViewerViewController = storyboard.instantiateViewController(withIdentifier: "LiveStreamingViewerController") as! LiveStreamingViewerController
            liveViewerViewController.currentVideo = stream
            self.present(liveViewerViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - - GetVideos
    func getStreamsListFromDFInstance ()
    {
        let sessionObject = DataAccess.sharedInstance
        sessionObject.getVideoDetailsList(self as VideosDetailsDelegate)
    }
    
    func getMore_n_StreamsListFromDFInstance(offset: Int)
    {
        print("getMore_n_VideosListFromDFInstance Called... ")
        
        let sessionObject = DataAccess.sharedInstance
        sessionObject.getNext_n_VideoSDetail(self as VideosDetailsDelegate, offset: offset)
    }
    
    // MARK: - - GetVideosDelegate Methods
    func setVideosRecieved(_ videos: [COVideo])
    {
        self.streamsArray = videos
        
        self.streamsTableView.reloadData()
    }
    
    func set_n_VideosRecieved(_ videos: [COVideo])
    {
        
    }
    
    func dataAccessError(_ error:NSError?)
    {
        
    }

    // MARK: - - SignInDelegate Methods
    func userIsSignedInSuccess(_ bSignedIn:Bool, message:String?) {
        
        if (bSignedIn) {
            self.getStreamsListFromDFInstance() // Call hit for Videos List
        }
        else {
            
        }
        print("Signed IN Status : ", bSignedIn, " with message : ", message ?? "null-String_98394")
    }
    
    func userIsSignedOut() {
        print("User is signed Out from the System")
    }
}
