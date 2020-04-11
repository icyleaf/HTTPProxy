import Highlightr
import UIKit

class TextViewerViewController: UIViewController {

    @IBOutlet private var textView: UITextView!
    @IBOutlet private var toolbar: UIToolbar!
    @IBOutlet private var stepper: UIStepper!

    private var text: String
    private var filename: String

    init(text: String, filename: String) {
        self.text = text
        self.filename = filename
        super.init(nibName: String(describing: TextViewerViewController.self), bundle: HTTPProxyPresenter.bundle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = filename
        toolbar.tintColor = HTTPProxyPresenter.shared.colorScheme.primaryTextColor
        toolbar.barTintColor = HTTPProxyPresenter.shared.colorScheme.foregroundColor
        stepper.minimumValue = 8
        stepper.maximumValue = 20
        stepper.value = 12
        setFontSize(12)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let activityIndicator = UIActivityIndicatorView(frame: textView.frame)
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        }
        activityIndicator.color = HTTPProxyPresenter.shared.colorScheme.primaryTextColor
        textView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        highlightedText(text) { highlightedText in
            DispatchQueue.main.async {
                self.textView.attributedText = highlightedText
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
    
    private func highlightedText(_ text: String, completionHandler: @escaping (NSAttributedString?) -> Void) {
        if let highlightr = Highlightr() {
            let theme = HTTPProxyPresenter.darkModeEnabled() ? "atom-one-dark" : "atom-one-light"
            highlightr.setTheme(to: theme)
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1, execute: {
                let highlightedText = highlightr.highlight(text)
                completionHandler(highlightedText)
                return
            })
         }
    }
    
    @IBAction private func share() {
        let activityItems = [textView.text]
        let activityController = UIActivityViewController(activityItems: activityItems as [Any], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction private func copyText() {
        UIPasteboard.general.string = textView.text
    }

    @IBAction private func changeFont(_ sender: UIStepper) {
        setFontSize(sender.value)
    }
    
    private func setFontSize(_ size: Double) {
        textView.font = UIFont(name: "Menlo", size: CGFloat(size))
    }
}
