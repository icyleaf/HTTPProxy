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
    @IBOutlet private var headerFieldsTextField: UITextField!

    @IBOutlet weak var tableViewBottomLayoutConstraint: NSLayoutConstraint!
    private var tableViewBottonInset: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = saveButton

        setupView()
        tableViewBottonInset = tableViewBottomLayoutConstraint.constant

        if let filter = filter {
            loadView(filter: filter)
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

        tableViewBottomLayoutConstraint.constant = -bottomInset
    }

    @objc
    private func keyboardWillDisappear(notification: NSNotification?) {
        tableViewBottomLayoutConstraint.constant = tableViewBottonInset
    }
    
    @objc func save() {
        guard let name = nameTextField.validText() else {
            showError(message: "Field 'name' cannot be empty")
            return
        }
        var requestFilter = RequestFilter()
        requestFilter.scheme = schemeTextField.validText()
        if let scheme = requestFilter.scheme {
            if !(scheme == "http" || scheme == "https") {
                showError(message: "Invalid value for field 'scheme'. Supported values: 'http' or 'https'")
                return
            }
        }
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
        
        if let items = headerFieldsTextField.validText() {
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
                requestFilter.headerFields = queryItems
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
            textField.delegate = self
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
        
        if let headerFields = filter.requestFilter.headerFields {
            let pairs = headerFields.map { (arg0) -> String in
                let (name, value) = arg0
                return "\(name)=\(value ?? "")"
            }
            headerFieldsTextField.text = pairs.joined(separator: "&")
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .actionSheet)
        present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}

extension EditFilterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
