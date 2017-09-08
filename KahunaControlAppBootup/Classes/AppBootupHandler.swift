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
    var production = false
    var bootUpViewController: UIViewController!

    public let remoteUpdateUpdateAvailableCode = 7001

    public enum RemoteUpdateCases {
        static let warning = "WARNING"
        static let block = "BLOCK"
        static let redirectAppStore = "REDIRECT_TO_APPSTORE"
        static let redirectSettings = "REDIRECT_TO_SETTINGS"
        static let redirectURL = "REDIRECT_TO_URL"
    }

    public static let sharedInstance = AppBootupHandler()

    public typealias AppBootupCompletionBlock = (Bool, AnyObject?) -> Void

    override init() {
    }

    deinit {
        print("** InstagramFeedHandler deinit called **")
    }

    public func isAppTypeProduction(flag: Bool) {
        self.production = flag
        self.appType = self.production ? "1" : "0"
    }

    func deviceRemainingFreeSpaceInBytes() -> String? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        guard
            let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory),
            let freeSize = systemAttributes[.systemFreeSize] as? NSNumber
            else {
            // something failed
            return nil
        }
        return freeSize.stringValue
    }

    public func initAllAppBootupKeysWithViewController(appId: String, viewController: UIViewController, checkFreeSpace: Bool = false) {
        self.appId = appId
        if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            self.appVersion = appVersion
            self.osVersion = UIDevice.current.systemVersion
            self.appType = self.production ? "1" : "0"
            if checkFreeSpace {
                let space = self.deviceRemainingFreeSpaceInBytes()
                if space != nil {
                    self.freeSpace = space!
                }
            }
            self.bootUpViewController = viewController
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

    public func checkForRemoteUpdateByCustomView(completionHandler: @escaping AppBootupCompletionBlock) {
        self.getAppBootupActionMessage { (success, jsonObject) in
            completionHandler(success, jsonObject)
        }
    }

    func getAppBootupActionMessage(completionHandler: @escaping AppBootupCompletionBlock) {
        if self.serverBaseURL != nil && self.serverBaseURL.characters.count > 0 && self.appId != nil && self.appId.characters.count > 0 {
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
                } else {
                    completionHandler(false, nil)
                }
            })
            task.resume()
        }
    }

    public func checkForRemoteUpdate(completionHandler: @escaping AppBootupCompletionBlock) {
        if self.bootUpViewController != nil {
            self.getAppBootupActionMessage { (success, jsonObject) in
                if success && jsonObject is KahunaAppBootup {
                    let kahunaAppBooup = jsonObject as! KahunaAppBootup
                    //7001 Error Code: Some thing is available for verification
                    if kahunaAppBooup.status != nil && kahunaAppBooup.status.code != nil && kahunaAppBooup.status.code == self.remoteUpdateUpdateAvailableCode && kahunaAppBooup.title != nil && kahunaAppBooup.message != nil {
                        let controller = UIAlertController(title: kahunaAppBooup.title, message: kahunaAppBooup.message, preferredStyle: .alert)
                        if kahunaAppBooup.action != RemoteUpdateCases.block {
                            var titleStrButton = "Ok"
                            if kahunaAppBooup.url != nil {
                                titleStrButton = "Cancel"
                                let updateAction = UIAlertAction(title: "Continue", style: .default, handler: { (UIAlertAction) in
                                    if kahunaAppBooup.action == RemoteUpdateCases.redirectSettings {
                                        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                                    } else {
                                        UIApplication.shared.openURL(URL(string: kahunaAppBooup.url)!)
                                    }
                                })
                                controller.addAction(updateAction)
                            }
                            if kahunaAppBooup.action == RemoteUpdateCases.warning {
                                let cancelAction = UIAlertAction(title: titleStrButton, style: .default, handler: nil)
                                controller.addAction(cancelAction)
                            }
                        }
                        self.bootUpViewController.present(controller, animated: true, completion: nil)
                    }
                }
                completionHandler(success, jsonObject)
            }
        } else {
            completionHandler(false, nil)
        }
    }

}
