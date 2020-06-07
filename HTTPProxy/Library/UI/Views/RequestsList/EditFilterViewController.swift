import UIKit

class EditFilterViewController: UIViewController {

    var filter: HTTPProxyFilter!
    
    @IBOutlet private var backgroundViews: [RoundedView]!
    @IBOutlet private var labels: [UILabel]!
    @IBOutlet private var textFields: [UITextField]!
    
    @IBOutlet private var httpMethodTextField: UITextField!
    @IBOutlet private var schemeTextField: UITextField!
    @IBOutlet private var hostTextField: UITextField!
    @IBOutlet private var portTextField: UITextField!
    @IBOutlet private var queryItemsTextField: UITextField!

    override func viewDidLoad() {
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
            textField.font = UIFont.menloBold14
            textField.textColor = HTTPProxyUI.colorScheme.primaryTextColor
            
        }
        
        if let scheme = filter.requestFilter.scheme {
            schemeTextField.text = scheme
        }
        
        if let httpMethod = filter.requestFilter.httpMethod {
            httpMethodTextField.text = httpMethod
        }
        
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
