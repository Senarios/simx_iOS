//
//  CustomYoutubeVc.swift
//  SimX
//
//  Created by Hashmi on 12/05/2022.
//  Copyright © 2022 Agilio. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView

class CustomYoutubeVc: UIViewController {

    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBOutlet weak var youTubeplayer: WKYTPlayerView!
    
    var youTubeId = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        youTubeplayer.playVideo()
        youTubeplayer.load(withVideoId: youTubeId)
    }
    
}
