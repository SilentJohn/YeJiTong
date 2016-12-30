//
//  Extensions.swift
//  SwiftProject
//
//  Created by IOS on 2016/10/24.
//  Copyright © 2016年 IOS. All rights reserved.
//

import Foundation
import MBProgressHUD

extension MBProgressHUD {
    @discardableResult
    class func show(messages: String, view: UIView?) -> MBProgressHUD {
        let backView = view == nil ? UIApplication.shared.keyWindow! : view!
        let hud = MBProgressHUD.showAdded(to: backView, animated: true)
        hud.bezelView.color = UIColor.black
        hud.bezelView.alpha = 0.9
        hud.contentColor = UIColor.white
        hud.detailsLabel.text = messages
        hud.mode = .text
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 1.5)
        return hud
    }
    
    @discardableResult
    class func show(error: String, view: UIView?) -> MBProgressHUD {
        let backView = view == nil ? UIApplication.shared.keyWindow! : view!
        let hud = MBProgressHUD.showAdded(to: backView, animated: true)
        hud.bezelView.color = UIColor.black
        hud.bezelView.alpha = 0.9
        hud.contentColor = UIColor.white
        hud.label.text = error
        hud.mode = .customView
        hud.customView = UIImageView(image: UIImage(named: "error"))
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 1.5)
        return hud
    }
}

extension UIDevice {
    func deviceString() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":
            return "iPhone 4"
        case "iPhone4,1":
            return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":
            return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":
            return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":
            return "iPhone 5s"
        case "iPhone7,1", "iPhone7,2":
            return "iPhone 6"
        case "iPhone7,2":
            return "iPhone 6 Plus"
        case "iPhone8,1":
            return "iPhone 6s"
        case "iPhone8,2":
            return "iPhone 6s Plus"
        case "iPod1,1":
            return "iPod Touch 1G "
        case "iPod2,1":
            return "iPod Touch 2G "
        case "iPod3,1":
            return "iPod Touch 3G "
        case "iPod4,1":
            return "iPod Touch 4G "
        case "iPod5,1":
            return "iPod Touch 5G "
        case "iPad1,1":
            return "iPad 1G "
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
            return "iPad 2 "
        case "iPad2,5", "iPad2,6", "iPad2,7":
            return "iPad Mini 1G "
        case "iPad3,1", "iPad3,2", "iPad3,3":
            return "iPad 3 "
        case "iPad3,4", "iPad3,5", "iPad3,6":
            return "iPad 4 "
        case "iPad4,1", "iPad4,2", "iPad4,3":
            return "iPad Air "
        case "iPad4,4", "iPad4,5", "iPad4,6":
            return "iPad Mini 2G "
        case "x86_64", "i386":
            return "Simulator"
            
        default:
            return identifier
        }
    }
}

extension Date {
    static func getNowTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
}

extension String {
    public func transformToPinyin() -> String {
        let str = NSMutableString(string: self) as CFMutableString
        if CFStringTransform(str, nil, kCFStringTransformToLatin, false) {
            if CFStringTransform(str, nil, kCFStringTransformStripDiacritics, false) {
                print("\(str)")
            }
        }
        return String(str)
    }
}
