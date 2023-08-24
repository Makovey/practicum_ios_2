//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by MAKOVEY Vladislav on 23.08.2023.
//

import Foundation

protocol IStatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var record: RecordModel { get set }
    
    func storeAttempt(newResult: RecordModel)
}

final class StatisticService: IStatisticService {
    // MARK: - Properties
    var totalQuestions: Int {
        get {
            userDefaults.integer(forKey: Keys.totalQuestions.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.totalQuestions.rawValue)
        }
    }

    var correctAnswers: Int {
        get {
            userDefaults.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        Double(correctAnswers) / Double(totalQuestions) * 100
    }
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var record: RecordModel {
        get {
            guard let record: RecordModel = getValueFromUserDefault(forKey: .record) else {
                return .init(correctAnswers: 0, totalQuestions: 0, date: Date())
            }
            
            return record
        }
        set {
            setValueFromUserDefault(value: newValue, forKey: .record)
        }
    }
    
    private enum Keys: String {
        case record, gamesCount, totalQuestions, correctAnswers
    }

    private let userDefaults = UserDefaults.standard

    // MARK: - Methods
    func storeAttempt(newResult: RecordModel) {
        gamesCount += 1
        correctAnswers += newResult.correctAnswers
        totalQuestions += newResult.totalQuestions
        
        if newResult > record {
            record = newResult
        }
    }
    
    private func getValueFromUserDefault<T: Decodable>(forKey key: Keys) -> T? {
        guard let data = userDefaults.data(forKey: key.rawValue),
            let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        
        return decodedData
    }
    
    private func setValueFromUserDefault<T: Encodable>(value: T, forKey key: Keys) {
        guard let data = try? JSONEncoder().encode(value) else {
            print("Невозможно сохранить данные для значения - \(value)")
            return
        }
        
        userDefaults.set(data, forKey: key.rawValue)
    }
}
