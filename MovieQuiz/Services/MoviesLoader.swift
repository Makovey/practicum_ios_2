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
    private let networkClient: INetworkClient
    
    init(networkClient: INetworkClient = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/\(ApiKeys.imdbDevKey.rawValue)") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    // MARK: - Methods
    func loadMovies(handler: @escaping (Result<MostPopularMovies, NetworkError>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    if !mostPopularMovies.errorMessage.isEmpty {
                        handler(.failure(.invalidToken))
                        return
                    }
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
