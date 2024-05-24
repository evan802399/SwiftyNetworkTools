//
//  API.swift
//  BaseProject
//
//  Created by Justsoso on 2024/1/22.
//
/// API.swift ---将来我们的接口列表和不同的接口的一些配置在里面完成，最长打交道的地方。

import Foundation
import Moya

enum APITest {
    ///定义无参数
    case testApi
    ///定义有少量参数
    case testAPi(para1:String,para2:String)
    ///定义有多个参数时，把参数组装成字典传入(推荐使用)
    case testApiDict(Dict:[String:Any])
}

extension APITest:TargetType{
    ///设置baseURL
    var baseURL: URL {
        //此处替换应该替换为Moya_baseURL，下面url是用于测试数据
        return URL.init(string: "http://t.weather.itboy.net/")!
    }
    ///设置各功能的url
    var path: String {
        switch self {
        case .testApi:
            return "api/weather/city/101030100"
        case .testAPi(let para1, _):
            return "\(para1)/news/latest"
        case .testApiDict(_):
            return "4/news/latest"
        }
    }
    
    /// 请求方式 get post put delete
    var method: Moya.Method {
        switch self {
        case .testApi:
            return .get
        default:
            return .post
        }
    }
    
    /// 这个是做单元测试模拟的数据，必须要实现，只在单元测试文件中有作用
    var sampleData: Data {
        switch self {
        case .testApi:
            return "".data(using: String.Encoding.utf8)!
        default:
            return "".data(using: String.Encoding.utf8)!
        }
        
    }
    
    ///设置不同任务的URLRequest参数
    var task: Task {
        switch self {
        case .testApi:
            return .requestPlain
        case .testAPi(let para1, _):
        ///后台的content-Type 为application/x-www-form-urlencoded时选择URLEncoding
            return .requestParameters(parameters: ["key":para1], encoding: URLEncoding.default)
        case .testApiDict(let dict):
            ///后台可以接收json字符串做参数时选这个
            return .requestParameters(parameters: dict, encoding: JSONEncoding.default)

        }
    }
    
    /// 设置请求头header
    var headers: [String : String]? {
        ///不同task，具体选择看后台 有application/x-www-form-urlencoded 、application/json
        return ["Content-Type":"application/x-www-form-urlencoded"]
    }
}
