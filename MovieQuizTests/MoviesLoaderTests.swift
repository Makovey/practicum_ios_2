//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by MAKOVEY Vladislav on 15.09.2023.
//

@testable import MovieQuiz
import XCTest

final class MoviesLoaderTests: XCTestCase {
    func testSuccessLoading() throws {
        // arrange
        let networkClient = NetworkClientStub(isNeededError: false)
        let loader = MoviesLoader(networkClient: networkClient)
        let expectation = expectation(description: "Loading expectation")
        
        // act
        loader.loadMovies { result in
            // assert
            switch result {
            case .success(let movies):
                XCTAssertEqual(movies.items.count, 2)
                expectation.fulfill()
            case .failure:
                XCTFail("Loading is failed")
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFailureLoading() throws {
        // arrange
        let networkClient = NetworkClientStub(isNeededError: true)
        let loader = MoviesLoader(networkClient: networkClient)
        let expectation = expectation(description: "Loading expectation")
        
        // act
        loader.loadMovies { result in
            // assert
            switch result {
            case .success:
                XCTFail("Loading is success")
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1)
    }
}
