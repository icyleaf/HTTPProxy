import UIKit

extension UIWindow {

    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if let event = event,
            event.type == .motion,
            event.subtype == .motionShake {
            HTTPProxyPresenter.shared.handleShakeGesture()
        }
        super.motionEnded(motion, with: event)
    }
}
