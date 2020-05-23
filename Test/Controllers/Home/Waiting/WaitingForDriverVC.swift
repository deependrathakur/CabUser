//
//  WaitingForDriverVC.swift
//  Test
//
//  Created by Harshit on 29/02/20.
//  Copyright © 2020 Deependra. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class WaitingForDriverVC: UIViewController, SWRevealViewControllerDelegate,MKMapViewDelegate {
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var txtPicupLocation:UITextField!
    @IBOutlet weak var txtDroupLocation:UITextField!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblNumberDetail:UILabel!
    @IBOutlet weak var lblHeaser:UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imgUser:UIImageView!
    @IBOutlet weak var btnCancel:UIButton!
    
    var bookingDict = ModelMyRides.init(dict: [:])
    var bookingId = ""
    var rideStatus = 1
    var driverId = ""
    var mobileNo = ""
    fileprivate let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnCancel.isHidden = false
        menuButton.addTarget(revealViewController, action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.revealViewController().delegate = self
        revealViewController()?.rearViewRevealWidth = 80
        parseData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getListDriver()
        self.trackStatus()
    }
    
    func parseData() {
        self.txtDroupLocation.text = self.bookingDict.dropAddress
        self.txtPicupLocation.text = self.bookingDict.pickupAddress
        if rideStatus == 1 || rideStatus == 2 {
            self.btnCancel.isHidden = false
        } else {
            self.btnCancel.isHidden = true
        }
        if rideStatus == 0 || rideStatus == 1 {
            self.lblHeaser.text = "Waiting for Driver"
        } else if rideStatus == 2 {
            self.lblHeaser.text = "Driver Reached"
        } else if rideStatus == 3 {
            self.lblHeaser.text = "On The Way"
        }else if rideStatus == 4  {
            self.lblHeaser.text = "Complete"
        }
    }
}
//MARK: - Button Method extension
extension WaitingForDriverVC {
    
    @IBAction func MenuAction(sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelAction(sender: UIButton) {
        db.collection("booking").document(bookingId).updateData(["status":6])
        let sb: UIStoryboard = UIStoryboard(name: homeStoryBoard, bundle:Bundle.main)
        let vcNew = sb.instantiateViewController(withIdentifier: "HomeNav") as? UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = vcNew
    }
    
    @IBAction func backAction(sender: UIButton) {
        self.view.endEditing(true)
        let sb: UIStoryboard = UIStoryboard(name: homeStoryBoard, bundle:Bundle.main)
        let vcNew = sb.instantiateViewController(withIdentifier: "HomeNav") as? UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = vcNew
    }
    
    @IBAction func CallAction(sender: UIButton) {
        self.view.endEditing(true)
        if let url = URL(string: "tel://\(mobileNo)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func reviewAction(sender: UIButton) {
        self.view.endEditing(true)
        goToNextVC(storyBoardID: homeStoryBoard, vc_id: writeReviewVC, currentVC: self)
    }
}

//MARK: - firebase method
extension WaitingForDriverVC {
    func trackStatus() {
        db.collection("booking").document(bookingId).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            let source = document.metadata.hasPendingWrites ? "Local" : "Server"
            print("\(source) data: \(document.data() ?? [:])")
            let objModel = ModelMyRides.init(dict: document.data() ?? [:])
            self.bookingDict = objModel
            self.rideStatus = Int(objModel.status) ?? 0
            self.getListDriver()
            self.parseData()
            if self.rideStatus == 4 {
                self.gotoNextVC()
            }
        }
    }
    
    func gotoNextVC() {
        let vc = UIStoryboard.init(name: homeStoryBoard, bundle: Bundle.main).instantiateViewController(withIdentifier: writeReviewVC) as? WriteReviewVC
        vc?.bookingDict = self.bookingDict
        vc?.bookingId = self.bookingId
        vc?.rideStatus = self.rideStatus
        vc?.driverId = self.driverId
        vc?.mobileNo = self.mobileNo
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func getListDriver() {
        if driverId.count > 0 {
            db.collection("driver").document(driverId).getDocument { (querySnapshot, err) in
                if let err = err {
                } else {
                    if let document = querySnapshot?.data() {
                        let objModel = ModelDriverList.init(dict: document)
                        self.lblName.text = objModel.name
                        self.mobileNo = objModel.mobile ?? ""
                        self.lblNumberDetail.text = objModel.cab.number + " " + objModel.cab.brandName + " " + objModel.cab.color
                    }
                }
            }
        }
    }
}
