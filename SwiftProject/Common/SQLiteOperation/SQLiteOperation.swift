//
//  SQLiteOperation.swift
//  SwiftProject
//
//  Created by IOS on 2016/11/25.
//  Copyright © 2016年 IOS. All rights reserved.
//

import Foundation
import FMDB

class SQLiteOperation {
    
    static private var _dbQueue: FMDatabaseQueue? = nil
    static var dbQueue: FMDatabaseQueue? {
        get {
            if _dbQueue == nil {
                guard let userPath = ReadPath.getUserFile() else {
                    return _dbQueue
                }
                let path = NSString(string: userPath).appendingPathComponent("yejitongDB.sqlite")
                _dbQueue = FMDatabaseQueue(path: path)
            }
            return _dbQueue
        }
    }
    
    class func insertInto(table: String, keyValue: [AnyHashable:Any]) {
        var keys = String()
        var values = String()
        
        for (key, _) in keyValue {
            keys.append("'\(key)',")
            values.append("?,")
        }
        keys = keys.substring(to: keys.index(before: keys.endIndex))
        values = values.substring(to: values.index(before: values.endIndex))
        let command = "INSERT INTO \(table)(\(keys) VALUES (\(values)))"
        dbQueue?.inDatabase { (db) in
            do {
                try db?.executeUpdate(command, values: Array(keyValue.values))
            } catch {
                print("SQLite update error = \(error)")
            }
        }
    }
    
    class func selectFrom(table: String, where constraint: String? = nil) -> [[AnyHashable:Any]] {
        var resultArray = [[AnyHashable:Any]]()
        var command = "SELECT * FROM \(table)"
        if let strConstraint = constraint {
            command.append("WHERE \(strConstraint)")
        }
        dbQueue?.inDatabase { (db) in
            do {
                if let set = try db?.executeQuery(command, values: nil) {
                    while set.next() {
                        resultArray.append(set.resultDictionary())
                    }
                }
            } catch {
                print("SQLite update error = \(error)")
            }
        }
        return resultArray
    }
    
    class func deleteFrom(table: String, where constraint: String? = nil) {
        var command = "DELETE * FROM \(table)"
        if let strConstraint = constraint {
            command.append("WHERE \(strConstraint)")
        }
        dbQueue?.inDatabase { (db) in
            do {
                try db?.executeUpdate(command, values: nil)
            } catch {
                print("SQLite delete error = \(error)")
            }
        }
    }
    
    class func modifyFrom(table: String, keyValue: [AnyHashable:Any], where constraint: String) {
        var command = String()
        for (key, value) in keyValue {
            command.append("'\(key)'='\(value)'")
        }
        dbQueue?.inDatabase { (db) in
            do {
                try db?.executeUpdate("UPDATE \(table) SET \(command) WHERE \(constraint)", values: nil)
            } catch {
                print("SQLite modify error = \(error)")
            }
        }
    }
    
    // MARK: - MYDATA table
    class func saveMyData(dic: [AnyHashable:Any]) {
        SQLiteOperation.modifyFrom(table: "MYDATA", keyValue: dic, where: "ID='1'")
    }
    
    class func getMyData(key: String) -> String? {
        let data = SQLiteOperation.selectFrom(table: "MYDATA")
        if data.count > 0 {
            return data[0][key] as! String?
        }
        return nil
    }
    
    // MARK: - Initialize all tables needed
    class func initAllTables() {
        
    }
}
