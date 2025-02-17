//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by MAKOVEY Vladislav on 21.08.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)
}
