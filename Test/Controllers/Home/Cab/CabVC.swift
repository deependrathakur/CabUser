//
//  CabeVC.swift
//  Test
//
//  Created by Harshit on 28/02/20.
//  Copyright © 2020 Deependra. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces
import Firebase

class CabVC: UIViewController, SWRevealViewControllerDelegate, UITextFieldDelegate, GMSAutocompleteViewControllerDelegate {
    
    @IBOutlet weak var txtPicupLocation:UITextField!
    @IBOutlet weak var txtDroupLocation:UITextField!
    
    @IBOutlet weak var lblTruck:UILabel!
    @IBOutlet weak var lblCar:UILabel!
    @IBOutlet weak var lblCab:UILabel!
    
    @IBOutlet weak var vwTruck:UIView!
    @IBOutlet weak var vwCar:UIView!
    @IBOutlet weak var vwCab:UIView!
    
    @IBOutlet weak var imgTruck:UIImageView!
    @IBOutlet weak var imgCar:UIImageView!
    @IBOutlet weak var imgCab:UIImageView!
    
    //popup view confirm
    @IBOutlet weak var vwPopup:UIView!
    
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var lblTimeDistance:UILabel!
    
    @IBOutlet weak var txtPicupLocationPopup:UITextField!
    @IBOutlet weak var txtDroupLocationPopup:UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var menuButton: UIButton!
    
    var placeForIndex = 1
    var bookingDict = [String:Any]()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtPicupLocation.delegate = self
        self.txtDroupLocation.delegate = self
        self.txtPicupLocationPopup.delegate = self
        self.txtDroupLocationPopup.delegate = self
        
        onTheWay(onTheWayBy: "car")
        self.vwPopup.isHidden = true
        menuButton.addTarget(revealViewController, action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.revealViewController().delegate = self
        revealViewController()?.rearViewRevealWidth = 60
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.vwPopup.isHidden = true
        UserDefaults.standard.set(cabVC, forKey: "vc") 
    }
}

//MARK: - Custome Method extension
fileprivate extension CabVC {
    func onTheWay(onTheWayBy: String) {
        self.vwCab.backgroundColor = #colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1)
        self.vwTruck.backgroundColor = #colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1)
        self.vwCar.backgroundColor = #colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1)
        
        self.imgCab.image = #imageLiteral(resourceName: "carGray")
        self.imgCar.image = #imageLiteral(resourceName: "nanoGray")
        self.imgTruck.image = #imageLiteral(resourceName: "truckGray")
        if onTheWayBy == "truck" {
            self.imgTruck.image = #imageLiteral(resourceName: "truckWhite")
            self.vwTruck.backgroundColor = appColor
        } else if onTheWayBy == "car" {
            self.imgCar.image = #imageLiteral(resourceName: "nanoWhite")
            self.vwCar.backgroundColor = appColor
        } else if onTheWayBy == "cab" {
            self.imgCab.image = #imageLiteral(resourceName: "carWhite")
            self.vwCab.backgroundColor = appColor
        }
    }
}

//MARK: - Button method
extension CabVC {
    @IBAction func placePickerAction(sender: UIButton) {
        placeForIndex = sender.tag
        let placePickerController = GMSAutocompleteViewController()
        placePickerController.delegate = self
        present(placePickerController, animated: true, completion: nil)
    }
}

//MARK: - location view extension
extension CabVC {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if placeForIndex == 1 {
            bookingDict["pickup"] = "\(place.name ?? "")" + "\(place.formattedAddress ?? "")"
            bookingDict["pickupPoint"] = "\(place.coordinate.latitude), " + "\(place.coordinate.longitude)"
            self.txtPicupLocation.text = bookingDict["pickup"] as? String ?? ""
            
        } else if placeForIndex == 2 {
            bookingDict["drop"] = "\(place.name ?? "")" + "\(place.formattedAddress ?? "")"
            self.txtDroupLocation.text = bookingDict["drop"] as? String ?? ""
            bookingDict["dropPoint"] = "\(place.coordinate.latitude), " + "\(place.coordinate.longitude)"
            
        } else if placeForIndex == 3 {
            bookingDict["pickup"] = "\(place.name ?? "")" + "\(place.formattedAddress ?? "")"
            self.txtPicupLocationPopup.text = bookingDict["pickup"] as? String ?? ""
            bookingDict["pickupPoint"] = "\(place.coordinate.latitude), " + "\(place.coordinate.longitude)"
            
        } else if placeForIndex == 4 {
            bookingDict["drop"] = "\(place.name ?? "")" + "\(place.formattedAddress ?? "")"
            self.txtDroupLocationPopup.text = bookingDict["drop"] as? String ?? ""
            bookingDict["dropPoint"] = "\(place.coordinate.latitude), " + "\(place.coordinate.longitude)"
            
        } else {
            
        }
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
extension CabVC {
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
//MARK: - Button Method extension
fileprivate extension CabVC {
        
    @IBAction func RideNowAction(sender: UIButton) {
        self.view.endEditing(true)
        self.validationForBooking(rideNow: true)
    }
    
    @IBAction func RideLaterAction(sender: UIButton) {
        self.view.endEditing(true)
        self.vwPopup.isHidden = false
    }
    
    @IBAction func ConfirmAction(sender: UIButton) {
        self.view.endEditing(true)
        self.validationForBooking(rideNow: false)
    }
    
    @IBAction func MenuAction(sender: UIButton) {
        self.view.endEditing(true)
    }
    
}

//MARK: - Button Method extension
fileprivate extension CabVC {
    func validationForBooking(rideNow: Bool) {
        if rideNow {
            if self.txtPicupLocation.isEmptyText() {
                showAlertVC(title: kAlertTitle, message: "Please select pikup location.", controller: self)
            } else if self.txtDroupLocation.isEmptyText() {
                showAlertVC(title: kAlertTitle, message: "Please select drop location.", controller: self)
            } else {
                bookingDict["date"] = Date()
                var ref: DocumentReference? = nil
                ref = db.collection("booking").addDocument(data: bookingDict) { err in
                    if let err = err {
                        self.vwPopup.isHidden = true
                        let vc = UIStoryboard.init(name: homeStoryBoard, bundle: Bundle.main).instantiateViewController(withIdentifier: waitingForDriverVC) as? WaitingForDriverVC
                        self.navigationController?.pushViewController(vc!, animated: true)
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                    }
                }
            }
        } else {
            if self.txtPicupLocationPopup.isEmptyText() {
                showAlertVC(title: kAlertTitle, message: "Please select pikup location.", controller: self)
            } else if self.txtDroupLocationPopup.isEmptyText() {
                showAlertVC(title: kAlertTitle, message: "Please select drop location.", controller: self)
            } else {
                bookingDict["date"] = Date()
                var ref: DocumentReference? = nil
                ref = db.collection("booking").addDocument(data: bookingDict) { err in
                    if let err = err {
                        showAlertVC(title: kAlertTitle, message: kErrorMessage, controller: self)
                    } else {
                        self.vwPopup.isHidden = true
                        let vc = UIStoryboard.init(name: homeStoryBoard, bundle: Bundle.main).instantiateViewController(withIdentifier: waitingForDriverVC) as? WaitingForDriverVC
                        self.navigationController?.pushViewController(vc!, animated: true)
                        print("Document added with ID: \(ref!.documentID)")
                    }
                }
            }
        }
    }
}
