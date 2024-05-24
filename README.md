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
![avatar][result]

## Author

Cocoa, evan802399@gmail.com

## License

SwiftyNetworkTools is available under the MIT license. See the LICENSE file for more info.


[result]:data:image/png;base64,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
