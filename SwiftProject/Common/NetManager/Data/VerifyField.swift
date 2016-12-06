//
//  VerifyField.swift
//  SwiftProject
//
//  Created by IOS on 2016/11/24.
//  Copyright © 2016年 IOS. All rights reserved.
//

import Foundation

let kNodeId = "kNode_id"

class VerifyField: Field {
    
    private var contentDic: [AnyHashable:Any] = [:] {
        didSet {
            do {
                contentData = try JSONSerialization.data(withJSONObject: contentDic, options: .prettyPrinted)
                if contentData != nil {
                    contentDataLen = contentData!.count
                    fieldContentLength = UInt32(getFieldLength())
                }
            } catch {
                print("error: \(error)")
            }
        }
    }
    private var contentData: Data?
    private var contentDataLen: Int = 0
    
    required override init(fieldID: UInt16) {
        super.init(fieldID: fieldID)
        var dic: [AnyHashable:Any] = [AnyHashable:Any]()
        dic["app_version"] = appVersion
        dic["validation_code"] = SQLiteOperation.getMyData(key: validationCodeKey)
        dic["devide_type"] = "2"
        dic["node_id"] = SQLiteOperation.getMyData(key: kNodeId)
        contentDic = dic
    }
    
    static func field() -> Self {
        return self.init(fieldID: 0x0005)
    }
    
    func getFieldLength() -> Int {
        return MemoryLayout<Int32>.size + contentDataLen
    }
    
    override func serialize(serializedData: inout Data) {
        super.serialize(serializedData: &serializedData)
        serializedData.append(Utility.data(fromUInt32: UInt32(contentDataLen)))
        serializedData.append(contentData!)
    }
}
