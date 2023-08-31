//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by MAKOVEY Vladislav on 31.08.2023.
//

import Foundation

protocol IMoviesLoader {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, NetworkError>) -> Void)
}

struct MoviesLoader: IMoviesLoader {
    // MARK: - Properties
    private let networkError: INetworkClient = NetworkClient()
    
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl") // TODO: hide token
        }
        return url
    }
    
    // MARK: - Methods
    func loadMovies(handler: @escaping (Result<MostPopularMovies, NetworkError>) -> Void) {
        networkError.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(.parseError))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
