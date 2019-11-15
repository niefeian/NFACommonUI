//
//  Window.swift
//  FBSnapshotTestCase
//
//  Created by 聂飞安 on 2019/11/6.
//

import UIKit

public func AppWindow() ->UIWindow {
    if let delegate: UIApplicationDelegate = UIApplication.shared.delegate {
        if let window = delegate.window {
            return window!
        }
    }
    
    return UIApplication.shared.keyWindow!
}

