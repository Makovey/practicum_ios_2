//
//  QuizResultsViewModel.swift
//  MovieQuiz
//
//  Created by MAKOVEY Vladislav on 20.08.2023.
//

import Foundation

struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
    
    static func makeViewModel(correctAnswers: Int, quantity: Int) -> QuizResultsViewModel {
        .init(
            title: "alert_title".localized,
            text: "\("alert_message".localized) \(correctAnswers)/\(quantity)",
            buttonText: "alert_button_text".localized
        )
    }
}
