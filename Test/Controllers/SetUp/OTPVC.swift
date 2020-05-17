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
        self.checkIfRegistered(currentDict: userDict)
    }
    
    func checkIfRegistered(currentDict: [String:Any]) {
        self.indicator.isHidden = false
        db.collection("user").getDocuments() { (querySnapshot, err) in
            var registeredUser = false
            var userId:String = ""
            if let err = err {
                self.indicator.isHidden = true
                print("Error getting documents: \(err)")
            } else {
                let mobileNo = self.userDict["mibile"] ?? ""
                for document in querySnapshot!.documents {
                    let dict = document.data()
                    let mobileNo = self.userDict["mibile"] as? String ?? ""
                    if (mobileNo == dict["mobile"] as? String ?? "") {
                        registeredUser = true
                        userId = document.documentID
                    }
                }
            }
            if registeredUser, (userId != "") {
                self.indicator.isHidden = true
                UserDefaults.standard.set(true, forKey: "isLogin")
                self.db.collection("user").document(userId).updateData(currentDict)
                modelUserDetail = ModelUserDetail.init(Dict: currentDict)
                UserDefaults.standard.set(userId, forKey: "userId")
                AppDelegate().getUserDetailFromFirebase()
                let sb: UIStoryboard = UIStoryboard(name: homeStoryBoard, bundle:Bundle.main)
                let vcNew = sb.instantiateViewController(withIdentifier: "HomeNav") as? UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = vcNew
            } else {
                var ref: DocumentReference? = nil
                ref = self.db.collection("user").addDocument(data: currentDict) { err in
                    if let err = err {
                        self.indicator.isHidden = true
                        print("Error adding document: \(err)")
                    } else {
                        self.indicator.isHidden = true
                        print("Document added with ID: \(ref!.documentID)")
                        UserDefaults.standard.set("\(ref!.documentID)", forKey: "userId")
                    self.db.collection("user").document("\(ref!.documentID)").updateData(["id":"\(ref!.documentID)","deviceToken":((firebaseToken == "" ? iosDeviceToken : firebaseToken))])
                        DictUserDetails = currentDict
                        modelUserDetail = ModelUserDetail.init(Dict: DictUserDetails ?? ["":""])
                        UserDefaults.standard.set(true, forKey: "isLogin")
                        let sb: UIStoryboard = UIStoryboard(name: homeStoryBoard, bundle:Bundle.main)
                        let vcNew = sb.instantiateViewController(withIdentifier: "HomeNav") as? UINavigationController
                        UIApplication.shared.keyWindow?.rootViewController = vcNew
                    }
                }

            }
        }
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
