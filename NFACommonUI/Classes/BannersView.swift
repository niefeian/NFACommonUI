//
//  BannerVC.swift
//  cloudclass
//
//  Created by jacty on 16/8/6.
//  Copyright © 2016年 accfun. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import NFAToolkit
extension UIImageView{
    func setImageFromURL(_ url :String?, defaultIcon : String = "", block : CBWithParam? = nil , isAutoHide : Bool = false) {
        
        if url ?? "" == "" {
            self.image = UIImage(named: defaultIcon)
            return
        }
        
        if let urls = URL(string: url!){
            self.sd_setImage(with: urls)
        }
    }
}

public protocol BannersViewDelegate {
    func didClickScrollView(_ index:NSInteger)
    func scrollViewDidScroll(_ index:NSInteger)
}

open class BannersView: UIView,UIScrollViewDelegate {
    
    var _mainScrollView : UIScrollView?
    var currentImageView : UIImageView!
    var preImageView : UIImageView!
    var nextImageView : UIImageView!
    var _currentIndex: NSInteger! = 0
    var _dataArray = NSMutableArray()
    weak var timer : Timer?
    weak var baseView : UIViewController?
    var rowTimeDelay : Int! = 0
    var addTimeDelay : Int! = 0
    var imgcount : Int = 0
    var delegate : BannersViewDelegate?
    var imageSize : CGSize!
    var pageSubView : UIView!
    /*
     *初始化scrollView及其部件
     */
    init(frame: CGRect, dataArray:NSMutableArray) {
        super.init(frame:frame)
        setupViewWithBannerVos(dataArray, count: dataArray.count)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setupViewWithBannerVos(_ banners : NSMutableArray, timeDelay : Double = 4, count : Int) {
        imgcount = count
        setupView(banners, timeDelay : timeDelay)
    }
    
    
    public func setupView(_ dataArray:NSMutableArray, timeDelay : Double = 4) {
        
        if _mainScrollView == nil{
             _mainScrollView = UIScrollView()
        }
        
        rowTimeDelay = Int(timeDelay)
        _mainScrollView?.frame = CGRect(x: 0, y: 0, width: AppWidth, height: frame.height)
        
        // 如果只有一张图片，就不需要滚动了
        if dataArray.count > 1{
            _mainScrollView?.contentSize = CGSize(width: AppWidth * 3, height: frame.height)
        } else  {
            _mainScrollView?.contentSize = CGSize(width: AppWidth * CGFloat(dataArray.count) , height: frame.height)
        }
        _mainScrollView?.backgroundColor = UIColor.white
        _mainScrollView?.delegate = self
        _mainScrollView?.isPagingEnabled = true
        _mainScrollView?.isUserInteractionEnabled = true
        _mainScrollView?.showsHorizontalScrollIndicator = false
        _mainScrollView?.showsVerticalScrollIndicator = false
        _mainScrollView?.bounces = false;
        _mainScrollView?.contentOffset = CGPoint(x: AppWidth, y: 0)
        if _mainScrollView != nil{
            self.addSubview(_mainScrollView!)
        }
        _currentIndex = 0;
       
        currentImageView = (_mainScrollView?.viewWithTag(101) as? UIImageView) ?? UIImageView()
        if currentImageView.tag != 101 {
            currentImageView.tag = 101
        }
        
        _dataArray.setArray(dataArray as [AnyObject])
        self.setUpDataDataArray(_dataArray)
        // 手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapCLick))
        currentImageView.addGestureRecognizer(tap)
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        if dataArray.count > 1 {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.runImgPage), userInfo: nil, repeats: true)
        }
    }
    
    @objc func runImgPage(){
        addTimeDelay += 1
        if  addTimeDelay  >= rowTimeDelay {
            addTimeDelay =  0
            timerAction()
        }
    }
    
    /*
     *此处为scrollView的复用，比目前网上大部分的同类型控件油画效果好，只需要三张图片依次替换即可实现轮播，不需要有几张图就使scrollView的contentSize为图片数＊宽度
     */
   public func setUpDataDataArray(_ dataArray:NSArray) {
        // 中间图
        if imageSize != nil {
            currentImageView.frame = CGRect(x: AppWidth + (AppWidth-imageSize.width)/2, y: (self.height-imageSize.height)/2, width: imageSize.width, height: imageSize.height);
        }else{
            currentImageView.frame = CGRect(x: AppWidth, y: 0, width: AppWidth, height: self.height);
        }
      
        currentImageView.setImageFromURL(_dataArray[_currentIndex] as? String)
        currentImageView.isUserInteractionEnabled = true;
        _mainScrollView?.addSubview(currentImageView)
        
        // 如果只有一张图片，就创建一张好了
        if dataArray.count == 1 {
            if imageSize != nil {
                currentImageView.frame = CGRect(x:0, y: (self.height-imageSize.height)/2, width: imageSize.width, height: imageSize.height);
            }else{
                currentImageView.frame = CGRect(x: 0, y: 0, width: AppWidth, height: self.height);
            }
             currentImageView.contentMode = .scaleAspectFill
            _mainScrollView?.contentOffset = CGPoint(x: 0, y: 0)
            return
        }
        
        // 左侧图
        if preImageView == nil {
            preImageView = UIImageView()
            _mainScrollView?.addSubview(preImageView)
        }
        
        if imageSize != nil {
            preImageView.frame = CGRect(x:-(AppWidth-imageSize.width)/2, y: (self.height-imageSize.height)/2, width: imageSize.width, height: imageSize.height);
        }else{
            preImageView.frame = CGRect(x: -AppWidth, y: 0, width: AppWidth, height: self.height);
        }
        // 右侧
        
        if nextImageView == nil {
            nextImageView = UIImageView()
            _mainScrollView?.addSubview(nextImageView)
        }
        
        if imageSize != nil {
            nextImageView.frame = CGRect(x: AppWidth * 2 + (AppWidth-imageSize.width)/2, y: (self.height-imageSize.height)/2, width: imageSize.width, height: imageSize.height);
        }else{
            nextImageView.frame = CGRect(x:  AppWidth * 2, y: 0, width: AppWidth, height: self.height);
        }
        
        let imageStr = _currentIndex - 1 >= 0 ? (dataArray[_currentIndex-1] as! String) : (dataArray.lastObject as! String)
       preImageView.isUserInteractionEnabled = true
       preImageView.setImageFromURL(imageStr)
        
        let imageStr1 = _currentIndex + 1 < dataArray.count ? (dataArray[_currentIndex+1] as! String) : (dataArray.firstObject as! String)
        
        nextImageView.isUserInteractionEnabled = true
        nextImageView.setImageFromURL(imageStr1)
        currentImageView.contentMode = .scaleAspectFill
        preImageView.contentMode = .scaleAspectFill
        nextImageView.contentMode = .scaleAspectFill
      
        self.createPageControl()
    }
    /*
     *图片的代理点击响应方法
     */
    @objc func tapCLick() {
        delegate?.didClickScrollView(_currentIndex)
    }
    /*
     *定时器方法，使banner页无限轮播
     */
    @objc func timerAction() {
        
        if _currentIndex+1 < _dataArray.count {
            _currentIndex = _currentIndex + 1;
        }
        else {
            _currentIndex=0;
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self._mainScrollView?.contentOffset = CGPoint(x: AppWidth * 2, y: 0)
        },completion: {
            (finished) in
            self._mainScrollView?.contentOffset = CGPoint(x: AppWidth, y: 0)
            self.setUpDataDataArray(self._dataArray)
        })
        (pageSubView.subviews[_currentIndex] as? UIImageView)?.image = UIImage(named: "ic_banner_point01")
    }
    
    /*
        *创建标题和pageControl，此处pageCOntrol为自定义的，如需要可修改为系统的，或更换图片即可
        */
       func createPageControl() {
        if pageSubView == nil {
                  pageSubView = UIView()
                            pageSubView.frame = CGRect(x: 0, y: self.frame.size.height-30, width: AppWidth, height: 30)
                            pageSubView.backgroundColor = UIColor.clear
                            self.addSubview(pageSubView)
              }
          
           
           for index in 0..<_dataArray.count {
            let imageView = pageSubView.viewWithTag(index + 100) as? UIImageView ?? UIImageView()
                imageView.tag = index + 100
               let x = AppWidth - (CGFloat(_dataArray.count)*12)-10+CGFloat(index)*12
               imageView.frame = CGRect(x : x, y : 11, width : 7 , height : 7)
                if index == self._currentIndex {
                   imageView.image = UIImage(named: "ic_banner_point01")
                }else{
                     imageView.image = UIImage(named: "ic_banner_point02")
                }
               pageSubView.addSubview(imageView)
           }
            self.bringSubview(toFront: pageSubView)

       }
    
    /*
     *UIScrollViewDelegate  协议方法，拖动图片的处理方法
     */
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == _mainScrollView
        {
            (pageSubView.subviews[_currentIndex] as? UIImageView)?.image = UIImage(named: "ic_banner_point02")
            let index = scrollView.contentOffset.x / AppWidth;
            if index > 1
            {
                _currentIndex = _currentIndex + 1 < _dataArray.count ? _currentIndex+1 : 0;
                UIView.animate(withDuration: 1, animations: {
                    self._mainScrollView?.contentOffset = CGPoint(x: AppWidth * 2, y: 0)
                },completion: {
                    (finished) in
                    self._mainScrollView?.contentOffset = CGPoint(x: AppWidth, y: 0)
                    self.setUpDataDataArray(self._dataArray)
                })
            }
            else if index < 1
            {
                _currentIndex = _currentIndex - 1 >= 0 ? _currentIndex-1 : _dataArray.count - 1;
                UIView.animate(withDuration: 1, animations: {
                    self._mainScrollView?.contentOffset = CGPoint(x: 0, y: 0)
                },completion: {
                    (finished) in
                    self._mainScrollView?.contentOffset = CGPoint(x: AppWidth, y: 0)
                    self.setUpDataDataArray(self._dataArray)
                })
            }
             (pageSubView.subviews[_currentIndex] as? UIImageView)?.image = UIImage(named: "ic_banner_point02")
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addTimeDelay = 0
        delegate?.scrollViewDidScroll(_currentIndex)
    }
    
    
}
