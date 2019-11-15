//
//  MD5Helper.swift
//  Pods-Tools_Example
//
//  Created by 聂飞安 on 2019/8/15.
//


import Foundation
import UIKit

public func printLog<T>(_ message : T, file : String = #file, method : String = #function, line : Int = #line) {
    #if DEBUG
    print(file)
    print("\(line),\(method):\n\(message)")
    #endif
}

public let AppWidth: CGFloat = UIScreen.main.bounds.size.width
public let AppHeight: CGFloat = UIScreen.main.bounds.size.height

public func colorConversion(colorValue: String, alpha: CGFloat = 1) -> UIColor{
    var str = colorValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    if str.hasPrefix("#") {
        str = str.replacingOccurrences(of: "#", with: "")
    }
    if str.count != 6 {
        return .white
    }
    let redStr = str.prefix(2)
    let greenStr = str.subString(start: 2, length: 2)
    let blueStr = str.subString(start: 4)
    var r:UInt64 = 0, g:UInt64 = 0, b:UInt64 = 0
    Scanner(string: String(redStr)).scanHexInt64(&r)
    Scanner(string: greenStr).scanHexInt64(&g)
    Scanner(string: blueStr).scanHexInt64(&b)
    return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: alpha)
}

public func pd6sW(_ pd : CGFloat) -> CGFloat{
    return pd * AppWidth / 375
}

public func pd6sH(_ pd : CGFloat) -> CGFloat{
    return pd * AppHeight / 568.0
}

public extension String {
    // 从0开始截取到to的位置。如果to的位置超过文本的长度，返回原始文本。注意需要截取到的位置是原始位置+1，如20160101要截取年度，substringToIndex(5).注意参数是5，不是4
    func substringToIndex(_ to : Int) -> String {
        
        var temp : NSString = self as NSString
        let length = temp.length
        if to > length {
            return self
        }
        temp = temp.substring(to: to - 1) as NSString
        return temp as String
    }
    
    func subString(start:Int, length:Int = -1)->String {
        var len = length
        if len == -1 {
            len = count - start
        }
        let st = index(startIndex, offsetBy:start)
        let en = index(st, offsetBy:len)
        let range = st ..< en
        return substring(with:range)
    }
    
    func positionOf(sub:String)->Int {
           var pos = -1
           if let range = range(of:sub) {
               if !range.isEmpty {
                   pos = distance(from:startIndex, to:range.lowerBound)
               }
           }
           return pos
       }
     
       
       func urlEncoded()->String {
           let res:NSString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, self as NSString, nil,
               "!*'();:@&=+$,/?%#[]" as CFString?, CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue))
           return res as String
       }
       
       func urlDecoded()->String {
           let res:NSString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, self as NSString, "" as CFString?, CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue))
           return res as String
       }
       
       
       /**
        将当前字符串拼接到cache目录后面
        */
       func cacheDir() -> String{
           let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!  as NSString
           return path.appendingPathComponent((self as NSString).lastPathComponent)
       }
       /**
        将当前字符串拼接到doc目录后面
        */
       func docDir() -> String
       {
           let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!  as NSString
           return path.appendingPathComponent((self as NSString).lastPathComponent)
       }
       /**
        将当前字符串拼接到tmp目录后面
        */
       func tmpDir() -> String
       {
           let path = NSTemporaryDirectory() as NSString
           return path.appendingPathComponent((self as NSString).lastPathComponent)
       }
    
        func stringValueDic() -> [String: Any]?{
            if let data = self.data(using:String.Encoding.utf8){
                if let dict = try? JSONSerialization.jsonObject(with: data,options: JSONSerialization.ReadingOptions.mutableContainers)as? [String: Any] {
                    return dict
                }
            }
           return nil
       }
}

public extension Dictionary {
     mutating func addAll(_ dic : Dictionary) {
        for (k , v) in dic {
            self[k] = v
        }
    }
    
    func dicValueString() ->String?{
        if let data = try? JSONSerialization.data(withJSONObject: self,options: []){
            let str = String(data: data,encoding:String.Encoding.utf8)
            return str
        }
        return nil
    }
}

public extension CGFloat {
    var valueBetweenZeroAndOne: CGFloat {
        return abs(self) > 1 ? 1 : abs(self)
    }
}

public extension UIImage {
    class func sharedCache() -> NSCache<AnyObject, AnyObject>!
    {
        return NSCache()
    }
}

/// 对UIView的扩展
public extension UIView {
    /// 宽度
    var width: CGFloat {
        return self.frame.size.width
    }
    ///高度
    var height: CGFloat {
        return self.frame.size.height
    }
}


public extension UITableView {
    func autoRowHeight(){
        self.estimatedRowHeight = 100.0
        self.rowHeight = UITableView.automaticDimension
    }
}

public extension UITableViewCell {
    func setRowSelectDisable(){
        self.accessoryType = UITableViewCell.AccessoryType.none
        self.selectionStyle = UITableViewCell.SelectionStyle.none
    }
}



import CommonCrypto
public extension String {
    
    var md5 : String{
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen);
        
        CC_MD5(str!, strLen, result);
        
        let hash = NSMutableString();
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i]);
        }
        result.deinitialize(count: 0);
        
        return String(format: hash as String).lowercased()
    }
    
    func pregReplace(pattern: String, with: String,
                     options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [],
                                              range: NSMakeRange(0, self.count),
                                              withTemplate: with)
    }
}

public extension UILabel {
    
    func setLable(text : String ,lineSpacing:CGFloat = 10 ) {
        let paraph = NSMutableParagraphStyle()
        paraph.lineSpacing = lineSpacing
        let attributes = [NSAttributedString.Key.paragraphStyle: paraph]
        self.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
    
    func setLineSpacing(_ lineSpacing : CGFloat = 5 ) {
        self.setLable(text: self.text ?? "", lineSpacing: lineSpacing)
    }
    
    func setAttrString(string : String , lineSpacing:CGFloat = 5 , array : [(String,UIColor,CGFloat)]) {
           let paraph = NSMutableParagraphStyle()
           paraph.lineSpacing = lineSpacing
           let attributes = [NSAttributedString.Key.paragraphStyle: paraph]
        let attrString = NSMutableAttributedString(string: string , attributes: attributes)
     
        for arr in array {
            let attr: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: arr.2),.foregroundColor: arr.1]
            let i  = string.positionOf(sub: arr.0)
            if  i >= 0  && i < string.count {
                attrString.addAttributes(attr, range:NSRange(location: string.positionOf(sub: arr.0), length: arr.0.count))
            }
        }
        self.attributedText = attrString
    }
    
    func setAttrStrings(string : String , lineSpacing:CGFloat = 5 , array : [(String,[NSAttributedString.Key : Any])]) {
          let paraph = NSMutableParagraphStyle()
          paraph.lineSpacing = lineSpacing
          let attributes = [NSAttributedString.Key.paragraphStyle: paraph]
       let attrString = NSMutableAttributedString(string: string , attributes: attributes)
    
       for arr in array {
            attrString.addAttributes(arr.1, range:NSRange(location: string.positionOf(sub: arr.0), length: arr.0.count))
       }
       self.attributedText = attrString
      }
}


public extension NSDictionary {
    
    func string(forKey key : String, _ defaultValue : String = "") -> String{
        return object(forKey: key) as? String ?? defaultValue
    }
    
    func integer(forKey key : String, _ defaultValue : Int = 0) -> Int{
        if  let integer = object(forKey: key) as? Int {
            return integer
        }else if  let string = object(forKey: key) as? String {
            return Int(string) ?? defaultValue
        }
        return  defaultValue
    }
    
    func doubleValue(forKey key : String, _ defaultValue : Double = 0.0) -> Double{
        if  let integer = object(forKey: key) as? Double {
            return integer
        }else if  let string = object(forKey: key) as? NSString {
            return string.doubleValue
        }
        return  defaultValue
    }
}

 public extension Int {
    var cn1: String {
        get {
            if self == 0 {
                return "零"
            }
            let zhNumbers = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
            let units = ["", "十", "百", "千", "万", "十", "百", "千", "亿", "十","百","千"]
            var cn = ""
            var currentNum = 0
            var beforeNum = 0
            let intLength = Int(floor(log10(Double(self))))
            for index in 0...intLength {
                currentNum = self/Int(pow(10.0,Double(index)))%10
                if index == 0{
                    if currentNum != 0 {
                        cn = zhNumbers[currentNum]
                        continue
                    }
                } else {
                    beforeNum = self/Int(pow(10.0,Double(index-1)))%10
                }
                if [1,2,3,5,6,7,9,10,11].contains(index) {
                    if currentNum == 1 && [1,5,9].contains(index) && index == intLength { // 处理一开头的含十单位
                        cn = units[index] + cn
                    } else if currentNum != 0 {
                        cn = zhNumbers[currentNum] + units[index] + cn
                    } else if beforeNum != 0 {
                        cn = zhNumbers[currentNum] + cn
                    }
                    continue
                }
                if [4,8,12].contains(index) {
                    cn = units[index] + cn
                    if (beforeNum != 0 && currentNum == 0) || currentNum != 0 {
                        cn = zhNumbers[currentNum] + cn
                    }
                }
            }
            return cn
        }
    }
    
    var cn2: String {
        get {
            if self == 0 {
                return "零"
            }
            let zhNumbers = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
            var cn = ""
            var currentNum = 0
            let intLength = Int(floor(log10(Double(self))))
            for index in 0...intLength {
                currentNum = self/Int(pow(10.0,Double(index)))%10
                cn = zhNumbers[currentNum] + cn
            }
            return cn
        }
    }
}
