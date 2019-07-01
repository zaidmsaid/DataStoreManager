# DataStoreManager

[![Swift 5](https://img.shields.io/badge/Swift-5-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](http://www.apple.com/ios/)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/DataStoreManager.svg?style=flat)](http://cocoapods.org/pods/DataStoreManager)
[![SwiftPM Compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License Apache](https://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat)](https://opensource.org/licenses/Apache-2.0)
[![Twitter](https://img.shields.io/badge/twitter-@SentulAsia-blue.svg)](http://twitter.com/SentulAsia)

DataStoreManager is a persistent data framework written in Swift and can be used with Objective-C.

## Getting Started

```swift
import DataStoreManager

class ViewController: UIViewController, DataStoreManagerDataSource {

    let manager = DataStoreManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        manager.dataSource = self
        manager.tag = 3
    }
    .
    .
    .
    func fetchFromDataStore(aValue: String) {
    	manager.read(forKey: "Key") { (object) in
            print("successfully read \(object) from UserDefaults")
    	}

    	manager.read(forKey: "temp_file.txt", forType: .temporaryDirectory) { (object) in
    	    print("successfully read \(object) from Temporary Directory")
    	}
    }

    func storeToDataStore(aValue: String) {
    	manager.create(value: aValue, forKey: "Key") { (isSuccessful) in
    	    print("successfully write to UserDefaults")
    	}

    	manager.create(value: aValue, forKey: "Inbox/file.txt", forType: .documentDirectory) { (isSuccessful) in
    	    print("successfully write to Inbox Document Directory")
    	}
    }
    .
    .
    .
    func defaultType(for manager: DataStoreManager) -> DataStoreManager.StorageType {
        return .userDefaults
    }
}
```

### Prerequisites

* iOS 8.0+
* Xcode 10.2+

### Installing

#### <img src="https://cloud.githubusercontent.com/assets/432536/5252404/443d64f4-7952-11e4-9d26-fc5cc664cb61.png" width="24" height="24"> [Carthage]

[Carthage]: https://github.com/Carthage/Carthage

To install it, simply add the following line to your **Cartfile**:

```ruby
github "zaidmsaid/DataStoreManager"
```

Then run `carthage update`.

Follow the current instructions in [Carthage's README][carthage-installation]
for up to date installation instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

#### <img src="https://raw.githubusercontent.com/zaidmsaid/DataStoreManager/master/Resources/Images/cocoapods.png" width="24" height="24"> [CocoaPods]

[CocoaPods]: http://cocoapods.org

To install it, simply add the following line to your **Podfile**:

```ruby
pod 'DataStoreManager'
```

You will also need to make sure you're opting into using frameworks:

```ruby
use_frameworks!
```

Then run `pod install` with CocoaPods 1.6.0 or newer.

#### <img src="https://raw.githubusercontent.com/zaidmsaid/DataStoreManager/master/Resources/Images/swift.png" width="24" height="24"> [Swift Package Manager]

[Swift Package Manager]: https://swift.org/package-manager/

To install it, simply add the following line to your **Package.swift**:

```swift
dependencies: [
    .package(url: "https://github.com/zaidmsaid/DataStoreManager.git", .upToNextMinor(from: "0.3.0"))
]
```

or more strict

```swift
dependencies: [
    .package(url: "https://github.com/zaidmsaid/DataStoreManager.git", .exact("0.3.0"))
]
```

Then run `swift package update`.

#### Manually

DataStoreManager in your project requires the following steps:

1. Add DataStoreManager as a [submodule](http://git-scm.com/docs/git-submodule) by opening the Terminal, `cd`-ing into your top-level project directory, and entering the command `git submodule add https://github.com/zaidmsaid/DataStoreManager.git`
2. Open the `DataStoreManager` folder, and drag `DataStoreManager.xcodeproj` into the file navigator of your app project.
3. In Xcode, navigate to the target configuration window by clicking on the blue project icon, and selecting the application target under the "Targets" heading in the sidebar.
4. Ensure that the deployment target of DataStoreManager.framework matches that of the application target.
5. In the tab bar at the top of that window, open the "Build Phases" panel.
6. Expand the "Link Binary with Libraries" group, and add `DataStoreManager.framework`.
7. Click on the `+` button at the top left of the panel and select "New Copy Files Phase". Rename this new phase to "Copy Frameworks", set the "Destination" to "Frameworks", and add `DataStoreManager.framework`.

## Built With

* [Xcode](https://developer.apple.com/xcode/ide/) - The IDE used

## Contributing

Please read [CONTRIBUTING.md](https://github.com/zaidmsaid/DataStoreManager/blob/master/CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/zaidmsaid/DataStoreManager/tags).

## Authors

* [**Zaid M. Said**](http://github.com/SentulAsia) - *Initial work* - [@SentulAsia](https://twitter.com/SentulAsia)

See also the list of [contributors](https://github.com/zaidmsaid/DataStoreManager/graphs/contributors) who participated in this project.

## License

This project is licensed under the Apache License, Version 2.0 - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
