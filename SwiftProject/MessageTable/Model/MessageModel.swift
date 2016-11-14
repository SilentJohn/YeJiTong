//
//  MessageModel.swift
//  SwiftProject
//
//  Created by IOS on 2016/10/27.
//  Copyright © 2016年 IOS. All rights reserved.
//

import UIKit

class MessageModel: NSObject {
    var headImageUrl: String = ""
    var senderTitle: String = ""
    var sendTime: String = ""
    var messageContent: String = ""
    
    override func setNilValueForKey(_ key: String) {
        NSLog("%s", #function)
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        NSLog("%s", #function)
    }
    
    override var description: String {
        var finalString: String = ""
        let modelMirror = Mirror(reflecting: self)
        for case let (label?, value) in modelMirror.children {
            finalString.append("\t\(label) = \(value)\n")
        }
        return finalString
    }
    
    init(dic:[String:String]) {
        super.init()
        setValuesForKeys(dic)
    }
}
