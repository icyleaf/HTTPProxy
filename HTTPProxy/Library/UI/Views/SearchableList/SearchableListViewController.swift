import UIKit

enum RequestStatus {
    case loading
    case completed(statusCode: Int)
    case error
}

protocol SearchableListItem {
    var key: String {get}
    var value: String {get}
    var method: String? {get}
    var statusCode: Int? {get}
    var requestStatus: RequestStatus? {get}
}

struct SearchableListSection {
    let title: String?
    let items: [SearchableListItem]
}

protocol RequestDetailsViewInput {
    func loadSections(_ sections: [SearchableListSection])
}

protocol RequestDetailsDelegate: class {
    func didSelectItem(at index: Int)
}

class SearchableListViewController: UIViewController {
    
    var sections: [SearchableListSection] = []
    var buttonTitle: String?
    var buttonCallback: (() -> Void)?
    weak var delegate: RequestDetailsDelegate?

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var button: UIButton!
    @IBOutlet private var buttonView: UIView!
    @IBOutlet weak var tableViewBottomLayoutConstraint: NSLayoutConstraint!

    private var headersListController: HeadersListController!
    private var searchListController: SearchListController!
    private let tableViewBottonInset: CGFloat = 10.0
    private var searchString: String?
    private var filteredSections: [SearchableListSection]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewBottomLayoutConstraint.constant = tableViewBottonInset

        view.backgroundColor = HTTPProxyUI.colorScheme.backgroundColor
        headersListController = HeadersListController(tableView: tableView)
        headersListController.delegate = self
        headersListController.load(sections: sections)
        searchListController = SearchListController(searchBar: searchBar)
        searchListController.delegate = self
        
        if let title = buttonTitle {
            button.setTitle(title, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
            button.backgroundColor = HTTPProxyUI.colorScheme.selectedColor
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 8.0
        } else {
            buttonView.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func keyboardWillAppear(notification: NSNotification?) {

        guard let keyboardFrame = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let bottomInset: CGFloat
        if #available(iOS 11.0, *) {
            bottomInset = keyboardFrame.cgRectValue.height - UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        } else {
            bottomInset = keyboardFrame.cgRectValue.height
        }

        tableViewBottomLayoutConstraint.constant = bottomInset + tableViewBottonInset
    }
    
    private func filter(searchString: String) {
        var filteredSections: [SearchableListSection] = []
        for section in sections {
            var filteredItems: [SearchableListItem] = []
            for item in section.items {
                if item.key.lowercased().range(of: searchString) != nil ||
                    item.value.lowercased().range(of: searchString) != nil {
                    filteredItems.append(item)
                }
            }
            let sectionCopy = SearchableListSection(title: section.title, items: filteredItems)
            filteredSections.append(sectionCopy)
        }
        self.filteredSections = filteredSections
        headersListController.load(sections: filteredSections, textToHighlight: searchString)
    }

    @objc
    private func keyboardWillDisappear(notification: NSNotification?) {
        tableViewBottomLayoutConstraint.constant = tableViewBottonInset
    }
    
    @objc
    private func buttonClicked() {
        buttonCallback?()
    }
}

extension SearchableListViewController: RequestDetailsViewInput {
    
    func loadSections(_ sections: [SearchableListSection]) {
        self.sections = sections
        if let searchString = searchString {
            filter(searchString: searchString)
        } else {
            headersListController?.load(sections: sections)
        }
    }
}

extension SearchableListViewController: HeadersListControllerDelegate {

    func didSelectItem(at index: Int) {
        if let filteredSections = filteredSections {
            let selectedItem = filteredSections[0].items[index]
            let selectedIndex = sections[0].items.firstIndex { (item) -> Bool in
                item.key == selectedItem.key && item.value == selectedItem.value
            }
            if let selectedIndex = selectedIndex {
                delegate?.didSelectItem(at: selectedIndex)
            } else {
                fatalError()
            }
        } else {
            delegate?.didSelectItem(at: index)
        }
    }
}

extension SearchableListViewController: SearchListControllerDelegate {
    
    func clear() {
        searchString = nil
        headersListController.load(sections: sections)
    }
    
    func searchText(_ searchText: String) {
        let lowercasedText = searchText.lowercased()
        searchString = lowercasedText
        filter(searchString: lowercasedText)
    }
}

protocol SearchListControllerDelegate: class {
    
    func clear()
    func searchText(_ searchText: String)
}

class SearchListController: NSObject {

    private var searchBar: UISearchBar
    weak var delegate: SearchListControllerDelegate?

    init(searchBar: UISearchBar) {
        self.searchBar = searchBar
        super.init()
        
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.placeholder = "Search"
            searchBar.searchTextField.backgroundColor = HTTPProxyUI.colorScheme.foregroundColor
            searchBar.searchTextField.textColor = HTTPProxyUI.colorScheme.primaryTextColor
        } else {
            let attributes = [NSAttributedString.Key.foregroundColor: HTTPProxyUI.colorScheme.primaryTextColor]
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = attributes
        }
    }
}

extension SearchListController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            delegate?.clear()
        } else {
            delegate?.searchText(searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        delegate?.clear()
        searchBar.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            delegate?.searchText(text)
        }
    }
}
