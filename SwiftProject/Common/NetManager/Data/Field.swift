//
//  Field.swift
//  SwiftProject
//
//  Created by IOS on 2016/11/11.
//  Copyright © 2016年 IOS. All rights reserved.
//

import Foundation

class Field {
    
    var fieldID: UInt16
    var fieldContentLength: UInt32
    
    class func getFieldHeaderLength() -> Int {
        return MemoryLayout.size(ofValue: UInt16.self) + MemoryLayout.size(ofValue: UInt32.self)
    }
    
    init(fieldID: UInt16) {
        self.fieldID = fieldID
        fieldContentLength = 0
    }
    
    func serialize() -> Data {
        var serializedData = Utility.data(fromUInt16: fieldID)
        serializedData.append(Utility.data(fromUInt32: fieldContentLength))
        return serializedData
    }
    
    func deserialize(data: Data, from: Data.Index, to: Data.Index) {
        guard from + Field.getFieldHeaderLength() <= to else {
            NSLog("Invalid field")
            return
        }
        let fieldID: UInt16 = UInt16(Utility.int(fromData: data, start: from, length: MemoryLayout.size(ofValue: UInt16.self)))
        let fieldLen: UInt32 = UInt32(Utility.int(fromData: data, start: from + MemoryLayout.size(ofValue: UInt16.self), length: MemoryLayout.size(ofValue: UInt32.self)))
        guard from + Field.getFieldHeaderLength() + Int(fieldID) >= to  else {
            NSLog("Field content too short")
            return
        }
        self.fieldID = fieldID
        fieldContentLength = fieldLen
    }
}
