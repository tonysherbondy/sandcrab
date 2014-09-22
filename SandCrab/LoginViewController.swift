//
//  LoginViewController.swift
//  SandCrab
//
//  Created by Anthony Sherbondy on 9/16/14.
//  Copyright (c) 2014 Sutro Labs. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = User.loggedInUser {
            println("Welcome back : \(currentUser.username)")
            
            // need to put a delay on...since view controller can't segue
            // until after viewDidLoad...
            Tools.delay(0.1, { _ in
                self.performSegueWithIdentifier("login", sender: self)
            })
        }
        
    }
    // TODO: Only allow known users to log in
    @IBAction func onLogin(sender: AnyObject) {
        println("LoginViewController:onLogin")
        let username = loginTextField.text
        if let user = User.allUsers[username] {
            User.loggedInUser = user
            performSegueWithIdentifier("login", sender: self)
        } else {
            UIAlertView(title: "MERP!", message: "Check the logs...", delegate: nil, cancelButtonTitle: "Try again...").show()
            println("Non-authenticated user: for now just use 'tony', 'nick', or 'joey' as user no pass needed")
        }
    }
}
