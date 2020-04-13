import UIKit

class RequestsListCell: UITableViewCell {
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var methodLabel: UILabel!
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var contentLabel: UILabel!
    @IBOutlet private var activityView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        containerView.backgroundColor = HTTPProxyUI.colorScheme.foregroundColor
        containerView.layer.shadowOpacity = 0.18
        containerView.layer.shadowOffset = CGSize(width: 2, height: 2)
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowColor = UIColor.clear.cgColor
        containerView.layer.cornerRadius = 8
        containerView.layer.borderColor = UIColor.clear.cgColor
        containerView.layer.borderWidth = 1
        containerView.layer.masksToBounds = false
        
        let boldFont = UIFont(name: "Menlo-Bold", size: 14.0)!
        titleLabel.font = boldFont
        titleLabel.textColor = HTTPProxyUI.colorScheme.secondaryTextColor
        
        methodLabel.font = boldFont
        methodLabel.layer.masksToBounds = true
        methodLabel.layer.cornerRadius = 8.0
        statusLabel.font = boldFont
        statusLabel.layer.masksToBounds = true
        statusLabel.layer.cornerRadius = 8.0
        
        activityView.color = HTTPProxyUI.colorScheme.primaryTextColor
    }
    
    func configure(with viewModel: SearchableListItem) {
        titleLabel.attributedText = formattedKey(viewModel.key)
        contentLabel.attributedText = formattedValue(viewModel.value)
        
        if let method = viewModel.method {
            methodLabel.text = method
            methodLabel.backgroundColor = .white
            methodLabel.textColor = .black
        } else {
            methodLabel.isHidden = true
        }
        
        if let requestStatus = viewModel.requestStatus {
            switch requestStatus {
            case .completed(let statusCode):
                statusLabel.backgroundColor = (statusCode >= 200 && statusCode < 300) ? #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1) : .red
                statusLabel.text = "\(statusCode)"
                statusLabel.isHidden = false
                activityView.isHidden = true
            case .error:
                statusLabel.backgroundColor = .red
                statusLabel.text = "Error"
                statusLabel.isHidden = false
                activityView.isHidden = true
            default:
                statusLabel.isHidden = true
                activityView.isHidden = false
                activityView.startAnimating()
            }
        } else {
            statusLabel.isHidden = true
            activityView.isHidden = true
        }
    }
    
    func emphasize(text: String) {
        emphasizeKey(text: text)
        emphasizeValue(text: text)
    }
    
    private func formattedKey(_ key: String) -> NSAttributedString {
        let attributes = [
            NSAttributedString.Key.font: UIFont.menloBold14,
            NSAttributedString.Key.foregroundColor: HTTPProxyUI.colorScheme.secondaryTextColor
        ]
        return NSAttributedString(string: "\(key)", attributes: attributes)
    }
    
    private func formattedValue(_ value: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        
        let attributes = [
            NSAttributedString.Key.font: UIFont.menlo14,
            NSAttributedString.Key.foregroundColor: HTTPProxyUI.colorScheme.primaryTextColor,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        return NSAttributedString(string: "\(value)", attributes: attributes)
    }
    
    private func emphasizeKey(text: String) {
        emphasizeText(text, label: contentLabel, font: UIFont.menloBold14, color: HTTPProxyUI.colorScheme.highlightedTextColor)
    }
    
    private func emphasizeValue(text: String) {
        emphasizeText(text, label: titleLabel, font: UIFont.menloBold14, color: HTTPProxyUI.colorScheme.highlightedTextColor)
    }
    
    private func emphasizeText(_ text: String, label: UILabel, font: UIFont, color: UIColor) {
        guard let attributedText = label.attributedText?.mutableCopy() as? NSMutableAttributedString else {
            return
        }
        
        guard let ranges = attributedText.string.lowercased().ranges(of: text) else {
            return
        }
        
        for range in ranges.map({ NSRange($0, in: attributedText.string) }) {
            let fontAttribute = [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.backgroundColor: color
            ]
            attributedText.addAttributes(fontAttribute, range: range)
        }
        
        label.attributedText = attributedText
    }
}
