import UIKit

protocol RequestsListViewInput {
    
    func loadRequests(requests: [HTTPRequest])
}

protocol RequestsListViewOutput {
    
    func viewLoaded()
    func requestSelected(request: HTTPRequest)
}

class RequestsListViewController: UIViewController, RequestsListViewInput {
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var filterView: UIView!
    @IBOutlet private weak var filterViewHeight: NSLayoutConstraint!
    var filters: [HTTPProxyFilter] = []

    private lazy var contentVC = SearchableListViewController(nibName: "SearchableListViewController", bundle: HTTPProxyUI.bundle)
    private var filterVC: RequestFilterViewController!

    @IBOutlet private var newRequestNotification: UILabel!

    private var refreshControl = UIRefreshControl()

    private var source: [HTTPRequest] = []
    var requestsListViewOutput: RequestsListViewOutput?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "iOS HTTP Proxy"
        view.backgroundColor = HTTPProxyUI.colorScheme.backgroundColor
        
        contentVC.delegate = self
        addChild(contentVC)
        contentView.addSubview(contentVC.view)
        var frame = contentView.frame
        frame.origin = CGPoint.zero
        contentVC.view.frame = frame
        contentVC.didMove(toParent: self)

        guard let filterViewController = children.first as? RequestFilterViewController else {
          fatalError("Check storyboard for missing LocationTableViewController")
        }
        filterVC = filterViewController
        filterVC.delegate = self
        filterVC.filters = filters
                
        requestsListViewOutput?.viewLoaded()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // You might want to check if this is your embed segue here
        // in case there are other segues triggered from this view controller.
        segue.destination.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func loadFilters(filters: [HTTPProxyFilter]) {
        filterVC.filters = filters
    }
    
    func loadRequests(requests: [HTTPRequest]) {
        source = requests
        showFilteredRequests()
    }
    
    func showFilteredRequests() {
        let filtered = source.filter { (request) -> Bool in
            guard let components = URLComponents(url: request.request.url!, resolvingAgainstBaseURL: false) else {
                return false
            }
            for filter in filters {
                if !filter.enabled {
                    continue
                }
                if let host = filter.host {
                    if host != components.host {
                        return false
                    }
                }
                if let method = filter.httpMethod {
                    if method != request.request.httpMethod {
                        return false
                    }
                }
            }
            return true
        }
                
        var requestModels: [RequestViewModel] = []
        for request in filtered {
            let viewModel = RequestViewModel(request: request)
            requestModels.append(viewModel)
        }
        
        let section = SearchableListSection(title: "Requests", items: requestModels)
        contentVC.loadSections([section])
    }
}

extension RequestsListViewController: RequestDetailsDelegate {
    func didSelectItem(at index: Int) {
        let request = source[index]
        requestsListViewOutput?.requestSelected(request: request)
    }
}

extension RequestsListViewController: RequestFilterViewControllerDelegate {
    func filterDidUpdateHeight(_ height: CGFloat) {
        filterViewHeight.constant = height
        view.layoutIfNeeded()
    }
    
    func filterSelected(_ filter: HTTPProxyFilter) {
        filter.enabled = !filter.enabled
        showFilteredRequests()
    }
}
