//
//  VisitorModel.swift
//  SwiftProject
//
//  Created by IOS on 2016/12/28.
//  Copyright © 2016年 IOS. All rights reserved.
//

import Foundation

// MARK: - Contact model
class VisitorModel: Model {
    var openId: String = ""
    var userId: String = ""
    var icon: String?
    var nickname: String?
    var message: String?
    var createAt: Date?
    var searchStr: String?
    var notReadNum: Int?
    var visitorType: String = ""
    var visible: String = ""
    
    enum Gender {
        case Male
        case Female
        case Unset
    }
    var gender: Gender = .Unset
    var phoneNum: String?
    var birthday: Date?
    var address: String?
    var remark: String?
}

extension VisitorModel {
    var createAtStr: String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm";
        guard let createDate = createAt else {
            return nil
        }
        return formatter .string(from: createDate)
    }
    var notReadNumStr: String? {
        guard let tempNotReadNum = notReadNum else {
            return nil
        }
        if tempNotReadNum > 99 {
            return "99+"
        } else {
            return "\(tempNotReadNum)"
        }
    }
}

// MARK: - Co-worker model
class collegueModel: VisitorModel {
    var position: String?
    var area: String?
}

// MARK: - 
