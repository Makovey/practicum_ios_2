//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by MAKOVEY Vladislav on 15.09.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }

    func testChangesPosterAndIndexWhenYesButtonTapped() throws {
        sleep(2)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        let firstIndexLabel = app.staticTexts["Index"].label

        app.buttons["Yes"].tap()

        sleep(2)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let secondIndexLabel = app.staticTexts["Index"].label

        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertNotEqual(firstIndexLabel, secondIndexLabel)
    }
    
    func testChangesPosterAndIndexWhenNoButtonTapped() throws {
        sleep(2)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        let firstIndexLabel = app.staticTexts["Index"].label

        app.buttons["No"].tap()

        sleep(2)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let secondIndexLabel = app.staticTexts["Index"].label

        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertNotEqual(firstIndexLabel, secondIndexLabel)
    }
    
    func testShowAlertWhenGameIsFinish() throws {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Game Results"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть еще раз")
    }
    
    func testDismissAlert() throws {
        sleep(2)
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Game Results"]
        XCTAssertTrue(alert.exists)
        
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        let indexLabel = app.staticTexts["Index"].label
        XCTAssertTrue(indexLabel == "1/10")
        XCTAssertFalse(alert.exists)
    }
}
