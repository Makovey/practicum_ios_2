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
    
    func showNextQuestionOrResult()
    func loadDataIfNeeded()
    func convert(model: QuizQuestionModel) -> QuizStepViewModel
    
    func updateCorrectAnswers()
}

final class MoviesQuizPresenter: IMovieQuizPresenter {
    // MARK: - Properties
    weak var viewController: MovieQuizViewController?
    private lazy var questionFactory: IQuestionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
    private lazy var alertPresenter: IAlertPresenter = AlertPresenter(controller: viewController)
    private let moviesLoader: IMoviesLoader = MoviesLoader()
    private let statisticService: IStatisticService = StatisticService()
    
    private var currentQuestion: QuizQuestionModel?
    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
    }

    // MARK: Methods
    func convert(model: QuizQuestionModel) -> QuizStepViewModel {
        .init(
            image: UIImage(data: model.imageData) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionFactory.quantity)"
        )
    }
    
    func yesButtonTapped() {
        didAnswer(answer: true)
    }
    
    func noButtonTapped() {
        didAnswer(answer: false)
    }

    func showNextQuestionOrResult() {        
        currentQuestionIndex += 1
        questionFactory.fetchNextQuestion()
    }
            
    func updateCorrectAnswers() {
        correctAnswers += 1
    }
    
    func loadDataIfNeeded() {
        questionFactory.loadDataIfNeeded()
    }
    
    // MARK: - Private
    private func didAnswer(answer: Bool) {
        guard let currentQuestion else { return }
        let usersAnswer = answer
        viewController?.showAnswerResult(isCorrect: usersAnswer == currentQuestion.correctAnswer)
    }
    
    private func restartGame() {
        self.currentQuestionIndex = .zero
        self.correctAnswers = .zero
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
            
            let alertModel = AlertModel(
                title: alertViewModel.title,
                message: alertViewModel.text,
                buttonText: alertViewModel.buttonText
            ) { [weak self] in
                guard let self else { return }
                self.restartGame()
                self.questionFactory.resetQuestions()
                self.questionFactory.fetchNextQuestion()
            }
                 
            DispatchQueue.main.async { [weak self] in
                self?.alertPresenter.showResult(model: alertModel)
            }
            
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
        
        let alertModel = AlertModel(
            title: "alert_title_error".localized,
            message: error.titleMessage,
            buttonText: "alert_button_error_text".localized
        ) { [weak self] in
            guard let self else { return }
            self.restartGame()
            self.viewController?.showLoading()
            self.questionFactory.loadDataIfNeeded()
        }
        
        alertPresenter.showResult(model: alertModel)
    }
}
