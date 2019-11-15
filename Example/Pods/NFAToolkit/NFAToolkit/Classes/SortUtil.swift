//
//  SortUtil.swift
//  Pods-Tools_Example
//
//  Created by 聂飞安 on 2019/8/15.
//


import Foundation

open class SortUtil {

    open class func test() {
        let t = ["1.1", "1.10", "1.2", "1.1.1"]
        let d = sortBySection(t)
        print(d)
    }
    /// 分节排序
    open class func sortSection(_ data1 : String, data2 : String) -> Int {
        var d1 = data1
        if d1 == "" {
            d1 = "999"
        }
        var d2 = data2
        if d2 == "" {
            d2 = "999"
        }
        return compareWith(d1, data2: d2, splitWith: ".")
    }
    
    class func compareWith(_ data1 : String, data2 : String, splitWith : String) -> Int{
        if data1 == "" {
            return -1
        }
        if data2 == "" {
            return -1
        }
        if data1 == data2 {
            return 0
        }
        
        return compare(data1.components(separatedBy: splitWith), data2.components(separatedBy: splitWith))
    }
    
    class func compare(_ x : [String], _ y : [String]) -> Int {
        if x.count > y.count {
            return -1 * (compare(y, x))
        }
        for i in 0..<x.count {
            let cmp = Int(x[i])! - Int(y[i])!
            if cmp != 0 {
                return cmp
            }
        }
        return x.count == y.count ? 0 : -1
    }
    
    /// 分节排序
    open class func sortBySection(_ datas : [String], separateChart : String = ".", sortObj: CBWithParam? = nil) -> [String]{
        
        let groups = NSMutableArray()
        var maxGroupCount : Int = 0
        for data in datas {
            let group = data.components(separatedBy: separateChart)
            groups.add(group)
            if group.count > maxGroupCount {
                maxGroupCount = group.count
            }
        }
        // 多少个分组就多少次循环，每次循环获取对应拆分后数据的第几小组数据。
        let groupMaxLength = NSMutableDictionary()
        for i in 0 ..< maxGroupCount {
            var maxLength = 0
            for group in groups {
                let g = group as! [String]
                var char : String = "0"
                if g.count > i {
                    char = g[i] // 这个分组的数据值
                }
                let length = (char as NSString).length
                if length > maxLength {
                    maxLength = length
                }
            }
            // 第n组最大的长度
            groupMaxLength.setObject(maxLength, forKey: i as NSCopying)
        }
        // 待排序数据，已经补零
        let sortArrs = NSMutableArray()
        
        // 每组对应原始数据
        let groupDatas = NSMutableDictionary()
        var index = 0
        for group in groups {
            var result : String = ""
            for i in 0 ..< maxGroupCount {
                let g = group as! [String]
                let maxLength = groupMaxLength.object(forKey: i) as! Int
                var char : String!
                if g.count > i {
                    char = g[i] // 这个分组的数据值
                    let length = (char as NSString).length
                    if length < maxLength {
                        // 补零
                        char = fillZero(char, fillNum : (maxLength-length))
                    }
                } else {
                    // 没有这么多分组的
                    char = fillZero("", fillNum : maxLength)
                }
                result += char
            }
            
            sortArrs.add(result)
            groupDatas.setValue(datas[index], forKey: result)
            index += 1
        }
        // 补零之后的排序。
        sortArrs.sort (comparator: { (d1, d2) -> ComparisonResult in
            let f1 = Int(d1 as! String) ?? 0
            let f2 = Int(d2 as! String) ?? 0
            if f1 > f2 {
                return ComparisonResult.orderedDescending
            }
            return ComparisonResult.orderedAscending
        })
        
        // 结果集转换
        var results = [String]()
        for sortArr in sortArrs {
            let result = groupDatas.object(forKey: sortArr as! String) as! String
            results.append(result)
            sortObj?(result as AnyObject?)
        }
        return results
    }
    
    // 补零操作
    class func fillZero(_ value : String, fillNum : Int) -> String {
        var append = ""
        for _ in 0 ..< fillNum {
            append += "0"
        }
        
        return append + value
    }
}
