//
//  AttatchmentField.swift
//  SwiftProject
//
//  Created by IOS on 2016/11/25.
//  Copyright © 2016年 IOS. All rights reserved.
//

import Foundation

class AttatchmentField: Field {
    private var _contentDic: [AnyHashable:Any]?
    var contentDic: [AnyHashable:Any]? {
        set {
            _contentDic = newValue
            do {
                contentData = try JSONSerialization.data(withJSONObject: newValue, options: .prettyPrinted)
                if contentData != nil {
                    contentDataLen = contentData!.count
                }
                fieldContentLength = UInt32(getFieldLength())
            } catch  {
                print("error: \(error)")
            }
        }
        get {
            return _contentDic
        }
    }
    
    private var contentData: Data?
    
    private var _attatchmentData: Data?
    var attatchmentData: Data? {
        set {
            if newValue == nil {
                attatchmentDataLen = 0
            } else {
                attatchmentDataLen = newValue!.count
                _attatchmentData = newValue
                fieldContentLength = UInt32(getFieldLength())
            }
        }
        get {
            return _attatchmentData
        }
    }
    
    private var contentDataLen: Int = 0
    private var attatchmentDataLen: Int = 0
    
    func getFieldLength() -> Int {
        return 2 * MemoryLayout.size(ofValue: Int32.self) + contentDataLen + attatchmentDataLen
    }
    
    override func serialize(serializedData: inout Data) {
        super.serialize(serializedData: &serializedData)
        serializedData.append(Utility.data(fromUInt32: UInt32(contentDataLen)))
        serializedData.append(contentData!)
        serializedData.append(Utility.data(fromUInt32: UInt32(attatchmentDataLen)))
        serializedData.append(attatchmentData!)
    }
}
