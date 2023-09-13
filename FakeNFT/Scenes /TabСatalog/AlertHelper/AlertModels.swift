import UIKit

struct AlertModel {
    let title: String
    let message: String?
    let actions: Array<ActionModel>
}

struct ActionModel {
    let title: String
    var style: UIAlertAction.Style = .default
    var handler: ((UIAlertAction) -> Void)? = nil
    var isPreferred: Bool = false
}
