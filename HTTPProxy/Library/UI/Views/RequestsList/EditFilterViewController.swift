import UIKit

protocol EditFilterViewControllerDelegate: class {
    func editFilterViewController(_ viewController: EditFilterViewController, didEditFilter filter: HTTPProxyFilter)
}

class EditFilterViewController: UIViewController {

    var filter: HTTPProxyFilter?
    weak var delegate: EditFilterViewControllerDelegate?
    
    @IBOutlet private var backgroundViews: [RoundedView]!
    @IBOutlet private var labels: [UILabel]!
    @IBOutlet private var textFields: [UITextField]!

    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var httpMethodTextField: UITextField!
    @IBOutlet private var schemeTextField: UITextField!
    @IBOutlet private var hostTextField: UITextField!
    @IBOutlet private var portTextField: UITextField!
    @IBOutlet private var queryItemsTextField: UITextField!
    
    override func viewDidLoad() {
        setupView()
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = saveButton
        
        if let filter = filter {
            loadView(filter: filter)
        }
    }
    
    @objc func save() {
        guard let name = nameTextField.validText() else {
            return
        }
        var requestFilter = RequestFilter()
        requestFilter.scheme = schemeTextField.validText()
        requestFilter.httpMethod = httpMethodTextField.validText()
        requestFilter.host = hostTextField.validText()
        var port: Int?
        if let portText = portTextField.validText() {
            port = Int(portText)
        }
        requestFilter.port = port
        if let items = queryItemsTextField.validText() {
            let pairs = items.split(separator: "&")
            if pairs.count > 0 {
                var queryItems: [(name: String, value: String?)] = []
                for substring in pairs {
                    let queryItem = substring.split(separator: "=")
                    guard let name = queryItem.first else {
                        return
                    }
                    let value = queryItem[1]
                    queryItems.append((name: String(name), value: String(value)))
                }
                requestFilter.queryItems = queryItems
            }
        }

        let filter = HTTPProxyFilter(name: name, requestFilter: requestFilter)
        delegate?.editFilterViewController(self, didEditFilter: filter)
    }
    
    private func setupView() {
        view.backgroundColor = HTTPProxyUI.colorScheme.backgroundColor
        backgroundViews.forEach { (view) in
            view.backgroundColor = HTTPProxyUI.colorScheme.foregroundColor
        }
        
        let boldFont = UIFont(name: "Menlo-Bold", size: 14.0)!
        labels.forEach { (label) in
            label.font = boldFont
            label.textColor = HTTPProxyUI.colorScheme.secondaryTextColor
        }
        
        textFields.forEach { (textField) in
            textField.autocorrectionType = .no
            textField.font = UIFont.menloBold14
            textField.textColor = HTTPProxyUI.colorScheme.primaryTextColor
        }
    }
    
    private func loadView(filter: HTTPProxyFilter) {
        nameTextField.text = filter.name
        schemeTextField.text = filter.requestFilter.scheme
        httpMethodTextField.text = filter.requestFilter.httpMethod
        
        if let host = filter.requestFilter.host {
            hostTextField.text = host
        }
        
        if let port = filter.requestFilter.port {
            portTextField.text = "\(port)"
        }
        
        if let queryItems = filter.requestFilter.queryItems {
            let pairs = queryItems.map { (arg0) -> String in
                let (name, value) = arg0
                return "\(name)=\(value ?? "")"
            }
            queryItemsTextField.text = pairs.joined(separator: "&")
        }
    }
}

extension UITextField {
    func validText() -> String? {
        if let text = self.text {
            let timmedString = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return timmedString.count > 0 ? timmedString : nil
        }
        return nil
    }
}
