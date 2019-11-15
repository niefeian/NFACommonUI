//
//  Tools.swift
//  Pods-Tools_Example
//
//  Created by 聂飞安 on 2019/8/15.
//


import Foundation
import UIKit


open class Tools {
    
    /// 清除角标
    open class func cleanMyAppBadge() {
        let app = UIApplication.shared
        let num = app.applicationIconBadgeNumber
        if num != 0 {
            app.cancelAllLocalNotifications()
            app.applicationIconBadgeNumber = 0
        }
    }
    
    open class func getUUID() -> String{
        let uc = CFUUIDCreate(nil)
        let uuid  = CFUUIDCreateString(nil, uc)
        return uuid! as String
    }
    
    /// 打开新的页面
    open class func openView(_ baseView : UIViewController, storyboard : String, identifier : String) {
        func fun(_ view : UIViewController){
        }
        openView(baseView, storyboard: storyboard, identifier: identifier, fun: fun)
    }
    
    open class func openView(_ baseView : UIViewController, storyboard : String, identifier : String, fun:(UIViewController) -> Void) {
        let bord = UIStoryboard(name: storyboard, bundle: nil)
        
        let vw = bord.instantiateViewController(withIdentifier: identifier)
        baseView.present(vw, animated: true, completion: nil)
        // callback，允许上一页面做特殊处理，比如传参等
        fun(vw as UIViewController)
    }
    
    /// 转场用场景切换
    open class func pushView(_ baseView : UIViewController, storyboard : String, identifier : String) {
        func fun(_ view : UIViewController){
        }
        self.pushView(baseView, storyboard: storyboard, identifier: identifier, fun: fun)
    }
    
    open class func pushTabView(_ baseView : UIViewController, storyboard : String, identifier : String, fun:(UIViewController) -> Void) {
        let bord = UIStoryboard(name: storyboard, bundle: nil)
        
        let vw = bord.instantiateViewController(withIdentifier: identifier)
        baseView.navigationController?.pushViewController(vw, animated: true)
        fun(vw as UIViewController)
    }
    
    open class func pushView(_ baseView : UIViewController, storyboard : String, identifier : String, hideBottom : Bool = true, animator : Bool = true, removeSelf : Bool = false, fun:(UIViewController) -> Void) {
        let bord = UIStoryboard(name: storyboard, bundle: nil)
        let vw = bord.instantiateViewController(withIdentifier: identifier)
        let navUI = vw as! UINavigationController
        let child = navUI.children[0]
        let childView = child as UIViewController
        if hideBottom {
            childView.hidesBottomBarWhenPushed = true
        }
        // 禁止重复打开
        var views = baseView.navigationController?.viewControllers
       
        if views?.count ?? 0 > 0 {
            if childView.classForCoder == views![views!.count - 1].classForCoder {
                return
            }
        }
        
        if removeSelf && views != nil {
            views!.removeLast()
            views!.append(childView)
            baseView.navigationController?.setViewControllers(views!, animated: true)
        } else {
            baseView.navigationController?.pushViewController(childView, animated: animator)
        }
        fun(childView)
    }
    
    /// 以根节点的方式打开
    open class func rootView(_ window : UIWindow, storyboard : String, identify : String) {
        let bord = UIStoryboard(name: storyboard, bundle: nil)
        let vw = bord.instantiateViewController(withIdentifier: identify)
        window.rootViewController = vw;
        window.makeKeyAndVisible()
    }
    
    /// 转场回退
    open class func popView(_ baseView : UIViewController) {
        baseView.navigationController?.popViewController(animated: true)
    }
    
    /// 回退到指定的界面
    open class func popToView(_ baseView : UIViewController, toViewClass : AnyClass) {
        let views = baseView.navigationController?.viewControllers
        var toView : UIViewController?
        for view in views! {
            let v = view as UIViewController
            if v.classForCoder == toViewClass {
                toView = v
                break
            }
        }
        if toView != nil {
            baseView.navigationController?.popToViewController(toView!, animated: true)
        }
    }
    
    /// 构建标题：当文字超长时，采用titleView进行构建，否则下一个试图的title会偏移
    open class func addTitleView(view : UIView, navigationItem : UINavigationItem, title : String?) {
        let titleView = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 100, height: 30))
        //        titleView.text = ME.curClass?.title
        navigationItem.titleView = titleView
        DispatchQueue.main.async {
            let width = UIScreen.main.bounds.size.width  - 100
            let centerView = UILabel()
            centerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - width) / 2, y: 20, width: width, height: 44)
            centerView.frame = (view.window?.convert(centerView.frame, to: navigationItem.titleView))!
            centerView.text = title
            centerView.textAlignment = .center
            centerView.font = UIFont.boldSystemFont(ofSize: 17)
            centerView.textColor = UIColor.white
            navigationItem.titleView?.addSubview(centerView)
        }
    }
    
    /// 执行几次的动画
    class func animationSomeTimes(_ time : TimeInterval = 0.2, count : Int = 1, doing : @escaping CBWithParam, finish : @escaping CB) {
        if count < 1 {
            return
        }
        var c = count
        UIView.animate(withDuration: time, animations: {
            c = count - 1
            doing(c as AnyObject?)
            
        }, completion: { (Bool) in
            if c > 0 {
                self.animationSomeTimes(time, count: c, doing: doing, finish: finish)
            } else {
                finish()
            }
        }) 
    }
    
    open class func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    /// 非空校验
    open class func validateEmpty(_ baseView : UIViewController, msgs : [String], textFields : [UITextField]) -> Bool {
        let count = msgs.count
        for i in 0 ..< count {
            if (textFields[i].text == nil || textFields[i].text == "") {
                return false
            }
        }
        return true
    }
    
    /// 包含
    open class func contains(_ arrays : [AnyObject], key : String) -> Bool {
        let contain = arrays.contains { (element) -> Bool in
            let ele = element as! String
            if ele == key {
                return true
            }
            return false
        }
        return contain
    }
    
    /// 是否为空
    open class func isEmpty(_ obj : AnyObject?) -> Bool {
        if obj == nil {
            return true
        }
        if obj is String {
            return obj as! String == ""
        }
        if obj is NSArray {
            return (obj as! NSArray).count == 0
        }
        if obj is NSDictionary {
            return (obj as! NSDictionary).count == 0
        }
        
        return false
    }
    /// 主要用于tableViewCell之类的动画显示。从底部慢慢滑上来出现
    open class func displayViewAnimationMoveIn(_ view: UIView, offsetY: CGFloat, duration: TimeInterval) {
        
        view.transform = CGAffineTransform(translationX: 0, y: offsetY)
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            view.transform = CGAffineTransform.identity
        })
    }
    
    /// 主要用于tableViewCell之类的动画显示。从透明到非透明（淡入）
    open class func displayViewAnimationFadeIn(_ view: UIView, defaultAlpha : CGFloat = 0, duration: TimeInterval) {
        view.alpha = defaultAlpha
        UIView.animate(withDuration: duration, animations: { () -> Void in
            view.alpha = 1
        })
    }
    
    /// 隐藏、显示nav标题
    open class func tapToggleNavBarHidden(_ navigationController : UINavigationController) {
        navigationController.setNavigationBarHidden(!navigationController.isNavigationBarHidden, animated: true)
    }
    
    /// 清除tab页签上的横线
    open class func removeTabBarTopLine(_ tabBar : UITabBar) {
        
        // 去掉原有的tab栏上的顶部横向
        let rect = CGRect(x: 0, y: 0, width: tabBar.frame.size.width, height: tabBar.frame.size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        tabBar.backgroundImage = img
        tabBar.shadowImage = img
    }
    
    /// 圆角
    open class func setCornerRadius(_ view : UIView, rate : CGFloat = 5) {
        view.layer.masksToBounds = true
        view.layer.cornerRadius = rate
    }
    
    /// 圆形图标
    open class func setCircleCornerRadius(_ view : UIView) {
        view.layer.masksToBounds = true
        let r = view.frame.size.width / 2
        view.layer.cornerRadius = r
    }
    
    
    /// 随机数 : 调用：radomInRange(1..<100)
    open class func radomInRange(_ range : Range<Int>) -> Int {
        let count = UInt32(range.upperBound - range.lowerBound)
        return Int(arc4random_uniform(count)) + range.lowerBound
    }
    
    /// 旋转角度。传入角度，正数为顺时针，负数为逆时针，如逆时针旋转25度：transformRotation(25)
    open class func transformRotation(_ angle : Double) -> CGAffineTransform {
        let r : Double = angle / 180
        return CGAffineTransform(rotationAngle: CGFloat(-1 * Double.pi * r))
    }
    
    /// 构建数组对应的json字符串
    open class func arraysToJson(_ arrs : NSArray, key : String) -> String? {
        let d = NSMutableArray()
        for data in arrs {
            let dic = NSMutableDictionary()
            dic.setValue((data as! String), forKey: key)
            d.add(dic)
        }
        var json : String?
        do {
            let data = try JSONSerialization.data(withJSONObject: d, options: JSONSerialization.WritingOptions.prettyPrinted)
            let strJson = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            json = strJson! as String
        }catch let e {
            print(e)
            return nil
        }
        
        guard let j = json else {
            return nil
        }
        json = j.replacingOccurrences(of: "\n", with: "")
        return json
    }

    // 使用16进制颜色
    open class func colorConversion(colorValue: String, alpha: CGFloat = 1) -> UIColor {
        var str = colorValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        if str.hasPrefix("#") {
            str = str.replacingOccurrences(of: "#", with: "")
        }
        if str.count != 6 {
            return .white
        }
        let redStr = str.subString(start: 0, length: 2)
        let greenStr = str.subString(start: 2, length: 2)
        let blueStr = str.subString(start: 4, length: 2)
        var r:UInt64 = 0, g:UInt64 = 0, b:UInt64 = 0
        Scanner(string: redStr).scanHexInt64(&r)
        Scanner(string: greenStr).scanHexInt64(&g)
        Scanner(string: blueStr).scanHexInt64(&b)
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: alpha)
    }
    
    //设置圆角并描边
   open class func masksToBounds(cornerView:UIView,cornerRadius:CGFloat = 0 , borderWidth:CGFloat = 0 , borderColor : UIColor) {
        cornerView.layer.cornerRadius = cornerRadius
        cornerView.layer.borderWidth = borderWidth
        cornerView.layer.borderColor = borderColor.cgColor
    }
    
    open class  func serCorner( _ view : UIView , byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
           let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
           let maskLayer = CAShapeLayer()
           maskLayer.frame = view.bounds
           maskLayer.path = maskPath.cgPath
           view.layer.mask = maskLayer
       }

}
