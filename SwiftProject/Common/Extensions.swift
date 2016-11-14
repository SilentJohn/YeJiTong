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
    class func show(messages: String, view: UIView?) {
        let backView = view == nil ? UIApplication.shared.keyWindow! : view!
        let hud = MBProgressHUD.showAdded(to: backView, animated: true)
        hud.bezelView.color = UIColor.black
        hud.bezelView.alpha = 0.9
        hud.contentColor = UIColor.white
        hud.detailsLabel.text = messages
        hud.mode = .text
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 1.5)
    }
    
    class func show(error: String, view: UIView?) {
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
    }
}
