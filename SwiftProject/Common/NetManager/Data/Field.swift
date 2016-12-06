//
//  Field.swift
//  SwiftProject
//
//  Created by IOS on 2016/11/11.
//  Copyright © 2016年 IOS. All rights reserved.
//

import Foundation

enum FID: Int16 {
    case TEXTFIELD = 0x0005
    case FILEFIELD
}

class Field {
    
    var fieldID: UInt16
    var fieldContentLength: UInt32
    
    class func getFieldHeaderLength() -> Int {
        return MemoryLayout<UInt16>.size + MemoryLayout<UInt32>.size
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
        let fieldID: UInt16 = UInt16(Utility.int(fromData: fromData, start: start, length: MemoryLayout<UInt16>.size))
        let fieldLen: UInt32 = UInt32(Utility.int(fromData: fromData, start: start.advanced(by: MemoryLayout<UInt16>.size), length: MemoryLayout<UInt32>.size))
        guard start + Field.getFieldHeaderLength() + Int(fieldLen) >= end  else {
            NSLog("Field content too short")
            return false
        }
        self.fieldID = fieldID
        fieldContentLength = fieldLen
        return true
    }
}

class FieldParser {
    static let shared = FieldParser()
    private init() {
        
    }
    
    func parseField(fromData: Data, start: Data.Index, end: Data.Index) -> Field? {
        guard start.distance(to: end) >= MemoryLayout<UInt16>.size else {
            NSLog("Cannot parse field ID")
            return nil
        }
        
        if let fieldID = FID(rawValue: Int16(Utility.int(fromData: fromData, start: start, length: 2))) {
            switch fieldID {
            case .TEXTFIELD:
                let fd = TextField(fieldID: UInt16(fieldID.rawValue))
                _ = fd.deserialize(fromData: fromData, start: start, end: end)
                return fd
            case .FILEFIELD:
                let fd = FileField(fieldID: UInt16(fieldID.rawValue))
                _ = fd.deserialize(fromData: fromData, start: start, end: end)
                return fd
            }
        } else {
            return nil
        }
    }
}
