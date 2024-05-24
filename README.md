# SwiftyNetworkTools

[![CI Status](https://img.shields.io/travis/Cocoa/SwiftyNetworkTools.svg?style=flat)](https://travis-ci.org/Cocoa/SwiftyNetworkTools)
[![Version](https://img.shields.io/cocoapods/v/SwiftyNetworkTools.svg?style=flat)](https://cocoapods.org/pods/SwiftyNetworkTools)
[![License](https://img.shields.io/cocoapods/l/SwiftyNetworkTools.svg?style=flat)](https://cocoapods.org/pods/SwiftyNetworkTools)
[![Platform](https://img.shields.io/cocoapods/p/SwiftyNetworkTools.svg?style=flat)](https://cocoapods.org/pods/SwiftyNetworkTools)

## Introduce

这是基于Moya二次封装的网络请求库，包含Get、Post、Download、Upload功能，能把返回数据直接转化为自定义的Model对象，简单好用。

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

对Moya有一定的了解，这是对它的二次封装

## Installation

SwiftyNetworkTools is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SwiftyNetworkTools'
```

## Instructions

1.首先配置好自己的TargetType
```ruby
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
        return URL.init(string: "http://xxx.xxx.xxx/")!
    }
    ///设置各功能的url
    var path: String {
        switch self {
        case .testApi:
            return "api/xxx/xxx/xxx"
        }
        .
        .
        .
    }
    .
    .
    .
}
```

2.定义好请求返回的数据Model, 请求结束后将自动把数据转化成Model
```ruby
struct ExampleModel: HandyJSON  {
    var wendu: Int64?
    var ganmao: String?
}

let target = APITest.testApi
NetworkManager<ExampleModel>.request(target, completion: { (result) in
    print(result)
})
```
![picture](https://github.com/evan802399/SwiftyNetworkTools/blob/master/result.png?raw=true)

## Author

Cocoa, evan802399@gmail.com

## License

SwiftyNetworkTools is available under the MIT license. See the LICENSE file for more info.

