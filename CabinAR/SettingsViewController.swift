//
//  SettingsViewController.swift
//  CabinAR
//
//  Created by Pascal Rettig on 3/27/19.
//  Copyright © 2019 Pascal Rettig. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var cabinKeyInput: UITextField!
    
    @IBOutlet weak var loginView: UIStackView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cabinKeyField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var loggedInView: UIStackView!
    @IBOutlet weak var currentUserLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let layer = aboutView.layer
                
        layer.cornerRadius = 30
        layer.maskedCorners = [ .layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        errorLabel.isHidden = true
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if(appDelegate.userInfo != nil) {
            showUser()
        } else {
            showLogin()
        }
    }
    
    func showUser() {
        loginView.isHidden = true
        loggedInView.isHidden = false
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let userInfo = appDelegate.userInfo {
            currentUserLabel.text = userInfo.email
        } else {
            currentUserLabel.text = "Unknown"
        }
    }
    
    func showLogin() {
        loginView.isHidden = false
        loggedInView.isHidden = true
        errorLabel.isHidden = true

    }
    
    @IBAction func clickLogout(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.userInfo = nil
        appDelegate.reloadScene = true
        CabinARApi.api.userToken = nil
        showLogin()
    }
    
    @IBAction func clickLogin(_ sender: Any) {
        loginButton.titleLabel?.text = "Logging in..."
        CabinARApi.api.performLogin(api_key: cabinKeyField.text!) { result, errorMessage, userInfo in
            if result {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.setUser(userInfo!)
                appDelegate.reloadScene = true
                self.showUser()
                //self.navigationController?.popViewController(animated: true)
            } else {
                self.loginButton.titleLabel?.text = "Login"
                self.errorLabel.text = errorMessage
                self.errorLabel.isHidden = false
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //if(appDelegate.userInfo != nil) {
        //    self.currentUserLabel.text! = appDelegate.userInfo!.email
        //} else {
        //    self.currentUserLabel.text! = "No current user"
       // }
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
