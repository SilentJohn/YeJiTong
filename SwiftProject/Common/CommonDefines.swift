//
//  CommonDefines.swift
//  SwiftProject
//
//  Created by IOS on 2016/12/1.
//  Copyright © 2016年 IOS. All rights reserved.
//

import UIKit
import SystemConfiguration

public enum TID: Int32 {
    case UNKNOWNREQRSP = 0x00000000
    case LOGINREQ
    case LOGINRSQ
    case LOGOUTREQ
    case LOGOUTRSP
}

public let iOSVersion = UIDevice.current.systemVersion
public let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String

public struct NodeInfo {
    static let nodeId: String = {
        if let nodeId = SQLiteOperation.getMyData(key: nodeIdKey) {
            return nodeId
        } else {
            return ""
        }
    }()
}

// MARK: - Common funtions

public let connetedToNetwork: Bool = {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
        }
    }) else {
        return false
    }
    
    var flags: SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
        return false
    }
    
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    
    return (isReachable && !needsConnection)
}()
