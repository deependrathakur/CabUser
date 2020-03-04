//
//  ViewController.swift
//  Test
//
//  Created by Harshit on 25/02/20.
//  Copyright © 2020 Deependra. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var txtEmailPhone:UITextField!
    @IBOutlet weak var txtPassword:UITextField!
    @IBOutlet weak var btnLogin:UIButton!
    @IBOutlet weak var btnRegister:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

//MARK: - System Method extension
extension LoginVC {
    override func viewWillAppear(_ animated: Bool) {
    }
}

//MARK: - Button Method extension
fileprivate extension LoginVC {
    
    @IBAction func loginAction(sender: UIButton) {
        self.view.endEditing(true)
        if self.txtEmailPhone.isEmptyText() {
            self.txtEmailPhone.shakeTextField()
        } else if !self.txtEmailPhone.isValidateEmail() {
            showAlertVC(title: kAlertTitle, message: InvalidEmail, controller: self)
        } else if self.txtPassword.isEmptyText() {
            self.txtPassword.shakeTextField()
        } else {
            let sb: UIStoryboard = UIStoryboard(name: homeStoryBoard, bundle:Bundle.main)
            let vcNew = sb.instantiateViewController(withIdentifier: "HomeNav") as? UINavigationController
             UIApplication.shared.keyWindow?.rootViewController = vcNew
        }
    }
    
    @IBAction func registeredAction(sender: UIButton) {
        self.view.endEditing(true)
        goToNextVC(storyBoardID: mainStoryBoard, vc_id: registerVC, currentVC: self)
    }
    
    @IBAction func forgotAction(sender: UIButton) {
        self.view.endEditing(true)
        goToNextVC(storyBoardID: mainStoryBoard, vc_id: otpVC, currentVC: self)
    }
}
