//
//  YouTubeURLPopup.swift
//  SimX
//
//  Created by Hashmi on 29/03/2022.
//  Copyright © 2022 Agilio. All rights reserved.
//

import UIKit
import Toaster

class YouTubeURLPopup: UIViewController {

    
    
    @IBOutlet weak var youtubeImg: UIImageView!
    
    @IBOutlet weak var youtubeLbl: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var urlTf: UITextField!
    @IBAction func cancelBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func okBtn(_ sender: Any) {
        if urlTf.text?.isEmpty == true{
            Toast(text: "Past your link").show()
        }else{
            callback?(urlTf.text ?? "")
            dismiss(animated: true, completion: nil)
        }
    }
    var callback : ((String) -> Void)?
    var url = ""
    var checkYouTube = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        if checkYouTube == "YES"{
            youtubeLbl.text = "Add a Jobsite Link"
        }else{
            youtubeLbl.text = "Add a youtube Link"
        }
        urlTf.text = url
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainView.layer.cornerRadius = 5.0
    }

}
