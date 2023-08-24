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
    
    static func makeViewModel(
        currentResult result: RecordModel,
        statisticService: IStatisticService
    ) -> QuizResultsViewModel {
        .init(
            title: "alert_title".localized,
            text: """
                \("alert_message".localized) \(result.correctAnswers)/\(result.totalQuestions)
                \("alert_quiz_count".localized) \(statisticService.gamesCount)
                \("alert_record".localized) \(statisticService.record.correctAnswers)/\(statisticService.record.totalQuestions) (\(statisticService.record.date.dateTimeString))
                \("alert_average_accuracy".localized) \(String(format: "%.2f", statisticService.totalAccuracy))%
            """,
            buttonText: "alert_button_text".localized
        )
    }
}
