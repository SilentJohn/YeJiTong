//
//  CommonDefines.swift
//  SwiftProject
//
//  Created by IOS on 2016/12/1.
//  Copyright © 2016年 IOS. All rights reserved.
//

import UIKit

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
public let ageKey = "kAge"
public let telKey = "kTel"
public let signatureKey = "kSignature"
public let storeNameKey = "kStore_name"
public let nodeTypeKey = "kNode_type"
public let wechatUrlKey = "kWechat_url"
public let nodeIdKey = "kNode_id"
public let newHeadKey = "kNewHead"
public let headLocalURLKey = "kHeadLocalURL"
public let wechatLocalURLKey = "kWechatLocalURL"
public let yejiMainRefreshKey = "kYeJiMainRefresh"
public let trainingRefreshKey = "kTrainingRefresh"
public let deliverTimeKey = "delivertime"
public let messageIdKey = "messageId"
public let pkSelectOneKey = "kPKSelectOne"
public let pkSelectTwoKey = "kPKSelectTwo"
public let noticeListRefreshKey = "kNoticeListRefresh"
public let exhibitStandardRefreshTimeKey = "exhibitStandardRefreshTime"
public let scriptListRefreshTimeKey = "kScriptListRefreshTime"
public let shufflePicLastUpdateTimeKey = "last_update"
public let activityListRefreshKey = "kActivityListRefresh"
public let vistorListLoginCountKey = "vistorListLoginCount"
public let collegueListLoginCountKey = "collegueListLoginCount"
public let extra1Key = "extra1"
public let extra2Key = "extra2"
public let extra3Key = "extra3"
public let extra4Key = "extra4"
public let extra5Key = "extra5"
public let extra6Key = "extra6"
public let extra7Key = "extra7"
public let extra8Key = "extra8"
public let extra9Key = "extra9"
public let extra10Key = "extra10"
public let extra11Key = "extra11"
public let extra12Key = "extra12"
public let extra13Key = "extra13"
public let extra14Key = "extra14"
public let extra15Key = "extra15"
public let extra16Key = "extra16"
public let extra17Key = "extra17"
public let extra18Key = "extra18"
public let extra19Key = "extra19"
public let extra20Key = "extra20"

// MARK: - Common funtions
func getNowTime() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter.string(from: Date())
}
