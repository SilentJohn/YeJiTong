//
//  NetRequestManager.swift
//  SwiftProject
//
//  Created by IOS on 2016/11/9.
//  Copyright © 2016年 IOS. All rights reserved.
//

import Foundation

let soapNamespace: String = "http://WebService.teddy.com"
let soapEndpoint: String = "http://115.28.42.18:18084/axis2/services/YeJiTongService?wsdl"
let methodName: String = "handleService"


let errorDesc1 = "网络异常，请稍后重试"


class NetRequestManager: NSObject, XMLParserDelegate {
    
    lazy var soapResults: String = { String() }()
    var recordResults: Bool = false
    
    var tid: TID?
    private var success: (([AnyHashable:Any], TID, Int) -> Void)?
    private var failure: ((String, TID) -> Void)?
    
    open func send(contentDic: [AnyHashable:Any]? = nil, attatchmentArray: [[AnyHashable:Any]]? = nil, tid: TID, requestID: Int, success: (@escaping ([AnyHashable:Any], TID, Int) -> Void), failure: (@escaping (String, TID) -> Void)) {
        guard let package = contrustPackageData(contentDic: contentDic, attatchmentArray: attatchmentArray, tid: tid, requestID: requestID) else {
            print("Package nil")
            return
        }
        self.success = success
        self.failure = failure
        let data = package.serialize()
        let base64Data = data.base64EncodedString(options: .lineLength64Characters)
        let soapMessage = "<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:web=\"\(soapNamespace)\"><soap:Header/><soap:Body><web:handleService><web:param>\(base64Data)</web:param></web:handleService></soap:Body></soap:Envelope>"
        if let url = URL(string: soapEndpoint) {
            var urlRequest = URLRequest(url: url, timeoutInterval: 30.0)
            urlRequest.addValue("application/soap+xml/form-data; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("", forHTTPHeaderField: "SOAPAction")
            urlRequest.addValue("\(soapMessage.characters.count)", forHTTPHeaderField: "Content-Length")
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = soapMessage.data(using: .utf8)
            let dataTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, urlResponse, error) in
                if error == nil {
                    let xmlParser = XMLParser(data: data!)
                    xmlParser.delegate = self
                    xmlParser.shouldResolveExternalEntities = true
                    if xmlParser.parse() {
                        print("XML parse succeed")
                    } else {
                        print("XML parse fail")
                    }
                } else {
                    print(error.debugDescription)
                    OperationQueue.main.addOperation {
                        failure(errorDesc1, tid)
                    }
                }
            })
            dataTask.resume()
        }
        
    }
    private func contrustPackageData(contentDic: [AnyHashable:Any]? = nil, attatchmentArray: [[AnyHashable:Any]]? = nil, tid: TID, requestID: Int) -> Package? {
        let package = Package(tid: tid, requestID: Int32(requestID))
        if tid != .LoginREQ {
            let verify = VerifyField(fieldID: UInt16(FID.TEXTFIELD.rawValue))
            guard let validationCode = SQLiteOperation.getMyData(key: validationCodeKey) else {
                print("No validation code")
                return nil
            }
            guard let nodeId = SQLiteOperation.getMyData(key: nodeIdKey) else {
                print("No node id")
                return nil
            }
            let dic: [String:String] = ["app_version":appVersion, "validation_code":validationCode, "device_type":"2", "node_id":nodeId]
            verify.contentDic = dic
            package.addField(verify)
        }
        if let tempContenDic = contentDic {
            let contentField = ContentField(fieldID: UInt16(FID.TEXTFIELD.rawValue))
            contentField.contentDic = tempContenDic
            package.addField(contentField)
        }
        if let tempAttatchmentArray = attatchmentArray {
            for attatchmentDic in tempAttatchmentArray {
                let attatchment = AttatchmentField(fieldID: UInt16(FID.FILEFIELD.rawValue))
                if case let value as [AnyHashable:Any]? = attatchmentDic["contentDic"] {
                    attatchment.contentDic = value!
                }
                if case let value as Data? = attatchmentDic["data"] {
                    attatchment.attatchmentData = value
                } else {
                    attatchment.attatchmentData = nil
                }
                package.addField(attatchment)
            }
        }
        return package
    }
    
    // MARK: - XML parser delegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "ns:return" {
            recordResults = true
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if recordResults {
            soapResults.append(string)
        }
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "ns:return" {
            recordResults = false
            guard let data = Data(base64Encoded: soapResults, options: .ignoreUnknownCharacters) else {
                print("Nil data")
                return
            }
            let rcvPackage = Package()
            _ = rcvPackage.deserialize(fromData: data, start: data.startIndex, end: data.endIndex)
            if rcvPackage.header.tid == .UnknownREQRSP {
                OperationQueue.main.addOperation {
                    self.failure?(errorDesc1, rcvPackage.header.tid)
                }
            } else {
                OperationQueue.main.addOperation {
                    let array = rcvPackage.fields
                    let respTid = rcvPackage.header.tid
                    guard array.count > 0 else {
                        self.failure?(errorDesc1, respTid)
                        return
                    }
                    let requestId = rcvPackage.header.requestID
                    guard let textField = array[0] as? TextField else {
                        print("Invalid text field")
                        return
                    }
                    guard let data = textField.json?.data(using: .utf8) else {
                        print("No json data")
                        return
                    }
                    guard let rltDic = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [AnyHashable:Any] else {
                        print("Json data cannot be resolved")
                        return
                    }
                    guard let rltCode = rltDic?["rlt_code"] as? Int else {
                        print("Invalid result code")
                        return
                    }
                    switch respTid {
                    case .LoginRSP:
                        self.success?(rltDic!, respTid, Int(requestId))
                    default:
                        var dic = [AnyHashable:Any]()
                        switch rltCode {
                        case 0:
                            dic["rlt_code"] = -1
                        case 1:
                            dic["rlt_code"] = -2
                        case 2:
                            dic["rlt_code"] = -3
                        default:
                            break
                        }
                        self.success?(dic, respTid, Int(requestId))
                    }
                    if array.count == 2 {
                        guard let textField = array[1] as? TextField else {
                            print("Invalid text field")
                            return
                        }
                        guard let data = textField.json?.data(using: .utf8) else {
                            print("No json data")
                            return
                        }
                        guard let rltDic = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [AnyHashable:Any] else {
                            print("Json data cannot be resolved")
                            return
                        }
                        self.success?(rltDic!, respTid, Int(requestId))
                    }
                }
            }
        }
    }
}
