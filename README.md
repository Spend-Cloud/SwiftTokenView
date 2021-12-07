# SwiftTokenView

<p align="center">
  <img src="https://raw.githubusercontent.com/Spend-Cloud/SwiftTokenView/main/swifttokenview.png" />
</p>

![CI](https://github.com/Spend-Cloud/SwiftTokenView/workflows/CI/badge.svg)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Packagist](https://img.shields.io/packagist/l/doctrine/orm.svg)]()

`SwiftTokenView` is a lightweight package that lets you create easy to use `Token` views to use in UIKit or SwiftUI.

## Features

- [] Initial setup of creating simple tokens in UIKit
- [] Initial setup of creating simple tokens in SwiftUI
- [] Support for iOS/Mac OS X/tvOS/watchOS/Linux
- [x] Support for Swift Package Manager
- [] Support for CocoaPods

## Examples

You can show a tokenview by creating a `StaticTokenView()` and adding tokens into it. These tokens need to conform to the `StaticToken` protocol. 

```
        let tokenView = StaticTokenView()
        
        for item in 0...200 {
            tokenView.addToken(SampleObject(id: item, name: "token \(item)"))
        }
        
        self.view.addSubview(tokenView)
```

You can also add a batch of tokens at once by using

```
        tokenView.addTokens(tokens)
```

### to be added

## Requirements

- Xcode 10 and higher
- Swift 5 and higher
- iOS 13 / macOS 10.14 / tvOS 13.0

## Installation

### Swift Package Manager(requires Xcode 11)

* Add package into Project settings -> Swift Packages

## Project status

`SwiftTokenView` is under active development by Visma | ProActive. Pull requests are very welcome!

## License

`SwiftTokenView` is released under the MIT license. See LICENSE for details.

## About Visma | ProActive

<p align="center">
  <img src="https://raw.githubusercontent.com/Spend-Cloud/SwiftTokenView/main/VismaProactive.png" />
</p>

[SwiftTokenView] is maintained by Visma | ProActive. What started as an internship assignment snowballed into the Spend Cloud software solution we know today. We are a proud part of Visma with the same mentality as in those early days: ‘let’s just do it and have fun too’. With this 100% cloud-based solution, you can digitize, automate and optimize all business expenses processes. Our goal is to keep improving the ultimate spend solution, which we can achieve by following agile methodologies to deliver a best in class spend management system: the Spend Cloud. 

Find out more [here][website] and don't hesitate to [contact us][contact]!

[website]: https://proactive-software.com/en/
[contact]: https://proactive-software.com/en/contact/
