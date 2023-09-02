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
    
    var resizedImageURL: URL {
        let urlString = imageUrl.absoluteString
        let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
        
        guard let newURL = URL(string: imageUrlString) else {
            return imageUrl
        }
        
        return newURL
    }
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageUrl = "image"
    }
}
