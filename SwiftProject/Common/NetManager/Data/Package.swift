//
//  Package.swift
//  SwiftProject
//
//  Created by IOS on 2016/11/14.
//  Copyright © 2016年 IOS. All rights reserved.
//

import Foundation

class PackageHeader {
    var tid: Int = 0
    var requestID: Int = 0
    var contentLen: Int = 0
    
    init() {}
    
    init(tid transID: Int, requestID reqID: Int) {
        tid = transID
        requestID = reqID
        contentLen = 0
    }
    
    func getHeaderLength() -> Int {
        return MemoryLayout.size(ofValue: tid) + MemoryLayout.size(ofValue: requestID) + MemoryLayout.size(ofValue: contentLen)
    }
    
    func serialize(serializedData: inout Data){
        serializedData.append(Utility.data(fromUInt32: UInt32(tid)))
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
        tid = Utility.int(fromData: data, start: from, length: MemoryLayout.size(ofValue: Int.self))
        requestID = Utility.int(fromData: data, start: from + MemoryLayout.size(ofValue: Int.self), length: MemoryLayout.size(ofValue: Int.self))
        contentLen = Utility.int(fromData: data, start: from + MemoryLayout.size(ofValue: Int.self) * 2, length: MemoryLayout.size(ofValue: Int.self))
    }
}

class Package {
    
    var fields: [Field] = [Field]()
    var header: PackageHeader = PackageHeader()
    
    init() {}
    
    init(tid transID: Int, requestID reqID: Int) {
        header = PackageHeader(tid: transID, requestID: reqID)
    }
}
