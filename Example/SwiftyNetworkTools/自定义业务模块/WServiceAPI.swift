//
//  WServiceAPI.swift
//  BaseProject
//
//  Created by Justsoso on 2024/2/2.
//  上传、下载 TargetType

import Moya
import SwiftyNetworkTools

enum WServiceAPI {
    //MARK: - 下载参数
    // 获取想要存储的文件路径
    var localLocation: URL {
        switch self {
        case .download(let saveName):
            let localFilePath = FileSystem.downloadDirectory
            return localFilePath.appendingPathComponent(saveName)
        default:
            return URL(string: "")!
        }
    }
    // 封装下下载路径
    var downloadDestination: DownloadDestination {
        // `createIntermediateDirectories` will create directories in file path
        return { _, _ in return (self.localLocation, [.removePreviousFile, .createIntermediateDirectories]) }
    }
    
    //MARK: - 定义请求类型
    ///如果是图片类型，formDatas最多2个元素，第1个是图片原始数据，第2个是缩略图数据, 第3个是参数，第4个是文件类型
    case uploadFile(fileData: Data, thumbData:Data? = nil, params: [String:Any], fileType:UploadFileType)
    case download(saveName:String = "")
    case dynamicURL(url:String)
}

extension WServiceAPI: TargetType {
    
    var baseURL: URL {
        switch self {
        case .uploadFile:
            return URL(string: Moya_upload_baseURL)!
        case .download:
            return URL(string: Moya_download_baseURL)!
        case .dynamicURL(url: let url):
            return URL(string: url)!
        }
    }
    
    var path: String {
        switch self {
        case .uploadFile:
            return "v1/assets/userupload"
        case .download(_):
            return "v1/assets/download"
        case .dynamicURL:
            return ""
        }
    }
    
    var sampleData: Data{
        return "sampleData".data(using: String.Encoding.utf8)!
    }
    
    var params: [String : Any] {
        switch self {
        case .uploadFile(_, _, let params, _):
            return params
        case .download:
            return [:]
        case .dynamicURL:
            return [:]
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .uploadFile:
            return .post
        case .download:
            return .get
        case .dynamicURL:
            return .get
        }
    }
    
    var task: Task {
        var t:Task?
        switch self {
        //目前仅支持上传1个， 如果需要支持上传多个，则fileType需改成数组类型 [UploadFileType]
        case .uploadFile(let fileData, let thumbData, let params, let fileType):
            var mulFormDatas = [MultipartFormData]()
            switch fileType {
            case .Image:
                //要上传的图片数据
                let name = "file"
                let fileName = "iOS\(Date().milliStamp).jpg"
                let formData = MultipartFormData(provider: .data(fileData), name: name, fileName: fileName)
                mulFormDatas.append(formData)
            case .Video:
                //要上传的视频数据
                let name = "file"
                let fileName = "iOS\(Date().milliStamp).mp4"
                let formData = MultipartFormData(provider: .data(fileData), name: name, fileName: fileName)
                mulFormDatas.append(formData)
            case .Audio:
                //要上传的视频数据
                let name = "file"
                let fileName = "iOS\(Date().milliStamp).mp3"
                let formData = MultipartFormData(provider: .data(fileData), name: name, fileName: fileName)
                mulFormDatas.append(formData)
            case .None:
                break
            }
            //缩略图
            if thumbData != nil {
                let thumbName = "thumbnail"
                let thumbFileName = "iOS\(Date().milliStamp)_thumbnail.jpg"
                let thumbFormData = MultipartFormData(provider: .data(thumbData!), name: thumbName, fileName: thumbFileName)
                mulFormDatas.append(thumbFormData)
            }
            
            //其它参数
            for (key, value) in params {
                let valueStr = "\(value)"
                if let valueData = valueStr.data(using: .utf8) {
                    let formData = MultipartFormData(provider: .data(valueData), name: key)
                    mulFormDatas.append(formData)
                }
            }
            t = .uploadMultipart(mulFormDatas)
        case .download:
            t = .downloadDestination(downloadDestination)
        case .dynamicURL:
            t = .requestPlain
        }
        return t!
    }
    
    var headers: [String : String]? {
        var header = ["Content-Type":"multipart/form-data"]
        switch self {
        case .uploadFile:
            header["Token"] = ""
        case .download:
            return nil
        case .dynamicURL:
            return nil
        }
        return header
    }
}



extension Date {
    /**
       根据时间戳获取 dd  hh:mm:ss
     */
    static  func getHHMMSSTimeString(teptime:TimeInterval) ->String{
        var time:Int = Int(teptime)
                  let ss = time % 60
                  time = time / 60
                  let mm = time % 60
                   time = time / 60
                  let hh = time % 24
                  time = time / 24
        var dd:Int = 0
        if time > 0 {
            dd = time
        }
        var str = ""
        if dd > 0 {
            str = str + String(format: "%02d ", dd)
        }
        str = str + String(format: "%02d:%02d:%02d", hh,mm,ss)
        return str
    }
    
//    static func getDayWithTimeInterval(time:TimeInterval) -> Int {
//        var day = Int(time)/24/3600
//    }
    
    // 当年农历年份
    func zodiac() -> Int {
        let calendar: Calendar = Calendar(identifier: .chinese)
        return calendar.component(.year, from: self)
    }
    

    
    
    ///根据时间戳创建日期 10位时间戳
    ///     let date = Date(unixTimestamp: 1484239783.922743) // "Jan 12, 2017, 7:49 PM"
    ///
    /// - Parameter unixTimestamp: UNIX timestamp.
    public init(unixTimestamp: Double) {
        self.init(timeIntervalSince1970: unixTimestamp)
    }
    
    
    
    
    /// 时间戳日期按照给定的格式转化为日期字符串
    ///     Date().string(withFormat: "dd/MM/yyyy") -> "1/12/17"
    ///     Date().string(withFormat: "HH:mm") -> "23:50"
    ///     Date().string(withFormat: "dd/MM/yyyy HH:mm") -> "1/12/17 23:50"
    ///        yyyy-MM-dd HH:mm:ss
    /// - Parameter format: Date format (default is "dd/MM/yyyy").
    /// - Returns: date string.
    static func string(withFormat format: String = "yyyy-MM-dd HH:mm:ss" ,timeStamp:String,isChina:Bool = false) -> String {
        if timeStamp.count < 1 {return ""}
        let interval:TimeInterval = TimeInterval.init(timeStamp)!

        let date = Date(timeIntervalSince1970: interval/1000)  //因为是十三位时间戳所以要除1000
        //13位数时间戳 (13位数的情况比较少见)
        // let interval = CLongLong(round(nowDate.timeIntervalSince1970*1000))
        let dateFormatter = DateFormatter()
        if isChina {
            dateFormatter.timeZone = TimeZone(identifier:"Asia/Chongqing")
        }
        
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    // 时间戳日期按照给定的格式转化为日期字符串
    ///     Date().string(withFormat: "dd/MM/yyyy") -> "1/12/17"
    ///     Date().string(withFormat: "HH:mm") -> "23:50"
    ///     Date().string(withFormat: "dd/MM/yyyy HH:mm") -> "1/12/17 23:50"
    ///        yyyy-MM-dd HH:mm:ss
    /// - Parameter format: Date format (default is "dd/MM/yyyy").
    /// - Returns: date string.
    static func string(format: String = "yyyy-MM-dd HH:mm:ss", timestamp:String) -> Date? {
        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = TimeZone(identifier:"Asia/Chongqing")
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: timestamp)
    }
    
    /// Date日期按照给定的格式转化为日期字符串
    /// - Parameter format: Date format (default is "yyyy-MM-dd").
    /// - Returns: date string.
    static func stringDate(withFormat format: String = "yyyy-MM-dd" , date:Date = Date(),isChina:Bool = false) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if isChina {
            dateFormatter.timeZone = TimeZone(identifier:"Asia/Chongqing")
        }
        return dateFormatter.string(from: date)
    }
    
    /// 时间戳转成字符串
    static func timeIntervalChangeToTimeStr(timeInterval:TimeInterval, dateFormat:String?) -> String {
        let date:NSDate = NSDate.init(timeIntervalSince1970: timeInterval)
        let formatter = DateFormatter.init()
        if dateFormat == nil {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }else{
            formatter.dateFormat = dateFormat
        }
        return formatter.string(from: date as Date)
    }
    
    /// 字符串转时间戳
    static func timeStrChangeTotimeInterval(timeStr: String?, dateFormat:String="yyyy-MM-dd HH:mm:ss") -> String {
        if timeStr?.count == 0 {
            return ""
        }
        let format = DateFormatter.init()
        format.dateStyle = .medium
        format.timeStyle = .short
        format.timeZone = TimeZone(identifier:"Asia/Chongqing")
//        if dateFormat == nil {
//            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        }else{
        format.dateFormat = dateFormat
//        }
        let date = format.date(from: timeStr!)
        return date!.milliStamp
    }
    
    /// 日期字符串转化为Date类型
    ///
    /// - Parameters:
    ///   - string: 日期字符串
    ///   - dateFormat: 格式化样式，默认为“yyyy-MM-dd HH:mm:ss”
    /// - Returns: Date类型
    static func stringConvertDate(string:String, dateFormat:String="yyyy-MM-dd HH:mm:ss") -> Date {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from: string)
        return date!
    }
    
    ///计算两个时间相差几天 可把day扩展为其他
    static func numberOfDaysWithFromDate(date:Date, toDate:Date) -> Int {
        let calendar = NSCalendar.init(calendarIdentifier: .gregorian)
        let comp = calendar?.components(.day, from: date, to: toDate, options: .wrapComponents)
        return comp?.day ?? 0
    }
    
    static func numberOfMinutesWithFromDate(date:Date, toDate:Date) -> Int {
        let calendar = NSCalendar.init(calendarIdentifier: .gregorian)
        let comp = calendar?.components(.minute, from: date, to: toDate, options: .wrapComponents)
        return comp?.minute ?? 0
    }
    
    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
    
    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
    
    
    //MARK: 将两个时间戳间隔 显示为（几分钟前，几小时前，几天前）
    ///     将两个时间戳间隔 显示为（几分钟前，几小时前，几天前）
    /// - Parameter stamp1: int    小的时间戳
    /// - Parameter stamp2: int    大的时间戳
    /// - Returns: string (几分钟前，几小时前，几天前）
    static func twotimeStampCompare(_ stamp1:Int ,_ stamp2:Int) -> String {
        if stamp1 > stamp2 { return "0秒前" }
        let timeInterval:TimeInterval = TimeInterval((stamp2 - stamp1)/1000)
        var temp:Double = 0
        var result:String = ""
        if timeInterval/60 < 1 {
            
            //            result = "刚刚"
            result = "\(Int(timeInterval))秒前"
            
        }else if (timeInterval/60) < 60{
            
            temp = timeInterval/60
            
            result = "\(Int(temp))分钟前"
            
        }else if timeInterval/60/60 < 24 {
            
            temp = timeInterval/60/60
            
            result = "\(Int(temp))小时前"
            
        }else if timeInterval/(24 * 60 * 60) < 30 {
            
            temp = timeInterval / (24 * 60 * 60)
            
            result = "\(Int(temp))天前"
            
        }else if timeInterval/(30 * 24 * 60 * 60)  < 12 {
            
            temp = timeInterval/(30 * 24 * 60 * 60)
            
            result = "\(Int(temp))个月前"
            
        }else{
            
            temp = timeInterval/(12 * 30 * 24 * 60 * 60)
            
            result = "\(Int(temp))年前"
            
        }
        
        return result
        
    }
    
    
    
    /*
     几年几月 这个月的多少天
     */
    static func getDaysInMonth( year: Int, month: Int) -> Int {
        
        let calendar = NSCalendar.current
        
        let startComps = NSDateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year
        
        let endComps = NSDateComponents()
        endComps.day = 1
        endComps.month = month == 12 ? 1 : month + 1
        endComps.year = month == 12 ? year + 1 : year
        
        let startDate = calendar.date(from: startComps as DateComponents)
        let endDate = calendar.date(from:endComps as DateComponents)!
        
        let diff = calendar.dateComponents([.day], from: startDate!, to: endDate)
        
        return diff.day!;
    }
    
    
    /*
     几年几月 这个月的第一天是星期几
     */
    static func firstWeekdayInMonth(year: Int, month: Int)->Int{
        
        let calender = NSCalendar.current;
        let startComps = NSDateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year
        let startDate = calender.date(from: startComps as DateComponents)
        let firstWeekday = calender.ordinality(of: .weekday, in: .weekOfMonth, for: startDate!)
        let week = firstWeekday! - 1;
        
        return week ;
    }
    
    /*
     今天是星期几
     */
    func dayOfWeek() -> Int {
        let interval = self.timeIntervalSince1970;
        let days = Int(interval / 86400);// 24*60*60
        return (days - 3) % 7;
    }
    
    static func getCurrentDay() ->Int {
        
        let com = self.getComponents();
        return com.day!
    }
    
    static func getCurrentMonth() ->Int {
        
        let com = self.getComponents();
        return com.month!
    }
    
    static func getCurrentYear() ->Int {
        
        let com = self.getComponents();
        return com.year!
    }
    
    static func getComponents(date:Date = Date())->DateComponents{
        
        let calendar = NSCalendar.current;
        //这里注意 swift要用[,]这样方式写
        let com = calendar.dateComponents([.year,.month,.day,.hour,.minute], from:date);
        return com
    }
    
    
    static func getComponents(timestamp:TimeInterval)->DateComponents{
        
        let date = Date(timeIntervalSince1970: timestamp / 1000)
        let calendar = NSCalendar.current;
        //这里注意 swift要用[,]这样方式写
        let com = calendar.dateComponents([.year,.month,.day,.hour,.minute], from:date);
        return com
    }
    
    /// 获取指定日期之前的第N天
    static func getDayForDesignDaysPreviou(designDate:Date = Date(), format:String = "yyyy-MM-dd", previou:Int = 7) -> Date? {
        //当前时间
        let currentDate = designDate
        let calender = Calendar(identifier: Calendar.Identifier.gregorian)
        var comp = calender.dateComponents([.year, .month, .day, .weekday], from: currentDate)

        //当前时间是几号、周几
        let currentDay = comp.day
        let weeKDay = comp.weekday

        //如果获取当前时间的日期和周几失败，返回nil
        guard let day = currentDay, let week = weeKDay else {
            return nil
        }

        //由于1代表的是周日，因此计算出准确的周几
        var currentWeekDay = 0
        if week == 1 {
            currentWeekDay = 7
        } else {
            currentWeekDay = week - 1
        }

        //1 ... 7表示周一到周日
        //进行遍历和currentWeekDay进行比较，计算出之间的差值，即为当前日期和一周时间日期的差值，即可计算出一周时间内准备的日期
//        var dateStrs: [String] = []
        var dateResult = Date()
        for index in 1 ... previou {
            let diff = index - currentWeekDay
            comp.day = day - diff
            let date = calender.date(from: comp)
        
            //由于上述方法返回的Date为可选类型，要进行判空处理
            if let _ = date {
                if previou == index + 1 {
                    dateResult = date ?? Date()
                }
            }
        }
        //返回时间
        return dateResult
    }
    
    /// 获取指定日期之前的N天日期
    static func getDaysForDesignDaysPrevious(designDate:Date = Date(), format:String = "yyyy年MM月dd日", previous:Int = 7) -> [String]? {
        //当前时间
        let currentDate = designDate
        let calender = Calendar(identifier: Calendar.Identifier.gregorian)
        var comp = calender.dateComponents([.year, .month, .day, .weekday], from: currentDate)

        //当前时间是几号、周几
        let currentDay = comp.day
        let weeKDay = comp.weekday

        //如果获取当前时间的日期和周几失败，返回nil
        guard let day = currentDay, let week = weeKDay else {
            return nil
        }

        //由于1代表的是周日，因此计算出准确的周几
        var currentWeekDay = 0
        if week == 1 {
            currentWeekDay = 7
        } else {
            currentWeekDay = week - 1
        }

        //1 ... 7表示周一到周日
        //进行遍历和currentWeekDay进行比较，计算出之间的差值，即为当前日期和一周时间日期的差值，即可计算出一周时间内准备的日期
        var dateStrs: [String] = []
        for index in 1 ... previous {
            let diff = index - currentWeekDay
            comp.day = day - diff
            let date = calender.date(from: comp)
        
            //由于上述方法返回的Date为可选类型，要进行判空处理
            if let _ = date {
                let dateStr =  Date.stringDate(withFormat: format, date: date!, isChina: true)
                dateStrs.append(dateStr)
            }
        }

        //返回时间数组
        return dateStrs
    }
    
    /// 获取指定日期之前的N个月月份
    static func getMonthsForDesignMonthPrevious(format: String = "yyyy年MM月", design:Date = Date(), previous:Int = 10) -> [String] {
        let curDate = design
        let formater = DateFormatter()
        formater.dateFormat = format
        
        let calendar = Calendar(identifier: .gregorian)
        var lastMonthComps = DateComponents()
        var months = [String]()
        for i in 0..<previous {
            // year = 1表示1年后的时间 year = -1为1年前的日期，month day 类推
            lastMonthComps.month = -i
            let newDate = calendar.date(byAdding: lastMonthComps, to: curDate)
            let dateStr = formater.string(from: newDate!)
            months.append(dateStr)
        }
        
        return months
    }
    
    
    static func getWeekDay(timeStamp:TimeInterval) -> String {
        let weekday = ["周日","周一","周二","周三","周四","周五","周六"]
        
        let newDate = Date(timeIntervalSince1970: timeStamp / 1000)
        let calendar = Calendar(identifier: .gregorian)
        let compoents = calendar.dateComponents([.weekday], from: newDate)
        
        let weekStr = weekday[compoents.weekday! - 1]
        
        return weekStr
    }
}
