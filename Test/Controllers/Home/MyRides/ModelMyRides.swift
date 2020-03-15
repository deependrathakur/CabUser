//
//  ModelMyRides.swift
//  Test
//
//  Created by Harshit on 07/03/20.
//  Copyright © 2020 Deependra. All rights reserved.
//

import UIKit
import GooglePlaces

class ModelMyRides: NSObject {
    var amount = ""
    var date = ""
    var driveId = ""
    var driverId = ""
    var drop = ""
    var dropPoint:CLLocationCoordinate2D!
    var geopoint:CLLocationCoordinate2D
    var km = ""
    var pickup = ""
    var pickupPoint:CLLocationCoordinate2D
    var reviewComment = ""
    var reviewStar = ""
    var status = ""
    var tax = ""

    init(dict: [String : Any]) {
        amount = dictToStringKeyParam(dict: dict, key: "amount")
        date = dictToStringKeyParam(dict: dict, key: "date")
        driveId = dictToStringKeyParam(dict: dict, key: "driveId")
        driverId = dictToStringKeyParam(dict: dict, key: "driverId")
        drop = dictToStringKeyParam(dict: dict, key: "drop")
        dropPoint = getCordinate(dict: dict, key: "dropPoint")
        geopoint  = getCordinate(dict: dict, key: "geopoint")
        km = dictToStringKeyParam(dict: dict, key: "km")
        pickup = dictToStringKeyParam(dict: dict, key: "pickup")
        pickupPoint = getCordinate(dict: dict, key: "pickupPoint")
        reviewComment = dictToStringKeyParam(dict: dict, key: "reviewComment")
        reviewStar = dictToStringKeyParam(dict: dict, key: "reviewStar")
        status = dictToStringKeyParam(dict: dict, key: "status")
        tax = dictToStringKeyParam(dict: dict, key: "tax")
    }
    
}
