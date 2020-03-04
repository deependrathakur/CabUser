//
//  WaitingForDriverVC.swift
//  Test
//
//  Created by Harshit on 29/02/20.
//  Copyright © 2020 Deependra. All rights reserved.
//

import UIKit

class WaitingForDriverVC: UIViewController {
    @IBOutlet weak var txtPicupLocation:UITextField!
    @IBOutlet weak var txtDroupLocation:UITextField!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblNumberDetail:UILabel!
    @IBOutlet weak var imgUser:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
//MARK: - Button Method extension
extension WaitingForDriverVC {
    
    @IBAction func MenuAction(sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func CallAction(sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func reviewAction(sender: UIButton) {
        self.view.endEditing(true)
        let vc = UIStoryboard.init(name: homeStoryBoard, bundle: Bundle.main).instantiateViewController(withIdentifier: writeReviewVC) as? WriteReviewVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
