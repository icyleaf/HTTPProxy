import UIKit

protocol RequestDetailsViewControllerDelegate: class {

    func viewController(index: Int) -> UIViewController
}

class RequestDetailsViewController: UIViewController {

    var delegate: RequestDetailsViewControllerDelegate!

    @IBOutlet private var segmentedControl: SegmentedControl! {
        didSet {
            let titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: HTTPProxyUI.colorScheme.primaryTextColor
            ]

            segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
            segmentedControl.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        }
    }
    @IBOutlet private var indicatorView: UIView!
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var segmentedView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = HTTPProxyUI.colorScheme.backgroundColor
        segmentedView.backgroundColor = HTTPProxyUI.colorScheme.foregroundColor
        indicatorView.backgroundColor = HTTPProxyUI.colorScheme.selectedColor

        updateChildViewController(0)
        updateIndicatorFrame()
    }
    
    @objc func close() {
       dismiss(animated: true, completion: nil)
    }

    // MARK: - Actions

    @IBAction private func selectedAction() {
        updateChildViewController(segmentedControl.selectedSegmentIndex)
        UIView.animate(withDuration: 0.2, animations: updateIndicatorFrame)
    }

    // MARK: - Layout

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.updateIndicatorFrame()
        }, completion: { _ in
            self.updateIndicatorFrame()
        })
    }

    // MARK: -

    private func updateChildViewController(_ index: Int) {
        let old = children.first
        let new = delegate.viewController(index: index)

        old?.willMove(toParent: nil)
        addChild(new)

        old?.view.removeFromSuperview()

        contentView.addSubview(new.view)
        var frame = contentView.frame
        frame.origin = CGPoint.zero
        new.view.frame = frame

        new.didMove(toParent: self)
        old?.removeFromParent()
    }

    // MARK: - Helpers

    private func updateIndicatorFrame() {
        guard segmentedControl != nil else { return }

        let width = segmentedControl.bounds.width / CGFloat(segmentedControl.numberOfSegments)
        let offset = width * CGFloat(segmentedControl.selectedSegmentIndex)
        let rect = CGRect(x: offset + width / 4, y: segmentedControl.bounds.height - 2, width: width / 2, height: 2)

        indicatorView.frame = rect
    }
}
