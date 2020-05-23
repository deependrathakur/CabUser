//
//  ViewController.swift
//  Test
//
//  Created by Harshit on 25/02/20.
//  Copyright © 2020 Deependra. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController,CountryCodeDelegate {
    
    @IBOutlet weak var txtEmailPhone:UITextField!
    @IBOutlet weak var txtPassword:UITextField!
    @IBOutlet weak var btnLogin:UIButton!
    @IBOutlet weak var btnRegister:UIButton!
    @IBOutlet weak var btnCountryCode:UIButton!
    @IBOutlet weak var indicator:UIActivityIndicatorView!
    let db = Firestore.firestore()
    var countryCodes = "+91"
    func onSelectCountry(countryCode: String, countryName: String) {
        self.btnCountryCode.setTitle("(\(countryName)) \(countryCode) ▾", for: .normal)
        self.btnCountryCode.setTitleColor(appColor, for: .normal)
        countryCodes = countryCode
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnCountryCode.setTitle("(IND) \(+91) ▾", for: .normal)
        self.btnCountryCode.setTitleColor(appColor, for: .normal)
        countryCodes = "+91"
    }
}

//MARK: - System Method extension
extension LoginVC {
    override func viewWillAppear(_ animated: Bool) {
        self.indicator.isHidden = true
        self.setNavigationRootStoryboard()
    }
}

//MARK: - Button Method extension
fileprivate extension LoginVC {
    
    @IBAction func loginAction(sender: UIButton) {
        self.view.endEditing(true)
        if self.txtEmailPhone.isEmptyText() {
            self.txtEmailPhone.shakeTextField()
        } else if self.txtPassword.isEmptyText() {
            self.txtPassword.shakeTextField()
        } else {
            self.indicator.isHidden = false
            db.collection("user").getDocuments() { (querySnapshot, err) in
                var registeredUser = false
                if let err = err {
                    self.indicator.isHidden = true
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let dict = document.data()
                        let mobileNo = self.countryCodes + (self.txtEmailPhone.text ?? "")
                        if (self.txtPassword.text == dict["password"] as? String ?? "") && ((self.txtEmailPhone.text == dict["email"] as? String ?? "") || (self.txtEmailPhone.text == dict["mobile"] as? String ?? "") || (mobileNo == dict["mobile"] as? String ?? "")) {
                            registeredUser = true
                            DictUserDetails = dict
                            DictUserDetails?["id"] = document.documentID
                            UserDefaults.standard.set(document.documentID, forKey: "userId")
                            self.db.collection("user").document("\(document.documentID)").updateData(["id":"\(document.documentID)","deviceToken":((firebaseToken == "" ? iosDeviceToken : firebaseToken))])
                        }
                    }
                }
                if registeredUser {
                    self.indicator.isHidden = true
                    UserDefaults.standard.set(true, forKey: "isLogin")
                    modelUserDetail = ModelUserDetail.init(Dict: DictUserDetails ?? ["":""])
                    self.setNavigationRootStoryboard()
                } else {
                    self.indicator.isHidden = true
                    showAlertVC(title: kAlertTitle, message: "Please check your login detail", controller: self)
                }
            }
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
    
    @IBAction func countruCodeAction(sender: UIButton) {
        self.view.endEditing(true)
         let vc = UIStoryboard.init(name: mainStoryBoard, bundle: Bundle.main).instantiateViewController(withIdentifier: "CountryCodeVC") as? CountryCodeVC
        vc?.delegat = self
        self.present(vc ?? CountryCodeVC(), animated: true, completion: nil)
    }
    
    func setNavigationRootStoryboard() {
        if UserDefaults.standard.bool(forKey: "isLogin") as Bool == true {
            AppDelegate().getUserDetailFromFirebase()
           let sb: UIStoryboard = UIStoryboard(name: homeStoryBoard, bundle:Bundle.main)
            let vcNew = sb.instantiateViewController(withIdentifier: "HomeNav") as? UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = vcNew
        }
    }
}
