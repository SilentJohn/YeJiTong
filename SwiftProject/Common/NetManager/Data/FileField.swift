//
//  FileField.swift
//  SwiftProject
//
//  Created by IOS on 2016/11/23.
//  Copyright © 2016年 IOS. All rights reserved.
//

import Foundation

class FileField: Field {
    var jsonLen: Int = 0
    var json: String?
    var fileContentLen: Int = 0
    private var _fileContentBuf: Data?
    var fileContentBuf: Data? {
        set {
            _fileContentBuf = newValue
            fileContentLen = fileContentBuf!.count
            fieldContentLength = UInt32(getFieldLength())
        }
        get {
            return _fileContentBuf
        }
    }
    
    func setFileNames(rootDict: [AnyHashable:Any]) {
        var newDic: Dictionary = rootDict
        newDic.removeValue(forKey: "BUF")
        guard let jsonData = try? JSONSerialization.data(withJSONObject: newDic, options: .prettyPrinted) else {
            json = nil
            jsonLen = 0
            fieldContentLength = 0
            return
        }
        json = String(data: jsonData, encoding: .utf8)
        jsonLen = json!.lengthOfBytes(using: .utf8)
    }
    
    func getFieldLength() -> Int {
        return MemoryLayout.size(ofValue: jsonLen) + MemoryLayout.size(ofValue: fileContentLen) + jsonLen + fileContentLen
    }
    override func serialize(serializedData: inout Data) {
        super.serialize(serializedData: &serializedData)
        serializedData.append(Utility.data(fromUInt32: UInt32(jsonLen)))
        if let jsonData = json?.data(using: .utf8) {
            serializedData.append(jsonData)
        }
        serializedData.append(Utility.data(fromUInt32: UInt32(fileContentLen)))
        serializedData.append(fileContentBuf!)
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
        guard curIndex.advanced(by: MemoryLayout<UInt32>.size) <= end else {
            NSLog("Cannot figure out text field content length")
            return false
        }
        fileContentLen = Utility.int(fromData: fromData, start: curIndex, length: MemoryLayout<UInt32>.size)
        curIndex = curIndex.advanced(by: MemoryLayout<UInt32>.size)
        guard curIndex.advanced(by: MemoryLayout<UInt32>.size) <= end else {
            NSLog("content too short")
            return false
        }
        fileContentBuf = fromData.subdata(in: Range(curIndex..<curIndex.advanced(by: fileContentLen)))
        return true
    }
}
