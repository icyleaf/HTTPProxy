import Foundation
import UIKit

protocol RequestsListPresenterDelegate: class {
    func didDismissView()
}

class RequestsListPresenter: NSObject {
    
    private var source: [HTTPRequest] = []
    private let requestsViewController: RequestsListViewController
    private var navigationController: UINavigationController
    private var presentingViewController: UIViewController
    weak var delegate: RequestsListPresenterDelegate?

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
        self.requestsViewController = UIStoryboard(name: "RequestsListViewController", bundle: HTTPProxyUI.bundle).instantiateInitialViewController() as! RequestsListViewController

        let navigationController = UINavigationController(rootViewController: self.requestsViewController)
        self.navigationController = navigationController

        super.init()

        self.requestsViewController.requestsListViewOutput = self

        let navigationBar = navigationController.navigationBar
        navigationBar.isTranslucent = false
        navigationBar.tintColor = HTTPProxyUI.colorScheme.primaryTextColor
        navigationBar.barTintColor = HTTPProxyUI.colorScheme.foregroundColor
        navigationBar.titleTextAttributes = [.foregroundColor: HTTPProxyUI.colorScheme.primaryTextColor]

        navigationController.modalPresentationStyle = .fullScreen
        requestsViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        let composeButton =  UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(filter))
        let clearButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clear))
        requestsViewController.navigationItem.rightBarButtonItems = [clearButton, composeButton]
        
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
    
    @objc func filter() {
        let filterVC = UIStoryboard(name: "EditFilterViewController", bundle: HTTPProxyUI.bundle).instantiateInitialViewController() as! EditFilterViewController
        filterVC.delegate = self
        navigationController.pushViewController(filterVC, animated: true)
    }
    
    @objc func clear() {
        HTTPProxy.shared.clearRequests()
        requestsViewController.loadRequests(HTTPProxy.shared.requests)
    }
}

extension RequestsListPresenter: HTTPProxyDelegate {

    func shouldFireURLRequest(_ urlRequest: URLRequest) -> Bool {
        return true
    }
    
    func willFireRequest(_ httpRequest: HTTPRequest) {
        requestsViewController.loadRequests(HTTPProxy.shared.requests)
    }
    
    func didCompleteRequest(_ httpRequest: HTTPRequest) {
        requestsViewController.loadRequests(HTTPProxy.shared.requests)
    }
}

extension RequestsListPresenter: RequestsListViewOutput {
    func viewLoaded() {
        requestsViewController.loadRequests(HTTPProxy.shared.requests)
        requestsViewController.loadFilters(HTTPProxy.shared.filters)
    }
    
    func requestSelected(_ request: HTTPRequest) {
        let presenter = RequestDetailsPresenter(request: request, presentingViewController: navigationController)
              presenter.present()
    }
    
    func editFilter(_ filter: HTTPProxyFilter) {
        let filterVC = UIStoryboard(name: "EditFilterViewController", bundle: HTTPProxyUI.bundle).instantiateInitialViewController() as! EditFilterViewController
        filterVC.delegate = self
        filterVC.filter = filter
        navigationController.pushViewController(filterVC, animated: true)
    }
    
    func deleteFilter(_ filter: HTTPProxyFilter) {
        var filters = requestsViewController.filters
        if let index = filters.firstIndex(where: { aFilter -> Bool in
               aFilter === filter
           }) {
            filters.remove(at: index)
            requestsViewController.loadFilters(filters)
        }
    }
}

extension RequestsListPresenter: EditFilterViewControllerDelegate {
    func editFilterViewController(_ viewController: EditFilterViewController, didEditFilter filter: HTTPProxyFilter) {
        if let originalFilter = viewController.filter {
            filter.enabled = originalFilter.enabled
            if let index = HTTPProxy.shared.filters.firstIndex(where: { (aFilter) -> Bool in
                originalFilter === aFilter
            }) {
                HTTPProxy.shared.filters[index] = filter
            }
        } else {
            HTTPProxy.shared.filters.append(filter)
        }
        requestsViewController.loadFilters(HTTPProxy.shared.filters)
        navigationController.popViewController(animated: true)
    }
}
