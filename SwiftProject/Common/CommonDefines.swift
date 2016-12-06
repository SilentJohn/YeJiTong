//
//  CommonDefines.swift
//  SwiftProject
//
//  Created by IOS on 2016/12/1.
//  Copyright © 2016年 IOS. All rights reserved.
//

import UIKit

public enum LoginError: Error {
    case UserNameNil
    case PasswordNil
}

public enum TID: Int32 {
    case UNKNOWNREQRSP = 0x00000000
    case LOGINREQ
    case LOGINRSQ
}

public let iOSVersion = UIDevice.current.systemVersion
public let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String

// MARK: - Login keys and values
public let forcibleLoginVersionKey = "forcibleLoginVersion"
public let forcibleLoginVersionValue = "1"

public let loginStateKey = "kLoginState"
public let YJTUserNodeIdKey = "YJTuserNodeId"
public let YJTPasswordKey = "YJTPassword"
public let runWebServiceKey = "RunwebService"
public let loginUserNameKey = "loginUserName"
public let nodePushCodeKey = "NodePushCode"
public let nodePushStateKey = "NodePushState"
public let lastLoginTimeKey = "LastLoginTime"
public let lastLogoutTimeKey = "LastLogoutTime"
public let validationCodeKey = "ValidationCode"
public let birthdayKey = "kBirthday"
public let sexKey = "kSex"
public let headImageURLKey = "kHeadImageURL"
public let addressesKey = "kAddresses"
public let nameKey = "kName"
//public 

// MARK: - Common funtions
func getNowTime() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter.string(from: Date())
}
