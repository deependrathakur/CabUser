//
//  RegisterVC.swift
//  Test
//
//  Created by Harshit on 26/02/20.
//  Copyright © 2020 Deependra. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController {
    
    @IBOutlet weak var txtFullName:UITextField!
    @IBOutlet weak var txtEmail:UITextField!
    @IBOutlet weak var txtMobile:UITextField!
    @IBOutlet weak var txtPassword:UITextField!
    
    @IBOutlet weak var btnLogin:UIButton!
    @IBOutlet weak var btnRegister:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

//MARK: - System Method extension
extension RegisterVC {
    override func viewWillAppear(_ animated: Bool) {
    }
}

//MARK: - Button Method extension
fileprivate extension RegisterVC {
    
    @IBAction func loginAction(sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func registeredAction(sender: UIButton) {
        self.view.endEditing(true)
        if self.txtFullName.isEmptyText() {
            self.txtFullName.shakeTextField()
        } else if self.txtEmail.isEmptyText() {
            self.txtEmail.shakeTextField()
        } else if !self.txtEmail.isValidateEmail() {
            showAlertVC(title: kAlertTitle, message: InvalidEmail, controller: self)
        } else if self.txtMobile.isValidateEmail() {
            self.txtMobile.shakeTextField()
        } else if self.txtPassword.isValidateEmail() {
            self.txtPassword.shakeTextField()
        } else {
            let sb: UIStoryboard = UIStoryboard(name: homeStoryBoard, bundle:Bundle.main)
            let vcNew = sb.instantiateViewController(withIdentifier: "HomeNav") as? UINavigationController
             UIApplication.shared.keyWindow?.rootViewController = vcNew
        }
    }
}
