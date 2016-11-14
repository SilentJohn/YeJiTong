//
//  RootViewController.swift
//  SwiftProject
//
//  Created by IOS on 2016/10/25.
//  Copyright © 2016年 IOS. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//        self.navigationController!.isNavigationBarHidden = true
        if UserDefaults.standard.bool(forKey: "login") {
            let mainTabController = storyBoard.instantiateViewController(withIdentifier: "main") as! MainTabViewController
            self.addChildViewController(mainTabController)
            self.view.addSubview(mainTabController.view)
        } else {
            let loginController = storyBoard.instantiateViewController(withIdentifier: "login") as! LoginViewController
            self.addChildViewController(loginController)
            self.view.addSubview(loginController.view)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
