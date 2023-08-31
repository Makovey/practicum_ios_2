//
//  UIActivityIndicator+Extension.swift
//  MovieQuiz
//
//  Created by MAKOVEY Vladislav on 31.08.2023.
//

import UIKit

extension UIActivityIndicatorView {
    func showLoadingIndicator() {
        self.isHidden = false
        self.startAnimating()
    }
    
    func hideLoadingIndicator() {
        self.isHidden = true
        self.stopAnimating()
    }
}
