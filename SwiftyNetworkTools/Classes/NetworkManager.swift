//
//  NetworkManager.swift
//  BaseProject
//
//  Created by Justsoso on 2024/1/22.
//
/// NetworkManager.swift ---基本框架配置及封装写到这里
import Foundation
import Moya
import Alamofire
import HandyJSON

public enum UploadFileType {
        case Image
        case Video
        case Audio
        case None
    }

/// 超时时长
private var requestTimeOut:Double = NetworkSetting.sharedManager.requestTimeOut

///endpointClosure
//这个closure存放了一些moya进行网络请求前的一些数据,可以在闭包中设置公共headers
private let endpointClosure = { (target: TargetType) -> Endpoint in
    //////主要是为了解决URL带有？无法请求正确的链接地址的bug
    let url = target.baseURL.absoluteString + target.path
    var task = target.task
    var endpoint = Endpoint(
        url: url,
        sampleResponseClosure: { .networkResponse(200, target.sampleData) },
        method: target.method,
        task: task,
        httpHeaderFields: target.headers
    )
    //     endpoint = endpoint.adding(newHTTPHeaderFields: ["platform": "iOS", "version" : "1.0"])
    // 针对于某个具体的业务模块来做接口配置
//    if let apiTarget = target as? MultiTarget, let target = apiTarget.target as? APITest {
//        switch target {
//        case .testApi:
//            return endpoint
//        case .testApiDict(_):
//            requestTimeOut = 5
//            return endpoint
//        default:
//            return endpoint
//        }
//    }
     return endpoint
 }

//这个闭包是moya提供给我们对网络请求开始前最后一次机会对请求进行修改，比如设置超时时间（默认是60s），禁用cookie等
private let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
    do {
        var request = try endpoint.urlRequest()
        //设置请求时长
        request.timeoutInterval = requestTimeOut
        // 打印请求参数
        if let requestData = request.httpBody {
            print("请求的url：\(request.url!)" + "\n" + "\(request.httpMethod ?? "")" + "发送参数" + "\(String(data: request.httpBody!, encoding: String.Encoding.utf8) ?? "")")
        } else {
            print("请求的url：\(request.url!)" + "\(String(describing: request.httpMethod))")
        }

        if let header = request.allHTTPHeaderFields {
            print("请求头内容：\(header)")
        }
        done(.success(request))
    } catch {
        done(.failure(MoyaError.underlying(error, nil)))
    }
}

/*   设置ssl
let policies: [String: ServerTrustPolicy] = [
    "example.com": .pinPublicKeys(
        publicKeys: ServerTrustPolicy.publicKeysInBundle(),
        validateCertificateChain: true,
        validateHost: true
    )
]
*/

// 过滤证书，指定域名
// DefaultTrustEvaluator 默认策略，只有合法证书才能通过验证
// RevocationTrustEvaluator 对注销证书做的一种额外设置
// PinnedCertificatesTrustEvaluator 证书验证模式，代表客户端会将服务器返回的证书和本地保存的证书中的 所有内容 全部进行校验，如果正确，才继续执行。
// PublicKeysTrustEvaluator 公钥验证模式，代表客户端会将服务器返回的证书和本地保存的证书中的
// DisabledTrustEvalutor 该选项下验证一直都是通过的，无条件信任。
// CompositeTrustEvalutor 自定义验证，需要返回一个布尔类型的结果
func customSession() -> Session {
    let serverTrustManager = ServerTrustManager(allHostsMustBeEvaluated: false,
                                                        evaluators: ["xxx.xxxxx.com": DisabledTrustEvaluator()])
    let configuration = URLSessionConfiguration.default
    configuration.headers = .default
    let session = Session(configuration: configuration,
                          startRequestsImmediately: false,
                          serverTrustManager: serverTrustManager)
    return session
}
//如何使用
//fileprivate let networkProvider = MoyaProvider<MultiTarget>(endpointClosure: endpointClosure, requestClosure: requestClosure,session:customSession(), plugins: [networkPlugin], trackInflights: false)


/// NetworkActivityPlugin插件用来监听网络请求
/// /// NetworkActivityPlugin插件用来监听网络请求，界面上做相应的展示
/// 但这里我没怎么用这个。。。 loading的逻辑直接放在网络处理里面了
private let networkPlugin = NetworkActivityPlugin.init { (changeType, targetType) in
    print("networkPlugin \(changeType)")
    //targetType 是当前请求的基本信息
    switch(changeType){
    case .began:
        print("开始请求网络")
    case .ended:
        print("结束")
    }
}

// https://github.com/Moya/Moya/blob/master/docs/Providers.md  参数使用说明
//stubClosure   用来延时发送网络请求

/// 网络请求发送的核心初始化方法，创建网络请求对象
fileprivate let networkProvider = MoyaProvider<MultiTarget>(endpointClosure: endpointClosure, requestClosure: requestClosure, plugins: [networkPlugin], trackInflights: false)

public struct NetworkManager<M: HandyJSON> {
    /// progress的回调
    public typealias NetworkProgress = (CGFloat) -> Void
    /// 请求完成的回调
    public typealias NetworkCompletion = (NetworkResult<M>) -> Void
    
    @discardableResult
    public static func request(_ target: TargetType, progress: NetworkProgress? = nil, completion: @escaping NetworkCompletion) -> Cancellable? {
        /// 先判断网络是否有链接 没有的话直接返回--代码略
        if !UIDevice.isNetworkConnect {
            completion(NetworkResult<M>(errorMsg: "网络似乎出现了问题"))
            return nil
        }
        
        ///发起请求
        let task = networkProvider.request(MultiTarget(target), callbackQueue: DispatchQueue.main) { progressResponse in
            progress?(CGFloat(progressResponse.progress))
        } completion: { result in
            //result转为NetworkResult结构体
            /* 方式一
            switch result {
            case .success(let response):
                do{
                    guard let json = try response.mapJSON() as? [String: Any] else {
                        completion(NetworkResult<M>(errorMsg: "服务器返回的不是JSON数据"))
                        return
                        return
                    }
                    completion(NetworkResult<M>(json: json))
                } catch {
                    completion(NetworkResult<M>(errorMsg:error.localizedDescription))
                }
            case .failure(let error):
                completion(NetworkResult<M>(errorMsg: error.errorDescription))
            }*/
            
            /* 方式二*/
            //result转为NetworkResult结构体
            let networkResult = result.mapNetworkResult(M.self)
            completion(networkResult)
        }
        return task
    }
    
    /// 上传文件的通用方法
    /// - Parameters:
    ///   - fileData: 文件Data类型数据
    ///   - thumbData: 缩略图数据，可选值可为nil
    ///   - params: 其它参数
    ///   - fileType: 上传文件类型
    ///   - isShowLoadHUD: 是否加载loading
    ///   - progress: 上传实时进度回调
    ///   - complete: 上传完成后的回调
    /// - Returns: 返回的是遵守Cancellable协议的Request, 用于取消息上传
    @discardableResult
    static func uploadRequest(_ target: TargetType, fileData: Data, thumbData:Data? = nil, params:[String:Any]? = nil, fileType:UploadFileType, isShowLoadHUD: Bool = false, progress:NetworkProgress? = nil,  completion:@escaping NetworkCompletion) -> Cancellable? {
        /// 先判断网络是否有链接 没有的话直接返回--代码略
        if !UIDevice.isNetworkConnect {
            completion(NetworkResult<M>(errorMsg: "网络似乎出现了问题"))
            return nil
        }

        // target从外部传入了，不需要在这处理了
//        let target = WServiceAPI.uploadFile(fileData: fileData, thumbData:thumbData, params: params ?? [:], fileType: fileType)
        let task = networkProvider.request(MultiTarget(target), callbackQueue: DispatchQueue.main) { progressResponse in
            progress?(CGFloat(progressResponse.progress))
        } completion: { result in
            //result转为NetworkResult结构体
            let networkResult = result.mapNetworkResult(M.self)
            completion(networkResult)
        }
        return task
    }
    
    /// 下载文件
    @discardableResult
    static func downloadFile(_ target: TargetType, saveName:String = "", isShowLoadHUD: Bool = false, progress:NetworkProgress? = nil,  completion:@escaping NetworkCompletion) -> Cancellable? {
        /// 先判断网络是否有链接 没有的话直接返回--代码略
        if !UIDevice.isNetworkConnect {
            completion(NetworkResult<M>(errorMsg: "网络似乎出现了问题"))
            return nil
        }

        // target从外部传入了，不需要在这处理了
        // let target = WServiceAPI.download(fileUrl: fileUrl, saveName: saveName)
        let task = networkProvider.request(MultiTarget(target), callbackQueue: DispatchQueue.main) { progressResponse in
            progress?(CGFloat(progressResponse.progress))
        } completion: { result in
            //result转为NetworkResult结构体
            let networkResult = result.mapNetworkResult(M.self)
            completion(networkResult)
        }
        return task
    }
}



extension UIDevice {
    static var isNetworkConnect: Bool {
        let network = NetworkReachabilityManager()
        return network?.isReachable ?? true // 无返回就默认网络已连接
    }
}



public class FileSystem {
public    static let documentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1]
    }()
    
public    static let cacheDirectory: URL = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1]
    }()
    
public    static let downloadDirectory: URL = {
        let directory: URL = FileSystem.documentsDirectory.appendingPathComponent("Download")
        return directory
    }()
}
