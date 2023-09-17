//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by MAKOVEY Vladislav on 17.09.2023.
//

import UIKit

protocol IMovieQuizPresenter {
    var viewController: MovieQuizViewController? { get set }
    
    func yesButtonTapped()
    func noButtonTapped()
    
    func didReceiveNextQuestion(question: QuizQuestionModel?)
    func showNextQuestionOrResult()
    func showNetworkError(message: String)
    
    func convert(model: QuizQuestionModel) -> QuizStepViewModel
    
    func updateCorrectAnswers()
}

final class MoviesQuizPresenter: IMovieQuizPresenter {
    // MARK: - Properties
    let questionFactory: IQuestionFactory
    weak var viewController: MovieQuizViewController?

    private let statisticService: IStatisticService = StatisticService()
    private lazy var alertPresenter: IAlertPresenter = AlertPresenter(controller: viewController)
    
    private var currentQuestion: QuizQuestionModel?
    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero

    // MARK: - Init
    init(questionFactory: IQuestionFactory) {
        self.questionFactory = questionFactory
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
                self.currentQuestionIndex = .zero
                self.correctAnswers = .zero
                
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
    
    func showNetworkError(message: String) {
        let alertModel = AlertModel(
            title: "alert_title_error".localized,
            message: message,
            buttonText: "alert_button_error_text".localized
        ) { [weak self] in
            guard let self else { return }
            
            self.currentQuestionIndex = .zero
            self.correctAnswers = .zero
            
            self.viewController?.showLoading()
            self.questionFactory.loadDataIfNeeded()
        }
        
        alertPresenter.showResult(model: alertModel)
    }
    
    func updateCorrectAnswers() {
        correctAnswers += 1
    }
    
    // MARK: - Private
    private func didAnswer(answer: Bool) {
        guard let currentQuestion else { return }
        let usersAnswer = answer
        viewController?.showAnswerResult(isCorrect: usersAnswer == currentQuestion.correctAnswer)
    }
}
