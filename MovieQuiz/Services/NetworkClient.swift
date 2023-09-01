//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by MAKOVEY Vladislav on 31.08.2023.
//

import Foundation

protocol INetworkClient {
    func fetch(url: URL, handler: @escaping (Result<Data, NetworkError>) -> Void)
}

struct NetworkClient: INetworkClient {
    func fetch(url: URL, handler: @escaping (Result<Data, NetworkError>) -> Void) {
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                return handler(.failure(.noInternetConnectionError))
            }
            
            guard let response = response as? HTTPURLResponse,
                  (200...399).contains(response.statusCode) else {
                return handler(.failure(.serverError))
            }
            
            guard let data else { return }
            handler(.success(data))
            
        }.resume()
    }
}
