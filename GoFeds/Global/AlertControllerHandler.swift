//
//  AlertControllerHandler.swift
//  Imperial Beats
//
//  Created by Gaurav Tiwari on 28/12/17.
//  Copyright © 2017 Igniva Solutions Pvt Ltd. All rights reserved.
//

import UIKit

typealias NullableCompletion = (() -> ())?
typealias AlertButtonWithAction = (AlertButtonTitle, NullableCompletion)
typealias CompletionHandler = ((Int) -> Void)?

extension UIViewController {
    func showAlertWith(title: AlertTitle = .appName, message: Messages,
                       completionOPresentationOfAlert:  NullableCompletion = nil,
                       actions: AlertButtonWithAction...) {
        let alertController = UIAlertController(title: title.value, message: message.value, preferredStyle: UIAlertController.Style.alert)
        for (title, action) in actions {
            let alertAction = UIAlertAction(title: title.value, style:
            actions.count > 1 ? (title != .cancel ? .default : .default) : .default) { _ in
                if let actionToPerform = action {
                    actionToPerform()
                }
            }
            alertController.addAction(alertAction)
        }
        present(alertController, animated: true, completion: completionOPresentationOfAlert)
    }
}

extension UIViewController {
    
    func presentAlertWithTitle(title: Messages = .custom("GoFeds"), message: Messages, options: AlertButtonTitle..., completion: CompletionHandler = nil) {
        let alertController = UIAlertController(title: title.value, message: message.value, preferredStyle: .alert)
        
        for (index, option) in options.enumerated() {
            alertController.addAction(UIAlertAction.init(title: option.value, style: (options.count > 1 ? (option != .cancel ? .destructive : .cancel) : .default), handler: { (action) in
                if completion != nil{
                    completion!(index)
                }
            }))
        }
        if options.count == 0 {
            // delays execution of code to dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                alertController.dismiss(animated: true, completion: nil)
            })
        }
        self.present(alertController, animated: true, completion: nil)
    }
}
