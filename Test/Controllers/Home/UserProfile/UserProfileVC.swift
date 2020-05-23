//
//  UserProfileVC.swift
//  Test
//
//  Created by Harshit on 01/03/20.
//  Copyright © 2020 Deependra. All rights reserved.
//

import UIKit
import GooglePlaces
import Firebase
import AlamofireImage

class UserProfileVC: UIViewController, SWRevealViewControllerDelegate,GMSAutocompleteViewControllerDelegate {

    @IBOutlet weak var imgUserProfile:UIImageView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    var userDict = [String:Any]()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuButton.addTarget(revealViewController, action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.revealViewController().delegate = self
        revealViewController()?.rearViewRevealWidth = 80
        self.parseUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UserDefaults.standard.set(userProfileVC, forKey: "vc")
    }
    
    func parseUserData() {
        
        if let userDetail = DictUserDetails {
            self.txtName.text = dictToStringKeyParam(dict: userDetail, key: "name")
            self.txtEmail.text = dictToStringKeyParam(dict: userDetail, key: "email")
            self.txtPhone.text = dictToStringKeyParam(dict: userDetail, key: "mobile")
            self.txtAddress.text = dictToStringKeyParam(dict: userDetail, key: "address")
            if let imgData = userDetail["profileImage"] as? Data {
                self.imgUserProfile.image = UIImage(data: imgData)
            } else if let url = URL(string: userDetail["profileImage"] as? String ?? "") {
                self.imgUserProfile.af.setImage(withURL: url)
            }
            userDict = userDetail
        }
    }
    
    @IBAction func updateUserDetilAction(sender: UIButton) {
        self.view.endEditing(true)
        if self.imgUserProfile.image == #imageLiteral(resourceName: "user_ico_setting") || self.imgUserProfile.image == nil {
            showAlertVC(title: kAlertTitle, message: "Please select profile image.", controller: self)
        } else if self.txtEmail.isEmptyText() {
            self.txtEmail.shakeTextField()
        } else if !self.txtEmail.isValidateEmail() {
            showAlertVC(title: kAlertTitle, message: InvalidEmail, controller: self)
        } else if self.txtName.isEmptyText() {
            self.txtName.shakeTextField()
        } else if self.txtPhone.isEmptyText() {
            self.txtPhone.shakeTextField()
        } else if self.txtAddress.isEmptyText() {
            self.txtAddress.shakeTextField()
        } else {
            userDict["name"] = self.txtName.text ?? ""
            userDict["email"] = self.txtEmail.text ?? ""
            userDict["address"] = self.txtAddress.text ?? ""
            userDict["mobile"] = self.txtPhone.text ?? ""
            
            if let imgData = DictUserDetails?["profileImage"] as? Data {
                if self.imgUserProfile.image != UIImage(data: imgData) {
                    userDict["profileImage"] = imageToData(image: self.imgUserProfile.image!)
                }
            } else if let url = URL(string: DictUserDetails?["profileImage"] as? String ?? "") {
                let imageView = UIImageView()
                imageView.af.setImage(withURL: url)
                if imageView.image != imgUserProfile.image {
                    userDict["profileImage"] = imageToData(image: self.imgUserProfile.image!)
                }
            }

            if let userId = UserDefaults.standard.string(forKey: "userId") {
                if userId != "" {
                    self.db.collection("user").document(userId).updateData(userDict)
                    DictUserDetails = userDict
                    modelUserDetail = ModelUserDetail.init(Dict: DictUserDetails ?? ["":""])
                    
                    showAlertVC(title: kAlertTitle, message: "Profile update successfully.", controller: self)
                }
            }
        }
        
    }
    
    @IBAction func placePickerAction(sender: UIButton) {
        let placePickerController = GMSAutocompleteViewController()
        placePickerController.delegate = self
        placePickerController.tableCellBackgroundColor = appColor
        present(placePickerController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        userDict["address"] = "\(place.name ?? ""), " + "\(place.formattedAddress ?? "")"
        self.txtAddress.text = userDict["address"] as? String ?? ""
        userDict["addressPoint"] = GeoPoint.init(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

// MARK: - ENSideMenu Delegate
extension UserProfileVC {
    func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        switch position {
            
        case FrontViewPosition.leftSideMostRemoved:
            print("LeftSideMostRemoved")
            
        case FrontViewPosition.leftSideMost:
            print("LeftSideMost")
            
        case FrontViewPosition.leftSide:
            print("LeftSide")
            
        case FrontViewPosition.left:
            print("Left")
            
        case FrontViewPosition.right:
            print("Right")
            
        case FrontViewPosition.rightMost:
            print("RightMost")
            
        case FrontViewPosition.rightMostRemoved:
            print("RightMostRemoved")
        @unknown default:
            print("Unknown")
        }
    }
    func sideMenuWillOpen() {
        self.view.isUserInteractionEnabled=false;
        print("sideMenuWillOpen")
    }
    func sideMenuWillClose() {
        self.view.isUserInteractionEnabled=true;
        print("sideMenuWillClose")
    }
    func sideMenuShouldOpenSideMenu() -> Bool {
        print("sideMenuShouldOpenSideMenu")
        return true
    }
    func sideMenuDidClose() {
        print("sideMenuDidClose")
    }
    func sideMenuDidOpen() {
        print("sideMenuDidOpen")
    }
}

//MARK: - Image picker Method extension
extension UserProfileVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBAction func imageAction(sender: UIButton) {
        self.view.endEditing(true)
        self.selectProfileImage()
    }
    
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
    
    func imageToData(image: UIImage) -> Data? {
        if let uploadImageData = (image).pngData(){
            return uploadImageData
        }
        return nil
    }
}
