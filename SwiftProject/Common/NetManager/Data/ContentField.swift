//
//  ContentField.swift
//  SwiftProject
//
//  Created by IOS on 2016/11/25.
//  Copyright © 2016年 IOS. All rights reserved.
//

import Foundation

class ContentField: Field {
    var contentDic: [AnyHashable:Any]? {
        didSet {
            do {
                var tempDic = [AnyHashable:Any]()
                
                for (key, value) in contentDic! {
                    tempDic[key] = value
                }
                print("\(tempDic)")
                contentData = try JSONSerialization.data(withJSONObject: contentDic!, options: .prettyPrinted)
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
    
    func getFieldLength() -> Int {
        return MemoryLayout.size(ofValue: Int32.self) + contentDataLen
    }
    
    override func serialize(serializedData: inout Data) {
        super.serialize(serializedData: &serializedData)
        serializedData.append(Utility.data(fromUInt32: UInt32(contentDataLen)))
        serializedData.append(contentData!)
    }
}
