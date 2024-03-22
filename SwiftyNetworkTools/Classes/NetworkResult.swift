//
//  NetworkResult.swift
//  BaseProject
//
//  Created by Justsoso on 2024/1/22.
//

import Foundation
import Moya
import HandyJSON

public struct NetworkResult<M: HandyJSON> {
    var data: M?
    var info: String?
    var code: String
    
    init(json: [String: Any]) {
        code = json["code"] as? String ?? "-1"
        info = json["message"] as? String
        data = parseData(jsonObj: json["data"])
    }
    
    init(errorMsg: String?) {
        code = "-1"
        info = errorMsg
    }
    
    /// 解析数据
    func parseData(jsonObj: Any?) -> M? {
        /// 判断是否为nil
        guard let dataObj = jsonObj else {
            return nil
        }
        
        /// 判断是否为NSNull
        guard !(dataObj as AnyObject).isEqual(NSNull()) else {
            return nil
        }
        
        /// 本身为M类型，直接赋值
        if let dataObj = dataObj as? M {
            return dataObj
        }
        
        if let jsondict = dataObj as? [String: Any] {
            if let object = M.deserialize(from: jsondict) {
                return object
            }
        }
        
//        if let jsonList = dataObj as? [Any] {
//            if let object = [M].deserialize(from: jsonList) {
//                return object
//            }
//        }
        return nil
        
        /// 转模型
//        let jsonData = try? JSONSerialization.data(withJSONObject: dataObj, options: .prettyPrinted)
//        guard let data = jsonData else { return nil }
//        do{
//            return try JSONDecoder().decode(M.self, from: data)
//        } catch {
//            print(error)
//            return nil
//        }
    }
    
}

//给Result增加一个扩展方法
extension Result where Success: Response, Failure == MoyaError {
    func mapNetworkResult<M>(_ type: M.Type) -> NetworkResult<M> where M: HandyJSON {
        switch self {
        case .success(let response):
            do {
                guard let json = try response.mapJSON() as? [String: Any] else {
                    /// 不是JSON数据
                    return NetworkResult(errorMsg: "服务器返回的不是JSON数据")
                }
                return NetworkResult(json: json)
            } catch {
                /// 解析出错
                return NetworkResult(errorMsg: error.localizedDescription)
            }
        case .failure(let error):
            /// 请求出错
            return NetworkResult(errorMsg: error.errorDescription)
        }
    }
}

