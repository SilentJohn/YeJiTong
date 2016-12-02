//
//  SettingTableViewController.swift
//  SwiftProject
//
//  Created by IOS on 2016/11/1.
//  Copyright © 2016年 IOS. All rights reserved.
//

import UIKit
import MBProgressHUD

class SettingTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 8:
            logOut()
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func logOut() {
        MBProgressHUD.show(messages: "注销成功", view: UIApplication.shared.keyWindow)
        repeat {
            UserDefaults.standard.set(false, forKey: loginStateKey)
        } while UserDefaults.standard.synchronize() == false
        var rootViewController = self.parent
        while rootViewController as? RootViewController == nil {
            rootViewController = rootViewController?.parent
        }
        var loginViewController: UIViewController?
        var currentNavigationController: UIViewController?
        if (rootViewController?.childViewControllers.count)! > 1 {
            for viewController in (rootViewController?.childViewControllers)! {
                if viewController.isKind(of: LoginViewController.self) {
                    loginViewController = viewController
                } else if viewController.isKind(of: MainTabViewController.self) {
                    currentNavigationController = viewController
                }
            }
        } else {
            currentNavigationController = (rootViewController?.childViewControllers[0])!
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            loginViewController = storyBoard.instantiateViewController(withIdentifier: "login") as! LoginViewController
            rootViewController?.addChildViewController(loginViewController!)
        }
        if currentNavigationController != nil && loginViewController != nil {
            rootViewController?.transition(from: currentNavigationController!
                , to: loginViewController!, duration: 1.5, options: .transitionFlipFromRight, animations: {
                    
                }, completion: { (finished) in
                    
            })
        }
    }
}
