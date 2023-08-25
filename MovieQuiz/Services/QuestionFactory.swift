//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by MAKOVEY Vladislav on 20.08.2023.
//

import Foundation

private extension String {
    static let commonQuestion = "common_question_label".localized
}

protocol IQuestionFactory: AnyObject {
    var quantity: Int { get }
    func fetchNextQuestion()
    func resetQuestions()
}

protocol IQuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestionModel?)
}

final class QuestionFactory: IQuestionFactory {
    // MARK: - Properties
    var quantity: Int {
        questions.count
    }
    
    private weak var delegate: IQuestionFactoryDelegate?
    
    private var questions: [QuizQuestionModel] = [
        .init(image: "Vivarium", text: .commonQuestion, correctAnswer: false),
        .init(image: "The Godfather", text: .commonQuestion, correctAnswer: true),
        .init(image: "Old", text: .commonQuestion, correctAnswer: false),
        .init(image: "The Dark Knight", text: .commonQuestion, correctAnswer: true),
        .init(image: "Kill Bill", text: .commonQuestion, correctAnswer: true),
        .init(image: "Tesla", text: .commonQuestion, correctAnswer: false),
        .init(image: "The Avengers", text: .commonQuestion, correctAnswer: true),
        .init(image: "Deadpool", text: .commonQuestion, correctAnswer: true),
        .init(image: "The Green Knight", text: .commonQuestion, correctAnswer: true),
        .init(image: "The Ice Age Adventures of Buck Wild", text: .commonQuestion, correctAnswer: false)
    ]
    
    private var currentIndex = 0
    
    // MARK: - Init
    init(delegate: IQuestionFactoryDelegate) {
        self.delegate = delegate
        questions.shuffle()
    }
    
    // MARK: - Methods
    func fetchNextQuestion() {
        guard let question = questions[safe: currentIndex] else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        currentIndex += 1
        delegate?.didReceiveNextQuestion(question: question)
    }
    
    func resetQuestions() {
        currentIndex = 0
        questions.shuffle()
    }
}
