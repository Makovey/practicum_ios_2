//
//  NetworkError.swift
//  MovieQuiz
//
//  Created by MAKOVEY Vladislav on 01.09.2023.
//

import Foundation

enum NetworkError: Error {
    case serverError
    case parseError
    case invalidToken
    case noInternetConnectionError
}

extension NetworkError {
    var titleMessage: String {
        switch self {
        case .noInternetConnectionError:
            return "internet_connection_error".localized
        default:
            return "unexpected_error".localized
        }
    }
}
