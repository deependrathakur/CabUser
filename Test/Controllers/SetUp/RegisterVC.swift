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

class RegisterVC: UIViewController,CountryCodeDelegate,AuthUIDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imgUserProfile:UIImageView!
    @IBOutlet weak var txtFullName:UITextField!
    @IBOutlet weak var txtEmail:UITextField!
    @IBOutlet weak var txtMobile:UITextField!
    @IBOutlet weak var txtPassword:UITextField!
    @IBOutlet weak var indicator:UIActivityIndicatorView!
    @IBOutlet weak var btnLogin:UIButton!
    @IBOutlet weak var btnRegister:UIButton!
    @IBOutlet weak var btnCountryCode:UIButton!
    var countryCodes = "+91"
    let db = Firestore.firestore()
    
    func onSelectCountry(countryCode: String,countryName: String) {
        countryCodes = countryCode
        self.btnCountryCode.setTitle("(\(countryName)) \(countryCode)", for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.indicator.isHidden = true
        self.btnCountryCode.setTitle("(IND) \(+91) ▾", for: .normal)
        self.btnCountryCode.setTitleColor(appColor, for: .normal)
        countryCodes = "+91"
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
    
    @IBAction func imageAction(sender: UIButton) {
        self.view.endEditing(true)
        self.selectProfileImage()
    }
    
    @IBAction func registeredAction(sender: UIButton) {
        self.view.endEditing(true)
        if self.imgUserProfile.image == #imageLiteral(resourceName: "user_ico_setting") || self.imgUserProfile.image == nil {
            showAlertVC(title: kAlertTitle, message: "Please select profile image.", controller: self)
        } else if self.txtFullName.isEmptyText() {
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
            let img = imageToData(image: self.imgUserProfile.image!)
            var ref: DocumentReference? = nil
            let mobileNo = self.countryCodes + (self.txtMobile.text ?? "")
            let dict = [ "created":Date(),
                         "email": self.txtEmail.text ?? "",
                         "mobile": mobileNo,
                         "mobileVerity": false,
                         "emailVerify": false,
                         "profileImage": img!,
                         "otp": "1234",
                         "password": self.txtPassword.text ?? "",
                         "userType": 1,
                         "wallet": 0,
                         "name": self.txtFullName.text ?? ""] as [String : Any]
            self.phoneVarification(mobile: mobileNo,Dict: dict)
        }
    }
     
    func phoneVarification(mobile: String,Dict: [String:Any]) {
        self.indicator.isHidden = false
        PhoneAuthProvider.provider().verifyPhoneNumber(mobile, uiDelegate: self) { (verificationID, error) in
            if ((error) != nil) {
                self.indicator.isHidden = true
                  // Verification code not sent.
                  print(error)
            } else {
                self.indicator.isHidden = true
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

//MARK: - Image picker Method extension
extension RegisterVC {
    func selectProfileImage() {
        let selectImage = UIAlertController(title: "Select Profile Image", message: nil, preferredStyle: .actionSheet)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let btn0 = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
        })
        let btn1 = UIAlertAction(title: "Camera", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                imagePicker.showsCameraControls = true
                imagePicker.allowsEditing = true;
                self.present(imagePicker, animated: true)
            }
        })
        let btn2 = UIAlertAction(title: "Photo Library", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true;
                self.present(imagePicker, animated: true)
            }
        })
        selectImage.addAction(btn0)
        selectImage.addAction(btn1)
        selectImage.addAction(btn2)
        present(selectImage, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.imgUserProfile.image = newImage
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
