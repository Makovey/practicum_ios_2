//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by MAKOVEY Vladislav on 17.09.2023.
//

@testable import MovieQuiz
import XCTest

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        // arrange
        let mock = MovieQuizViewControllerMock()
        let presenter = MoviesQuizPresenter(viewController: mock)
        
        let question = QuizQuestionModel(imageData: Data(), text: "Question Text", correctAnswer: true)
        
        // act
        let viewModel = presenter.convert(model: question)
        
        // assert
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
    
}
