//
//  PickerViewVC.swift
//  Test
//
//  Created by Harshit on 12/03/20.
//  Copyright © 2020 Deependra. All rights reserved.
//

import UIKit

class PickerViewVC: UIViewController {
   
    @IBOutlet weak var picker:UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.picker.minimumDate = Date()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backAction(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
