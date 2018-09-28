//
//  RSNetworkAgent.swift
//  SuperSports
//
//  Created by oak on 2017/4/17.
//  Copyright © 2017年 Rocky. All rights reserved.
//

import UIKit

let queue: OperationQueue = {
    var q: OperationQueue = OperationQueue()
    q.maxConcurrentOperationCount = 1
    q.name = "NetworkAgentQueue"
    return q
}()

let TIME_OUT = 60 * 2

typealias NetworkCompletionHandler = (_ response: URLResponse, _ result: Any, _ error: Error?) -> Void

typealias NetworkSuccessHandler = (_ data: AnyObject?, _ action: String?) -> Void

typealias NetworkFailedHandler = (_ msg: String?, _ code: String?, _ action: String?) -> Void

var showError = true

class RSNetworkTaskDelegate: NSObject {
    
    private var mutableData: Data = Data()
    
    var completionHandler: NetworkCompletionHandler?
    
    var successHandler: NetworkSuccessHandler?
    
    var failedHandler: NetworkFailedHandler?
    
    // MARK:
    func sessionDataTaskDidReceiveData(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.mutableData.append(data)
    }
    
    func sessionTaskDidComplete(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        do {
            let result = try JSONSerialization.jsonObject(with: self.mutableData, options: []) as? [String : Any]
            
            print(result ?? "")
        }catch {
            if let handler = self.failedHandler {
                handler("数据解析失败", "-10003", "")
            }
        }
        
    }
    
    
}

class RSNetworkAgent: NSObject {
    
    static let sharedInstance = RSNetworkAgent()
    
    private var sessionConfiguration: URLSessionConfiguration!

    private var session: URLSession!
    
    // 目前属性相关操作都主线程中，所以访问此属性不存在线程安全的问题，若以后任务并行，需要注意！
    fileprivate var taskDelegateDictionary: Dictionary<String, RSNetworkTaskDelegate> = Dictionary()
    
    
    // MARK: lifecycle
    override init() {
        super.init()
        self.sessionConfiguration = URLSessionConfiguration.default
        self.session = URLSession.init(configuration: self.sessionConfiguration, delegate: self, delegateQueue: queue)
    }
    
    init(sessionConfiguration: URLSessionConfiguration) {
        super.init()
        self.sessionConfiguration = sessionConfiguration
        self.session = URLSession.init(configuration: self.sessionConfiguration, delegate: self, delegateQueue: queue)
    }
    
    // MARK: - public
    
    func cancelConnection() {
        self.session.invalidateAndCancel()
        self.taskDelegateDictionary = Dictionary()
    }
    
    func cancelConnection(_ clear: Bool) {
        self.cancelConnection()
    }
    
    // MARK: -
    func httpPost(url: String, params: Dictionary<String, Any>, completion: NetworkCompletionHandler) {
        //
        
    }
    
    func sendGet(_ url: String?, succHandler: NetworkSuccessHandler?, failHandler: NetworkFailedHandler?) {
        
        if url == nil { return }
        
        let request = NSMutableURLRequest.init(url: URL.init(string: url!)!)
        request.httpMethod = "GET"
        request.timeoutInterval = TimeInterval(TIME_OUT)
        
        let task = self.dataTask(request: request as URLRequest, successHandler: succHandler, failedHandler: failHandler)
        task.resume()
        
    }
    
    func sendRequest(_ request: URLRequest, succHandler: NetworkSuccessHandler?, failHandler: NetworkFailedHandler?) {
        
        let task = self.dataTask(request: request, successHandler: succHandler, failedHandler: failHandler)
        task.resume()
        
    }
    
    func sendGetPlList(_ paramStr: String, succHandler: NetworkSuccessHandler?, failHandler: NetworkFailedHandler?) {
        
        /*
        let request = NSMutableURLRequest()
        let url = "\(PL_ROOT)\(paramStr)"
        request.url = URL(string: url)
        
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = TIME_OUT
        request.httpMethod = "GET"
        
        let dataTask = self.dataTask(request: request as URLRequest, successHandler: succHandler, failedHandler: failHandler)
        
        dataTask.resume()
         */
    }
    
    func getJsonData(_ jUrl:String, succHandler: NetworkSuccessHandler?, failHandler: NetworkFailedHandler?) {
        
        let request = NSMutableURLRequest()
        request.url = URL(string: jUrl)
        
        
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = TimeInterval(TIME_OUT)
        request.httpMethod = "GET"
        
        let task = self.dataTask(request: request as URLRequest, successHandler: succHandler, failedHandler: failHandler)
        task.resume()
        
    }
    
    // MARK: -
    func sendPost(_ params: NSDictionary?, method: String, showWait: Bool, succHandler: NetworkSuccessHandler?, failHandler: NetworkFailedHandler?) {
     
        /*
        let pa: NSMutableDictionary = NSMutableDictionary()
        pa.setObject(NSString(string: method), forKey: "action" as NSCopying)
        
        if let par = params{
            
            let npd = NSMutableDictionary(dictionary: par)
            npd.setObject(RSPltUtil.sharedInstance.getUserInfo(UD.USER_DEF_KEY_UID), forKey: "userId" as NSCopying)
            pa.setObject(npd, forKey: "params" as NSCopying)
        }
        //        "userToken":RSPltUtil.sharedInstance.getUserInfo(UD.USER_DEF_KEY_TOKEN)
        //        "YWVoak1RGbWU0eXpTeDYrNkVSd0ltNkY2a1B1dit3YlVhTU02dTlSUlczc0kvcmM9"
        let whr = NSString(format: "%.2f", SCREEN_WIDTH/SCREEN_HEIGHT)
        let dinfo = ["appVersion":VERSION, "deviceToken":RSPltUtil.sharedInstance.getUserInfo(UD.USER_DEF_KEY_DEV_TOKEN), "userToken":RSPltUtil.sharedInstance.getUserInfo(UD.USER_DEF_KEY_TOKEN), "channelCode":CHANNEL_ID, "systemVersion":UIDevice.current.systemVersion, "deviceType":UIDevice.current.model, "whRatio":whr, "deviceId":RSPltUtil.sharedInstance.getUserInfo(UD.USER_DEF_UUID)] as [String : Any]
        
        pa.setObject(dinfo, forKey: "device" as NSCopying)
        
        if !JSONSerialization.isValidJSONObject(pa){
            if let handler = failHandler{
                handler("参数错误", "-10001", method)
            }
            return
        }
        
        let body: Data = try! JSONSerialization.data(withJSONObject: pa, options: [])
        
        if DEBUGE == 1, let str = String(data: body, encoding: String.Encoding.utf8) {
            
            print(str)
            
        }
        
        let request = NSMutableURLRequest()
        request.url = URL(string: "\(BASE_URL)?action=\(method)")
        
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = TIME_OUT
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.setValue(NSString(format: "%d", body.count) as String, forHTTPHeaderField: "Content-Length")
        request.httpBody = body
        
        let task = self.dataTask(request: request as URLRequest, successHandler: succHandler, failedHandler: failHandler)
        task.resume()
        */
    }
    
    func sendPostAddPL(_ params: NSDictionary?, method: String, succHandler: NetworkSuccessHandler?, failHandler: NetworkFailedHandler?) {
        
        /*
        var bodyStr = ""
        if let p = params {
            let k = p.allKeys
            for key in k {
                if let ks = key as? String {
                    if let value = p[ks] as? String {
                        if bodyStr == "" {
                            bodyStr = "\(ks)=\(value)"
                        }else{
                            bodyStr = bodyStr + "&\(ks)=\(value)"
                        }
                    }
                }
            }
        }
        
        if bodyStr != "" {
            print("\(bodyStr)")
            let data = bodyStr.data(using: String.Encoding.utf8)
            if let body = data {
                let request = NSMutableURLRequest()
                let url = "\(PL_ROOT)\(method)/save"
                print("\(url)")
                request.url = URL(string: url)
                request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
                request.timeoutInterval = TIME_OUT
                request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                request.setValue(NSString(format: "%d", body.count) as String, forHTTPHeaderField: "Content-Length")
                request.httpBody = body
                
                let task = self.dataTask(request: request as URLRequest, successHandler: succHandler, failedHandler: failHandler)
                task.resume()
                
                
            }else {
                RSToastView.sharedInstance.showToastWithInfo("参数错误",succ: false)
                if let handler = failHandler {
                    handler("","-10005" ,"")
                }
            }
            
        }else {
            RSToastView.sharedInstance.showToastWithInfo("参数错误",succ: false)
            if let handler = failHandler {
                handler("","-10005" ,"")
            }
        }
    
        */
    }
    
    func sendPostND(_ params: NSDictionary?, method: String) {
        
        /*
        let pa:NSMutableDictionary = NSMutableDictionary()
        pa.setObject(NSString(string: method), forKey: "action" as NSCopying)
        
        if let par = params{
            let npd = NSMutableDictionary(dictionary: par)
            npd.setObject(RSPltUtil.sharedInstance.getUserInfo(UD.USER_DEF_KEY_UID), forKey: "userId" as NSCopying)
            pa.setObject(npd, forKey: "params" as NSCopying)
        }
        
        let whr = NSString(format: "%.2f", SCREEN_WIDTH/SCREEN_HEIGHT)
        
        let dinfo = ["appVersion":VERSION, "deviceToken":RSPltUtil.sharedInstance.getUserInfo(UD.USER_DEF_KEY_DEV_TOKEN), "userToken":RSPltUtil.sharedInstance.getUserInfo(UD.USER_DEF_KEY_TOKEN), "channelCode":CHANNEL_ID, "systemVersion":UIDevice.current.systemVersion, "deviceType":UIDevice.current.model, "whRatio":whr, "deviceId":RSPltUtil.sharedInstance.getUserInfo(UD.USER_DEF_UUID)] as [String : Any]
        
        pa.setObject(dinfo, forKey: "device" as NSCopying)
        
        if !JSONSerialization.isValidJSONObject(pa){
            
            return
        }
        
        let body:Data = try!JSONSerialization.data(withJSONObject: pa, options: [])
        
        
        if DEBUGE == 1, let str = String(data: body, encoding: String.Encoding.utf8) {
            print(str)
        }
        
        
        let request = NSMutableURLRequest()
        request.url = URL(string: "\(BASE_URL)?action=\(method)")
        
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = TIME_OUT
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.setValue(NSString(format: "%d", body.count) as String, forHTTPHeaderField: "Content-Length")
        request.httpBody = body
        
        let task = self.dataTask(request: request as URLRequest, successHandler: nil, failedHandler: nil)
        task.resume()
        
        */
    }
    
    // MARK: - private
    
    private func dataTask(request: URLRequest, successHandler: NetworkSuccessHandler?, failedHandler: NetworkFailedHandler?) -> URLSessionTask {
        
        let task = self.session.dataTask(with: request)
        
        self.setDelegateForDataTask(task, successHandler: successHandler, failedHandler: failedHandler)
        
        return task
    }
    
    // MARK: -
    
    fileprivate func delegateForTask(_ task: URLSessionTask) -> RSNetworkTaskDelegate? {
        return self.taskDelegateDictionary[String(task.taskIdentifier)]
    }
    
    private func setDelegateForDataTask(_ task: URLSessionTask, successHandler: NetworkSuccessHandler?, failedHandler: NetworkFailedHandler?) -> Void {
        
        let delegate = RSNetworkTaskDelegate()
        
        //
        delegate.successHandler = successHandler
        delegate.failedHandler = failedHandler
        
        self.taskDelegateDictionary[String(task.taskIdentifier)] = delegate
        
    }
    
    // MARK: should be deprecated
    func showLogOutPop(_ msg: String) {
    
    }
    
}

// MARK: - Session Delegate
extension RSNetworkAgent: URLSessionTaskDelegate, URLSessionDataDelegate {

    // MARK: - URLSessionTaskDelegate
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        //
        if  let delegate = self.delegateForTask(task) {
            
            // callback on main thread
            DispatchQueue.main.async(execute: {
                
                delegate.sessionTaskDidComplete(session, task: task, didCompleteWithError: error)
                
                self.taskDelegateDictionary.removeValue(forKey: String(task.taskIdentifier))
                
            })
        }
        
    }
    
    // MARK: - URLSessionDataDelegate
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        //
        if  let delegate = self.delegateForTask(dataTask) {
            
            delegate.sessionDataTaskDidReceiveData(session, dataTask: dataTask, didReceive: data)
            
        }
        
    }
    
}
