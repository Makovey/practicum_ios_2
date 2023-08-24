//
//  RecordModel.swift
//  MovieQuiz
//
//  Created by MAKOVEY Vladislav on 23.08.2023.
//

import Foundation

struct RecordModel: Codable {
    let correctAnswers: Int
    let totalQuestions: Int
    let date: Date
    
    private var accuracy: Double {
        guard totalQuestions != 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }
}

// MARK: - Comparable
extension RecordModel: Comparable {
    static func < (lhs: RecordModel, rhs: RecordModel) -> Bool {
        lhs.accuracy < rhs.accuracy
    }
}
