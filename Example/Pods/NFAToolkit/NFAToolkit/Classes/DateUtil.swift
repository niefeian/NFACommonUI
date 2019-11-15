//
//  DateUtil.swift
//  Pods-Tools_Example
//
//  Created by 聂飞安 on 2019/8/15.
//


import Foundation

open class DateUtil {
    
    /// 时间差：客户端与服务器的时间差,采用服务端-客户端
    fileprivate static var timediff : TimeInterval = 0
    
    open class func calcTimeDiff(_ servtime : Double, beginCall : Double) {
        let client_seconds = Date().timeIntervalSince1970 * 1000
        timediff = servtime - beginCall - (client_seconds - beginCall) / 2
    }
    
    /// 获取到1970年的时间差。注意，这个独立成一个方法主要是需要包含服务端与客户端的时间差
    open class func getTimeSince1970() -> TimeInterval {
        //+客户端与服务端时间差
        return Date().timeIntervalSince1970 + timediff/1000
    }
    
    open class func getTimeStamp() -> TimeInterval {
        return Date().timeIntervalSince1970 * 1000 + timediff
    }
    
    /// 当前时间。加上了客户端与服务端的时间差
    open class func curDate() -> Date {
        return Date(timeIntervalSince1970: getTimeSince1970())
    }
    
    /// 2016年起点
    open class func time2016() -> Date {
        return dateTimeFromStr("2015-01-01 00:00:00")
    }
    
    /// 获取年月日...秒的时间
    open class func dateTimeToStr(_ date : Date) -> String {
        
        return formatDateToStr(date, format: "yyyy-MM-dd HH:mm:ss")
    }
    
    /// 获取年月日的时间
    open class func dateToStr(_ date : Date) -> String {
        
        return formatDateToStr(date, format: "yyyy-MM-dd")
    }
    
    /// 获取格式化的日期
    open class func formatDateToStr(_ date : Date, format : String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: date)
    }
    
    /// 文本转时间
    open class func dateTimeFromStr(_ strDate : String) -> Date {
        return formatStrToDate(strDate, format: "yyyy-MM-dd HH:mm:ss")
    }
    
    open class func dateFromStr(_ strDate : String) -> Date {
        
        return formatStrToDate(strDate, format: "yyyy-MM-dd")
    }
    
    open class func formatStrToDate(_ strDate : String, format : String) -> Date {
        let fmt = DateFormatter()
        fmt.dateFormat = format
        return fmt.date(from: strDate)!
    }
    
    /// 转换秒成时间格式
    open class func transTimeIntervalToYYYYMMDD(_ curTimes : TimeInterval) -> String{
        let h = Int(curTimes / 3600)
        var t = ""
        if h > 0 {
            if h > 0 && h < 10 {
                t = "0\(h):"
            } else {
                t = "\(h):"
            }
        }
        let min = Int((Int(curTimes) - h * 3600) / 60)
        if min > 0 {
            if min < 10 {
                t += "0\(min):"
            } else {
                t += "\(min):"
            }
        } else if t != "" {
            t += "00:"
        }
        
        let sec = Int(curTimes.truncatingRemainder(dividingBy: 60))
        if sec > 0 {
            if sec < 10 {
                t += "0\(sec)"
            } else {
                t += "\(sec)"
            }
        } else if t != "" {
            t += "00"
        }
        return t
    }
    
    /// 获取显示的时间：传入毫秒数
    open class func getShowTimeWithMillisecond(_ toTime : Double) -> String{
        return getShowTime(toTime / 1000)
    }
    
    /// 传入秒数
    open class func getShowTime(_ toTime : Double, simpleDateFormat : String = "MM/dd") -> String{
        // 比较时间
        let toDateTime = Date(timeIntervalSince1970: toTime)
        let toDate = DateUtil.formatDateToStr(toDateTime, format : "yyyy/MM/dd")
        // 当前日期
        let curDateTime = DateUtil.curDate()
        let curDate = DateUtil.formatDateToStr(curDateTime, format : "yyyy/MM/dd")
        
        if toDate == curDate {
            // 同一天
            return DateUtil.formatDateToStr(toDateTime, format : "HH:mm")
        } else {
            if (toDate.substringToIndex(5) == curDate.substringToIndex(5)) {
                // 同一年
                return DateUtil.formatDateToStr(toDateTime, format : simpleDateFormat)
            } else {
                return toDate
            }
        }
    }
    
    
    /// 获得显示显示：原始格式：yyyyMMddHHmmss。
    /// 刚刚、xx分钟前、xx小时前、同一年的显示月-日，最后yyyy/MM/dd
    open class func getShowTime2(_ time : String, format : String = "yyyyMMddHHmmss") -> String{
        let dateTime = DateUtil.formatStrToDate(time, format: format)
        let curDate = DateUtil.formatDateToStr(dateTime, format : "yyyy/MM/dd")
        let today = DateUtil.curDate()
        let date = DateUtil.formatDateToStr(today, format : "yyyy/MM/dd")
        var ret : String!
        if date == curDate {
            // 同一天
            let oldTime = DateUtil.formatStrToDate(time, format: format).timeIntervalSince1970
            let nowTime = getTimeSince1970()
            let sub = nowTime - oldTime
            if sub < 60 {
                ret = "刚刚"
            } else if sub < 60 * 60 {
                ret = "\(Int(sub / 60))分钟前"
            } else {
                ret = "\(Int(sub / 3600))小时前"
            }
        } else {
            if (date.substringToIndex(5) == curDate.substringToIndex(5)) {
                // 同一年
                ret = DateUtil.formatDateToStr(dateTime, format : "MM-dd")
            } else {
                ret = curDate
            }
        }
        return ret
    }
    
    /// 返回MM-dd HH:mm 格式
    open class func getShowDateTime(_ time : String, format : String = "yyyyMMddHHmmss") -> String{
        let dateTime = DateUtil.formatStrToDate(time, format: format)
        let curDate = DateUtil.formatDateToStr(dateTime, format : "yyyy/MM/dd")
        let today = DateUtil.curDate()
        let date = DateUtil.formatDateToStr(today, format : "yyyy/MM/dd")
        var ret : String!
        if (date.substringToIndex(5) == curDate.substringToIndex(5)) {
            // 同一年
            ret = DateUtil.formatDateToStr(dateTime, format : "MM-dd HH:mm")
        } else {
            ret = curDate
        }
        
        return ret
    }
    
    /// 获得显示显示：原始格式：yyyyMMddHHmmss
    open class func getShowTime(_ time : String, format : String = "yyyyMMddHHmmss") -> String{
        let dateTime = DateUtil.formatStrToDate(time, format: format)
        let curDate = DateUtil.formatDateToStr(dateTime, format : "yyyy/MM/dd")
        let today = DateUtil.curDate()
        let date = DateUtil.formatDateToStr(today, format : "yyyy/MM/dd")
        var ret : String!
        if date == curDate {
            // 同一天
            let oldTime = DateUtil.formatStrToDate(time, format: format).timeIntervalSince1970
            let nowTime = getTimeSince1970()
            let sub = nowTime - oldTime
            if sub < 60 {
                ret = "刚刚"
            } else if sub < 60 * 60 {
                ret = "\(Int(sub / 60))分钟前"
            } else {
                ret = "\(Int(sub / 3600))小时前"
            }
        } else {
            if (date.substringToIndex(5) == curDate.substringToIndex(5)) {
                // 同一年
                ret = DateUtil.formatDateToStr(dateTime, format : "MM月dd日 HH:mm")
            } else {
                ret = curDate
            }
        }
        return ret
    }
    
    open class func dateToStrt(_ date : Date) -> String {
           return formatDateToStr(date, format: "yyyy-MM-dd-HH")
    }
}
