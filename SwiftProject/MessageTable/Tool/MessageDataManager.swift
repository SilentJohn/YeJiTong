//
//  MessageDataManager.swift
//  SwiftProject
//
//  Created by IOS on 2016/12/23.
//  Copyright © 2016年 IOS. All rights reserved.
//

import Foundation
import FMDB

class MessageDataManager {
    
    // MARK: - Customer table names
    private let customerTable = "vistor_list"
    
    private struct customerTableKeys {
        let openIdKey        = "open_id"
        let useIdKey         = "user_id"
        let iconKey          = "icon"
        let nickNameKey      = "nick_name"
        let messageKey       = "message"
        let createAtKey      = "create_at"
        let searchStrKey     = "search_str"
        let notReadNumKey    = "not_read_num"
        let visitorTypeKey   = "visitor_type"
        let visibleKey       = "visible"
        let markNameKey      = "mark_name"
        let countryKey       = "country"
        let provinceKey      = "province"
        let cityKey          = "city"
        let genderKey        = "gender"
        let phoneNumKey      = "phone_num"
        let birthdayKey      = "birthday"
        
        static func createTable() {
            SQLiteOperation.dbQueue?.inDatabase { db in
                
            }
        }
    }
    
    static let shared = MessageDataManager()
    
    private init() {
        customerTableKeys.createTable()
    }
}
