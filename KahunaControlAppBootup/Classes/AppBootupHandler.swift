//
//  AppBootupHandler.swift
//  Pods
//
//  Created by Kahuna on 8/1/17.
//
//

import Foundation
import UIKit

public class AppBootupHandler: NSObject {

    var serverBaseURL = String()
    var appId = String()
    var appVersion = String()
    var osVersion = String()
    var freeSpace = String()
    var appType = String()
    let endPoint = "/datarepo/v1/controlAppBootup/check"
    let kTimeoutInterval = 60

    public static let sharedInstance = AppBootupHandler()

    public typealias AppBootupCompletionBlock = (Bool, AnyObject?) -> Void

    override init() {
    }

    deinit {
        print("** InstagramFeedHandler deinit called **")
    }

    public func initAllAppBootupKeys(appId: String, appType: String, appVersion: String, osVersion: String, freeSpace: String? = nil) {
        self.appId = appId
        self.appVersion = appVersion
        self.osVersion = osVersion
        self.appType = appType
        if freeSpace != nil, let strSpace = freeSpace! as? String {
            self.freeSpace = strSpace
        }
    }

    public func initServerBaseURL(serverBaseURL: String) {
        self.serverBaseURL = serverBaseURL
    }

    func createURLRequest(_ path: String, parameters: NSMutableDictionary, timeoutInterval interval: Int) -> URLRequest? {
        var jsonData: Data!
        if parameters != nil {
            do {
                jsonData = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
            } catch let error as NSError {
                print(error)
            }
        }
        if let url = NSURL(string: path) as? URL {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            request.timeoutInterval = TimeInterval(interval)
            return request
        }
        return nil
    }

    func createParametersDic() -> NSMutableDictionary {
        var jsonDic = NSMutableDictionary()
        jsonDic.setValue(self.appId, forKey: "appId")
        jsonDic.setValue(self.appType, forKey: "appType")
        jsonDic.setValue(self.appVersion, forKey: "appVersion")
        jsonDic.setValue(self.osVersion, forKey: "osVersion")
        if self.freeSpace != nil && self.freeSpace.characters.count > 0 {
            jsonDic.setValue(self.freeSpace, forKey: "freeSpace")
        }
        return jsonDic
    }

    public func getAppBootupActionMessage(completionHandler: @escaping AppBootupCompletionBlock) {
        if self.serverBaseURL != nil {
            let jsonDic = self.createParametersDic()
            let urlStr = self.serverBaseURL + self.endPoint
            let request = self.createURLRequest(urlStr, parameters: jsonDic, timeoutInterval: kTimeoutInterval)
            guard request != nil else {
                completionHandler(false, nil)
                return
            }
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: request! as URLRequest, completionHandler: { (data, response, error) in
                if data != nil {
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data!, options: [])
                        DispatchQueue.main.async {
                            let kahunaAppBootup = KahunaAppBootup(fromDictionary: jsonObject as! NSDictionary)
                            if kahunaAppBootup.status != nil && kahunaAppBootup.status.code != 200 {
                                completionHandler(true, kahunaAppBootup)
                            } else {
                                completionHandler(false, nil)
                            }
                        }
                    } catch let Error as NSError {
                        print(Error.description)
                        completionHandler(false, nil)
                    }
                }
            })
            task.resume()
        }
    }

}
