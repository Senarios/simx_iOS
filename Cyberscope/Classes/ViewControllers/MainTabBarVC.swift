//
//  MainTabBarVC.swift
//  CyberScope
//
//  Created by Saad Furqan on 05/04/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit

class MainTabBarVC: UITabBarController {

    let user = User()
    override func viewDidLoad() {
        super.viewDidLoad()

        print(user.name)
        // Do any additional setup after loading the view.
        self.selectedIndex = 1
        self.check_connectionTo_QB_Chat()
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)
    {
        self.check_connectionTo_QB_Chat()
    }

    func check_connectionTo_QB_Chat()
    {
        DispatchQueue.main.async
        {
            AppDelegate.shared_instance.check_and_login_to_QBChat()
        }
    }
}
