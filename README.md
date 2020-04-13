# HTTPProxy

A network debugging tool for iOS

## Features

<p float="left">
  <img src="/screenshots/Screenshot1.png" width="250" />
  <img src="/screenshots/Screenshot2.png" width="250" /> 
  <img src="/screenshots/Screenshot3.png" width="250" />
</p>

- List all HTTP and HTTPS traffic from URLSessions run with configuration URLSessionConfiguration.default
- Search requests by url
- Display detailed information about each request, including text search
- Inspect request/response body and headers

## Installation

### CocoaPods

<pre>
pod 'HTTPProxy'
</pre>

## Setup
First, enable HTTPProxy before any request is fired (e.g. in `application(:, didFinishLaunchingWithOptions:)` ) by calling `HTTPProxy.shared.enable()`

```swift
import HTTPProxy

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        HTTPProxy.shared.enable()
        
        return true
    }

}
```

Then, from any point in the application you can visualize the requests calling:
```swift
 HTTPProxy.shared.presentViewController()
```

The tool can also be displayed with a shake gesture.