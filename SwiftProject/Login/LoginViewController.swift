//
//  LoginViewController.swift
//  SwiftProject
//
//  Created by IOS on 2016/10/20.
//  Copyright © 2016年 IOS. All rights reserved.
//

import UIKit
import MBProgressHUD

// MARK: - Login dictionary keys
let userNameKey = "user_name"
let userPassKey = "user_pwd"
let userDeviceKey = "device_info"
let userForcedLoginKey = "forced_login"
let appVersionKey = "app_version"
let deviceTypeKey = "device_type"

class LoginViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet private weak var txtUserName: LoginTextField!
    @IBOutlet private weak var txtPassword: LoginTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction(sender:))))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        txtUserName.text = nil
        txtPassword.text = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func keyboardWillChangeFrame(notification: NSNotification) {
        if let firstResponder: LoginTextField = txtUserName.isFirstResponder ? txtUserName : txtPassword.isFirstResponder ? txtPassword : nil {
            let keyboardRect = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue
            let intersectionRect: CGRect = firstResponder.frame.intersection((keyboardRect?.cgRectValue)!)
            if !intersectionRect.equalTo(CGRect.null) {
                let animateDuration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as? NSNumber
                let animateOptions = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
                UIView.animate(withDuration: (animateDuration?.doubleValue)!, delay: 0, options: UIViewAnimationOptions(rawValue: (animateOptions?.uintValue)! << 16), animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: intersectionRect.size.height > 0 ? -intersectionRect.size.height : 0)
                    }, completion: { (finished) in
                        
                })
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtUserName {
            if textField.returnKeyType == .next {
                return txtPassword.becomeFirstResponder()
            }
            return false
        } else if textField == txtPassword {
            textField.resignFirstResponder()
            btnLogin(Optional.none)
            return true
        }
        return false
    }
    
    func tapAction(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view == view {
            return true
        }
        return false
    }
    
    @IBAction private func btnLogin(_ sender: UIButton?) {
        NSLog("Try to login!")
        do {
            try checkLogin(userForcedLogin:"0")
        } catch LoginError.UserNameNil {
            NSLog("UserName is nil")
            MBProgressHUD.show(error: "请输入用户名", view: view)
        } catch LoginError.PasswordNil {
            NSLog("Password is nil")
            MBProgressHUD.show(error: "请输入密码", view: view)
        } catch {
            
        }
    }
    
    private func checkLogin(userForcedLogin: String) throws {
        guard let userName = txtUserName.text, userName.characters.count > 0 else {
            throw LoginError.UserNameNil
        }
        guard let password = txtPassword.text, password.characters.count > 0 else {
            throw LoginError.PasswordNil
        }
        MBProgressHUD.showAdded(to: view, animated: true)
        let deviceAndiOSVersion = "\(UIDevice.current.deviceString()) + IOS\(iOSVersion)"
        let loginDic: [String:String] = [userNameKey:userName, userPassKey:password, userDeviceKey:deviceAndiOSVersion, userForcedLoginKey:userForcedLogin, deviceTypeKey:"2", appVersionKey:appVersion]
        NetRequestManager.shared.send(contentDic: loginDic, tid: .LOGINREQ, requestID: 4, success: { (dic, tid, requestId) in
            MBProgressHUD.hide(for: self.view, animated: true)
            guard let rltCode = dic["rlt_code"] as? Int else {
                print("Invalid result code")
                return
            }
            switch rltCode {
            case 0:
                MBProgressHUD.show(error: "用户名或者密码错误", view: self.view)
            case 1:
                self.didLogin(userInfo: dic)
            case 2:
                MBProgressHUD.show(error: "该账号处于停用状态", view: self.view)
            case 3:
                MBProgressHUD.show(messages: "软件版本过低，请及时升级", view: self.view)
            case 4:
                let alert = UIAlertController(title: "提示", message: "该账号已在其它设备登录，是否强行登录？", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                    
                })
                let forcedLogin = UIAlertAction(title: "强制登录", style: .destructive, handler: { (action) in
                    try! self.checkLogin(userForcedLogin: "1")
                })
                alert.addAction(cancel)
                alert.addAction(forcedLogin)
                self.present(alert, animated: true)
            default:
                print("Unrecognized result code")
            }
            }) { (error, tid) in
                MBProgressHUD.hide(for: self.view, animated: true)
                MBProgressHUD.show(error: error, view: self.view)
        }
    }
    
    // MARK: - The dictionary will be filled and saved into db
    var info: [String:Any] = [:]
    
    private func didLogin(userInfo: [AnyHashable:Any]) {
        // MARK: - Save some personal info into UserDefaults
        UserDefaults.standard.set(txtUserName.text!, forKey: loginUserNameKey)
        UserDefaults.standard.set(userInfo["node_id"], forKey: YJTUserNodeIdKey)
        UserDefaults.standard.set(txtPassword.text!, forKey: YJTPasswordKey)
        UserDefaults.standard.set(true, forKey: runWebServiceKey)
        UserDefaults.standard.set(userInfo["node_push_code"], forKey: nodePushCodeKey)
        
        // MARK: - Save some personal info into db
        info[lastLoginTimeKey] = getNowTime()
        info[lastLogoutTimeKey] = ""
        info[nodePushCodeKey] = userInfo["node_push_code"]
        info[validationCodeKey] = userInfo["validation_code"]
        info[birthdayKey] = userInfo["birthday"]
//        info[]
        
        UserDefaults.standard.set(true, forKey: loginStateKey)
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabController = storyBoard.instantiateViewController(withIdentifier: "main") as! MainTabViewController
        parent?.addChildViewController(mainTabController)
        parent?.transition(from: self
            , to: mainTabController, duration: 1.5, options: .transitionFlipFromRight, animations: {
                
            }, completion: { (finished) in
                
        })
    }
}

