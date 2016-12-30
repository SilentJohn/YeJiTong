//
//  Model.swift
//  SwiftProject
//
//  Created by IOS on 2016/12/28.
//  Copyright © 2016年 IOS. All rights reserved.
//

import Foundation

open class Model: NSObject {
    // MARK: - Initialize from dictionary
    public init?(dic: [String:Any]?) {
        guard let tempDic: [String:Any] = dic else { return nil }
        super.init()
        setValuesForKeys(tempDic)
    }
    
    // MARK: - KVC error
    open override func setValue(_ value: Any?, forUndefinedKey key: String) {
        print("\(#function), \(key) is undefined")
    }
    open override func setNilValueForKey(_ key: String) {
        print("\(#function), nil value for key \(key)")
    }
    
    open override var description: String {
        var finalString: String = ""
        let modelMirror = Mirror(reflecting: self)
        for case let (label?, value) in modelMirror.children {
            finalString.append("\t\(label) = \(value)\n")
        }
        return finalString
    }
    
    func modelToDictionary() -> [String:Any] {
        var dic: [String:Any] = [String:Any]()
        let modelMirror = Mirror(reflecting: self)
        for case let (label?, value) in modelMirror.children {
            dic[label] = value
        }
        return dic
    }
}
