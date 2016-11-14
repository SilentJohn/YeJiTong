//
//  LoginViewController.swift
//  SwiftProject
//
//  Created by IOS on 2016/10/20.
//  Copyright © 2016年 IOS. All rights reserved.
//

import UIKit
import MBProgressHUD

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
    
    private enum LoginError: Error {
        case UserNameNil
        case UserNameNotExist
        case PasswordNil
        case PasswordIncorrect
    }
    
    @IBAction func btnLogin(_ sender: UIButton?) {
        NSLog("Try to login!")
        var result: Bool?
        do {
            result = try checkLogin()
        } catch LoginError.UserNameNil {
            NSLog("UserName is nil")
            MBProgressHUD.show(error: "用户名不能为空", view: view)
        } catch LoginError.PasswordNil {
            NSLog("Password is nil")
            MBProgressHUD.show(error: "密码不能为空", view: view)
        } catch LoginError.UserNameNotExist {
            NSLog("UserName is not exist")
            MBProgressHUD.show(error: "用户名不存在", view: view)
        } catch LoginError.PasswordIncorrect {
            NSLog("Password is incorrect")
            MBProgressHUD.show(error: "密码不正确", view: view)
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
    
    func checkLogin() throws -> Bool {
        guard txtUserName.text != nil && txtUserName.text != "" else {
            throw LoginError.UserNameNil
        }
        guard txtPassword.text != nil && txtPassword.text != "" else {
            throw LoginError.PasswordNil
        }
        return true
    }
}

