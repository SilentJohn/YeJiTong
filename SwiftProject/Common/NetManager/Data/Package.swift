//
//  Package.swift
//  SwiftProject
//
//  Created by IOS on 2016/11/14.
//  Copyright © 2016年 IOS. All rights reserved.
//

import Foundation

class PackageHeader {
    var tid: TID = TID(rawValue: 0)!
    var requestID: Int = 0
    var contentLen: Int = 0
    
    init() {}
    
    init(tid transID: TID, requestID reqID: Int) {
        tid = transID
        requestID = reqID
        contentLen = 0
    }
    
    func getHeaderLength() -> Int {
        return MemoryLayout.size(ofValue: tid) + MemoryLayout.size(ofValue: requestID) + MemoryLayout.size(ofValue: contentLen)
    }
    
    func serialize(serializedData: inout Data){
        serializedData.append(Utility.data(fromUInt32: UInt32(tid.rawValue)))
        serializedData.append(Utility.data(fromUInt32: UInt32(requestID)))
        serializedData.append(Utility.data(fromUInt32: UInt32(contentLen)))
    }
    
    func deserialize(data: Data, from: Data.Index, to: Data.Index) {
        guard from > 0 && from <= to && to < data.count else {
            NSLog("Invalid data")
            return
        }
        let headerLen = getHeaderLength()
        guard data.count - from >= headerLen else {
            NSLog("Content too short")
            return
        }
        tid = TID(rawValue: Int32(Utility.int(fromData: data, start: from, length: MemoryLayout.size(ofValue: Int.self))))!
        requestID = Utility.int(fromData: data, start: from + MemoryLayout.size(ofValue: Int.self), length: MemoryLayout.size(ofValue: Int.self))
        contentLen = Utility.int(fromData: data, start: from + MemoryLayout.size(ofValue: Int.self) * 2, length: MemoryLayout.size(ofValue: Int.self))
    }
}

class Package {
    
    private(set) var fields: [Field] = [Field]()
    var header: PackageHeader = PackageHeader()
    
    init(tid transID: TID, requestID reqID: Int) {
        header = PackageHeader(tid: transID, requestID: reqID)
    }
    
    init() {
        
    }
    
    func serialize() -> Data {
        var data: Data = Data(capacity: header.contentLen + header.getHeaderLength())
        header.serialize(serializedData: &data)
        for field in fields {
            field.serialize(serializedData: &data)
        }
        return data
    }
    
    func addField(_ newField: Field) {
        fields.append(newField)
        header.contentLen += Int(newField.fieldContentLength) + Field.getFieldHeaderLength()
    }
    
    func validatePackage(source: Data, start: Data.Index, end: Data.Index) -> Int {
        guard start >= 0 && start <= end && end <= source.count    else {
            return -2
        }
        let len = start.distance(to: end)
        let headerLen = header.getHeaderLength()
        guard len >= headerLen else {
            return -1
        }
        header.deserialize(data: source, from: start, to: end.advanced(by: headerLen))
        let contentLen = header.contentLen
        guard len >= contentLen else {
            return -1
        }
        return headerLen + contentLen
    }
    
    func parseContent(fromData: Data, start: Data.Index, end: Data.Index) -> Bool {
        var result: Bool = false
        var index = start
        while index < end {
            let subData = fromData.subdata(in: Range(index.advanced(by: 2)..<index.advanced(by: 4 * MemoryLayout.size(ofValue: Int8.self))))
            let fieldLen = Utility.int(fromData: subData, start: 0, length: 4)
            let fieldEnd = index.advanced(by: fieldLen + Field.getFieldHeaderLength())
            if let fd = FieldParser.shared.parseField(fromData: fromData, start: index, end: fieldEnd) {
                index = fieldEnd
                fields.append(fd)
            } else {
                fields.removeAll()
                break
            }
            if index >= end {
                result = true
            }
        }
        return result
    }
    
    func deserialize(fromData: Data, start: Data.Index, end: Data.Index) -> Bool {
        var result: Bool = false
        let totalLen = validatePackage(source: fromData, start: start, end: end)
        if totalLen > 0 {
            let headerLen = header.getHeaderLength()
            let contentStart = start.advanced(by: headerLen)
            let contentEnd = start.advanced(by: totalLen)
            result = parseContent(fromData: fromData, start: contentStart, end: contentEnd)
        }
        return result
    }
}
