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
    var markName: String?
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
        return formatter.string(from: createDate)
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
    var markNamePinyin: String? {
        guard let tempMarkName = markName else {
            return nil
        }
        return tempMarkName.transformToPinyin()
    }
}

// MARK: - Co-worker model
class ColleagueModel: VisitorModel {
    var position: String?
    var area: String?
}

// MARK: - Customer model
class CustomerModel: VisitorModel {
    var joinTime: Date?
    var country: String?
    var province: String?
    var city: String?
    var lastActiveTime: Date?
    var companyLabels: String?
    var customLabels: String?
    var levelRank: Int = 0
    var memberStartDate: Date?
    var memberEndDate: Date?
    var levelName: String?
    var levelImg: String?
    var levelDiscount: Double = 0.0
    var customerSN: String?
    var bonding: Bool = true
}

extension CustomerModel {
    var joinTimeStr: String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm";
        guard let joinDate = joinTime else {
            return nil
        }
        return formatter.string(from: joinDate)
    }
}
