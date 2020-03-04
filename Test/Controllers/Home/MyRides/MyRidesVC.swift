//
//  MyRidesVC.swift
//  Test
//
//  Created by Harshit on 27/02/20.
//  Copyright © 2020 Deependra. All rights reserved.
//

import UIKit

class MyRidesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var button1:UIButton!
    @IBOutlet weak var button2:UIButton!
    @IBOutlet weak var button3:UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet var viewForSide: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        button1.setTitle("ONGOING", for: .normal)
        button2.setTitle("COMPLETED", for: .normal)
        button3.setTitle("CANCLED", for: .normal)
        changeSegmentAction(sender: button1)
        menuButton.addTarget(revealViewController, action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.revealViewController().delegate=self
        revealViewController()?.rearViewRevealWidth = 60
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UserDefaults.standard.set(myRidesVC, forKey: "vc")
    }
    
    @IBAction func btnMenuAction(_ sender: UIButton) {
        viewForSide.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    // MARK: - ENSideMenu Delegate
    func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        switch position {
            
        case FrontViewPosition.leftSideMostRemoved:
            print("LeftSideMostRemoved")
            
        case FrontViewPosition.leftSideMost:
            print("LeftSideMost")
            
        case FrontViewPosition.leftSide:
            print("LeftSide")
            
        case FrontViewPosition.left:
            print("Left")
            
        case FrontViewPosition.right:
            print("Right")
            
        case FrontViewPosition.rightMost:
            print("RightMost")
            
        case FrontViewPosition.rightMostRemoved:
            print("RightMostRemoved")
        @unknown default:
            print("Unknown")
        }
    }
    func sideMenuWillOpen() {
        self.view.isUserInteractionEnabled=false;
        print("sideMenuWillOpen")
    }
    func sideMenuWillClose() {
        self.view.isUserInteractionEnabled=true;
        print("sideMenuWillClose")
    }
    func sideMenuShouldOpenSideMenu() -> Bool {
        print("sideMenuShouldOpenSideMenu")
        return true
    }
    func sideMenuDidClose() {
        print("sideMenuDidClose")
    }
    func sideMenuDidOpen() {
        print("sideMenuDidOpen")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - Tableview Extension
extension MyRidesVC {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CellMyRides", for: indexPath as IndexPath) as? CellMyRides {
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard.init(name: homeStoryBoard, bundle: Bundle.main).instantiateViewController(withIdentifier: cabVC) as? CabVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

//MARK: - Button Method extension
fileprivate extension MyRidesVC {
    
    @IBAction func changeSegmentAction(sender: UIButton) {
        self.view.endEditing(true)
        if sender.tag == 0 {
            button1.addBottomLineWithColor(color: appColor, lineHeight: 2, textColor: appColor)
            button2.addBottomLineWithColor(color: whiteColor, lineHeight: 2, textColor: grayColor)
            button3.addBottomLineWithColor(color: whiteColor, lineHeight: 2, textColor: grayColor)
        } else if sender.tag == 1 {
            button2.addBottomLineWithColor(color: appColor, lineHeight: 2, textColor: appColor)
            button1.addBottomLineWithColor(color: whiteColor, lineHeight: 2, textColor: grayColor)
            button3.addBottomLineWithColor(color: whiteColor, lineHeight: 2, textColor: grayColor)
        } else if sender.tag == 2 {
            button3.addBottomLineWithColor(color: appColor, lineHeight: 2, textColor: appColor)
            button2.addBottomLineWithColor(color: whiteColor, lineHeight: 2, textColor: grayColor)
            button1.addBottomLineWithColor(color: whiteColor, lineHeight: 2, textColor: grayColor)
        }
    }
}
