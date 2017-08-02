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

## Installation

KahunaControlAppBootup is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'KahunaControlAppBootup', '~> 0.1.2'
```
> New development will happen exclusively on the master/Swift 3 branch.

## Set Server URL
```swift
let shared = AppBootupHandler.sharedInstance
shared.initServerBaseURL(serverBaseURL: kServerBaseURL)
```
Note:
Add import KahunaControlAppBootup into respected file

## Set all App Boot Up keys
```swift
shared.initAllAppBootupKeys(appId: logCampId, appType: 0, appVersion: appVersion, osVersion: osVersion, freeSpace: freeSpace)
```
> _Note:_
appType: 0 -> QA
appType: 1 -> Production


## Detect an app to boot or not when success == true and jsonObject is KahunaAppBootup then we need to perform check actions and show message.
```swift
shared.getAppBootupActionMessage { (success, jsonObject) in
    if success && jsonObject is KahunaAppBootup {
    let kahunaAppBooup = jsonObject as! KahunaAppBootup
        print(kahunaAppBooup.action)
        print(kahunaAppBooup.message)
    }
}
```

## Author

siddharthchopra, siddharth.chopra@kahunasystems.com

## License

KahunaControlAppBootup is available under the MIT license. See the LICENSE file for more info.
