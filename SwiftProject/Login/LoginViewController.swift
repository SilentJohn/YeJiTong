//
//  LoginViewController.swift
//  SwiftProject
//
//  Created by IOS on 2016/10/20.
//  Copyright © 2016年 IOS. All rights reserved.
//

import UIKit
import MBProgressHUD
import FMDB

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
    
    enum LoginError: Error {
        case UserNameNil
        case PasswordNil
    }
    
    private func checkLogin(userForcedLogin: String) throws {
        self.view.endEditing(true)
        guard let userName = txtUserName.text, userName.characters.count > 0 else {
            throw LoginError.UserNameNil
        }
        guard let password = txtPassword.text, password.characters.count > 0 else {
            throw LoginError.PasswordNil
        }
        MBProgressHUD.showAdded(to: view, animated: true)
        let deviceAndiOSVersion = "\(UIDevice.current.deviceString()) + IOS\(iOSVersion)"
        let loginDic: [String:String] = [userNameKey:userName, userPassKey:password, userDeviceKey:deviceAndiOSVersion, userForcedLoginKey:userForcedLogin, deviceTypeKey:"2", appVersionKey:appVersion]
        NetRequestManager().send(contentDic: loginDic, tid: .LoginREQ, requestID: 4, success: { (dic, tid, requestId) in
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
                    do {
                        try self.checkLogin(userForcedLogin:"1")
                    } catch LoginError.UserNameNil {
                        NSLog("UserName is nil")
                        MBProgressHUD.show(error: "请输入用户名", view: self.view)
                    } catch LoginError.PasswordNil {
                        NSLog("Password is nil")
                        MBProgressHUD.show(error: "请输入密码", view: self.view)
                    } catch {
                        
                    }
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
        info[lastLoginTimeKey] = Date.getNowTime()
        info[lastLogoutTimeKey] = ""
        info[nodePushCodeKey] = userInfo["node_push_code"]
        info[validationCodeKey] = userInfo["validation_code"]
        info[birthdayKey] = userInfo["birthday"]
        info[sexKey] = userInfo["gender"]
        info[headImageURLKey] = userInfo["head_path"]
        info[addressesKey] = userInfo["node_address"]
        info[nameKey] = userInfo["node_person"]
        info[ageKey] = ""
        info[telKey] = userInfo["node_tel"]
        info[signatureKey] = userInfo["signature"]
        info[storeNameKey] = userInfo["store_name"]
        info[nodeTypeKey] = userInfo["node_type"]
        info[wechatUrlKey] = userInfo["wechat_url"]
        info[nodeIdKey] = userInfo["node_id"]
        info[newHeadKey] = "1"
        info[headLocalURLKey] = ""
        info[wechatLocalURLKey] = ""
        info[yejiMainRefreshKey] = ""
        info[trainingRefreshKey] = ""
        info[deliverTimeKey] = Date.getNowTime()
        info[messageIdKey] = "0"
        info[pkSelectOneKey] = "0"
        info[pkSelectTwoKey] = "0"
        let farPastTime = "1990-01-01 01:00:00"
        info[noticeListRefreshKey] = farPastTime
        info[exhibitStandardRefreshTimeKey] = farPastTime
        info[scriptListRefreshTimeKey] = farPastTime
        info[activityListRefreshKey] = farPastTime
        info[vistorListLoginCountKey] = "0"
        info[collegueListLoginCountKey] = "0"
        info[extra1Key] = "0"
        info[extra2Key] = "0"
        info[extra3Key] = "1"
        info[extra4Key] = "1900-1-1"
        info[extra5Key] = "0"
        info[extra6Key] = "0"
        info[extra7Key] = "0"
        info[extra8Key] = "0"
        info[extra9Key] = userInfo["parent_id"]
        info[extra10Key] = "0"
        info[extra11Key] = "0"
        info[extra12Key] = "0"
        info[extra13Key] = "0"
        info[extra14Key] = "0"
        info[extra15Key] = "0"
        info[extra16Key] = "0"
        info[extra17Key] = "0"
        info[extra18Key] = "0"
        info[extra19Key] = "0"
        info[extra20Key] = "0"
        
        UserDefaults.standard.set("", forKey: nodePushStateKey)
        
        if let nodeId = userInfo["node_id"] as? String {
            do {
                try ReadPath.createFilePath(nodeId)
            } catch {
                if let createError = error as? CreateFilePathError {
                    print(createError.localizedDescription)
                }
            }
        }
        
        SQLiteOperation.initAllTables()
        createTable()
        MBProgressHUD.hide(for: view, animated: true)
        UserDefaults.standard.set(true, forKey: loginStateKey)
        UserDefaults.standard.synchronize()
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabController = storyBoard.instantiateViewController(withIdentifier: "main") as! MainTabViewController
        parent?.addChildViewController(mainTabController)
        parent?.transition(from: self
            , to: mainTabController, duration: 0.5, options: .transitionFlipFromRight, animations: {
                
            }) { (finished) in
                
        }
    }
    
    private func createTable() {
        var result = true
        SQLiteOperation.dbQueue?.inDatabase() { (db) in
           let command = "CREATE TABLE IF NOT EXISTS MYDATA (ID INTEGER PRIMARY KEY AUTOINCREMENT,\(lastLoginTimeKey) TEXT,\(lastLogoutTimeKey) TEXT,\(nodePushCodeKey) TEXT,\(validationCodeKey) TEXT,\(nameKey) TEXT,\(ageKey) TEXT,\(sexKey) TEXT,\(addressesKey) TEXT,\(signatureKey) TEXT,\(telKey) TEXT,\(birthdayKey) TEXT,\(storeNameKey) TEXT,\(nodeIdKey) TEXT,\(nodeTypeKey) TEXT,\(pkSelectOneKey) TEXT,\(pkSelectTwoKey) TEXT,\(wechatUrlKey) TEXT,\(wechatLocalURLKey) TEXT,\(headImageURLKey) TEXT,\(headLocalURLKey) TEXT,\(newHeadKey) TEXT,\(yejiMainRefreshKey) TEXT,\(trainingRefreshKey) TEXT,\(deliverTimeKey) TEXT,\(messageIdKey) TEXT,\(noticeListRefreshKey) TEXT,\(exhibitStandardRefreshTimeKey) TEXT,\(scriptListRefreshTimeKey) TEXT,\(shufflePicLastUpdateTimeKey) TEXT,\(activityListRefreshKey) TEXT,\(vistorListLoginCountKey) TEXT,\(collegueListLoginCountKey) TEXT,\(extra1Key) TEXT,\(extra2Key) TEXT,\(extra3Key) TEXT,\(extra4Key) TEXT,\(extra5Key) TEXT,\(extra6Key) TEXT,\(extra7Key) TEXT,\(extra8Key) TEXT,\(extra9Key) TEXT,\(extra10Key) TEXT,\(extra11Key) TEXT,\(extra12Key) TEXT,\(extra13Key) TEXT,\(extra14Key) TEXT,\(extra15Key) TEXT,\(extra16Key) TEXT,\(extra17Key) TEXT,\(extra18Key) TEXT,\(extra19Key) TEXT,\(extra20Key) TEXT)"
            do {
                try db?.executeUpdate(command, values: [])
            } catch {
                print("Create table failed")
                result = false
            }
        }
        if result {
            if SQLiteOperation.isValue("1", existedForKey: "ID", inTable: "MYDATA") {
                if let oldPath = SQLiteOperation.getMyData(key: headLocalURLKey), let newPath = info[headImageURLKey] as? String, oldPath == newPath {
                    info[newHeadKey] = "0"
                    info.removeValue(forKey: headLocalURLKey)
                } else {
                    info[newHeadKey] = "1"
                    if let newPath = info[headImageURLKey] as? String {
                        if let imgUrl = URL(string: newPath) {
                            if let imageData = try? Data(contentsOf: imgUrl) {
                                if let headImage = UIImage(data: imageData), let basePath = ReadPath.getUserFile() {
                                    let newLocalHeadPath = ReadPath.save(image: headImage, withName: "MYHead", toPath: basePath)
                                    info[headLocalURLKey] = newLocalHeadPath
                                }
                            }
                        }
                    }
                }
                info.removeValue(forKey: yejiMainRefreshKey)
                info.removeValue(forKey: trainingRefreshKey)
                info.removeValue(forKey: lastLogoutTimeKey)
                info.removeValue(forKey: wechatLocalURLKey)
                info.removeValue(forKey: pkSelectOneKey)
                info.removeValue(forKey: pkSelectTwoKey)
                info.removeValue(forKey: deliverTimeKey)
                info.removeValue(forKey: messageIdKey)
                info.removeValue(forKey: noticeListRefreshKey)
                info.removeValue(forKey: exhibitStandardRefreshTimeKey)
                info.removeValue(forKey: scriptListRefreshTimeKey)
                info.removeValue(forKey: shufflePicLastUpdateTimeKey)
                info.removeValue(forKey: activityListRefreshKey)
                info.removeValue(forKey: vistorListLoginCountKey)
                info.removeValue(forKey: collegueListLoginCountKey)
                info.removeValue(forKey: extra1Key)
                info.removeValue(forKey: extra2Key)
                info.removeValue(forKey: extra3Key)
                info.removeValue(forKey: extra4Key)
                info.removeValue(forKey: extra5Key)
                info.removeValue(forKey: extra6Key)
                info.removeValue(forKey: extra7Key)
                info.removeValue(forKey: extra8Key)
                
                SQLiteOperation.modifyFrom(table: "MYDATA", keyValue: info, where: "ID='1'")
            } else {
                if let headUrlString = info[headImageURLKey] as? String, headUrlString != "" {
                    if let imgUrl = URL(string: headUrlString) {
                        if let imageData = try? Data(contentsOf: imgUrl) {
                            if let headImage = UIImage(data: imageData), let basePath = ReadPath.getUserFile() {
                                let newLocalHeadPath = ReadPath.save(image: headImage, withName: "MYHead", toPath: basePath)
                                info[headLocalURLKey] = newLocalHeadPath
                            }
                        }
                    }
                }
                SQLiteOperation.insertInto(table: "MYDATA", keyValue: info)
            }
            print("Personal info table created successfully")
        }
    }
}

