//
//  NetRequestManager.swift
//  SwiftProject
//
//  Created by IOS on 2016/11/9.
//  Copyright © 2016年 IOS. All rights reserved.
//

import UIKit

let soapNamespace: String = "http://WebService.teddy.com"
let soapEndpoint: String = "http://115.28.42.18:18084/axis2/services/YeJiTongService?wsdl"
let methodName: String = "handleService"


class NetRequestManager: NSObject {
    
    static let shared = NetRequestManager()
    private override init() {
        super.init()
    }
    
    func send(contentDic: [String:AnyObject?], tid: Int, requestID: Int, success: (@escaping ([String:AnyObject], Int, Int) -> Void), failure: (@escaping (String, Int) -> Void)) {
        
    }
    private func contrustPackageData(contentDic: [String:AnyObject?], tid: Int, requestID: Int) -> AnyObject? {
        
        return nil
    }
}
