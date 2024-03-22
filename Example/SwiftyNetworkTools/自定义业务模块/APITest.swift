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
    case testApi//无参数的接口
    //有参数的接口
    case testAPi(para1:String,para2:String)//普遍的写法
    case testApiDict(Dict:[String:Any])//把参数包装成字典传入--推荐使用
}

extension APITest:TargetType{
    //baseURL 也可以用枚举来区分不同的baseURL，不过一般也只有一个BaseURL
    var baseURL: URL {
        //此处替换应该替换为Moya_baseURL，下面url是用于测试数据
        return URL.init(string: "http://t.weather.itboy.net/api/weather/city/101030100")!
    }
    //不同接口的字路径
    var path: String {
        switch self {
        case .testApi:
            return ""
        case .testAPi(let para1, _):
            return "\(para1)/news/latest"
        case .testApiDict(_):
            return "4/news/latest"
//        default:
//            return "4/news/latest"
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
            <#code#>
        default:
            return "".data(using: String.Encoding.utf8)!
        }
        
    }
    
    /// 这个就是API里面的核心。嗯。。至少我认为是核心，因为我就被这个坑过
    //类似理解为AFN里的URLRequest
    var task: Task {
        switch self {
        case .testApi:
            return .requestPlain
        case .testAPi(let para1, _)://这里的缺点就是多个参数会导致parameters拼接过长
        //后台的content-Type 为application/x-www-form-urlencoded时选择URLEncoding
            return .requestParameters(parameters: ["key":para1], encoding: URLEncoding.default)
        case .testApiDict(let dict)://所有参数当一个字典进来完事。
            //后台可以接收json字符串做参数时选这个
            return .requestParameters(parameters: dict, encoding: JSONEncoding.default)

        }
    }
    
    /// 设置请求头header
    var headers: [String : String]? {
        //同task，具体选择看后台 有application/x-www-form-urlencoded 、application/json
        return ["Content-Type":"application/x-www-form-urlencoded"]
    }
}
