import Foundation
import UIKit

protocol RequestsListPresenterDelegate: class {
    func didDismissView()
}

class RequestsListPresenter: NSObject {
    
    private var source: [HTTPRequest] = []
    private let viewController: RequestsListViewController
    private var navigationController: UINavigationController
    private var presentingViewController: UIViewController
    weak var delegate: RequestsListPresenterDelegate?

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
        //self.viewController = RequestsListViewController(nibName: "RequestsListViewController", bundle: HTTPProxyUI.bundle)
        self.viewController = UIStoryboard(name: "RequestsListViewController", bundle: HTTPProxyUI.bundle).instantiateInitialViewController() as! RequestsListViewController

        let navigationController = UINavigationController(rootViewController: self.viewController)
        self.navigationController = navigationController

        super.init()

        self.viewController.requestsListViewOutput = self

        let navigationBar = navigationController.navigationBar
        navigationBar.isTranslucent = false
        navigationBar.tintColor = HTTPProxyUI.colorScheme.primaryTextColor
        navigationBar.barTintColor = HTTPProxyUI.colorScheme.foregroundColor
        navigationBar.titleTextAttributes = [.foregroundColor: HTTPProxyUI.colorScheme.primaryTextColor]

        navigationController.modalPresentationStyle = .fullScreen
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clear))

        viewController.filters = HTTPProxy.shared.filters
        
        HTTPProxy.shared.internalDelegate = self
    }
    
    func present() {
        presentingViewController.present(navigationController, animated: false)
    }
    
    @objc func close() {
        navigationController.dismiss(animated: true) {
            self.delegate?.didDismissView()
        }
    }
    
    @objc func clear() {
        HTTPProxy.shared.clearRequests()
        viewController.loadRequests(requests: HTTPProxy.shared.requests)
    }
}

extension RequestsListPresenter: HTTPProxyDelegate {

    func shouldFireURLRequest(_ urlRequest: URLRequest) -> Bool {
        return true
    }
    
    func willFireRequest(_ httpRequest: HTTPRequest) {
        viewController.loadRequests(requests: HTTPProxy.shared.requests)
    }
    
    func didCompleteRequest(_ httpRequest: HTTPRequest) {
        viewController.loadRequests(requests: HTTPProxy.shared.requests)
    }
}

extension RequestsListPresenter: RequestsListViewOutput {

    func viewLoaded() {
         viewController.loadRequests(requests: HTTPProxy.shared.requests)
    }
    
    func requestSelected(request: HTTPRequest) {
        let presenter = RequestDetailsPresenter(request: request, presentingViewController: navigationController)
              presenter.present()
    }
}
