//
//  Utility.swift
//  SwiftProject
//
//  Created by IOS on 2016/11/11.
//  Copyright © 2016年 IOS. All rights reserved.
//

import Foundation

class Utility {
    class func data(fromUInt16: UInt16) -> Data {
        return Data(bytes: [UInt8(fromUInt16 & 0x00ff), UInt8(fromUInt16 & 0xff00) >> 8])
    }
    
    class func data(fromUInt32: UInt32) -> Data {
        return Data(bytes: [UInt8(fromUInt32 & 0x000000ff), UInt8(fromUInt32 & 0x0000ff00) >> 8, UInt8(fromUInt32 & 0x00ff0000) >> 16, UInt8(fromUInt32 & 0xff000000) >> 24])
    }
    
    class func int(fromData: Data, start: Int, length: Int) -> Int {
        guard start + length <= fromData.count else {
            return 0
        }
        var result: Int = 0
        for index in start..<start + length {
            result = result << 8 | Int(fromData[index] & 0x00ff)
        }
        return result
    }
}
