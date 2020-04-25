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

class RegisterVC: UIViewController {
    
    @IBOutlet weak var txtFullName:UITextField!
    @IBOutlet weak var txtEmail:UITextField!
    @IBOutlet weak var txtMobile:UITextField!
    @IBOutlet weak var txtPassword:UITextField!
    @IBOutlet weak var indicator:UIActivityIndicatorView!
    @IBOutlet weak var btnLogin:UIButton!
    @IBOutlet weak var btnRegister:UIButton!
    let db = Firestore.firestore()

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
            let dict = [ "created":Date(),
                         "email": self.txtEmail.text ?? "",
                         "mobile": self.txtMobile.text ?? "",
                         "mobileVerity": false,
                         "emailVerify": false,
                         "otp": "1234",
                         "password": self.txtPassword.text ?? "",
                         "userType": 1,
                         "wallet": 0,
                         "name": self.txtFullName.text ?? ""] as [String : Any]

            ref = db.collection("user").addDocument(data: dict) { err in
                self.indicator.isHidden = true
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    UserDefaults.standard.set("\(ref!.documentID)", forKey: "userId")
                    self.db.collection("user").document("\(ref!.documentID)").updateData(["id":"\(ref!.documentID)"])
                    DictUserDetails = dict
                    modelUserDetail = ModelUserDetail.init(Dict: DictUserDetails ?? ["":""])
                    UserDefaults.standard.set(true, forKey: "isLogin")
                }
            }
        
            let sb: UIStoryboard = UIStoryboard(name: homeStoryBoard, bundle:Bundle.main)
            let vcNew = sb.instantiateViewController(withIdentifier: "HomeNav") as? UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = vcNew
        }
    }
    /*
    func phoneVarification() {
        Auth.auth().languageCode = "fr";
        PhoneAuthProvider.provider().verifyPhoneNumber(self.txtMobile.text ?? "", uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                showAlertVC(title: kAlertTitle, message: kErrorMessage, controller: self)
            } else {
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                let verificationIDs = UserDefaults.standard.string(forKey: "authVerificationID")
                
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID,verificationCode: verificationCode)

            }
        }
    }
    
    func fireAuthMethod(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (authResult, error) in
          if let error = error {
            let authError = error as NSError
            if (isMFAEnabled && authError.code == AuthErrorCode.secondFactorRequired.rawValue) {
              // The user is a multi-factor user. Second factor challenge is required.
              let resolver = authError.userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
              var displayNameString = ""
              for tmpFactorInfo in (resolver.hints) {
                displayNameString += tmpFactorInfo.displayName ?? ""
                displayNameString += " "
              }
              self.showTextInputPrompt(withMessage: "Select factor to sign in\n\(displayNameString)", completionBlock: { userPressedOK, displayName in
                var selectedHint: PhoneMultiFactorInfo?
                for tmpFactorInfo in resolver.hints {
                  if (displayName == tmpFactorInfo.displayName) {
                    selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                  }
                }
                PhoneAuthProvider.provider().verifyPhoneNumber(with: selectedHint!, uiDelegate: nil, multiFactorSession: resolver.session) { verificationID, error in
                  if error != nil {
                    print("Multi factor start sign in failed. Error: \(error.debugDescription)")
                  } else {
                    self.showTextInputPrompt(withMessage: "Verification code for \(selectedHint?.displayName ?? "")", completionBlock: { userPressedOK, verificationCode in
                      let credential: PhoneAuthCredential? = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!, verificationCode: verificationCode!)
                      let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator.assertion(with: credential!)
                      resolver.resolveSignIn(with: assertion!) { authResult, error in
                        if error != nil {
                          print("Multi factor finanlize sign in failed. Error: \(error.debugDescription)")
                        } else {
                          self.navigationController?.popViewController(animated: true)
                        }
                      }
                    })
                  }
                }
              })
            } else {
             // self.showMessagePrompt(error.localizedDescription)
              return
            }
            // ...
            return
          }
          // User is signed in
          // ...
        }
    }
    
}
func aaa(){
    
    
    let phoneNumber = "+16505554567"

    // This test verification code is specified for the given test phone number in the developer console.
    let testVerificationCode = "123456"

    Auth.auth().settings?.isAppVerificationDisabledForTesting = true
    PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate:nil) {
                                                                verificationID, error in
        if ((error) != nil) {
          // Handles error
          return
        }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID ?? "",
                                                                   verificationCode: testVerificationCode)
        Auth.auth().signInAndRetrieveData(with: credential) { authData, error in
            if ((error) != nil) {
            // Handles error
            return
          }
        }
    }
}

*/
}
