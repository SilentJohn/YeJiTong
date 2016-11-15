//
//  Field.swift
//  SwiftProject
//
//  Created by IOS on 2016/11/11.
//  Copyright © 2016年 IOS. All rights reserved.
//

import Foundation

enum FID {
    case TEXTFIELD
    case FILEFIELD
}

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
    
    func serialize(serializedData: inout Data) {
        serializedData.append(Utility.data(fromUInt16: fieldID))
        serializedData.append(Utility.data(fromUInt32: fieldContentLength))
    }
    
    func deserialize(fromData: Data, start: Data.Index, end: Data.Index) -> Bool {
        guard start + Field.getFieldHeaderLength() <= end else {
            NSLog("Invalid field")
            return false
        }
        let fieldID: UInt16 = UInt16(Utility.int(fromData: fromData, start: start, length: MemoryLayout.size(ofValue: UInt16.self)))
        let fieldLen: UInt32 = UInt32(Utility.int(fromData: fromData, start: start.advanced(by: MemoryLayout.size(ofValue: UInt16.self)), length: MemoryLayout.size(ofValue: UInt32.self)))
        guard start + Field.getFieldHeaderLength() + Int(fieldID) >= end  else {
            NSLog("Field content too short")
            return false
        }
        self.fieldID = fieldID
        fieldContentLength = fieldLen
        return true
    }
}

class FieldParser {
    func parseField(fromData: Data, start: Data.Index, end: Data.Index) -> Field? {
        guard start.distance(to: end) < MemoryLayout.size(ofValue: UInt16.self) else {
            NSLog("Cannot parse field ID")
            return nil
        }
        return nil
    }
}
