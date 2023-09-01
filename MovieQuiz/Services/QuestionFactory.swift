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
    func loadDataIfNeeded()
}

protocol IQuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestionModel?)
    func didLoadDataFromServer()
    func didFailToLoadDataFromServer(with error: NetworkError)
}

final class QuestionFactory: IQuestionFactory {
    // MARK: - Properties
    var quantity: Int {
        moviesToShow.count
    }
    
    private let moviesLoader: IMoviesLoader
    private weak var delegate: IQuestionFactoryDelegate?
    private var allMovies: [MostPopularMovie] = []
    private var moviesToShow: [MostPopularMovie] = []
    private var currentIndex = 0
    
    // MARK: - Init
    init(
        moviesLoader: IMoviesLoader,
        delegate: IQuestionFactoryDelegate
    ) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    // MARK: - Methods
    func fetchNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            guard let movie = moviesToShow[safe: currentIndex] else {
                delegate?.didReceiveNextQuestion(question: nil)
                return
            }
            
            currentIndex += 1
            
            var imageData = Data()
           
           do {
               imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                delegate?.didFailToLoadDataFromServer(with: .parseError)
            }
            
            let movieRating = Float(movie.rating) ?? 0
            
            let randomRating = Int.random(in: 6...9)
            let questionText = "\(String.commonQuestion.localized) \(randomRating)?"
            let correctAnswer = Int(movieRating) >= randomRating
            
            let question = QuizQuestionModel(
                imageData: imageData,
                text: questionText,
                correctAnswer: correctAnswer
            )
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
        
    }
    
    func loadDataIfNeeded() {
        guard allMovies.isEmpty else {
            self.delegate?.didLoadDataFromServer()
            return
        }

        moviesLoader.loadMovies { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let mostPopularMovies):
                self.allMovies = mostPopularMovies.items.shuffled()
                self.moviesToShow = Array(allMovies.prefix(10))
                self.delegate?.didLoadDataFromServer()
            case .failure(let error):
                self.delegate?.didFailToLoadDataFromServer(with: error)
            }
        }
    }
    
    func resetQuestions() {
        currentIndex = 0
        moviesToShow = Array(allMovies.shuffled().prefix(10))
    }
}
