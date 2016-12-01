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
    
    @IBOutlet weak var txtUserName: LoginTextField!
    @IBOutlet weak var txtPassword: LoginTextField!
    
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
            btnLogin(Optional.none)
            return textField.resignFirstResponder()
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
    
    @IBAction func btnLogin(_ sender: UIButton?) {
        NSLog("Try to login!")
        var result: Bool?
        do {
            result = try checkLogin(userForcedLogin:"0")
        } catch LoginError.UserNameNil {
            NSLog("UserName is nil")
            MBProgressHUD.show(error: "请输入用户名", view: view)
        } catch LoginError.PasswordNil {
            NSLog("Password is nil")
            MBProgressHUD.show(error: "请输入密码", view: view)
        } catch LoginError.UserNameNotExistOrPasswordIncorrect {
            NSLog("UserName is not exist")
            MBProgressHUD.show(error: "用户名或者密码错误", view: view)
        } catch {
            
        }
        guard result == true else {
            NSLog("Unknown error")
            return
        }
        repeat {
            UserDefaults.standard.set(true, forKey: "login")
        } while UserDefaults.standard.synchronize() == false
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabController = storyBoard.instantiateViewController(withIdentifier: "main") as! MainTabViewController
        parent?.addChildViewController(mainTabController)
        parent?.transition(from: self
            , to: mainTabController, duration: 1.5, options: .transitionFlipFromRight, animations: {
                
            }, completion: { (finished) in
                
        })
    }
    
    func checkLogin(userForcedLogin: String) throws -> Bool {
        guard let userName = txtUserName.text, userName.characters.count > 0 else {
            throw LoginError.UserNameNil
        }
        guard let password = txtPassword.text, password.characters.count > 0 else {
            throw LoginError.PasswordNil
        }
        MBProgressHUD.showAdded(to: view, animated: true)
        let deviceAndiOSVersion = "\(UIDevice.current.deviceString()) + IOS\(iOSVersion)"
        let loginDic = [userNameKey:userName, userPassKey:password, userDeviceKey:deviceAndiOSVersion, userForcedLoginKey:userForcedLogin, deviceTypeKey:"2", appVersionKey:appVersion]
        NetRequestManager.shared.send(contentDic: loginDic, tid: .LOGINREQ, requestID: 4, success: { (dic, tid, requestId) in
            guard let rltCode = dic["rlt_code"] as? Int else {
                print("Invalid result code")
                return
            }
            switch rltCode {
            case 0:
                throw LoginError.UserNameNotExistOrPasswordIncorrect
            }
            }) { (error, tid) in
                
        }
        return true
    }
}

