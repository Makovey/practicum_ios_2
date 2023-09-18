//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by MAKOVEY Vladislav on 17.09.2023.
//

import UIKit

protocol IMovieQuizPresenter {
    func yesButtonTapped()
    func noButtonTapped()
    
    func loadDataIfNeeded()
    func convert(model: QuizQuestionModel) -> QuizStepViewModel
    func restartGame()
}

final class MoviesQuizPresenter: IMovieQuizPresenter {
    private struct Constants {
        static let delay = 1.5
        static let basicQuantityOfQuestion = 10
    }
    
    // MARK: - Properties
    weak var viewController: IMovieQuizViewController?
    private lazy var questionFactory: IQuestionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
    private let moviesLoader: IMoviesLoader = MoviesLoader()
    private let statisticService: IStatisticService = StatisticService()
    
    private var currentQuestion: QuizQuestionModel?
    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero
    
    init(viewController: IMovieQuizViewController) {
        self.viewController = viewController
    }

    // MARK: Methods
    func convert(model: QuizQuestionModel) -> QuizStepViewModel {
        let quantity = questionFactory.quantity == .zero ? Constants.basicQuantityOfQuestion: questionFactory.quantity
        
        return .init(
            image: UIImage(data: model.imageData) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(quantity)"
        )
    }
    
    func yesButtonTapped() {
        didAnswer(answer: true)
    }
    
    func noButtonTapped() {
        didAnswer(answer: false)
    }
    
    func loadDataIfNeeded() {
        viewController?.showLoading()
        questionFactory.loadDataIfNeeded()
    }
    
    func restartGame() {
        currentQuestionIndex = .zero
        correctAnswers = .zero
        questionFactory.resetQuestions()
        questionFactory.fetchNextQuestion()
    }
    
    // MARK: - Private
    private func didAnswer(answer: Bool) {
        guard let currentQuestion else { return }
        let usersAnswer = answer
        showAnswerResult(isCorrect: usersAnswer == currentQuestion.correctAnswer)
    }
    
    private func showNextQuestionOrResult() {
        currentQuestionIndex += 1
        questionFactory.fetchNextQuestion()
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        viewController?.disableButtons()
        
        if isCorrect { correctAnswers += 1 }
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delay) { [weak self] in
            guard let self else { return }
            self.viewController?.enableButtons()
            self.viewController?.eraseImageBorder()
            self.showNextQuestionOrResult()
        }
    }
}

// MARK: - IQuestionFactoryDelegate
extension MoviesQuizPresenter: IQuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestionModel?) {
        guard let question else {
            let currentResult = RecordModel(
                correctAnswers: correctAnswers,
                totalQuestions: questionFactory.quantity,
                date: Date()
            )
            
            statisticService.storeAttempt(newResult: currentResult)
            
            let alertViewModel = QuizResultsViewModel.makeViewModel(
                currentResult: currentResult,
                statisticService: statisticService
            )
            
            viewController?.showGameResult(with: alertViewModel)
            
            return
        }
        
        currentQuestion = question
        
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(viewModel: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoading()
        questionFactory.fetchNextQuestion()
    }
    
    func didFailToLoadDataFromServer(with error: NetworkError) {
        viewController?.hideLoading()
        viewController?.showNetworkError(with: error.titleMessage)
    }
}
