# KahunaControlAppBootup

[![CI Status](http://img.shields.io/travis/siddharthchopra/KahunaControlAppBootup.svg?style=flat)](https://travis-ci.org/siddharthchopra/KahunaControlAppBootup)
[![Version](https://img.shields.io/cocoapods/v/KahunaControlAppBootup.svg?style=flat)](http://cocoapods.org/pods/KahunaControlAppBootup)
[![License](https://img.shields.io/cocoapods/l/KahunaControlAppBootup.svg?style=flat)](http://cocoapods.org/pods/KahunaControlAppBootup)
[![Platform](https://img.shields.io/cocoapods/p/KahunaControlAppBootup.svg?style=flat)](http://cocoapods.org/pods/KahunaControlAppBootup)

![LogCamp](http://www.kahuna-mobihub.com/templates/ja_puresite/images/logo-trans.png)

KahunaControlAppBootup is written in Swift

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
In order to access this feature of app boot up, you need to have Kahuna Logcamp Id

## Installation

KahunaControlAppBootup is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'KahunaControlAppBootup', '~> 0.2.2'
```
> New development will happen exclusively on the master/Swift 3 branch.

## Set Server URL
```swift
let shared = AppBootupHandler.sharedInstance
shared.initServerBaseURL(serverBaseURL: kServerBaseURL)
```
Note:
Add import KahunaControlAppBootup into respected file


## Set for Production app type

```swift
shared.isAppTypeProduction(flag: true)
```
> _Note:_ Default value for production = false


## Set all App Boot Up key and default bool value of checkFreeSpace = false
```swift
shared.initAllAppBootupKeys(appId: logCampId)
```
OR

```swift
shared.initAllAppBootupKeys(appId: logCampId, checkFreeSpace: true)
```
> _Note:_ Default value for checkFreeSpace = false

## Detect an app to boot or not in a device based on that apply app version, os version and free space.
- Default View managed in a alert by library based on action.
```swift
shared.checkForRemoteUpdate()
```

- Custom View managed based on action managed by an app.
```swift
shared.checkForRemoteUpdateByCustomView { (success, jsonObject) in
    if success && jsonObject is KahunaAppBootup {
    let kahunaAppBooup = jsonObject as! KahunaAppBootup
        print(kahunaAppBooup.action)
        print(kahunaAppBooup.message)
        print(kahunaAppBooup.title)
        print(kahunaAppBooup.url)
    }
}
```
> _Note:_
When success == true and jsonObject is KahunaAppBootup 
then we need to perform check actions and show message with title
- Action BLOCK -> Restrict User to use an app by showing title and message in a alert.
- Action WARNING -> Prompt message in an alert to User with title.
- Action REDIRECT_TO_APPSTORE -> Prompt message in an alert to User with title and click ok then redirect to app store to update an app version.
- Action REDIRECT_TO_SETTINGS -> Prompt message in an alert to User with title and click ok then redirect to device settings to update an os version.
- Action REDIRECT_TO_URL -> Prompt message in an alert to User with title and click install then redirect to respective url to update an app version.

## Required methods to be written in appdelegate class.
> _Note:_
Call setupRemoteUpdate in didFinishLaunchingWithOptions method
```swift
func setupRemoteUpdate() {
  let shared = AppBootupHandler.sharedInstance
  shared.initServerBaseURL(serverBaseURL: Constants.KALogger.KALoggerURL)
  if let rootViewController = self.window?.rootViewController {
    shared.initAllAppBootupKeysWithViewController(appId: Constants.KALogger.KALoggerAppID, viewController: rootViewController)
    #if DEVELOPMENT
      shared.isAppTypeProduction(flag: false)
    #else
      shared.isAppTypeProduction(flag: true)
    #endif
  }
}
```

> _Note:_
Call checkForRemoteUpdate in applicationWillEnterForeground method
```swift
func checkForRemoteUpdate(splashScreen: UIImageView? = nil) {
  if CheckConnectivity.hasConnectivity() {
    AppBootupHandler.sharedInstance.checkForRemoteUpdate { (success, jsonObject) in
      if let splashScreenView = splashScreen {
        DispatchQueue.main.async {
          splashScreenView.removeFromSuperview()
            MBProgressHUD.hideAllHUDs(for: self.window, animated: true)
        }
      }
    }
  } else {
    if let splashScreenView = splashScreen {
      DispatchQueue.main.async {
        splashScreenView.removeFromSuperview()
        MBProgressHUD.hideAllHUDs(for: self.window, animated: true)
      }
    }
  }
}
```

## Author

siddharthchopra, siddharth.chopra@kahunasystems.com

## License

KahunaControlAppBootup is available under the MIT license. See the LICENSE file for more info.
