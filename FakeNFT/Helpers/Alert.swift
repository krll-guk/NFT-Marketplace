import UIKit

enum Alert {
    static var error: UIAlertController = {
        let alert = UIAlertController(title: .ProfileErrorAlert.title, message: .ProfileErrorAlert.message, preferredStyle: .alert)
        let action = UIAlertAction(title: .ProfileErrorAlert.button, style: .default)
        alert.addAction(action)
        return alert
    }()
}
