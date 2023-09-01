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
    func loadData()
}

protocol IQuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestionModel?)
    func didLoadDataFromServer()
    func didFailToLoadDataFromServer(with error: NetworkError)
}

final class QuestionFactory: IQuestionFactory {
    // MARK: - Properties
    var quantity: Int {
        movies.count
    }
    
    private let moviesLoader: IMoviesLoader
    private weak var delegate: IQuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = .init()
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
            
            guard let movie = movies[safe: currentIndex] else {
                delegate?.didReceiveNextQuestion(question: nil)
                return
            }
            
            currentIndex += 1
            
            var imageData = Data()
           
           do {
                imageData = try Data(contentsOf: movie.imageUrl)
            } catch {
                print("Failed to load image") // TODO: error handling
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let text: String = .commonQuestion.localized
            let correctAnswer = rating > 6 // TODO: generate random questions
            
            let question = QuizQuestionModel(
                imageData: imageData,
                text: text,
                correctAnswer: correctAnswer
            )
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
        
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let mostPopularMovies):
                self.movies = mostPopularMovies.items.shuffled()
                self.delegate?.didLoadDataFromServer()
            case .failure(let error):
                self.delegate?.didFailToLoadDataFromServer(with: error)
            }
        }
    }
    
    func resetQuestions() {
        currentIndex = 0
        movies.shuffle()
    }
}
