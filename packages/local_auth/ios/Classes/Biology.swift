//
//  Biology.swift
//
//  Created by 李广斌 on 2020/9/22.
//  Copyright © 2019年 Local_auth. All rights reserved.
//

import UIKit
import LocalAuthentication

@objc public class Biology: NSObject {
    
    @objc public static func biologyUnLock(tip:String = " ",sensitiveTransaction:Int,negativeBtn:String,positiveBtn:String,unLockSuccess:@escaping (()->()),unLockFail:@escaping ((_ failCode:Int)->()),unLockError:@escaping ((_ code:Int)->())){
        let authenticationContext = LAContext()
        var err:NSError?

        authenticationContext.localizedFallbackTitle = positiveBtn

        if #available(iOS 10.0, *) {
            authenticationContext.localizedCancelTitle = negativeBtn
        } else {
            
        }
        let isTouchIdAvailable = authenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication,error: &err)
        
        if isTouchIdAvailable{
            authenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: tip) { (success, error) in
                OperationQueue.main.addOperation {
                    if success{
                        unLockSuccess()
                    }else{
                        let erroring = (error as NSError?)
                        unLockFail(erroring?.code ?? 0)
                    }
                }
            }
        }else{
            OperationQueue.main.addOperation {
                unLockError(err?.code ?? 0)
            }
        }
    }
    
    @objc public static func isSupport()->Int{
        let authenticationContext = LAContext()
        var err:NSError?
        _ = authenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication,error: &err)
        
        return err?.code ?? 0
    }
    
    @objc public static func getWhitchBiology()->Int{
        let authenticationContext = LAContext()
        var err:NSError?
        _ = authenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication,error: &err)
        
        if #available(iOS 11.0, *) {
            return authenticationContext.biometryType.rawValue
        }
        return 1
    }
    
    @objc public static func setBiologyOk(title1:String,negativeBtn:String,positiveBtn:String,onPositive:(()->())?,onNegative:(()->())?){
        let one = UIAlertController(title: title1, message: "", preferredStyle: UIAlertController.Style.alert)
        
        let positiveBtn = UIAlertAction(title: "去开启", style: UIAlertAction.Style.default, handler: { (action) in
            onPositive?()
            jumpToSystemSeting()
            
        })
        let negativeBtn = UIAlertAction(title: "取消", style: UIAlertAction.Style.default, handler: { (action) in
            onNegative?()
        })
        
        one.addAction(negativeBtn)
        one.addAction(positiveBtn)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(one, animated: true, completion: nil)
    }
    /// 跳转到系统设置主页
    fileprivate static func jumpToSystemSeting() {
        let settingUrl = URL(string: UIApplication.openSettingsURLString)
        if let url = settingUrl, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
    @objc public static func setBiologyshouldOpen(title2:String,negativeBtn:String,positiveBtn:String,onNegative:(()->())?){
        let one = UIAlertController(title: title2, message: "", preferredStyle: UIAlertController.Style.alert)
        
        let negativeBtn = UIAlertAction(title: negativeBtn, style: UIAlertAction.Style.default, handler: { (action) in
            onNegative?()
        })
        
        one.addAction(negativeBtn)
        UIApplication.shared.keyWindow?.rootViewController?.present(one, animated: true, completion: nil)
    }
    
    @objc public static func biologyOut(title3:String,negativeBtn:String,positiveBtn:String,onPositive:(()->())?,onNegative:(()->())?){
        
        let one = UIAlertController(title: title3, message: "", preferredStyle: UIAlertController.Style.alert)
        
        let negativeBtn = UIAlertAction(title: negativeBtn, style: UIAlertAction.Style.default, handler: { (action) in
            onNegative?()
        })
        
        let positiveBtn = UIAlertAction(title: positiveBtn, style: UIAlertAction.Style.default, handler: {(action) in
            onPositive?()
            /// 密码支付回调
        })
        one.addAction(negativeBtn)
        one.addAction(positiveBtn)
        UIApplication.shared.keyWindow?.rootViewController?.present(one, animated: true, completion: nil)
    }
    
}
