//
//  ReadPath.swift
//  SwiftProject
//
//  Created by IOS on 2016/11/25.
//  Copyright © 2016年 IOS. All rights reserved.
//

import UIKit

enum CreateFilePathError: Error {
    case Failed
    case Existed
    
    var localizedDescription: String {
        switch self {
        case .Failed:
            return "创建目录失败"
        case .Existed:
            return "目录已存在"
        }
    }
}

enum UserDirectories: String {
    case Image
    case Other
    case Voice
    case Download
    
    static let allValues = [Image, Other, Voice, Download]
    
    func appendToBasePath(_ path: String) -> String {
        return "\(path)/\(self.rawValue)"
    }
}

class ReadPath {

    class func documentPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    class func getUserFile() -> String? {
        guard let nodeId = UserDefaults.standard.string(forKey: YJTUserNodeIdKey) else {
            return nil
        }
        return (ReadPath.documentPath() as NSString).appendingPathComponent(nodeId)
    }
    
    class func createFilePath(_ path: String) throws {
        let absolutePath = (ReadPath.documentPath() as NSString).appendingPathComponent(path)
        guard !FileManager.default.fileExists(atPath: absolutePath) else {
            throw CreateFilePathError.Existed
        }
        do {
            try FileManager.default.createDirectory(atPath: absolutePath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error = \(error)")
            throw CreateFilePathError.Failed
        }
        for userDirectory in UserDirectories.allValues {
            let userDirectoryAbsolutePath = (ReadPath.documentPath() as NSString).appendingPathComponent(userDirectory.appendToBasePath(path))
            do {
                try FileManager.default.createDirectory(atPath: userDirectoryAbsolutePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error = \(error)")
                throw CreateFilePathError.Failed
            }
        }
    }
    
    class func save(image: UIImage, withName name: String, toPath path: String) -> String {
        let imagePath = (path as NSString).appendingPathComponent("\(name).png")
        do {
            try UIImagePNGRepresentation(image)?.write(to: URL.init(fileURLWithPath: imagePath), options: .atomic)
        } catch {
            print("\(error.localizedDescription)")
        }
        return imagePath
    }
}
