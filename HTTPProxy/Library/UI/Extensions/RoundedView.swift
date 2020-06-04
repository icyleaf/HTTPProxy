import UIKit

@IBDesignable class RoundedView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()

        updateCornerRadius()
    }
    
    @IBInspectable var cornerRadius: CGFloat = 4 {
        didSet {
            updateCornerRadius()
        }
    }

    func updateCornerRadius() {
        layer.cornerRadius = cornerRadius
    }
}
