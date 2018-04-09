
<p align="center">
  <img src="./Assets/Ghost.jpg" alt="Ghost">
  <br/><a href="https://cocoapods.org/pods/Ghost">
  <img alt="Version" src="https://img.shields.io/badge/version-1.3.1-brightgreen.svg">
  <img alt="Author" src="https://img.shields.io/badge/author-Meniny-blue.svg">
  <img alt="Build Passing" src="https://img.shields.io/badge/build-passing-brightgreen.svg">
  <img alt="Swift" src="https://img.shields.io/badge/swift-4.0%2B-orange.svg">
  <br/>
  <img alt="Platforms" src="https://img.shields.io/badge/platform-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS-lightgrey.svg">
  <img alt="MIT" src="https://img.shields.io/badge/license-MIT-blue.svg">
  <br/>
  <img alt="Cocoapods" src="https://img.shields.io/badge/cocoapods-compatible-brightgreen.svg">
  <img alt="Carthage" src="https://img.shields.io/badge/carthage-working%20on-red.svg">
  <img alt="SPM" src="https://img.shields.io/badge/swift%20package%20manager-compatible-brightgreen.svg">
  </a>
</p>

# Introduction

**Ghost** is a versatile HTTP(s) networking framework written in Swift.

## 🌟 Features

- [x] Chainable Request / Response Methods
- [x] Asynchronous & synchronous task execution
- [x] Basic, Bearer & Custom Authorization Handling
- [x] `URL` / `JSON` / `Property List` Parameter Encoding
- [x] Upload File / `Data` / `Stream` / `Multipart Form Data`
- [x] Download File using Request / Resume Data
- [x] Authentication with `URLCredential`
- [x] Custom Cache Controls
- [x] Custom Content Types
- [x] Upload & Download Progress Closures
- [x] `cURL` Command Debug Output
- [x] Request & Response Interceptors
- [x] Inference of response object type
- [x] Network reachability
- [x] `TLS Certificate` & `Public Key Pinning`
- [x] Retry requests
- [x] `Codable` protocols compatible (`JSON` / `Property List`)
- [x] `watchOS` Compatible
- [x] `tvOS` Compatible
- [x] `macOS` Compatible

## 📋 Requirements

- iOS 8.0+
- macOS 10.9+
- tvOS 9.0+
- watchOS 2.0+
- Xcode 9.0+ with Swift 4.0+

## 📲 Installation

Ghost is available on [CocoaPods](https://cocoapods.org):

```ruby
use_frameworks!
pod 'Ghost'
```

## 🔧 Usage

### Build a GhostRequest

```swift
import Ghost

do {
    let request = try GhostRequest.builder("YOUR_URL")!
                .setAccept(.json)
                .setCache(.reloadIgnoringLocalCacheData)
                .setMethod(.PATCH)
                .setTimeout(20)
                .setJSONBody(["foo", "bar"])
                .setContentType(.json)
                .setServiceType(.background)
                .setCacheControls([.maxAge(500)])
                .setURLParameters(["foo": "bar"])
                .setAcceptEncodings([.gzip, .deflate])
                .setBasicAuthorization(user: "user", password: "password")
                .setHeaders(["foo": "bar"])
                .build()
} catch {
    print("Request error: \(error)")
}
```

### Request asynchronously

```swift
import Ghost

let ghost = GhostURLSession()

ghost.data(URL(string: "YOUR_URL")!).async { (response, error) in
    do {
        if let object: [AnyHashable: Any] = try response?.object() {
            print("Response dictionary: \(object)")
        } else if let error = error {
            print("Net error: \(error)")
        }
    } catch {
        print("Parse error: \(error)")
    }
}
```

### Request synchronously

```swift
import Ghost

let ghost = GhostURLSession()

do {
    let object: [AnyHashable: Any] = try ghost.data("YOUR_URL").sync().object()
    print("Response dictionary: \(object)")
} catch {
    print("Error: \(error)")
}
```

### Request from cache

```swift
import Ghost

let ghost = GhostURLSession()

do {
    let object: [AnyHashable: Any] = try ghost.data("YOUR_URL").cached().object()
    print("Response dictionary: \(object)")
} catch {
    print("Error: \(error)")
}
```

### Track progress

```swift
import Ghost

let ghost = GhostURLSession()

do {
    let task = try ghost.data("YOUR_URL").progress({ progress in
        print(progress)
    }).sync()
} catch {
    print("Error: \(error)")
}
```

### Add interceptors for all requests

```swift
import Ghost

let ghost = GhostURLSession()

ghost.addRequestInterceptor { request in
    request.addHeader("foo", value: "bar")
    request.setBearerAuthorization(token: "token")
    return request
}
```

### Retry requests

```swift
import Ghost

let ghost = GhostURLSession()

ghost.retryClosure = { response, _, _ in response?.statusCode == XXX }

do {
    let task = try ghost.data("YOUR_URL").retry({ response, error, retryCount in
        return retryCount < 2
    }).sync()
} catch {
    print("Error: \(error)")
}
```

## 🧙‍♂️ Codable

### Encodable

```swift
import Ghost

let request = GhostRequest.builder("YOUR_URL")!
            .setJSONObject(Encodable())
            .build()
```

### Decodable

```swift
import Ghost

let ghost = URLSession()

do {
    let object: Decodable = try ghost.data("YOUR_URL").sync().decode()
    print("Response object: \(object)")
} catch {
    print("Error: \(error)")
}
```

## 🌙 GhostHunter

```swift
let url = URL.init(string: "YOUR_URL")!
do {
    try GhostHunter.async(.GET, url: url, parameters: ["name": "elias"], headers: ["Content-Type": "text/json"], progress: { (pregress) in
        print(pregress)
    }, completion: { (response, error) in
        do {
            if let result: SomeCodableType = try response?.decode() {
                print("GhostHunter Asynchronous: \(result)")
            } else if let error = error {
                print("GhostHunter Asynchronous: Ghost error: \(error)")
            }
        } catch {
            print("GhostHunter: Parse error: \(error)")
        }
    }
} catch {
    print("GhostHunter: Request error: \(error)")
}
```

## ❤️ Contribution

You are welcome to fork and submit pull requests.

## 🔖 License

`Ghost` is open-sourced software, licensed under the `MIT` license.
