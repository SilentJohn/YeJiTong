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


class NetRequestManager: XMLParserDelegate {
    
    static let shared = NetRequestManager()
    private init() {
        
    }
    
    func send(contentDic: [AnyHashable:Any]? = nil, attatchmentArray: [[AnyHashable:Any]]? = nil, tid: Int, requestID: Int, success: (@escaping ([AnyHashable:Any], Int, Int) -> Void), failure: (@escaping (String, Int) -> Void)) {
        guard let package = contrustPackageData(contentDic: contentDic, attatchmentArray: attatchmentArray, tid: tid, requestID: requestID) else {
            print("Package nil")
            return
        }
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
                    let xmlPaser = XMLParser(data: data!)
                    xmlPaser.delegate = self
                    xmlPaser.shouldResolveExternalEntities = true
                    if xmlPaser.parse() {
                        print("XML parse succeed")
                    } else {
                        print("XML parse fail")
                    }
                } else {
                    print(error.debugDescription)
                    OperationQueue.main.addOperation {
                        failure(error.debugDescription, tid)
                    }
                }
            })
            dataTask.resume()
        }
        
    }
    private func contrustPackageData(contentDic: [AnyHashable:Any]? = nil, attatchmentArray: [[AnyHashable:Any]]? = nil, tid: Int, requestID: Int) -> Package? {
        let package = Package(tid: tid, requestID: requestID)
        let verify = VerifyField.field()
        package.addField(verify)
        if let tempContenDic = contentDic {
            let contentField = ContentField(fieldID: 0x0005)
            contentField.contentDic = tempContenDic
            package.addField(contentField)
        }
        if let tempAttatchmentArray = attatchmentArray {
            for attatchmentDic in tempAttatchmentArray {
                let attatchment = AttatchmentField(fieldID: 0x0006)
                if case let value as [AnyHashable:Any]? = attatchmentDic["contentDic"] {
                    attatchment.contentDic = value
                } else {
                    attatchment.contentDic = nil
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
    
    /// MARK: XML parser delegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
    }
}
