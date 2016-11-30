//
//  ReadPath.swift
//  SwiftProject
//
//  Created by IOS on 2016/11/25.
//  Copyright © 2016年 IOS. All rights reserved.
//

let kYJTUserName = "YJTuserName"

import Foundation

class ReadPath {
    class func documentPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    class func getUserFile() -> String {
        var userPath = ""
        if let userName = UserDefaults.standard.string(forKey: kYJTUserName) {
            userPath = NSString(string: ReadPath.documentPath()).appendingPathComponent(userName)
        }
        return userPath
    }
}
