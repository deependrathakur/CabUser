//
//  OTPVC.swift
//  Test
//
//  Created by Harshit on 27/02/20.
//  Copyright © 2020 Deependra. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class OTPVC: UIViewController {
    
    @IBOutlet weak var lblMobile:UILabel!
    @IBOutlet weak var txtOTP:UITextField!
    @IBOutlet weak var btnVerify:UIButton!
    @IBOutlet weak var indicator:UIActivityIndicatorView!

    var userDict = [String:Any]()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

//MARK: - System Method extension
extension OTPVC {
    override func viewWillAppear(_ animated: Bool) {
        self.indicator.isHidden = true
        self.lblMobile.text = userDict["mobile"] as? String ?? ""
    }
    
}

//MARK: - Button Method extension
fileprivate extension OTPVC {
    
    @IBAction func verifiAction(sender: UIButton) {
        self.view.endEditing(true)
        if self.txtOTP.isEmptyText() {
            self.txtOTP.shakeTextField()
        } else {
            self.verifyCode()
        }
    }
    
    func registerUser() {
        var ref: DocumentReference? = nil
        userDict["mobileVerity"] = true
        userDict["otp"] = self.txtOTP.text ?? ""
        let dict = userDict
        ref = db.collection("user").addDocument(data: dict) { err in
            if let err = err {
                self.indicator.isHidden = true
                print("Error adding document: \(err)")
            } else {
                self.indicator.isHidden = true
                print("Document added with ID: \(ref!.documentID)")
                UserDefaults.standard.set("\(ref!.documentID)", forKey: "userId")
                self.db.collection("user").document("\(ref!.documentID)").updateData(["id":"\(ref!.documentID)","deviceToken":((firebaseToken == "" ? iosDeviceToken : firebaseToken))])
                DictUserDetails = dict
                modelUserDetail = ModelUserDetail.init(Dict: DictUserDetails ?? ["":""])
                UserDefaults.standard.set(true, forKey: "isLogin")
            }
        }
        let sb: UIStoryboard = UIStoryboard(name: homeStoryBoard, bundle:Bundle.main)
        let vcNew = sb.instantiateViewController(withIdentifier: "HomeNav") as? UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = vcNew
    }
    
    func verifyCode() {
        let verificationID = UserDefaults.standard.value(forKey: "firebase_verification")
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID! as! String, verificationCode: self.txtOTP.text ?? "")
        self.indicator.isHidden = false

        Auth.auth().signIn(with: credential) { (response, error) in
            if error == nil {
                self.registerUser()
            } else {
                self.indicator.isHidden = true
                showAlertVC(title: kAlertTitle, message: kErrorMessage, controller: self)
            }
        }
    }
    
    @IBAction func backAction(sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
}
