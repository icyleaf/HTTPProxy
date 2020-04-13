import UIKit

class HTTPProxyUI {

    static let bundle = Bundle(for: HTTPProxy.self)
    static var colorScheme: ColorScheme = HTTPProxyUI.darkModeEnabled() ? DarkColorScheme() : LightColorScheme()
    
    static func darkModeEnabled() -> Bool {
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark
        }
        return false
    }
}
