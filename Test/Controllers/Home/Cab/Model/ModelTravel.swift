//
//  ModelTravel.swift
//  Test
//
//  Created by Harshit on 02/05/20.
//  Copyright © 2020 Deependra. All rights reserved.
//

import UIKit

class ModelTravel: NSObject {
    var Description = ""
    var create = ""
    var icon = ""
    var name = ""
    var perMin = 0
    var pricePerKM = 0
    var startKM = 0
    var startMinute = 0
    var startPrice = 0
    var type = ""
    init(dict : [String:Any]) {
        Description = dictToStringKeyParam(dict: dict, key: "Description")
        create = dictToStringKeyParam(dict: dict, key: "create")
        icon = dictToStringKeyParam(dict: dict, key: "icon")
        name = dictToStringKeyParam(dict: dict, key: "name")
        perMin = dictToIntKeyParam(dict: dict, key: "perMin")
        pricePerKM = dictToIntKeyParam(dict: dict, key: "pricePerKM")
        startKM = dictToIntKeyParam(dict: dict, key: "startKM")
        startMinute = dictToIntKeyParam(dict: dict, key: "startMinute")
        startPrice = dictToIntKeyParam(dict: dict, key: "startPrice")
        type = dictToStringKeyParam(dict: dict, key: "type")
    }
}
