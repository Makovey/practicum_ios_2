//
//  UIActivityIndicator+Extension.swift
//  MovieQuiz
//
//  Created by MAKOVEY Vladislav on 31.08.2023.
//

import UIKit

extension UIActivityIndicatorView {
    func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.isHidden = false
            self.startAnimating()
        }
    }
    
    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.isHidden = true
            self.stopAnimating()
        }
    }
}
