//
//  AppShareClass.swift
//  Test
//
//  Created by Harshit on 27/02/20.
//  Copyright © 2020 Deependra. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import MapKit
import GooglePlaces

//MARK: - Identifire viewcontroller and storyboard

//colors
let appColor = #colorLiteral(red: 0.2235200405, green: 0.04756128043, blue: 0.06039769202, alpha: 1)
let grayColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
let whiteColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
let blackColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

//storyboardName
let mainStoryBoard = "Main"
//UIViewController name
let registerVC = "RegisterVC"
let loginVC = "LoginVC"
let otpVC = "OTPVC"
let uploadDocVC = "UploadDocVC"

let homeStoryBoard = "Home"
//UIViewController name
let myRidesVC = "MyRidesVC"
let cabVC = "CabVC"
let waitingForDriverVC = "WaitingForDriverVC"
let writeReviewVC = "WriteReviewVC"
let userProfileVC = "UserProfileVC"
let myMenuVC = "MyMenuVC"

//cell
let myMenuCell = "MyMenuCell"
let cellMyRides = "CellMyRides"
let commanGeoPoint = GeoPoint.init(latitude: 22.7764, longitude: 75.9548)
var currentLocationGeoPoint = GeoPoint.init(latitude: 22.7764, longitude: 75.9548)
var lastPointLocation = GeoPoint.init(latitude: 22.7764, longitude: 75.9548)
var currentAddress = ""
var modelUserDetail:ModelUserDetail?
var DictUserDetails:[String:Any]?
var kServerKey = "AAAA_DFNOHY:APA91bEaDgtdj3AcKgYjF7e0yEiOXHgF08LnUzQ03XDAafNYf2HJhIGJaNat808poAOy6DXKPClxudmXobIiSRgEaemP0qTE_5B_dubaaXZsZJs8ogV0R_SdpIsVjurBz5OVNARjx9Ce"
var firebaseToken = ""
var iosDeviceToken = ""
//MARK: - Navigation Method
func goToNextVC(storyBoardID: String, vc_id: String, currentVC: UIViewController) {
    let vc = UIStoryboard.init(name: storyBoardID, bundle: Bundle.main).instantiateViewController(withIdentifier: vc_id)
    currentVC.navigationController?.pushViewController(vc, animated: true)
}

func setRevelVC(storyBoardID: String, vc_id: String, currentVC: UIViewController) {
    let sb2 = UIStoryboard.init(name: storyBoardID, bundle:Bundle.main)
    let objChatHistory = sb2.instantiateViewController(withIdentifier: vc_id)
    let navigationcontroller = UINavigationController.init(rootViewController: objChatHistory)
    objChatHistory.navigationController?.navigationBar.isHidden = true
    currentVC.revealViewController().pushFrontViewController(navigationcontroller, animated: true)
}

////MARK: - DATE TIME PICKER
func getCurrentTimeStampWOMiliseconds(dateToConvert: NSDate) -> String {
    let objDateformat: DateFormatter = DateFormatter()
    objDateformat.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS+00:00"
    let strTime: String = objDateformat.string(from: dateToConvert as Date)
    let objUTCDate: NSDate = objDateformat.date(from: strTime)! as NSDate
    let milliseconds: Int64 = Int64(objUTCDate.timeIntervalSince1970)
    let strTimeStamp: String = "\(milliseconds)"
    return strTimeStamp
}

func getTimeFromTime(date:Date) -> String {
    let formatter  = DateFormatter()
    formatter.dateFormat = "dd MMM yyyy hh:mm a"
    formatter.dateFormat = "MMM DD yyyy hh:mm a"
    formatter.dateFormat = "E, d MMM yyyy hh:mm a"

    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
    let formatedDate: String = formatter.string(from: date)
    return formatedDate
}

//MARK: - Logic Calculation
func getDistanceOfTwoPoint(startPoint: String, endPoint: String) -> String {
    let arrStartPoint =  startPoint.components(separatedBy: ",")
    let arrEndPoint =  endPoint.components(separatedBy: ",")
    
    if arrStartPoint.count > 1 && arrEndPoint.count > 1 {
        let a = distance(lat1: Double(arrStartPoint[0])!,
                         lon1: Double(arrStartPoint[1])!,
                         lat2: Double(arrEndPoint[0])!,
                         lon2: Double(arrEndPoint[1])!, unit: "K")
        let doubleStr = String(format: "%.2f", a)
        return doubleStr
    }
    return "0"
}

func getDistanceOfTwoPointInGeoPoint(startPoint: GeoPoint, endPoint: GeoPoint) -> Double {
    
    let a = distance(lat1: startPoint.latitude,
                     lon1: startPoint.longitude,
                     lat2:endPoint.latitude,
                     lon2: endPoint.longitude, unit: "K")
        let doubleStr = String(format: "%.2f", a)
        return Double(doubleStr) ?? 0.00
    return 0.00
}
func getDistanceOfTwoPointInDouble(sourcePoint: GeoPoint, destinationPoint: GeoPoint) -> Double {
    
    let a = distance(lat1: sourcePoint.latitude,
                     lon1:sourcePoint.longitude,
                     lat2:destinationPoint.latitude,
                     lon2: destinationPoint.longitude, unit: "K")
        let doubleStr = String(format: "%.2f", a)
        return Double(doubleStr) ?? 0.00
}

    func distance(lat1:Double, lon1:Double, lat2:Double, lon2:Double, unit:String) -> Double {
        let theta = lon1 - lon2
        var dist = sin(deg2rad(deg: lat1)) * sin(deg2rad(deg: lat2)) + cos(deg2rad(deg: lat1)) * cos(deg2rad(deg: lat2)) * cos(deg2rad(deg: theta))
        dist = acos(dist)
        dist = rad2deg(rad: dist)
        dist = dist * 60 * 1.1515
        if (unit == "K") {
            dist = dist * 1.609344
        }
        else if (unit == "N") {
            dist = dist * 0.8684
        }
        return dist
    }
    
    func deg2rad(deg:Double) -> Double {
        return deg * M_PI / 180
    }

    ///////////////////////////////////////////////////////////////////////
    ///  This function converts radians to decimal degrees              ///
    ///////////////////////////////////////////////////////////////////////
    func rad2deg(rad:Double) -> Double {
        return rad * 180.0 / M_PI
    }

//MARK: - Data Parsing
func dictToStringKeyParam(dict: [String:Any], key: String) -> String {
    if let value = dict[key] as? String {
        return value
    } else if let value = dict[key] as? Int {
        return String(value)
    } else if let value = dict[key] as? Double {
        return String(value)
    } else if let value = dict[key] as? Float {
        return String(value)
    } else if let stamp = dict[key] as? Timestamp {
        return getTimeFromTime(date: stamp.dateValue())
    } else {
        return ""
    }
}
func dictToGeoPointKeyParam(dict: [String:Any], key: String) -> GeoPoint {
    let geoPoint = commanGeoPoint
    if let value = dict[key] as? GeoPoint {
        return value
    } else {
        return geoPoint
    }
}
func dictToDateKeyParam(dict: [String:Any], key: String) -> Date {
    if let value = dict[key] as? Date {
        return value
    } else {
        return Date()
    }
}
func dictToBoolKeyParam(dict: [String:Any], key: String) -> Bool {
    if let value = dict[key] as? Bool {
        return value
    } else if let value = dict[key] as? Int {
        return (value == 0) ? false : true
    } else if let value = dict[key] as? String {
       return (value == "0") ? false : true
    } else {
        return false
    }
}

func dictToGioPointKeyParam(dict: [String:Any], key: String) -> GeoPoint {
    let geoPoint = commanGeoPoint
    if let value = dict[key] as? GeoPoint {
        return value
    }
    return geoPoint
}

func dictToDoubleKeyParam(dict: [String:Any], key: String) -> Double {
    if let value = dict[key] as? Double {
        return value
    } else if let value = dict[key] as? Int {
        return Double(value)
    } else if let value = dict[key] as? String {
        return Double(value) ?? 00.00
    } else {
        return 0.0
    }
}

func dictToIntKeyParam(dict: [String:Any], key: String) -> Int {
    if let value = dict[key] as? Int {
        return value
    } else if let value = dict[key] as? String {
        return Int(value) ?? 0
    } else {
        return 0
    }
}

func getCordinate(dict: [String : Any], key: String) -> CLLocationCoordinate2D {
    var value = CLLocationCoordinate2D()
    if let obj = dict[key] as? CLLocationCoordinate2D {
        value = obj
    } else if let obj = dict[key] as? String {
        let arrEndPoint =  obj.components(separatedBy: ",")
        if arrEndPoint.count > 1 {
            let lat = Double(arrEndPoint[0]) ?? 22.7195687
            let long = Double(arrEndPoint[1]) ?? 75.8577258
            value.latitude = lat
            value.longitude = long
        } else {
            let lat =  22.7195687
            let long = 75.8577258
            value.latitude = lat
            value.longitude = long
        }
    }
    return value
}

//MARK: - Drow polyline
func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, mapView: MKMapView) -> MKMapView {

    let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
    let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)

    let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
    let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

    let sourceAnnotation = MKPointAnnotation()

    if let location = sourcePlacemark.location {
        sourceAnnotation.coordinate = location.coordinate
    }

    let destinationAnnotation = MKPointAnnotation()

    if let location = destinationPlacemark.location {
        destinationAnnotation.coordinate = location.coordinate
    }

    mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )

    let directionRequest = MKDirections.Request()
    directionRequest.source = sourceMapItem
    directionRequest.destination = destinationMapItem
    directionRequest.transportType = .automobile
    // Calculate the direction
    let directions = MKDirections(request: directionRequest)
    directions.calculate {
        (response, error) -> Void in

        guard let response = response else {
            if let error = error {
                print("Error: \(error)")
            }

            return
        }
        let route = response.routes[0]
        mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
        let rect = route.polyline.boundingMapRect
        mapView.setRegion(MKCoordinateRegion(rect), animated: true)
    }
    return mapView
}

