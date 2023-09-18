//
//  MovieQuizViewControllerMock.swift
//  MovieQuizTests
//
//  Created by MAKOVEY Vladislav on 17.09.2023.
//

@testable import MovieQuiz
import XCTest

final class MovieQuizViewControllerMock: IMovieQuizViewController {
    func show(viewModel: MovieQuiz.QuizStepViewModel) {}
    
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    
    func eraseImageBorder() {}
    
    func showGameResult(with model: MovieQuiz.QuizResultsViewModel) {}
    
    func showNetworkError(with message: String) {}
    
    func showLoading() {}
    
    func hideLoading() {}
    
    func enableButtons() {}
    
    func disableButtons() {}
}
