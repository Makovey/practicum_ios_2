//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by MAKOVEY Vladislav on 31.08.2023.
//

import Foundation

struct MostPopularMovies: Decodable {
    let errorMessage: String
    let items: [MostPopularMovie]
}

struct MostPopularMovie: Decodable {
    let title: String
    let rating: String
    let imageUrl: URL
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageUrl = "image"
    }
}
