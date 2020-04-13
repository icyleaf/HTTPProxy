import UIKit

class HTTPProxyPresenter {

    private var requestsListPresenter: RequestsListPresenter?
    static let shared = HTTPProxyPresenter()
    
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
}

extension HTTPProxyPresenter: RequestsListPresenterDelegate {
    func didDismissView() {
        requestsListPresenter = nil
    }
}
