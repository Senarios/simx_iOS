//
//  splashVC.swift
//  SimX
//
//  Created by Salman on 07/04/2021.
//  Copyright © 2021 Agilio. All rights reserved.
//

import UIKit

class splashVC: UIViewController {

    var timer = Timer()
    let user = User()
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        
        
      timer = Timer.scheduledTimer(timeInterval: 2.8, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)

        

        
        // Do any additional setup after loading the view.
    }
    

    // called every time interval from the timer
    @objc func timerAction() {
        print("flow123Timer Call")
        timer.invalidate()
        
        print(user)
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BoardingViewController") as? BoardingViewController
        vc?.modalPresentationStyle = .fullScreen
        self.present(vc! , animated: true , completion: nil )
    }

}
