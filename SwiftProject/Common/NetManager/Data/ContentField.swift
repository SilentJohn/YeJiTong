//
//  ContentField.swift
//  SwiftProject
//
//  Created by IOS on 2016/11/25.
//  Copyright © 2016年 IOS. All rights reserved.
//

import Foundation

class ContentField: Field {
    private var _contentDic: [AnyHashable:Any]?
    var contentDic: [AnyHashable:Any]? {
        set {
            _contentDic = newValue
            do {
                contentData = try JSONSerialization.data(withJSONObject: newValue, options: .prettyPrinted)
                if contentData != nil {
                    contentDataLen = contentData!.count
                    fieldContentLength = UInt32(getFieldLength())
                }
            } catch {
                print("error: \(error)")
            }
        }
        get {
            return _contentDic
        }
    }
    private var contentData: Data?
    private var contentDataLen: Int = 0
    
    func getFieldLength() -> Int {
        return MemoryLayout.size(ofValue: Int32.self) + contentDataLen
    }
    
    override func serialize(serializedData: inout Data) {
        super.serialize(serializedData: &serializedData)
        serializedData.append(Utility.data(fromUInt32: UInt32(contentDataLen)))
        serializedData.append(contentData!)
    }
}
