import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }

    private static var isShown: Bool = false

    static func show() {
        guard !isShown else { return }
        window?.isUserInteractionEnabled = false
        ProgressHUD.show()
        isShown = true
    }

    static func dismiss() {
        guard isShown else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            window?.isUserInteractionEnabled = true
            ProgressHUD.dismiss()
            isShown = false
        }
    }
}
