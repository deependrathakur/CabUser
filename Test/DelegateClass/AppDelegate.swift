//
//  AppDelegate.swift
//  Test
//
//  Created by Harshit on 25/02/20.
//  Copyright © 2020 Deependra. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces
import FirebaseAuth
import UserNotifications
import NotificationCenter
import FirebaseMessaging
import FirebaseInstanceID
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate,UNUserNotificationCenterDelegate,MessagingDelegate {
    var locationManager = CLLocationManager()
    
    var window: UIWindow?
    var navigationcontroller:UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        self.configureNotification()
        GMSPlacesClient.provideAPIKey("AIzaSyDhb3bII6A6O0CCogK08U6aWpExoLmf-aQ")// info.plist
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = false
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = false
        } else {
            // Fallback on earlier versions
        }
        locationManager.startUpdatingLocation()
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func getUserDetailFromFirebase() {
        if let userId = UserDefaults.standard.string(forKey: "userId") {
            if userId != "" {
                Firestore.firestore().collection("user").document(userId).getDocument() { (querySnapshot, err) in
                    if let err = err {
                    } else {
                        let document = querySnapshot
                        let dict = document?.data()
                        UserDefaults.standard.set(document?.documentID, forKey: "userId")
                        DictUserDetails = dict
                        UserDefaults.standard.set(true, forKey: "isLogin")
                        modelUserDetail = ModelUserDetail.init(Dict: DictUserDetails ?? ["":""])
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let latitude = location?.coordinate.latitude ?? 00.00
        let longitude = location?.coordinate.longitude ?? 0.0
        
        let distanceFromLastLocation = getDistanceOfTwoPointInGeoPoint(startPoint: GeoPoint.init(latitude: latitude, longitude: longitude), endPoint: lastPointLocation)
            let meter = (distanceFromLastLocation * 1000)
            if meter > 3 {
                lastPointLocation = GeoPoint.init(latitude: latitude, longitude: longitude)
                currentLocationGeoPoint = GeoPoint.init(latitude: latitude, longitude: longitude)
                if let userId = UserDefaults.standard.string(forKey: "userId") {
                    if userId != "" {
                        Firestore.firestore().collection("user").document(userId).updateData(["currentLocation":currentLocationGeoPoint])
                   }
                }
            }
        
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = false
        } else {
            // Fallback on earlier versions
        }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation((location ?? nil)!) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            if placemarks != nil{
                let placemark = placemarks! as [CLPlacemark]
                if placemark.count > 0 {
                    let placemark = placemarks![0]
                    
                    let address = String(placemark.subLocality ?? "")+" "+String(placemark.name ?? "")
                    let address2 = String(placemark.locality ?? "")+" "+String(placemark.administrativeArea ?? "")+" "+String(placemark.country ?? "")
                    currentAddress  = address+address2
                }}
        }
        
    }
}

//MARK: Notification method
extension AppDelegate {
    //MARK: - Remote Notification Get Device token methods.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        if deviceTokenString.count > 0 {
            iosDeviceToken = deviceTokenString
        }
        
        InstanceID.instanceID().instanceID(handler: { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID(Token): \(error)")
            }else if let result = result{
                print("Remote instance ID token: \(result.token)")
                firebaseToken = "\(result.token)"
            }
        })
        
        let firebaseAuth = Auth.auth()
          //At development time we use .sandbox
          firebaseAuth.setAPNSToken(deviceToken, type: AuthAPNSTokenType.sandbox)

    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error)")
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // Print message ID.
        //      if let messageID = userInfo[gcm] {
        //        print("Message ID: \(messageID)")
        //      }
        
        // Print full message.
        let firebaseAuth = Auth.auth()

        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        ////      // Print message ID.
        //      if let messageID = userInfo[gcmMessageIDKey] {
        //        print("Message ID: \(messageID)")
        //      }
        
        // Print full message.
        print(userInfo)
        let firebaseAuth = Auth.auth()

        completionHandler(UIBackgroundFetchResult.newData)
    }

    func configureNotification() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            UNUserNotificationCenter.current().delegate = self
            
            let openAction = UNNotificationAction(identifier: "OpenNotification", title: NSLocalizedString("Abrir", comment: ""), options: UNNotificationActionOptions.foreground)
            let deafultCategory = UNNotificationCategory(identifier: "CustomSamplePush", actions: [openAction], intentIdentifiers: [], options: [])
            center.setNotificationCategories(Set([deafultCategory]))
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
        }
        UIApplication.shared.registerForRemoteNotifications()
    }


    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        firebaseToken = fcmToken
        print("firebaseToken = \(firebaseToken)")
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        firebaseToken = fcmToken
        print("firebaseToken = \(firebaseToken)")
        ConnectToFCM()
    }
    
    func tokenRefreshNotification(_ notification: Notification) {
        InstanceID.instanceID().instanceID(handler: { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID(Token): \(error)")
            }else if let result = result{
                print("Remote instance ID token: \(result.token)")
                firebaseToken = "\(result.token)"
            }
        })
        ConnectToFCM()
    }
    
    // Receive data message on iOS 10 devices while app is in the foreground.
    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
    }
    
    func ConnectToFCM() {
        InstanceID.instanceID().instanceID(handler: { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID(Token): \(error)")
            }else if let result = result{
                print("Remote instance ID token: \(result.token)")
                firebaseToken = "\(result.token)"
            }
        })
    }
}
