//
//  FAQsViewController.swift
//  Cyberscope
//
//  Created by Salman on 06/09/2018.
//  Copyright © 2018 Agilio. All rights reserved.
//

import UIKit

class FAQsViewController: UIViewController {

    @IBOutlet weak var mTextView: UITextView!
    
    @IBAction func dismissButtonClicked(_ sender: UIButton) {
        if (self.navigationController != nil) {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true, completion:nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mTextView.setContentOffset(.zero, animated: true)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
