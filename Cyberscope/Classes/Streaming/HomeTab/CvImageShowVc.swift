//
//  CvImageShowVc.swift
//  SimX
//
//  Created by Hashmi on 21/04/2022.
//  Copyright © 2022 Agilio. All rights reserved.
//

import UIKit

class CvImageShowVc: UIViewController {

    @IBOutlet weak var cvImageView: UIImageView!
    
    @IBOutlet weak var okBtn: UIButton!
    
    @IBAction func okBtn(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    var url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(url)
        
//        if let url = URL(string:url){
//             cvImageView.load(url: url)
//           }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        okBtn.layer.cornerRadius = 10.0
        okBtn.clipsToBounds = true
    }
    

 

}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
