//
//  WriteReviewVC.swift
//  Test
//
//  Created by Harshit on 29/02/20.
//  Copyright © 2020 Deependra. All rights reserved.
//

import UIKit
import HCSStarRatingView
import Firebase

class WriteReviewVC: UIViewController {
    @IBOutlet weak var txtPicupLocation:UITextField!
    @IBOutlet weak var txtDroupLocation:UITextField!
    
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var lblTimeDate:UILabel!
    
    @IBOutlet weak var txtViewComment:UITextView!
    @IBOutlet weak var starView:HCSStarRatingView!
    
    var bookingDict = ModelMyRides.init(dict: [:])
    var bookingId = ""
    var rideStatus = 1
    var driverId = ""
    var mobileNo = ""
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parseData()
    }
    
    func parseData() {
        self.txtDroupLocation.text = self.bookingDict.dropAddress
        self.txtPicupLocation.text = self.bookingDict.pickupAddress
        self.lblPrice.text = "N$" + self.bookingDict.amount
        self.lblTimeDate.text = String(self.bookingDict.totalDistanceKM) + "KM " + self.bookingDict.totalTimeMinute + "Min"
    }
}

//MARK: - Button Method extension
extension WriteReviewVC {
    
    @IBAction func backAction(sender: UIButton) {
        self.view.endEditing(true)
        let sb: UIStoryboard = UIStoryboard(name: homeStoryBoard, bundle:Bundle.main)
        let vcNew = sb.instantiateViewController(withIdentifier: "HomeNav") as? UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = vcNew
    }
    
    @IBAction func submitReviewAction(sender: UIButton) {
        self.txtViewComment.text = self.txtViewComment.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if self.txtViewComment.text.count < 10 {
            showAlertVC(title: kAlertTitle, message: "Please enter atlist comment 10 charactor", controller: self)
        } else {
            var ref: DocumentReference? = nil
            let dict = ["bookingId":bookingId,
                        "driverId":driverId,
                        "userId":bookingDict.userId,
                        "comment":self.txtViewComment.text ?? "",
                        "reviewCount":self.starView.value] as [String : Any]
            ref = db.collection("driverReview").addDocument(data: dict) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    let sb: UIStoryboard = UIStoryboard(name: homeStoryBoard, bundle:Bundle.main)
                    let vcNew = sb.instantiateViewController(withIdentifier: "HomeNav") as? UINavigationController
                    UIApplication.shared.keyWindow?.rootViewController = vcNew
                }
            }
        }
    }
}
