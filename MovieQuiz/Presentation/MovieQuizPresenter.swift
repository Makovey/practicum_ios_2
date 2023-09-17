//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by MAKOVEY Vladislav on 17.09.2023.
//

import UIKit

protocol IMovieQuizPresenter {
    var questionQuantity: Int { get }
    
    func convert(model: QuizQuestionModel) -> QuizStepViewModel
    func resetQuestionIndex()
    func switchToNextQuestion()
}

final class MoviesQuizPresenter: IMovieQuizPresenter {
    var questionQuantity: Int
    private var currentQuestionIndex: Int = .zero
    
    init(questionQuantity: Int) {
        self.questionQuantity = questionQuantity
    }
    
    func convert(model: QuizQuestionModel) -> QuizStepViewModel {
        .init(
            image: UIImage(data: model.imageData) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionQuantity)"
        )
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = .zero
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
}
