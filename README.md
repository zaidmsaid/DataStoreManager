# DataStoreManager

[![Swift 5](https://img.shields.io/badge/swift-v5.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platform](https://img.shields.io/cocoapods/p/DataStoreManager.svg?style=flat)](http://www.apple.com/ios/)
[![Carthage compatible](https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/DataStoreManager.svg?style=flat)](http://cocoapods.org/pods/DataStoreManager)
[![License](https://img.shields.io/github/license/zaidmsaid/DataStoreManager.svg?style=flat)](https://opensource.org/licenses/Apache-2.0)
[comment]: <> ([![Codebeat badge](https://codebeat.co/badges/5403398a-5535-4def-8937-ab9a413584cc)](https://codebeat.co/projects/github-com-zaidmsaid-datastoremanager))
[![Reviewed by Hound](https://img.shields.io/badge/reviewed_by-Hound-8E64B0.svg)](https://houndci.com)
[![Documentation](https://zaidmsaid.github.io/DataStoreManager/badge.svg)](https://zaidmsaid.github.io/DataStoreManager/)
[![Twitter](https://img.shields.io/badge/twitter-@SentulAsia-blue.svg?style=flat)](http://twitter.com/SentulAsia)

[DataStoreManager](https://github.com/zaidmsaid/DataStoreManager) is a persistent data framework written in Swift and can be used with Objective-C.

## Usage

```swift
import DataStoreManager

class ViewController: UIViewController {

    let manager = DataStoreManager(identifier: "Example")

    func fetchFromDataStore() {
    	manager.read(forKey: "Age", withObjectType: Int.self, forType: .userDefaults) { (object, _, _) in
            if let object = object {
                print("successfully read int \(object) from UserDefaults")
            }
    	}

        manager.read(forKey: "Balance", withObjectType: Decimal.self, forType: .genericKeychain) { (object, _, _) in
            if let object = object {
                print("successfully read decimal \(object) from Generic Keychain")
            }
        }

    	manager.read(forKey: "temp_file.txt", withObjectType: String.self, forType: .temporaryDirectory) { (object, _, _) in
            if let object = object {
    	        print("successfully read string \(object) from /tmp")
            }
    	}

    	manager.read(forKey: "Image", withObjectType: UIImage.self, forType: .cache) { (object, _, _) in
            if let object = object {
                print("successfully read image \(object) from NSCache")
            }
        }
    }

    func storeToDataStore(object aObject: Any) {
    	manager.create(object: aObject, forKey: "Text", forType: .userDefaults) { (isSuccessful, _, _) in
            if isSuccessful {
    	        print("successfully create object at UserDefaults")
            }
    	}

        manager.update(object: aObject, forKey: "Text", forType: .genericKeychain) { (isSuccessful, _, _) in
            if isSuccessful {
                print("successfully update object at Generic Keychain")
            }
        }

    	manager.create(object: aObject, forKey: "Inbox/file.txt", forType: .documentDirectory) { (isSuccessful, _, _) in
            if isSuccessful {
    	        print("successfully create file at Inbox Document Directory")
            }
    	}

    	let exampleModel = DynamicModel(name: "Text", number: 123)

    	manager.create(object: exampleModel, forKey: "column_name", forType: .privateCloudDatabase) { (isSuccessful, recordID, _) in
            if isSuccessful {
    	        print("successfully create model at CloudKit Private Database with ID \(recordID)")
            }
    	}
    }
}
```

Available storage types:

```swift
/// UserDefaults
.userDefaults

/// FileManager (~/Documents)
.documentDirectory

/// FileManager (/Users)
.userDirectory

/// FileManager (/Library)
.libraryDirectory

/// FileManager (/Applications)
.applicationDirectory

/// FileManager (/System/Library/CoreServices)
.coreServiceDirectory

/// FileManager (/tmp)
.temporaryDirectory

/// NSCache
.cache

/// Keychain (kSecClassGenericPassword)
.genericKeychain

/// Keychain (kSecClassInternetPassword)
.internetKeychain

/// CoreData
.coreData

/// CloudKit (.privateCloudDatabase)
.privateCloudDatabase

/// CloudKit (.publicCloudDatabase)
.publicCloudDatabase

/// CloudKit (.sharedCloudDatabase)
.sharedCloudDatabase

/// NSUbiquitousKeyValueStore
.ubiquitousCloudStore
```

### Prerequisites

* iOS 8.0+
* macOS 10.10+
* watchOS 2.0+
* tvOS 9.0+
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

#### <img src="https://raw.githubusercontent.com/zaidmsaid/DataStoreManager/master/Resources/cocoapods.png" width="24" height="24"> [CocoaPods]

[CocoaPods]: http://cocoapods.org

To install it, simply add the following line to your **Podfile**:

```ruby
pod "DataStoreManager"
```

You will also need to make sure you're opting into using frameworks:

```ruby
use_frameworks!
```

Then run `pod install` with CocoaPods 1.6.0 or newer.

#### <img src="https://raw.githubusercontent.com/zaidmsaid/DataStoreManager/master/Resources/swift.png" width="24" height="24"> [Swift Package Manager]

[Swift Package Manager]: https://swift.org/package-manager/

To install it, simply add the following line to your **Package.swift**:

```swift
dependencies: [
    .package(url: "https://github.com/zaidmsaid/DataStoreManager.git", .upToNextMinor(from: "0.9.3"))
]
```

or more strict:

```swift
dependencies: [
    .package(url: "https://github.com/zaidmsaid/DataStoreManager.git", .exact("0.9.3"))
]
```

Then run `swift package update`.

#### <img src="https://git-scm.com/images/logos/downloads/Git-Icon-1788C.png" width="24" height="24"> [Git Submodule]

[Git Submodule]: https://github.com/zaidmsaid/DataStoreManager

To install DataStoreManager to your project, simply follow the following steps:

1. Add DataStoreManager as a [submodule](http://git-scm.com/docs/git-submodule) by opening the Terminal, `cd`-ing into your top-level project directory, and entering the command `git submodule add https://github.com/zaidmsaid/DataStoreManager.git`
2. Open the `DataStoreManager` folder, and drag `DataStoreManager.xcodeproj` into the file navigator of your app project.
3. In Xcode, navigate to the target configuration window by clicking on the blue project icon, and selecting the application target under the "Targets" heading in the sidebar.
4. Ensure that the deployment target of `DataStoreManager.framework` matches that of the application target.
5. In the tab bar at the top of that window, open the "Build Phases" panel.
6. Expand the "Link Binary with Libraries" group, and add `DataStoreManager.framework`.
7. Click on the `+` button at the top left of the panel and select "New Copy Files Phase". Rename this new phase to "Copy Frameworks", set the "Destination" to "Frameworks", and add `DataStoreManager.framework`.

### Documentation

Having trouble with DataStoreManager? Check out our [documentation](https://zaidmsaid.github.io/DataStoreManager/).

## Built With

* [Xcode](https://developer.apple.com/xcode/ide/) - The IDE used
* [jazzy](https://github.com/realm/jazzy) - Used to generate docs

## Contributing

Please read [CONTRIBUTING.md](https://github.com/zaidmsaid/DataStoreManager/blob/master/CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](https://github.com/zaidmsaid/DataStoreManager/blob/master/CODE_OF_CONDUCT.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/zaidmsaid/DataStoreManager/tags).

## Authors

* [**Zaid M. Said**](http://github.com/SentulAsia) - *Initial work* - [@SentulAsia](https://twitter.com/SentulAsia)

See also the list of [contributors](https://github.com/zaidmsaid/DataStoreManager/graphs/contributors) who participated in this project.

## License

This project is licensed under the Apache License, Version 2.0 - see the [LICENSE](https://github.com/zaidmsaid/DataStoreManager/blob/master/LICENSE) file for details

## Acknowledgments

* Hat tip to anyone whose code was used

![analytics](https://ga-beacon.appspot.com/UA-22180067-6/DataStoreManager/README.md?pixel)
