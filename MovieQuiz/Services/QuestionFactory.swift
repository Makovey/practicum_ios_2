//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by MAKOVEY Vladislav on 20.08.2023.
//

import Foundation

private extension String {
    static let commonQuestion = "common_question".localized
}

protocol IQuestionFactory: AnyObject {
    var quantity: Int { get }
    func fetchNextQuestion()
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
    
    // MARK: - Init
    init(delegate: IQuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Methods
    func fetchNextQuestion() {
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        let question = questions[safe: index]
        delegate?.didReceiveNextQuestion(question: question)
    }
}
