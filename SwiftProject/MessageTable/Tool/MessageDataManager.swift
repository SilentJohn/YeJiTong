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
    
    private func createTable() {
        SQLiteOperation.dbQueue?.inDatabase { db in
            // customer table
            var sql = "CREATE TABLE IF NOT EXISTS visitor_list(id INTEGER PRIMARY KEY,open_id TEXT NOT NULL,user_id TEXT NOT NULL,icon TEXT,nickname TEXT,message TEXT,create_at TEXT,search_str TEXT,not_read_num TEXT,visitor_type TEXT NOT NULL,visible TEXT NOT NULL,mark_name TEXT,country TEXT,province TEXT,city TEXT,gender TEXT,phone_num TEXT,birthday TEXT,address TEXT,remark TEXT,join_time TEXT,last_active_time TEXT,vip_code TEXT,credit TEXT,status TEXT,last_activity_time TEXT,company_label TEXT,custom_label TEXT,member_level TEXT,member_start_date TEXT,member_end_date TEXT,level_name TEXT,level_img TEXT,level_discount TEXT,customer_sn TEXT,bonding TEXT)"
            try? db?.executeUpdate(sql, values: [])
            
            // co-worker table
            sql = "CREATE TABLE IF NOT EXISTS colleague_list(id INTEGER PRIMARY KEY,open_id TEXT NOT NULL,user_id TEXT NOT NULL,icon TEXT,nickname TEXT, message TEXT,create_at TEXT,search_str TEXT,area TEXT,position TEXT,not_read_num TEXT,visitor_type TEXT NOT NULL,visible TEXT NOT NULL,colleague BLOB NOT NULL)"
            try? db?.executeUpdate(sql, values: [])
            
            // message table
            sql = "CREATE TABLE IF NOT EXISTS message (id integer PRIMARY KEY,_j_msgid TEXT,message BLOB NOT NULL, create_at TEXT NOT NULL,user_id TEXT NOT NULL,open_id TEXT NOT NULL,state TEXT,message_type TEXT)"
            try? db?.executeUpdate(sql, values: [])
        }
    }
    
    static let shared = MessageDataManager()
    
    private init() {
        createTable()
    }
    
    func getJMessageId(withLastRefreshTime refreshTime: String?,  userId: String) -> String? {
        guard let tempRefreshTime = refreshTime else {
            return nil
        }
        var resultStr: String = String()
        SQLiteOperation.dbQueue?.inDatabase { db in
            let sql = "SELECT * FROM message WHERE user_id='\(userId) AND message_type='1' AND create_at>'\(tempRefreshTime)'"
            guard let queryResult = try? db?.executeQuery(sql, values: []) else {
                return
            }
            if let set = queryResult {
                while set.next() {
                    guard let jMessageId = set.object(forColumnName: "_j_msgid") as? String  else {
                        print("Invalid _j_msgid")
                        continue
                    }
                    resultStr += "\(jMessageId),"
                }
            }
            if resultStr.characters.count <= 0 {
                resultStr = "0"
            } else {
                resultStr = resultStr.substring(to: resultStr.index(before: resultStr.endIndex))
            }
        }
        return resultStr
    }
    
    func getColleagues(withUserId userId: String?, visible: Bool) -> [ColleagueModel]? {
        guard let tempUserId = userId else {
            return nil
        }
        var sql = ""
        if visible {
            sql = "SELECT * FROM colleague_list WHERE user_id = '\(tempUserId)' AND visible='1' AND (vistor_type='1' OR visitor_type='2' OR visitor_type='3')"
        } else {
            sql = "SELECT * FROM colleague_list WHERE user_id = '\(tempUserId)' AND (vistor_type='1' OR visitor_type='2')"
        }
        var colleagueArray = [ColleagueModel]()
        SQLiteOperation.dbQueue?.inDatabase { db in
            guard let queryResult = try? db?.executeQuery(sql, values: []) else {
                return
            }
            if let set = queryResult {
                while set.next() {
                    if let resultDic = set.resultDictionary() {
                        var finalDic: [String:Any] = [String:Any]()
                        for (key, value) in resultDic {
                            if let keyStr = key as? String {
                                if keyStr == "colleague" {
                                    if let colleague = resultDic["colleague"] as? Data {
                                        if let colleagueDic = NSKeyedUnarchiver.unarchiveObject(with: colleague) as? [AnyHashable:Any] {
                                            for (smallKey, smallValue) in colleagueDic {
                                                if let smallKeyStr = smallKey as? String {
                                                    finalDic[smallKeyStr.underlineToCamel()] = smallValue
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    finalDic[keyStr.underlineToCamel()] = value
                                }
                                if let model = ColleagueModel.init(dic: finalDic) {
                                    colleagueArray.append(model)
                                }
                            }
                        }
                    }
                }
                set.close()
            }
        }
        return colleagueArray
    }
}
