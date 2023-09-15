import UIKit

protocol AlertProtocol {
    func present(title: String?, message: String, actions: Alert.Action..., from controller: UIViewController)
}

struct Alert: AlertProtocol {
    func present(title: String?, message: String, actions: Alert.Action..., from controller: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alertController.addAction(action.alertAction)
        }
        controller.present(alertController, animated: true, completion: nil)
    }
}

extension Alert {
    enum Action {
        case cancel(handler: (() -> Void)?)
        case retry(handler: (() -> Void)?)

        private var title: String {
            switch self {
            case .cancel:
                return .ProfileErrorAlert.cancel
            case .retry:
                return .ProfileErrorAlert.retry
            }
        }

        private var handler: (() -> Void)? {
            switch self {
            case .cancel(let handler):
                return handler
            case .retry(let handler):
                return handler
            }
        }

        private var style: UIAlertAction.Style {
            switch self {
            case .cancel:
                return .destructive
            case .retry:
                return .default
            }
        }

        var alertAction: UIAlertAction {
            return UIAlertAction(title: title, style: style, handler: { _ in
                if let handler = self.handler {
                    handler()
                }
            })
        }
    }
}

enum AlertType {
    case updateError, loadError
}
