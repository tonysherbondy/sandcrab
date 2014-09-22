//
//  SettingsViewController.swift
//  SandCrab
//
//  Created by Nicolas Halper on 9/22/14.
//  Copyright (c) 2014 Sutro Labs. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCloseButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onLogoutButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: { () -> Void in
            // wait until the settings modal is completely removed
            // before we set loggedInUser to nil, so that the timelineViewController can call it's own dismissal
            User.loggedInUser = nil
        })
    }

}
