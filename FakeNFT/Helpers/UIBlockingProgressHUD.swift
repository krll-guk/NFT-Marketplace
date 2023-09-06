import UIKit
import ProgressHUD

protocol UIBlockingProgressHUDProtocol {
    func show()
    func dismiss()
}

final class UIBlockingProgressHUD: UIBlockingProgressHUDProtocol {
    private var window: UIWindow? {
        return UIApplication.shared.windows.first
    }

    private var isShown: Bool = false

    func show() {
        guard !isShown else { return }
        window?.isUserInteractionEnabled = false
        ProgressHUD.show()
        isShown = true
    }

    func dismiss() {
        guard isShown else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.window?.isUserInteractionEnabled = true
            ProgressHUD.dismiss()
            self.isShown = false
        }
    }
}
