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
        let alertExit = UIAlertController(title: "确认退出", message: "退出后不会删除任何历史数据，下次登录依然可以使用本账号。", preferredStyle: .actionSheet)
        alertExit.addAction(UIAlertAction(title: "取消", style: .cancel) { action in
            
        })
        alertExit.addAction(UIAlertAction(title: "确定", style: .destructive) { action in
            if connetedToNetwork {
                MBProgressHUD.showAdded(to: self.view, animated: true)
                NetRequestManager().send(tid: .LOGOUTREQ, requestID: 2, success: { (dic, tid, requestId) in
                    MBProgressHUD.hide(for: self.view, animated: true)
                    guard let rltCode = dic["rlt_code"] as? Int else {
                        print("Invalid result code")
                        return
                    }
                    if rltCode == 1 {
                        UserDefaults.standard.set("", forKey: nodePushStateKey)
                        UserDefaults.standard.set(false, forKey: runWebServiceKey)
                        UserDefaults.standard.set(false, forKey: loginStateKey)
                        SQLiteOperation .saveMyData(dic: [lastLogoutTimeKey:Date.getNowTime()])
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        guard let loginViewController = storyBoard.instantiateViewController(withIdentifier: "login") as? LoginViewController else {
                            print("Check if LoginViewController exists in Main.storyboard")
                            return
                        }
                        self.parent?.parent?.parent?.addChildViewController(loginViewController)
                        self.parent?.parent?.parent?.transition(from: self.parent!.parent!
                            , to: loginViewController, duration: 0.5, options: .transitionFlipFromRight, animations: {
                                
                        }) { (finished) in
                            MBProgressHUD.show(messages: "注销成功", view: loginViewController.view)
                        }
                    } else {
                        MBProgressHUD.show(error: "注销失败", view: self.view)
                    }
                    }, failure: { (error, tid) in
                        print("\(error)")
                        MBProgressHUD.hide(for: self.view, animated: true)
                        MBProgressHUD.show(error: error, view: self.view)
                })
            }
        })
        self .present(alertExit, animated: true)
    }
}
