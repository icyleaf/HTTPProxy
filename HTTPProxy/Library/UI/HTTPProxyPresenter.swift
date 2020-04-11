import UIKit

class HTTPProxyPresenter {

    private var requestsListPresenter: RequestsListPresenter?
    static let shared = HTTPProxyPresenter()
    static let bundle = Bundle(for: HTTPProxy.self)
    var colorScheme: ColorScheme

    init() {
        colorScheme = HTTPProxyPresenter.darkModeEnabled() ? DarkColorScheme() : LightColorScheme()
    }
    
    func handleShakeGesture() {
        presentViewController()
    }
    
    func presentViewController() {
        if requestsListPresenter != nil {
            requestsListPresenter?.close()
            return
        }
        guard let presentingViewController = presentingViewController() else {
            return
        }
        requestsListPresenter = RequestsListPresenter(presentingViewController: presentingViewController)
        requestsListPresenter?.delegate = self
        requestsListPresenter?.present()
    }

    private func presentingViewController() -> UIViewController? {
        var presentingViewController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = presentingViewController?.presentedViewController {
            presentingViewController = presentedViewController
        }
        return presentingViewController
    }
    
    static func darkModeEnabled() -> Bool {
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark
        }
        return false
    }
}

extension HTTPProxyPresenter: RequestsListPresenterDelegate {
    func didDismissView() {
        requestsListPresenter = nil
    }
}
