//
//  AppShareClass.swift
//  Test
//
//  Created by Harshit on 27/02/20.
//  Copyright © 2020 Deependra. All rights reserved.
//

import Foundation
import UIKit

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

func goToNextVC(storyBoardID: String, vc_id: String, currentVC: UIViewController) {
    let vc = UIStoryboard.init(name: storyBoardID, bundle: Bundle.main).instantiateViewController(withIdentifier: vc_id)
    currentVC.navigationController?.pushViewController(vc, animated: true)
}
