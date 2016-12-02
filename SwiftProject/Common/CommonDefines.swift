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
public let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")

// MARK: - Login keys and values
public let forcibleLoginVersionKey = "forcibleLoginVersion"
public let forcibleLoginVersionValue = "1"

public let loginStateKey = "kLoginState"
