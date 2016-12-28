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
            var sql = "CREATE TABLE IF NOT EXISTS visitor_list(id INTEGER PRIMARY KEY,open_id TEXT NOT NULL,user_id TEXT NOT NULL,icon TEXT,nickname TEXT,message TEXT,create_at TEXT,search_str TEXT,not_read_num TEXT,visitor_type TEXT NOT NULL,visible TEXT NOT NULL,mark_name TEXT,country TEXT,province TEXT,city TEXT,gender TEXT,phone_num TEXT,birthday TEXT,address TEXT,remark TEXT,join_time TEXT,last_active_time TEXT,vip_code TEXT,credit TEXT,status TEXT,last_activity_time TEXT,company_label TEXT,custom_label TEXT,member_level TEXT,member_start_date TEXT,member_end_date TEXT,level_name TEXT,level_img TEXT,level_discount TEXT,customer_sn TEXT,bunding TEXT)"
            try? db?.executeUpdate(sql, values: [])
            
            // co-worker table
            sql = "CREATE TABLE IF NOT EXISTS colleague_list(id INTEGER PRIMARY KEY,open_id TEXT NOT NULL,user_id TEXT NOT NULL,icon TEXT,nickname TEXT, message TEXT,create_at TEXT,search_str TEXT,area TEXT,position TEXT,not_read_num TEXT,visitor_type TEXT NOT NULL,visible TEXT NOT NULL,colleague BLOB NOT NULL)"
            try? db?.executeUpdate(sql, values: [])
            
            // message table
            sql = "CREATE TABLE IF NOT EXISTS tmessage (id integer PRIMARY KEY,_j_msgid TEXT,message BLOB NOT NULL, create_at TEXT NOT NULL,user_id TEXT NOT NULL,open_id TEXT NOT NULL,state TEXT,messageType TEXT)"
            try? db?.executeUpdate(sql, values: [])
        }
    }
    
    static let shared = MessageDataManager()
    
    private init() {
        createTable()
    }
    
}
