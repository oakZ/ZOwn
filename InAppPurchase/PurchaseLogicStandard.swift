//
//  PurchaseLogicStandard.swift
//  SuperSports
//
//  Created by oak on 2017/6/20.
//  Copyright © 2017年 Rocky. All rights reserved.
//

import UIKit

let HTTP_CREATE_ORDER = ""
let HTTP_VERIFY_APPLE_ORDER = ""

struct PurchaseCustomError {
    var errorCode: String
    var msg: String
}

enum PurchaseLogicStatus {
    case pause
    case orderWaiting
    case orderSuccess
    case orderFailed
    case payWaiting
    case paySuccess
    case payFailed
    case verifyWaiting
    case verifySuccess
    case verifyFailed
}

protocol PurchaseLogicDelegate: class {
    func purchaseBegin(_ purchase: String?)
    func purchaseStatusChanged(_ purchase: String?, status: PurchaseLogicStatus)
    func purchaseFinished(_ purchase: String?, success: Bool, error: PurchaseCustomError?)
}

class PurchaseLogicStandard: NSObject, InAppPurchaseDelegate {

    weak var delegate: PurchaseLogicDelegate?
    
    var name: String?
    
    private var orderData: [String : Any]?
    
    private var error: PurchaseCustomError?
    
    var appleId: String? {
        get {
            return self.orderData?["apple_id"] as? String
        }
    }
    
    var needPay: Bool {
        get {
            return self.orderData?["need_pay"] as? String == "1"
        }
    }
    
    var paySn: String {
        get {
            if let order = self.orderData?["order"] as? [String : Any], let paySn = order["paySn"] as? String {
                return paySn
            }
            return ""
        }
    }
    
    var orderId: String {
        get {
            if let order = self.orderData?["order"] as? [String : Any], let orderId = order["orderId"] as? String {
                return orderId
            }
            return ""
        }
    }
    
    var productIds: String {
        get {
            if let order = self.orderData?["order"] as? [String : Any], let productIds = order["productIds"] as? String {
                return productIds
            }
            return ""
        }
    }
    
    private(set) var status: PurchaseLogicStatus = .pause {
        didSet {
            
            self.delegate?.purchaseStatusChanged(self.name, status: status)
            
            switch status {
            case .orderWaiting:
                print("------ order waiting ------")
            case .orderSuccess:
                print("------ order success ------")
                if self.needPay == false {
                    self.delegate?.purchaseFinished(self.name, success: true, error: nil)
                    break
                }
                
                if self.appleId != nil, self.appleId?.isEmpty == false {
                    self.payInAppleStore(appleId: self.appleId!)
                }else {
                    let error = PurchaseCustomError.init(errorCode: "908", msg: "no appleId")
                    self.error = error
                    self.delegate?.purchaseFinished(self.name, success: false, error: self.error)
                }
            case .orderFailed:
                print("------ order failed ------")
                self.delegate?.purchaseFinished(self.name, success: false, error: self.error)
            case .payWaiting:
                print("------ pay waiting ------")
            case .paySuccess:
                print("------ pay success ------")
                self.verifyOrder()
            case .payFailed:
                print("------ pay failed ------")
                self.delegate?.purchaseFinished(self.name, success: false, error: self.error)
            case .verifyWaiting:
                print("------ verify waiting ------")
            case .verifySuccess:
                print("------ verify success ------")
                self.delegate?.purchaseFinished(self.name, success: true, error: nil)
            case .verifyFailed:
                print("------ verify failed ------")
                self.delegate?.purchaseFinished(self.name, success: false, error: self.error)
            default:
                break
            }
        }
    }
    
    private var signature: String?
    
    private var transactionId: String?
    
    
    // MARK: - public
    func purchaseProducts(_ productIds: String, coupon: String?) {
        
        var params: [String : String] = Dictionary()
        
//        let userId = RSPltUtil.sharedInstance.getUserInfo(UD.USER_DEF_KEY_UID)
        
//        if userId.isEmpty == false {
//            params.updateValue(userId, forKey: "userId")
//        }
        
        if productIds.isEmpty == false {
            params.updateValue(productIds, forKey: "productIds")
        }
        
        if coupon != nil, coupon!.isEmpty == false {
            params.updateValue(coupon!, forKey: "couponId")
        }
        
        self.requestCreatingOrder(params: params)
    }
    
    func purchaseMatch(_ matchId: String, productIds: String, coupon: String?) {
        var params: [String : String] = Dictionary()
        
//        let userId = RSPltUtil.sharedInstance.getUserInfo(UD.USER_DEF_KEY_UID)
        
//        if userId.isEmpty == false {
//            params.updateValue(userId, forKey: "userId")
//        }
        
        if matchId.isEmpty == false {
            params.updateValue(matchId, forKey: "matchId")
        }
        
        if productIds.isEmpty == false {
            params.updateValue(productIds, forKey: "productIds")
        }
        
        if coupon != nil, coupon!.isEmpty == false {
            params.updateValue(coupon!, forKey: "couponId")
        }
        
        self.requestCreatingOrder(params: params)
    }
    
    // MARK: - private
    
    private func payInAppleStore(appleId: String) {
        self.status = .payWaiting
        InAppPurchaseManager.sharedInstance.delegate = self
        InAppPurchaseManager.sharedInstance.buy(productId: appleId)

    }
    
    private func verifyOrder() {
        
        self.status = .verifyWaiting
        
        var params: [String : Any] = Dictionary()

//        params.updateValue(RSPltUtil.sharedInstance.getUserInfo(UD.USER_DEF_KEY_UID), forKey: "userId")
        params.updateValue(self.paySn, forKey: "paySn")
        params.updateValue(self.orderId, forKey: "orderId")
        params.updateValue(self.productIds, forKey: "productIds")
        
        if self.signature != nil {
            params.updateValue(self.signature!, forKey: "verifySignature")
        }
        if self.transactionId != nil {
            params.updateValue(self.transactionId!, forKey: "thirdNo")
        }
        
        RSNetworkAgent.sharedInstance.sendPost(params as NSDictionary, method: HTTP_VERIFY_APPLE_ORDER, showWait: false, succHandler: { (data, action) in
            // success
            self.status = .verifySuccess
            
        }) { (msg, code, action) in
            // failed
            let error = PurchaseCustomError.init(errorCode: code ?? "", msg: msg ?? "")
            self.error = error
            self.status = .verifyFailed
        }
    }
    
    private func requestCreatingOrder(params: [String : Any]) {
        
        self.delegate?.purchaseBegin(self.name)
        
        self.status = .orderWaiting
        
        RSNetworkAgent.sharedInstance.sendPost(params as NSDictionary, method: HTTP_CREATE_ORDER, showWait: true, succHandler: { (data, action) in
            // success
            
            self.orderData = data as? [String : Any]
            self.status = .orderSuccess
            
        }) { (msg, code, action) in
            // failed
            let error = PurchaseCustomError.init(errorCode: code ?? "", msg: msg ?? "")
            self.error = error
            self.status = .orderFailed
            
        }
        
    }
    
    // MARK: - InAppPurchaseDelegate
    func purchaseCompleted(productId: String, forStatus: InAppPurchaseStatus, signature: String?, transactionId: String?, error: Error?) {
        //
        if self.appleId != productId {
            return
        }
        
        switch forStatus {
        case InAppPurchaseStatus.purchaseSucceed:
            self.signature = signature
            self.transactionId = transactionId
            self.status = .paySuccess
        case InAppPurchaseStatus.purchaseFailed:
            if let msg = error?.localizedDescription {
                let error = PurchaseCustomError.init(errorCode: "909", msg: msg)
                self.error = error
            }
            self.status = .payFailed
        case InAppPurchaseStatus.purchaseCanceled:
            self.error = nil
            self.status = .payFailed
        default:
            break
        }
        
    }
}
