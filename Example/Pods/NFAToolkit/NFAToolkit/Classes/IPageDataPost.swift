//
//  IPageDataPost.swift
//  Pods-Tools_Example
//
//  Created by 聂飞安 on 2019/8/15.
//


import Foundation

/// 有参数的回调
public typealias CBWithParam = (AnyObject?) -> Void

/// 无参数的回调
public typealias CB = () -> Void


public protocol IPageDataPost {
    /// 当前页面索引
    func setPageIndex(_ index : Int)
    /// 用户自定义数据
    func setUserData(_ data : AnyObject?)
    
    func getUserData() -> AnyObject?
    func getPageIndex() -> Int
}

public protocol IDataPost {
    
    /// 注册回调函数
    func regCallBack(_ cb : @escaping CBWithParam)
    
    /// 传输数据
    func postData(_ data : AnyObject?)
}
