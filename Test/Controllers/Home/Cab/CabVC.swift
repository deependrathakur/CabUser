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

class CabVC: UIViewController, SWRevealViewControllerDelegate, UITextFieldDelegate, GMSAutocompleteViewControllerDelegate, PickerDelegate, MKMapViewDelegate,CLLocationManagerDelegate {
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
    @IBOutlet weak var menuButton:UIButton!

    @IBOutlet weak var mapViewPopUp: MKMapView!
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var vwWaiting:UIView!
    @IBOutlet weak var lblWaiting:UILabel!

    fileprivate var placeForIndex = 1
    fileprivate var bookingDict = [String:Any]()
    fileprivate let db = Firestore.firestore()
    fileprivate var arrModelDriverList = [ModelDriverList]()
    fileprivate var arrShortDriverList = [ModelDriverList]()
    fileprivate var cabOverView = ModelTravel(dict: ["":""])
    fileprivate var travelType = "car"
    
    func onSelectPicker(date: Date) {
        let a = getTimeFromTime(date: date)
        bookingDict["createdData"] = date
        self.buttonDate.setTitle(a, for: .normal)
        self.buttonDate.setTitleColor(appColor, for: .normal)
        self.checkCurrentLocation()
    }
}

extension CabVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.vwWaiting.isHidden = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        self.mapView.delegate = self
        self.mapViewPopUp.delegate = self
        mapView.showsUserLocation = true
        
        self.indicator.isHidden = true
        self.getCurrentLocation()
        self.txtPicupLocation.delegate = self
        self.txtDroupLocation.delegate = self
        self.txtPicupLocationPopup.delegate = self
        self.txtDroupLocationPopup.delegate = self
        self.buttonDate.setTitleColor(grayColor, for: .normal)
        onTheWay(onTheWayBy: "car")
        getCabDetail(type: "micro")
        self.vwPopup.isHidden = true
        menuButton.addTarget(revealViewController, action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.revealViewController().delegate = self
        revealViewController()?.rearViewRevealWidth = 80
        
        bookingDict = ["cabId":"",
            "id":"",
            "isReview":false,
            "paymentType":"",
            "acceptedDate": "",
            "amount":"0",
            "bookingLaterDate": "",
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
            "rattingStar":0.0,
            "reachedDate":"",
            "review":false,
            "reviewComment":"",
            "rideNow":true,
            "status":0,
            "totalDistanceKM":0.0,
            "totalTimeMinute":0.0,
            "userId":(UserDefaults.standard.value(forKey: "userId") as? String ?? "")]
        self.checkCurrentLocation()
        self.lblWaiting.text = "Please wait...\nRequesting to driver..."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.vwPopup.isHidden = true
        self.getAllCabDetail()
        UserDefaults.standard.set(cabVC, forKey: "vc")
        self.getListDriver()
        AppDelegate().getUserDetailFromFirebase()
        self.checkCurrentLocation()
    }
}

//MARK: - Location method
extension CabVC {
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        currentLocationGeoPoint = GeoPoint.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    func checkCurrentLocation() {
        if self.txtPicupLocation.text == "" || self.txtPicupLocation.text == nil {
            self.txtPicupLocation.text = currentAddress
            bookingDict["pickupAddress"] = currentAddress
            bookingDict["pickupLocation"] = currentLocationGeoPoint
        }
    }
    
    // MARK: MKMapViewDelegate
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        if let polyline = overlay as? MKPolyline {
//            let polylineRenderer = MKPolylineRenderer(overlay: polyline)
//            polylineRenderer.strokeColor = .blue
//            polylineRenderer.lineWidth = 0
//            return polylineRenderer
//        }
//        return MKOverlayRenderer(overlay: overlay)
//    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView?.image =  #imageLiteral(resourceName: "car5")
            anView?.canShowCallout = true
        }
        else {
            anView?.annotation = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId) as? MKAnnotation
        }
        return anView
    }
}

//MARK: - Custome Method extension
fileprivate extension CabVC {
    
    func onTheWay(onTheWayBy: String) {
        travelType = onTheWayBy
        self.vwCab.backgroundColor = #colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1)
        self.vwTruck.backgroundColor = #colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1)
        self.vwCar.backgroundColor = #colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1)
        self.getListDriver()
        self.imgCab.image = #imageLiteral(resourceName: "busG")
        self.imgCar.image = #imageLiteral(resourceName: "nanoGray")
        self.imgTruck.image = #imageLiteral(resourceName: "truckGray")
        if onTheWayBy == "truck" {
            self.imgTruck.image = #imageLiteral(resourceName: "truckWhite")
            self.vwTruck.backgroundColor = appColor
        } else if onTheWayBy == "car" {
            self.imgCar.image = #imageLiteral(resourceName: "nanoWhite")
            self.vwCar.backgroundColor = appColor
        } else if onTheWayBy == "cab" {
            self.imgCab.image = #imageLiteral(resourceName: "busW")
            self.vwCab.backgroundColor = appColor
        }
        self.checkCurrentLocation()
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
            self.lblPrice.text = "N$" + String(Int(getDistanceInInt()*2))
            let newDistances = String(format: "%.2f", getDistanceInInt())
            self.lblTimeDistance.text = "\(newDistances) KM, \(Int(getDistanceInInt()*2)) min"
            bookingDict["totalTimeMinute"] = Int(getDistanceInInt()*2)
            self.calculationDistanceAndTime()
            return true
        }
        self.checkCurrentLocation()
    }
    
    func calculationDistanceAndTime() {
        if Int(getDistanceInInt()) > cabOverView.startKM {
            let price = (cabOverView.startPrice + ((Int(getDistanceInInt()) - cabOverView.startKM) * cabOverView.pricePerKM) + (Int(getDistanceInInt()*2) * cabOverView.perMin))
            self.lblPrice.text = "N$" + "\(price)"
            bookingDict["amount"] = price
        }else{
            self.lblPrice.text = "N$\(cabOverView.startPrice)"
            bookingDict["amount"] = cabOverView.startPrice
        }
    }
    
    func getDistanceInInt() -> Double {
        let value = getDistanceOfTwoPointInDouble(sourcePoint: bookingDict["pickupLocation"] as? GeoPoint ?? commanGeoPoint, destinationPoint: bookingDict["dropLocation"] as? GeoPoint ?? commanGeoPoint)
        return value
    }
    
    func setupMap() {
        if self.arrCordinate.count > 1 {
            self.mapView = showRouteOnMap(pickupCoordinate: self.arrCordinate[0], destinationCoordinate: self.arrCordinate[1], mapView: mapView)
            self.mapViewPopUp = showRouteOnMap(pickupCoordinate: self.arrCordinate[0], destinationCoordinate: self.arrCordinate[1], mapView: mapViewPopUp)
        }
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
}

//MARK: - location view extension
extension CabVC  {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if placeForIndex == 1 {
            bookingDict["pickupAddress"] = "\(place.name ?? ""), " + "\(place.formattedAddress ?? "")"
            bookingDict["pickupLocation"] = GeoPoint.init(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            self.txtPicupLocation.text = bookingDict["pickupAddress"] as? String ?? ""
            self.txtPicupLocationPopup.text = bookingDict["pickupAddress"] as? String ?? ""
            if arrCordinate.count > 0 { arrCordinate[0] = place.coordinate } else { arrCordinate.append(place.coordinate) }
            
        } else if placeForIndex == 2 {
            bookingDict["dropAddress"] = "\(place.name ?? ""), " + "\(place.formattedAddress ?? "")"
            bookingDict["dropLocation"] = GeoPoint.init(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            self.txtDroupLocation.text = bookingDict["dropAddress"] as? String ?? ""
            self.txtDroupLocationPopup.text = bookingDict["dropAddress"] as? String ?? ""
            if arrCordinate.count > 1 { arrCordinate[1] = place.coordinate } else { arrCordinate.append(place.coordinate) }
            
            
        } else if placeForIndex == 3 {
            bookingDict["pickupAddress"] = "\(place.name ?? ""), " + "\(place.formattedAddress ?? "")"
            bookingDict["pickupLocation"] = GeoPoint.init(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            self.txtPicupLocationPopup.text = bookingDict["pickupAddress"] as? String ?? ""
            self.txtPicupLocation.text = bookingDict["pickupAddress"] as? String ?? ""
            
        } else if placeForIndex == 4 {
            bookingDict["dropAddress"] = "\(place.name ?? ""), " + "\(place.formattedAddress ?? "")"
            bookingDict["dropLocation"] = GeoPoint.init(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            self.txtDroupLocationPopup.text = bookingDict["dropAddress"] as? String ?? ""
            self.txtDroupLocation.text = bookingDict["dropAddress"] as? String ?? ""
            
        }
        self.setupMap()
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
                self.sendBookingNotificationToAllDrivers(bookingId: "\(ref!.documentID)")
                if (self.bookingDict["rideNow"] as? Bool ?? false) == true {
                    self.checkBookingStatus(bookingId: "\(ref!.documentID)")
                } else {
                    let vc = UIStoryboard.init(name: homeStoryBoard, bundle: Bundle.main).instantiateViewController(withIdentifier: myRidesVC) as? MyRidesVC
                    self.navigationController?.pushViewController(vc!, animated: true)
                    showAlertVC(title: kAlertTitle, message: "Booking successfully submited.", controller: self)
                }
            }
        }
    }
    
    func checkBookingStatus(bookingId: String) {
        self.indicator.isHidden = false
        self.vwWaiting.isHidden = false
        db.collection("booking").document(bookingId).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            let source = document.metadata.hasPendingWrites ? "Local" : "Server"
            print("\(source) data: \(document.data() ?? [:])")
            let objModel = ModelMyRides.init(dict: document.data() ?? [:])
            if objModel.status == "1" {
                self.indicator.isHidden = true
                self.vwWaiting.isHidden = true
                let vc = UIStoryboard.init(name: homeStoryBoard, bundle: Bundle.main).instantiateViewController(withIdentifier: waitingForDriverVC) as? WaitingForDriverVC
                vc?.bookingDict = objModel
                vc?.bookingId = bookingId
                vc?.rideStatus = Int(objModel.status) ?? 0
                vc?.driverId = objModel.driverId
                self.navigationController?.pushViewController(vc!, animated: true)
                showAlertVC(title: kAlertTitle, message: "Booking successfully submited.", controller: self)
            }
        }
        let deadlineTime = DispatchTime.now() + .seconds(60)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.db.collection("booking").document(bookingId).setData([:])
            self.indicator.isHidden = true
            self.vwWaiting.isHidden = true
        }
    }
    
    func sendBookingNotificationToAllDrivers(bookingId:String) {
        // for driver in self.arrShortDriverList {
        for driver in self.arrShortDriverList {
            self.ChatNotification(token:driver.deviceToken, bookingId: bookingId, userId:driver.id)
        }
    }
    
    func sendNotificationOnFirebase() {
        let dictionary = ["create": Date(),
                          "dropLocation":bookingDict["dropLocation"] as? GeoPoint ?? commanGeoPoint,
                          "dropAddress":bookingDict["dropAddress"] as? String ?? "",
                          "pickupAddress": bookingDict["pickupLocation"] as? String ?? "",
                          "pickupLocation": bookingDict["pickupLocation"] as? GeoPoint ?? commanGeoPoint,
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
    @IBAction func currentLocation(sender: UIButton) {
        let center = CLLocationCoordinate2D(latitude: currentLocationGeoPoint.latitude, longitude: currentLocationGeoPoint.longitude)
        var region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        region.center = mapView.userLocation.coordinate
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func placePickerAction(sender: UIButton) {
        placeForIndex = sender.tag
        let placePickerController = GMSAutocompleteViewController()
        placePickerController.delegate = self
        placePickerController.tableCellBackgroundColor = whiteColor
        placePickerController.tintColor = appColor
        placePickerController.primaryTextColor = appColor
        placePickerController.secondaryTextColor = blackColor
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
            if self.arrShortDriverList.count == 0 {
                showAlertVC(title: kAlertTitle, message: "\(travelType.capitalized) not available.", controller: self)
            } else {
            vwDateTimePopup.isHidden = true
            self.vwPopup.isHidden = false
        }
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
            getCabDetail(type: "micro")
            onTheWay(onTheWayBy: "car")
        } else if sender.tag == 1 {
            onTheWay(onTheWayBy: "cab")
            getCabDetail(type: "mini")
        } else if sender.tag == 2 {
            onTheWay(onTheWayBy: "truck")
            getCabDetail(type: "sedan")
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
    func getAllCabDetail() {
        var arrCabList = [Int]()
        var arrCarList = [Int]()
        var arrTruckList = [Int]()
        for dict in self.arrModelDriverList {
            if dict.cab_type == "micro" {
                arrCabList.append(Int(dict.distanceFromCurrentPoint))
            } else if dict.cab_type == "mini" {
                arrCarList.append(Int(dict.distanceFromCurrentPoint))
            } else if dict.cab_type == "sedan" {
                arrTruckList.append(Int(dict.distanceFromCurrentPoint))
            }
        }
        arrCabList = arrCabList.sorted()
        arrCarList = arrCarList.sorted()
        arrTruckList = arrTruckList.sorted()
        
        if arrCabList.count > 0, arrCabList[0] >= 0  {
            self.lblCab.text = "Bus \(arrCabList[0]) min"
        } else {
            self.lblCab.text = "Bus \nNo Cab"
        }
        if arrCarList.count > 0 , arrCarList[0] > 0 {
            self.lblCar.text = "Car \(arrCarList[0]) min"
        } else {
            self.lblCar.text = "Bus \nNo Cab"
        }
        
        if arrTruckList.count > 0 , arrTruckList[0] > 0 {
            self.lblTruck.text = "Truck \(arrTruckList[0]) min"
        } else {
            self.lblTruck.text = "Truck \nNo Cab"
        }
    }

    func getCabDetail(type:String) {
        db.collection("cabs").document(type).getDocument { (querySnapshot, err) in
            var dictUser = [String:Any]()
            if let err = err {
            } else {
                if let document = querySnapshot!.data()  {
                    self.cabOverView = ModelTravel.init(dict: document)
                }
                self.parseShortData()
            }
        }
    }
    
    func getListDriver() {
        self.arrModelDriverList.removeAll()
        db.collection("driver").addSnapshotListener { querySnapshot, error in
            //  db.collection("driver").getDocuments() { (querySnapshot, err) in
            var dictUser = [String:Any]()
            if let err = error {
                self.indicator.isHidden = true
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let obj = ModelDriverList.init(dict: document.data())
                    let distanceFromLastLocation = getDistanceOfTwoPointInGeoPoint(startPoint: obj.currentLocation ?? commanGeoPoint, endPoint: lastPointLocation)
                    if distanceFromLastLocation < 16 {
                        obj.distanceFromCurrentPoint = distanceFromLastLocation
                        self.arrModelDriverList.append(obj)
                    }
                }
                self.parseShortData()
                self.getAllCabDetail()
            }
        }
    }
    
    
    func parseShortData() {
        self.arrShortDriverList.removeAll()
        mapView.removeAnnotations(mapView.annotations)
        for obj in self.arrModelDriverList {
            print("Type = ",obj.cab_type, self.travelType)
            if (obj.cab_type == "sedan" && self.travelType == "truck") || (obj.cab_type == "mini" && self.travelType == "car")  || (obj.cab_type == "micro" && self.travelType == "cab") {
                let newPin = MKPointAnnotation()
                newPin.coordinate.latitude = obj.currentLocation?.latitude ?? commanGeoPoint.latitude
                newPin.coordinate.longitude = obj.currentLocation?.longitude ?? commanGeoPoint.longitude
                mapView.addAnnotation(newPin)
                
                // Drop a pin at user's Current Location
                let myAnnotation: MKPointAnnotation = MKPointAnnotation()
                myAnnotation.coordinate = CLLocationCoordinate2DMake(obj.currentLocation?.latitude ?? commanGeoPoint.latitude, obj.currentLocation?.longitude ?? commanGeoPoint.longitude);
                myAnnotation.title = obj.name
                mapView.addAnnotation(myAnnotation)
                self.arrShortDriverList.append(obj)
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        let pinImage = #imageLiteral(resourceName: "logout")
        annotationView!.image = pinImage
        return annotationView
    }
    
    func getDirections(enterdLocations:[String]) {
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
                    self.mapView.showAnnotations(locations, animated: true)
                }
            })
        }
    }
}


//MARK: - Notification method
extension CabVC{
    func ChatNotification(token:String,bookingId:String, userId:String){
        //Android
        let messageDict = ["body": checkForNULL(obj: "booking"),
                           "title": checkForNULL(obj: "CabBooking" ),
                           "icon": "icon",
                           "sound": "default",
                           "badge": "1",
                           "userId":userId,
                           "bookingId":bookingId,
                           "message": "booking",
                           "notifincationType": "1",
                           "type": "booking"]
        //IOS
        let notificationDict = ["body": checkForNULL(obj: "booking"),
                                "title": checkForNULL(obj: modelUserDetail?.name ?? "" ),
                                "icon": "icon",
                                "sound": "default",
                                "badge": "1",
                                "message": "booking",
                                "notifincationType": "1",
                                "type": "booking"]
        
        let finalDict = ["to":checkForNULL(obj:token),
                         "data": checkForNULL(obj:messageDict),
                         "priority" : "high",
                         "notification": checkForNULL(obj:notificationDict),
                         "sound": "default"] as [String : Any]
        
        self.sendNotificationWithDict(dictNotification:finalDict)
    }
    
    func sendNotificationWithDict(dictNotification:Dictionary<String, Any>){
        let strUrl = "https://fcm.googleapis.com/fcm/send"
        var request = URLRequest.init(url: URL.init(string: strUrl)!)
        request.setValue( "key=" + kServerKey, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: dictNotification, options: .prettyPrinted)
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                return
            }
            guard data != nil else {
                return
            }
        }.resume()
    }
}
