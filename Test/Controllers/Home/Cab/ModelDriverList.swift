//
//  ModelDriverList.swift
//  Test
//
//  Created by Harshit on 02/04/20.
//  Copyright © 2020 Deependra. All rights reserved.
//

import UIKit
import Firebase
class ModelDriverList: NSObject {
    var available = false
    var busy = false
    var cab = ModelCabDetail(dict: [:])
    var cabAdded = false
    var cab_type = ""
    var create = ""
    var currentLocation:GeoPoint?
    var deviceToken = ""
    var documentAdded = false
    var documentFile = ModelDriverDocument(dict: [:])
    var email = ""
    var gender = ""
    var id = ""
    var mobile = ""
    var name = ""
    var password = ""
    var status = ""
    var verified = false
    var distanceFromCurrentPoint = 0.0

    init(dict: [String : Any]) {
        
        available = dictToBoolKeyParam(dict: dict, key: "available")
        busy = dictToBoolKeyParam(dict: dict, key: "busy")
        cab = ModelCabDetail(dict: dict["cab"] as? [String:Any] ?? [:])
        cabAdded = dictToBoolKeyParam(dict: dict, key: "cabAdded")
        cab_type = dictToStringKeyParam(dict: dict, key: "cab_type")
        create = dictToStringKeyParam(dict: dict, key: "create")
        currentLocation = dictToGioPointKeyParam(dict: dict, key: "currentLocation")
        deviceToken = dictToStringKeyParam(dict: dict, key: "deviceToken")
        documentAdded = dictToBoolKeyParam(dict: dict, key: "documentAdded")
        documentFile = ModelDriverDocument(dict: dict["documentFile"] as? [String:Any] ?? [:])
        email = dictToStringKeyParam(dict: dict, key: "email")
        gender = dictToStringKeyParam(dict: dict, key: "gender")
        id = dictToStringKeyParam(dict: dict, key: "id")
        mobile = dictToStringKeyParam(dict: dict, key: "mobile")
        name = dictToStringKeyParam(dict: dict, key: "name")
        password = dictToStringKeyParam(dict: dict, key: "password")
        status = dictToStringKeyParam(dict: dict, key: "status")
        verified = dictToBoolKeyParam(dict: dict, key: "verified")
    }
}

class ModelCabDetail : NSObject {
   var brandName = ""
    var color = ""
    var modelName = ""
    var number = ""
    
    init(dict: [String : Any]) {
          brandName = dictToStringKeyParam(dict: dict, key: "brandName")
          color = dictToStringKeyParam(dict: dict, key: "color")
          modelName = dictToStringKeyParam(dict: dict, key: "modelName")
          number = dictToStringKeyParam(dict: dict, key: "number")
      }
}

class ModelDriverDocument: NSObject {
        var certificateRegistration = ""
        var commercialInsurance = ""
        var driverLicence = ""
        var penCard = ""
        var profilePicture = ""
        var touristPermit = ""

    init(dict: [String : Any]) {
        certificateRegistration = dictToStringKeyParam(dict: dict, key: "certificateRegistration")
        commercialInsurance = dictToStringKeyParam(dict: dict, key: "commercialInsurance")
        driverLicence = dictToStringKeyParam(dict: dict, key: "driverLicence")
        penCard = dictToStringKeyParam(dict: dict, key: "penCard")
        profilePicture = dictToStringKeyParam(dict: dict, key: "profilePicture")
        touristPermit = dictToStringKeyParam(dict: dict, key: "touristPermit")
      }
}
