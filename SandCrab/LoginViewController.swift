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
    }
    // TODO: Only allow known users to log in
    @IBAction func onLogin(sender: AnyObject) {
        let username = loginTextField.text
        if let user = USER_STORE[username] {
            LOGGED_IN_USER = user
            performSegueWithIdentifier("login", sender: self)
        }
    }
}
