# SwiftTokenView

<p align="center">
  <img src="https://raw.githubusercontent.com/Spend-Cloud/SwiftTokenView/main/swifttokenview.png" />
</p>

![CI](https://github.com/Spend-Cloud/SwiftTokenView/workflows/CI/badge.svg)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Packagist](https://img.shields.io/packagist/l/doctrine/orm.svg)]()

`SwiftTokenView` is a lightweight package that lets you create easy to use `Token` views to use in UIKit or SwiftUI.

## Current features

- [x] Initial setup of creating simple tokens in SwiftUI
- [x] Initial setup of creating customizable tokens in a textfield
- [x] Support for Swift Package Manager
- [x] UIKit Support
- [x] Support for CocoaPods
- [x] Support for autocomplete/suggestion when using textfields

## Features in progress

- Add documentation for SwiftTokenTextField/SwiftTokenTextView

## SwiftUI Examples

### the tokens support a @State property that you can modify to change the tokens in a reactive way.

```@State var tokens: [StaticToken] = []```

### it's as easy as creating a SwiftTokenView and adding it to where you want to show it. 

```
SwiftTokenView(tokenStyle: CustomTokenStyle(), tokens: $tokens)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    .background(Color.green)
```

### full example

```
struct MainView: View {
    
    @State var tokens: [StaticToken] = []
    
    var body: some View {
        VStack {
            SwiftTokenView(tokenStyle: CustomTokenStyle(), tokens: $tokens)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color.green)
                .onAppear {
                    var tokens: [StaticToken] = []
                    for item in 0...2 {
                        tokens.append(SampleObject(id: item, name: "token \(item)"))
                    }
                    
                    self.tokens = tokens
                }
            
            Spacer()
            
            HStack {
                Button(action: {
                        tokens.append(SampleObject(id: tokens.count + 2, name: "token \(tokens.count + 2)"))
                    }, label: {
                        Text("Add token")
                })
                
                Button(action: {
                        tokens.removeLast()
                    }, label: {
                        Text("Remove token")
                })
            }
        }
    }
}
```

## Textfield support

### We also support tokens inside textfields. Not only showing them but also creating them. You can simply create a SwiftTokenTextView and add a state property to it with SwiftToken. The SwiftToken object supports whatever object you want to use with it.

```
    @State var tokens: [SwiftToken] = []
    
    var body: some View {
        SwiftTokenTextView(width: 300, height: 44, tokens: $tokens)
            .frame(width: 400, height: 44, alignment: .center)
    }
```

### You can use the same TokenStyle that you used for a static token view by providing it as the first argument.  

```
    var body: some View {
        SwiftTokenTextView(tokenStyle: CustomTokenStyle(), width: 300, height: 44, tokens: $tokens)
            .frame(width: 400, height: 44, alignment: .center)
    }
```

## Show suggestions when using textfields

### We also support showing suggestions inside textfields. You can simply create your own method to handle the suggestions and pass a callback to the SwiftTokenTextView..

```
    struct MainView: View {
        
        @State var tokens: [SwiftToken] = []
        
        var body: some View {
            SwiftTokenTextView(width: 300, height: 44, tokens: $tokens, performSearch: { query in
                performSearch(query)
            }, displayTitleForObject: { object in
                (object as! SampleObject).tokenName()
            })
            .frame(width: UIScreen.main.bounds.width, height: 44, alignment: .center)
        }
        
        private func performSearch(_ query: String) -> [SampleObject] {
            
            let list = [
                SampleObject(id: 1, name: "Apple"),
                SampleObject(id: 2, name: "Banana"),
                SampleObject(id: 3, name: "Orange"),
                SampleObject(id: 3, name: "Lemon")
            ]
            
            if (query.isEmpty) {
                return list
            }
            
            return list.filter { $0.name.range(of: query, options: .caseInsensitive) != nil }
        }
    }
```

### Currently we support most of the styling and options in UIKit where the SwiftUI version is limited. if the default swiftUI implementation doesn't work for your use-case you can check out the SwiftTokenTextView file and use it as a guideline to create your own variant. But feel free to make a pull request if you want to improve the default version! 

## UIKit Examples

### You can show a tokenview by creating a `StaticTokenView()` and adding tokens into it. These tokens need to conform to the `StaticToken` protocol. 

```
let tokenView = StaticTokenView()

for item in 0...200 {
    tokenView.addToken(SampleObject(id: item, name: "token \(item)"))
}

self.view.addSubview(tokenView)
```

### You can also add a batch of tokens at once by using

```
tokenView.addTokens(tokens)
```

### if you wish to style the tokens you can add a style by creating a style object. 

```
struct CustomTokenStyle: TokenStyle {
    var textColor: UIColor = .white
    var backgroundColor: UIColor = .red
}
```

### Then you can override the default style

```
tokenView.style = CustomTokenStyle
```

## Textfield support

### we also support textfields for UIKIT. Just create an instance of SwiftTokenTextField and it works the same as swiftUI.

```
class ViewController: UIViewController {
    
    var tokenTextField: SwiftTokenTextField = {
        let view = SwiftTokenTextField(frame: CGRect(x: 0, y: 0, width: 400, height: 56))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.style = .squared
        view.minimumCharactersToSearch = 0
        view.shouldAddTokenFromTextInput = true
        view.tokenizingCharacters = [",", "."]
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemBackground
        self.view.addSubview(tokenTextField)
        tokenTextField.translatesAutoresizingMaskIntoConstraints = false
        tokenTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tokenTextField.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        tokenTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tokenTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
}
```

## Requirements

- Xcode 10 and higher
- Swift 5 and higher
- iOS 13 / macOS 10.14 / tvOS 13.0

## Installation

### Swift Package Manager(requires Xcode 11)

* Add package into Project settings -> Swift Packages

### CocoaPods
* Add a pod entry for SwiftTokenView to your Podfile

```
source 'https://github.com/Spend-Cloud/SwiftTokenView.git'
platform :ios, '13.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'SwiftTokenView'
end
```

* Then, run the following command:

```
$ pod install
```

## Project status

`SwiftTokenView` is under active development by Visma | ProActive. Pull requests are very welcome!

## License

`SwiftTokenView` is released under the MIT license. See LICENSE for details.

## About Visma | ProActive

<p align="center">
  <img src="https://raw.githubusercontent.com/Spend-Cloud/SwiftTokenView/main/VismaProActive.png" />
</p>

[SwiftTokenView] is maintained by Visma | ProActive. What started as an internship assignment snowballed into the Spend Cloud software solution we know today. We are a proud part of Visma with the same mentality as in those early days: ‘let’s just do it and have fun too’. With this 100% cloud-based solution, you can digitize, automate and optimize all business expenses processes. Our goal is to keep improving the ultimate spend solution, which we can achieve by following agile methodologies to deliver a best in class spend management system: the Spend Cloud. 

Find out more [here][website] and don't hesitate to [contact us][contact]!

[website]: https://proactive-software.com/en/
[contact]: https://proactive-software.com/en/contact/
