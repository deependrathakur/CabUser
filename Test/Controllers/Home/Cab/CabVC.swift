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

class CabVC: UIViewController, SWRevealViewControllerDelegate, UITextFieldDelegate, GMSAutocompleteViewControllerDelegate, PickerDelegate, MKMapViewDelegate {
    var arrCordinate = [CLLocationCoordinate2D]()

    @IBOutlet weak var txtPicupLocation:UITextField!
    @IBOutlet weak var txtDroupLocation:UITextField!
    @IBOutlet weak var buttonDate:UIButton!
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!

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
    @IBOutlet weak var vwDateTimePopup:UIView!

    @IBOutlet weak var mapViewPopUp: MKMapView!
    @IBOutlet weak var menuButton: UIButton!
    
    fileprivate var placeForIndex = 1
    fileprivate var bookingDict = [String:Any]()
    fileprivate let db = Firestore.firestore()
    fileprivate let locationManager = CLLocationManager()
    fileprivate var arrModelDriverList = [ModelDriverList]()
    fileprivate var arrShortDriverList = [ModelDriverList]()
    fileprivate var travelType = "car"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.mapViewPopUp.delegate = self
        self.indicator.isHidden = true
        self.getCurrentLocation()
        self.txtPicupLocation.delegate = self
        self.txtDroupLocation.delegate = self
        self.txtPicupLocationPopup.delegate = self
        self.txtDroupLocationPopup.delegate = self
        self.buttonDate.setTitleColor(grayColor, for: .normal)
        onTheWay(onTheWayBy: "car")
        self.vwPopup.isHidden = true
        menuButton.addTarget(revealViewController, action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.revealViewController().delegate = self
        revealViewController()?.rearViewRevealWidth = 60
        
        bookingDict = ["acceptedData": "",
                       "amount":"0",
                       "bookingLaterDate": "123132",
                       "cardId": "",
                       "completeDate": "",
                       "createdData":  Date(),
                       "driverId": "",
                       "dropAddress": "",
                       "dropLocation": "",
                       "otp": "",
                       "paymentId": "",
                       "pickupLocation":"",
                       "pickupAddress":"",
                       "rattingStar":"",
                       "reachedDate":"",
                       "review":false,
                       "reviewComment":"",
                       "rideNow":true,
                       "status":3,
                       "totalDistanceKM":0,
                       "totalTimeMinute":0,
                       "userId":(UserDefaults.standard.value(forKey: "userId") as? String ?? "")]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.vwPopup.isHidden = true
        UserDefaults.standard.set(cabVC, forKey: "vc")
        self.getListDriver()
    }
    
    func onSelectPicker(date: Date) {
        let a = getTimeFromTime(date: date)
        bookingDict["createdData"] = date
        self.buttonDate.setTitle(a, for: .normal)
        self.buttonDate.setTitleColor(appColor, for: .normal)
    }
    
    // MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: polyline)
            polylineRenderer.strokeColor = .blue
            polylineRenderer.lineWidth = 3
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

//MARK: - Custome Method extension
fileprivate extension CabVC {
    func onTheWay(onTheWayBy: String) {
        travelType = onTheWayBy
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
    
    func basicValidationTrue() -> Bool {
        if self.txtPicupLocation.isEmptyText() {
            showAlertVC(title: kAlertTitle, message: "Please select pikup location.", controller: self)
            return false
        } else if self.txtDroupLocation.isEmptyText() {
            showAlertVC(title: kAlertTitle, message: "Please select drop location.", controller: self)
            return false
        } else {
            bookingDict["totalDistanceKM"] = String(format: "%.2f", getDistanceInInt())
            self.lblPrice.text = "$" + String(Int(getDistanceInInt()*2))
            let newDistances = String(format: "%.2f", getDistanceInInt())
            self.lblTimeDistance.text = "\(newDistances) KM, \(Int(getDistanceInInt())) min"
            bookingDict["totalTimeMinute"] = Int(getDistanceInInt())
            return true
        }
    }
    
    func getDistanceInInt() -> Double {
        var arrStartPoint = [String]()
        var arrEndPoint = [String]()
        arrStartPoint.append(String(arrCordinate[0].latitude))
        arrStartPoint.append(String(arrCordinate[0].longitude))
        arrEndPoint.append(String(arrCordinate[1].latitude))
        arrEndPoint.append(String(arrCordinate[1].longitude))
        let value = getDistanceOfTwoPointInDouble(arrStartPoint: arrStartPoint, arrEndPoint: arrEndPoint)
        return value
    }
}

//MARK: - location view extension
extension CabVC : CLLocationManagerDelegate {
    
    func setupMap() {
        self.mapView = showRouteOnMap(pickupCoordinate: self.arrCordinate[0], destinationCoordinate: self.arrCordinate[1], mapView: mapView)
        self.mapViewPopUp = showRouteOnMap(pickupCoordinate: self.arrCordinate[0], destinationCoordinate: self.arrCordinate[1], mapView: mapViewPopUp)
    }
    
    
    func getCurrentLocation() {
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            let locValue = locationManager.location?.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if placeForIndex == 1 {
            bookingDict["pickupAddress"] = "\(place.name ?? ""), " + "\(place.formattedAddress ?? "")"
            bookingDict["pickupPoint"] = "\(place.coordinate.latitude)," + "\(place.coordinate.longitude)"
            self.txtPicupLocation.text = bookingDict["pickupAddress"] as? String ?? ""
            self.txtPicupLocationPopup.text = bookingDict["pickupAddress"] as? String ?? ""
            if arrCordinate.count > 0 { arrCordinate[0] = place.coordinate } else { arrCordinate.append(place.coordinate) }
            
        } else if placeForIndex == 2 {
            bookingDict["dropAddress"] = "\(place.name ?? ""), " + "\(place.formattedAddress ?? "")"
            bookingDict["dropPoint"] = "\(place.coordinate.latitude)," + "\(place.coordinate.longitude)"
            self.txtDroupLocation.text = bookingDict["dropAddress"] as? String ?? ""
            self.txtDroupLocationPopup.text = bookingDict["dropAddress"] as? String ?? ""
            if arrCordinate.count > 1 { arrCordinate[1] = place.coordinate } else { arrCordinate.append(place.coordinate) }
            self.setupMap()
            
        } else if placeForIndex == 3 {
            bookingDict["pickupAddress"] = "\(place.name ?? ""), " + "\(place.formattedAddress ?? "")"
            bookingDict["pickupPoint"] = "\(place.coordinate.latitude)," + "\(place.coordinate.longitude)"
            self.txtPicupLocationPopup.text = bookingDict["pickupAddress"] as? String ?? ""
            self.txtPicupLocation.text = bookingDict["pickupAddress"] as? String ?? ""
            
        } else if placeForIndex == 4 {
            bookingDict["dropAddress"] = "\(place.name ?? ""), " + "\(place.formattedAddress ?? "")"
            bookingDict["dropPoint"] = "\(place.coordinate.latitude)," + "\(place.coordinate.longitude)"
            self.txtDroupLocationPopup.text = bookingDict["dropAddress"] as? String ?? ""
            self.txtDroupLocation.text = bookingDict["dropAddress"] as? String ?? ""
            
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

//MARK: - Firebase method extension
extension CabVC {
    func sendBookingOnFirebase() {
        self.sendNotificationOnFirebase()
        let distance = getDistanceInInt()
        let amount = Int(distance*2)
        bookingDict["amount"] = amount
        self.indicator.isHidden = false
        
        var ref: DocumentReference? = nil
        ref = db.collection("booking").addDocument(data: bookingDict) { err in
            if let _ = err {
                self.indicator.isHidden = true
                showAlertVC(title: kAlertTitle, message: kErrorMessage, controller: self)
            } else {
                self.indicator.isHidden = true
                self.vwPopup.isHidden = true
                self.txtDroupLocationPopup.text = ""
                self.txtPicupLocationPopup.text = ""
                self.txtDroupLocation.text = ""
                self.txtPicupLocation.text = ""
                let vc = UIStoryboard.init(name: homeStoryBoard, bundle: Bundle.main).instantiateViewController(withIdentifier: myRidesVC) as? MyRidesVC
                self.navigationController?.pushViewController(vc!, animated: true)
                showAlertVC(title: kAlertTitle, message: "Booking successfully submited.", controller: self)
            }
        }
    }
    
    func sendNotificationOnFirebase() {
        
        let dictionary = ["create": Date(),
                          "dropLocation":bookingDict["dropAddress"] as? String ?? "",
                          "pickupAddress": "\(arrCordinate[0].latitude), \(arrCordinate[0].longitude)",
                          "pickupLocation": bookingDict["pickupAddress"] as? String ?? "",
                          "ride":bookingDict["ride"] as? String ?? "",
                          "status": 0,
                          "userId": (UserDefaults.standard.value(forKey: "userId") as? String ?? "")] as [String : Any]
        var ref: DocumentReference? = nil
        ref = db.collection("bookingAlert").addDocument(data: dictionary) { err in
            
            if let _ = err {
                
            } else {
 
            }
        }
    }
}
//MARK: - Button Method extension
fileprivate extension CabVC {
    
    @IBAction func placePickerAction(sender: UIButton) {
        placeForIndex = sender.tag
        let placePickerController = GMSAutocompleteViewController()
        placePickerController.delegate = self
        present(placePickerController, animated: true, completion: nil)
    }
    
    @IBAction func CancelRideLaterAction(sender: UIButton) {
        self.view.endEditing(true)
        self.vwPopup.isHidden = true
     }
    
    @IBAction func RideNowAction(sender: UIButton) {
        self.view.endEditing(true)
        bookingDict["rideNow"] = true
        if self.basicValidationTrue() {
            vwDateTimePopup.isHidden = true
            self.vwPopup.isHidden = false
        }
    }
    
    @IBAction func RideLaterAction(sender: UIButton) {
        self.view.endEditing(true)
        bookingDict["rideNow"] = false
        if self.basicValidationTrue() {
            vwDateTimePopup.isHidden = false
            self.vwPopup.isHidden = false
        }
    }
    
    @IBAction func ConfirmAction(sender: UIButton) {
        self.view.endEditing(true)
        if self.basicValidationTrue() {
            
            if (bookingDict["rideNow"] as? Bool ?? false) == false {
                if self.buttonDate.currentTitle == "Select Picup Date & Time" {
                    showAlertVC(title: kAlertTitle, message: "Please select pikup Time.", controller: self)
                    return
                } else if (bookingDict["createdData"] as? Date ?? Date()) < Date() {
                    showAlertVC(title: kAlertTitle, message: "Please select valid Time.", controller: self)
                    return
                }
            }
                self.sendBookingOnFirebase()
        }
    }
    
    @IBAction func selectTimeAction(sender: UIButton) {
        self.view.endEditing(true)
        if let vc = UIStoryboard.init(name: homeStoryBoard, bundle: Bundle.main).instantiateViewController(withIdentifier: "PickerViewVC") as? PickerViewVC {
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func MenuAction(sender: UIButton) {
        self.view.endEditing(true)
    }
    
    @IBAction func selectDriveTypeAction(sender: UIButton) {
        self.view.endEditing(true)
        if sender.tag == 0 {
            onTheWay(onTheWayBy: "car")
        } else if sender.tag == 1 {
            onTheWay(onTheWayBy: "cab")
        } else if sender.tag == 2 {
            onTheWay(onTheWayBy: "truck")
        }
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

//MARK: - Get driver list
extension CabVC {
    func getListDriver() {

        db.collection("driver").getDocuments() { (querySnapshot, err) in
            var dictUser = [String:Any]()
            if let err = err {
                self.indicator.isHidden = true
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let obj = ModelDriverList.init(dict: document.data())
                    self.arrModelDriverList.append(obj)
                }
                self.parseShortData()
            }
        }
    }
    
    func parseShortData() {
        self.arrShortDriverList.removeAll()
        for obj in self.arrModelDriverList {
            if obj.cab_type == travelType {
                self.arrShortDriverList.append(obj)
            }
        }
    }
    
    func getDirections(enterdLocations:[String])  {
        // array has the address strings
        var locations = [MKPointAnnotation]()
        for item in enterdLocations {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(item, completionHandler: {(placemarks, error) -> Void in
                if((error) != nil){
                    print("Error", error)
                }
                if let placemark = placemarks?.first {

                    let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate

                    let dropPin = MKPointAnnotation()
                    dropPin.coordinate = coordinates
                    dropPin.title = item
                    self.mapView.addAnnotation(dropPin)
                    self.mapView.selectAnnotation( dropPin, animated: true)

                    locations.append(dropPin)
                    //add this if you want to show them all
                    self.mapView.showAnnotations(locations, animated: true)
                }
            })
        }
    }
}
