//
//  String+Extensions.swift
//  MovieQuiz
//
//  Created by MAKOVEY Vladislav on 07.08.2023.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
