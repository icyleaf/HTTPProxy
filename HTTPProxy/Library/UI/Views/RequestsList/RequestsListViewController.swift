import UIKit

protocol RequestsListViewInput {
    
    func loadRequests(requests: [HTTPRequest])
}

protocol RequestsListViewOutput {
    
    func viewLoaded()
    func requestSelected(request: HTTPRequest)
}

class RequestsListViewController: UIViewController, RequestsListViewInput, RequestDetailsDelegate {
    @IBOutlet private var contentView: UIView!
    private lazy var contentVC = SearchableListViewController(nibName: "SearchableListViewController", bundle: HTTPProxyUI.bundle)

    @IBOutlet private var newRequestNotification: UILabel!

    private var refreshControl = UIRefreshControl()

    private var source: [HTTPRequest] = []
    var requestsListViewOutput: RequestsListViewOutput?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "HTTP Monitoring"
        view.backgroundColor = HTTPProxyUI.colorScheme.backgroundColor
        
        contentVC.delegate = self
        addChild(contentVC)
        contentView.addSubview(contentVC.view)
        var frame = contentView.frame
        frame.origin = CGPoint.zero
        contentVC.view.frame = frame
        contentVC.didMove(toParent: self)

        requestsListViewOutput?.viewLoaded()
    }
    
    func loadRequests(requests: [HTTPRequest]) {
        source = requests

        var requestModels: [RequestViewModel] = []
        for request in requests {
            let viewModel = RequestViewModel(request: request)
            requestModels.append(viewModel)
        }
        
        let section = SearchableListSection(title: "Requests", items: requestModels)
        contentVC.loadSections([section])
    }
    
    func didSelectItem(at index: Int) {
        let request = source[index]
        requestsListViewOutput?.requestSelected(request: request)
    }
}
