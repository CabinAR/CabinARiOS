//
//  LoginViewController.swift
//  CabinAR
//
//  Created by Pascal Rettig on 3/27/19.
//  Copyright © 2019 Pascal Rettig. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        errorLabel.isHidden = true
    }
    

    @IBAction func clickLogin(_ sender: Any) {
        loginButton.titleLabel?.text = "Logging in..."
        CabinARApi.api.performLogin(email: emailField.text!,
                                   password: passwordField.text!) { result, errorMessage, userInfo in
                                    if result {
                                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                        appDelegate.setUser(userInfo!)
                                       self.navigationController?.popViewController(animated: true)
                                    } else {
                                        self.loginButton.titleLabel?.text = "Login"
                                        self.errorLabel.text = errorMessage
                                        self.errorLabel.isHidden = false
                                    }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
