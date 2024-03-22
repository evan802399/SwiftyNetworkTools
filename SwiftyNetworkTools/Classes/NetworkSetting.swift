//
//  NetworkSetting.swift
//  SwiftNetworking
//
//  Created by Justsoso on 2024/3/7.
//

import Foundation

public class NetworkSetting {
    //  单例
    class var sharedManager: NetworkSetting {
            struct Static {
                static let sharedInstance: NetworkSetting = NetworkSetting()
            }
            return Static.sharedInstance
        }
    
    //    默认超时时间
    var requestTimeOut:Double = 30.0
}



