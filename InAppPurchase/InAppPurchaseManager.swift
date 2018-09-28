//
//  InAppPurchaseManager.swift
//  SuperSports
//
//  Created by oak on 2017/6/6.
//  Copyright © 2017年 Rocky. All rights reserved.
//

import UIKit
import StoreKit

enum InAppPurchaseStatus {
    case pause
    case disable        // in app purchase disable on this device
    case requesting     // product request already sent, waiting for the response
    case responsed       // get response
    case purchasing     //
    case purchaseCanceled     // user cancel
    case purchaseFailed     //
    case purchaseSucceed    //
}

protocol InAppPurchaseDelegate: class {
    
    func purchaseCompleted(productId: String, forStatus: InAppPurchaseStatus, signature: String?, transactionId: String?, error: Error?)
    
}

class InAppPurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    static let sharedInstance: InAppPurchaseManager = {
        let instance = InAppPurchaseManager()
        // obsever
        SKPaymentQueue.default().add(instance)
        return instance
    }()
    
    weak var delegate: InAppPurchaseDelegate?
    
    private(set) var status: InAppPurchaseStatus = InAppPurchaseStatus.pause {
        didSet {
            switch status {
            case InAppPurchaseStatus.disable:
                // disable
                if self.purchaseId != nil {
                    self.delegate?.purchaseCompleted(productId: self.purchaseId!, forStatus: status, signature: nil, transactionId: nil, error: nil)
                }
                print("disable")
            case InAppPurchaseStatus.requesting:
                print("product information requesting")
            case InAppPurchaseStatus.responsed:
                if let product = self.validProducts.first(where: {$0.productIdentifier == self.purchaseId}) {

                    self.purchase(product: product)
                    
                }else if self.purchaseId != nil {
                
                    self.delegate?.purchaseCompleted(productId: self.purchaseId!, forStatus: .purchaseFailed, signature: nil, transactionId: nil, error: nil)
                
                }
            case InAppPurchaseStatus.purchasing:
                print("purchasing")
            case InAppPurchaseStatus.purchaseSucceed:
                
                let urlRequest = URLRequest(url: Bundle.main.appStoreReceiptURL!)
                let receiptData = try? NSURLConnection.sendSynchronousRequest(urlRequest, returning: nil)
                
                if let data = receiptData {
//                    if let str = DeviceOriAgent.getRecipStr(data), str.isEmpty == false, self.purchaseId != nil {
//                        self.delegate?.purchaseCompleted(productId: self.purchaseId!, forStatus: status, signature: str, transactionId: self.transactionId, error: nil)
//                    }
                }
                
            case InAppPurchaseStatus.purchaseCanceled:
                if self.purchaseId != nil {
                    self.delegate?.purchaseCompleted(productId: self.purchaseId!, forStatus: status, signature: nil, transactionId: nil, error: nil)
                }
                
            case InAppPurchaseStatus.purchaseFailed:
                if self.purchaseId != nil {
                    self.delegate?.purchaseCompleted(productId: self.purchaseId!, forStatus: status, signature: nil, transactionId: nil, error: self.error)
                }
            default:
                break
            }
        }
    }
    
    private(set) var purchaseId: String?
    
    private var transactionId: String?
    
    private var error: Error?
    
    private var validProducts: [SKProduct] = Array()
    
    
    // MARK: - public
    
    // add payment for product
    func buy(productId: String) {
        
        if SKPaymentQueue.canMakePayments() == false {
            self.status = InAppPurchaseStatus.disable
            return
        }
        
        self.purchaseId = productId
        self.fetchProductInfomationFor([productId])
        
    }
    
    // MARK: - private
    
    // fetch the information about the products from the App Store
    private func fetchProductInfomationFor(_ products: [String]) {
        
        self.status = InAppPurchaseStatus.requesting
        
        let request = SKProductsRequest.init(productIdentifiers: Set.init(products))
        request.delegate = self
        request.start()
        
    }
    
    // add payment
    private func purchase(product: SKProduct) {
        self.status = InAppPurchaseStatus.purchasing
        let payment = SKPayment.init(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    // purchase complete handler
    private func completeTransaction(_ transaction: SKPaymentTransaction, state: SKPaymentTransactionState) {
        
        if state == .purchased {
            self.transactionId = transaction.transactionIdentifier
            self.status = .purchaseSucceed
        }else if state == .failed {
            let error = transaction.error as NSError?
            if error?.code == SKError.Code.paymentCancelled.rawValue {
                
                self.status = .purchaseCanceled
                
            }else {
            
                self.status = .purchaseFailed
            }
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    // transaction restore handler
    private func restoreTransaction(_ transaction: SKPaymentTransaction) {
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    // MARK: - SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        //
        if response.products.count > 0 {
            self.validProducts = response.products
        }
        
        if response.invalidProductIdentifiers.count > 0 {
            
        }
        
        self.status = InAppPurchaseStatus.responsed
        
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        // SKRequest failed
        print("Product Request Status: %@", error.localizedDescription);
        self.status = .responsed
    }
    
    // MARK: - SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        //
        
        for transaction in transactions {
            
            //
            self.error = transaction.error
            
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                self.completeTransaction(transaction, state: SKPaymentTransactionState.purchased)
            case SKPaymentTransactionState.failed:
                self.completeTransaction(transaction, state: SKPaymentTransactionState.failed)
                print("--- in app purchase error:" + transaction.error.debugDescription)
            case SKPaymentTransactionState.deferred:
                print("--- in app purchase defered ---")
            case SKPaymentTransactionState.restored:
                print("--- in app purchase restored ---")
                self.restoreTransaction(transaction)
            case SKPaymentTransactionState.purchasing:
                break
            }
            
        }
    }
    
}
