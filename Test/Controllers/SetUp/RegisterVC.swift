//
//  RegisterVC.swift
//  Test
//
//  Created by Harshit on 26/02/20.
//  Copyright © 2020 Deependra. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class RegisterVC: UIViewController,CountryCodeDelegate,AuthUIDelegate {
    
    @IBOutlet weak var txtFullName:UITextField!
    @IBOutlet weak var txtEmail:UITextField!
    @IBOutlet weak var txtMobile:UITextField!
    @IBOutlet weak var txtPassword:UITextField!
    @IBOutlet weak var indicator:UIActivityIndicatorView!
    @IBOutlet weak var btnLogin:UIButton!
    @IBOutlet weak var btnRegister:UIButton!
    @IBOutlet weak var btnCountryCode:UIButton!

    let db = Firestore.firestore()
    func onSelectCountry(countryCode: String) {
        self.btnCountryCode.setTitle(countryCode, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.indicator.isHidden = true
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
    
    @IBAction func countruCodeAction(sender: UIButton) {
        self.view.endEditing(true)
         let vc = UIStoryboard.init(name: mainStoryBoard, bundle: Bundle.main).instantiateViewController(withIdentifier: "CountryCodeVC") as? CountryCodeVC
        vc?.delegat = self
        self.present(vc ?? CountryCodeVC(), animated: true, completion: nil)
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
          //  self.phoneVarification()
            self.indicator.isHidden = false

            var ref: DocumentReference? = nil
            let mobileNo = (self.btnCountryCode.currentTitle ?? "+91") + (self.txtMobile.text ?? "")
            let dict = [ "created":Date(),
                         "email": self.txtEmail.text ?? "",
                         "mobile": mobileNo,
                         "mobileVerity": false,
                         "emailVerify": false,
                         "otp": "1234",
                         "password": self.txtPassword.text ?? "",
                         "userType": 1,
                         "wallet": 0,
                         "name": self.txtFullName.text ?? ""] as [String : Any]
            self.phoneVarification(mobile: mobileNo,Dict: dict)
        }
    }
     
    func phoneVarification(mobile: String,Dict: [String:Any]) {
        self.indicator.isHidden = true
        PhoneAuthProvider.provider().verifyPhoneNumber(mobile, uiDelegate: self) { (verificationID, error) in
            if ((error) != nil) {
                  // Verification code not sent.
                  print(error)
            } else {
                  UserDefaults.standard.set(verificationID, forKey: "firebase_verification")
                  UserDefaults.standard.synchronize()
                if let vc = UIStoryboard.init(name: mainStoryBoard, bundle: Bundle.main).instantiateViewController(withIdentifier: otpVC) as? OTPVC {
                    vc.userDict = Dict
                  self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
