import UIKit

protocol AlertHelperDelegate: AnyObject {
    func didMakeAlert(controller: UIAlertController)
}

struct AlertHelper {
    
    // MARK: Internal properties
    
    weak var delegate: AlertHelperDelegate?
    
    // MARK: Internal functions
    
    func makeAlertController(from model: AlertModel) {
        
        let controller = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        for actionModel in model.actions {
            
            let action = UIAlertAction(
                title: actionModel.title,
                style: actionModel.style,
                handler: actionModel.handler
            )
            controller.addAction(action)
            
            if actionModel.isPreferred {
                controller.preferredAction = action
            }
        }
        
        delegate?.didMakeAlert(controller: controller)
    }
    
    func makeRetryAlertModel(with action: @escaping (UIAlertAction) -> Void) -> AlertModel {
        let cancelActionModel = ActionModel(
            title: NSLocalizedString("", value: "Отменить", comment: ""),
            style: .cancel
        )
        let retryActionModel = ActionModel(
            title: NSLocalizedString("", value: "Повторить", comment: ""),
            handler: action,
            isPreferred: true
        )
        let alertModel = AlertModel(
            title: NSLocalizedString("", value: "Что-то пошло не так", comment: ""),
            message: NSLocalizedString("", value: "Попробовать ещё раз?", comment: ""),
            actions: [cancelActionModel, retryActionModel]
        )
        return alertModel
    }
}
