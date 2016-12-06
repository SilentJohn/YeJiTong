//
//  TextField.swift
//  SwiftProject
//
//  Created by IOS on 2016/11/15.
//  Copyright © 2016年 IOS. All rights reserved.
//

import Foundation

class TextField: Field {
    var jsonLen: Int = 0
    var json: String?
    
    func setJsonString(rootDict: [AnyHashable:Any]) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: rootDict, options: .prettyPrinted) else {
            json = nil
            jsonLen = 0
            fieldContentLength = 0
            return
        }
        json = String(data: jsonData, encoding: .utf8)
        jsonLen = json!.lengthOfBytes(using: .utf8)
        fieldContentLength = UInt32(getFieldLength())
    }
    
    func getFieldLength() -> Int {
        return MemoryLayout.size(ofValue: jsonLen) + jsonLen
    }
    
    override func serialize(serializedData: inout Data) {
        super.serialize(serializedData: &serializedData)
        serializedData.append(Utility.data(fromUInt32: UInt32(jsonLen)))
        if let jsonData = json?.data(using: .utf8) {
            serializedData.append(jsonData)
        }
    }
    override func deserialize(fromData: Data, start: Data.Index, end: Data.Index) -> Bool {
        guard super.deserialize(fromData: fromData, start: start, end: end) else {
            NSLog("Field deserialize failed")
            return false
        }
        let fieldHeaderLen = Field.getFieldHeaderLength()
        var curIndex = start.advanced(by: fieldHeaderLen)
        guard curIndex.advanced(by: MemoryLayout<UInt32>.size) <= end else {
            NSLog("Cannot figure out text field json length")
            return false
        }
        jsonLen = Utility.int(fromData: fromData, start: curIndex, length: MemoryLayout<UInt32>.size)
        curIndex = curIndex.advanced(by: MemoryLayout<UInt32>.size)
        guard curIndex.advanced(by: MemoryLayout<UInt32>.size) <= end else {
            NSLog("json too short")
            return false
        }
        json = String(data: fromData.subdata(in: Range(curIndex..<curIndex.advanced(by: jsonLen))), encoding: .utf8)
        return true
    }
}
