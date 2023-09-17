//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by MAKOVEY Vladislav on 21.08.2023.
//

import UIKit

protocol IAlertPresenter {
    func showResult(model: AlertModel)
}

final class AlertPresenter: IAlertPresenter {
    // MARK: - Dependencies
    private weak var controller: UIViewController?
    
    // MARK: - Init
    init(controller: UIViewController?) {
        self.controller = controller
    }
    
    // MARK: - Methods
    func showResult(model: AlertModel) {
        guard let controller else { return }
        
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        alert.view.accessibilityIdentifier = "Game Results"
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        alert.addAction(action)
        
        DispatchQueue.main.async {
            controller.present(alert, animated: true, completion: nil)
        }
    }
}
