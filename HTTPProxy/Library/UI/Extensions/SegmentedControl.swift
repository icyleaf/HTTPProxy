import UIKit

@IBDesignable
class SegmentedControl: UISegmentedControl {
    // MARK: - Inspectables

    @IBInspectable var selectedTintColor: UIColor = .white {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var normalTintColor: UIColor = .lightGray {
        didSet { setNeedsDisplay() }
    }

    // MARK: - Internal

    @objc
    private func updateSegmentsColor() {
        if #available(iOS 13, *) {
            // Setting the divider image to empty image
            setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
            // Setting the background image to empty image
            setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
            // Setting the tintColor on the segment
            for (index, segment) in subviews.sorted(by: { $0.frame.minX < $1.frame.minX }).enumerated() {
                segment.tintColor = index == selectedSegmentIndex ? selectedTintColor : normalTintColor
            }
        } else {
            tintColor = .clear
            for (index, segment) in subviews.sorted(by: { $0.frame.minX < $1.frame.minX }).enumerated() {
                segment.subviews.first?.tintColor = index == selectedSegmentIndex ? selectedTintColor : normalTintColor
            }
        }
    }

    override func didMoveToSuperview() {
        if superview != nil {
            addTarget(self, action: #selector(updateSegmentsColor), for: .valueChanged)
        } else {
            removeTarget(self, action: #selector(updateSegmentsColor), for: .valueChanged)
        }

        updateSegmentsColor()
    }

    override func layoutSubviews() {
        tintColor = .clear
        super.layoutSubviews()
    }

}
