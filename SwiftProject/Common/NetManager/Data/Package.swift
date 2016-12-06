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
    var requestID: Int32 = 0
    var contentLen: Int32 = 0
    
    init() {}
    
    init(tid transID: TID, requestID reqID: Int32) {
        tid = transID
        requestID = reqID
        contentLen = 0
    }
    
    func getHeaderLength() -> Int32 {
        return Int32(MemoryLayout.size(ofValue: tid.rawValue) + MemoryLayout.size(ofValue: requestID) + MemoryLayout.size(ofValue: contentLen))
    }
    
    func serialize(serializedData: inout Data){
        serializedData.append(Utility.data(fromUInt32: UInt32(tid.rawValue)))
        serializedData.append(Utility.data(fromUInt32: UInt32(requestID)))
        serializedData.append(Utility.data(fromUInt32: UInt32(contentLen)))
    }
    
    func deserialize(data: Data, from: Data.Index, to: Data.Index) {
        guard from >= 0 && from <= to && to <= data.count else {
            NSLog("Invalid data")
            return
        }
        let headerLen = getHeaderLength()
        guard data.count - Int(from) >= Int(headerLen) else {
            NSLog("Content too short")
            return
        }
        let intValue = Utility.int(fromData: data, start: from, length: MemoryLayout<Int32>.size)
        guard let tempTid = TID(rawValue: Int32(intValue)) else {
            print("Invalid tid")
            return
        }
        tid = tempTid
        requestID = Int32(Utility.int(fromData: data, start: from + MemoryLayout<Int32>.size, length: MemoryLayout<Int32>.size))
        contentLen = Int32(Utility.int(fromData: data, start: from + MemoryLayout<Int32>.size * 2, length: MemoryLayout<Int32>.size))
    }
}

class Package {
    
    private(set) var fields: [Field] = [Field]()
    var header: PackageHeader = PackageHeader()
    
    init(tid transID: TID, requestID reqID: Int32) {
        header = PackageHeader(tid: transID, requestID: reqID)
    }
    
    init() {
        
    }
    
    func serialize() -> Data {
        var data: Data = Data(capacity: Int(header.contentLen + header.getHeaderLength()))
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
    
    func validatePackage(source: Data, start: Data.Index, end: Data.Index) -> Int32 {
        guard start >= 0 && start <= end && end <= source.count else {
            return -2
        }
        let len = start.distance(to: end)
        let headerLen = header.getHeaderLength()
        guard len >= Int(headerLen) else {
            return -1
        }
        header.deserialize(data: source, from: start, to: start.advanced(by: Int(headerLen)))
        let contentLen = header.contentLen
        guard len >= Int(contentLen) else {
            return -1
        }
        return headerLen + contentLen
    }
    
    func parseContent(fromData: Data, start: Data.Index, end: Data.Index) -> Bool {
        var result: Bool = false
        var index = start
        while index < end {
            let subData = fromData.subdata(in: Range(index.advanced(by: 2)..<index.advanced(by: 2 + 4 * MemoryLayout<Int8>.size)))
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
            let contentStart = start.advanced(by: Int(headerLen))
            let contentEnd = start.advanced(by: Int(totalLen))
            result = parseContent(fromData: fromData, start: contentStart, end: contentEnd)
        }
        return result
    }
}
