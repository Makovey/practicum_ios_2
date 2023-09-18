//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by MAKOVEY Vladislav on 15.09.2023.
//

@testable import MovieQuiz
import XCTest

final class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        // arrange
        let array = [1, 2, 3, 4, 5]
        
        // act
        let value = array[safe: 2]
        
        // assert
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 3)
    }
    
    func testGetValueOutOfRange() throws {
        // arrange
        let array = [1, 2, 3, 4, 5]
        
        // act
        let value = array[safe: 10]
        
        // assert
        XCTAssertNil(value)
    }
}
