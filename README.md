# SwiftyNetworkTools

[![CI Status](https://img.shields.io/travis/Cocoa/SwiftyNetworkTools.svg?style=flat)](https://travis-ci.org/Cocoa/SwiftyNetworkTools)
[![Version](https://img.shields.io/cocoapods/v/SwiftyNetworkTools.svg?style=flat)](https://cocoapods.org/pods/SwiftyNetworkTools)
[![License](https://img.shields.io/cocoapods/l/SwiftyNetworkTools.svg?style=flat)](https://cocoapods.org/pods/SwiftyNetworkTools)
[![Platform](https://img.shields.io/cocoapods/p/SwiftyNetworkTools.svg?style=flat)](https://cocoapods.org/pods/SwiftyNetworkTools)

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
    case testApi//无参数的接口
    //有参数的接口
    case testAPi(para1:String,para2:String)//普遍的写法
    case testApiDict(Dict:[String:Any])//把参数包装成字典传入--推荐使用
}

extension APITest:TargetType{
    //baseURL 也可以用枚举来区分不同的baseURL，不过一般也只有一个BaseURL
    var baseURL: URL {
        //此处替换应该替换为Moya_baseURL，下面url是用于测试数据
        return URL.init(string: "http://xxx/api/feature/city/101030100")!
    }
    //不同接口的子路径
    var path: String {
        switch self {
        case .testApi:
            return ""
            default:
            return "xxx"
        }
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

## Author

Cocoa, evan802399@gmail.com

## License

SwiftyNetworkTools is available under the MIT license. See the LICENSE file for more info.
