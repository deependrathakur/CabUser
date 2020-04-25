//
//  ModelUserDetail.swift
//  Test
//
//  Created by Harshit on 25/04/20.
//  Copyright © 2020 Deependra. All rights reserved.
//

import UIKit
import Firebase

class ModelUserDetail: NSObject {
    var available:Bool?
    var busy:Bool?
    var cabAdded:Bool?
    var cab_type:String?
    var create:Date?
    var currentLocation:GeoPoint?
    var deviceToken:String?
    var documentAdded:Bool?
    var email:String?
    var gender:String?
    var id:String?
    var mobile:String?
    var name:String?
    var password:String?
    var status:Int?
    var verified:Bool?
    
    init(Dict: [String : Any]) {
        available = dictToBoolKeyParam(dict: Dict, key: "available")
        busy = dictToBoolKeyParam(dict: Dict, key: "busy")
        cabAdded = dictToBoolKeyParam(dict: Dict, key: "cabAdded")
        cab_type = dictToStringKeyParam(dict: Dict, key: "cab_type")
        create = dictToDateKeyParam(dict: Dict, key: "create")
        currentLocation = dictToGeoPointKeyParam(dict: Dict, key: "currentLocation")
        deviceToken = dictToStringKeyParam(dict: Dict, key: "deviceToken")
        documentAdded = dictToBoolKeyParam(dict: Dict, key: "documentAdded")
        email = dictToStringKeyParam(dict: Dict, key: "email")
        gender = dictToStringKeyParam(dict: Dict, key: "gender")
        id = dictToStringKeyParam(dict: Dict, key: "id")
        mobile = dictToStringKeyParam(dict: Dict, key: "mobile")
        name = dictToStringKeyParam(dict: Dict, key: "name")
        password = dictToStringKeyParam(dict: Dict, key: "password")
        status = dictToIntKeyParam(dict: Dict, key: "status")
        verified = dictToBoolKeyParam(dict: Dict, key: "verified")
    }
}
