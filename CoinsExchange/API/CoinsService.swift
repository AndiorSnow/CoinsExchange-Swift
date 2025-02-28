//
//  CoinsService.swift
//  CoinsExchange
//
//  Created by LMC60018 on 2024/1/23.
//

import Foundation
import Combine

protocol CoinsActions {
    func fetchCoins(query: String?, offset: Int) -> AnyPublisher<[Coin], CoinsError>
}

class CoinsService: CoinsActions {
    
    private let defaultLimit = LOAD_NUMBER
    
    private let requestPath = "/coins"
    
    func fetchCoins(query: String?, offset: Int) -> AnyPublisher<[Coin], CoinsError> {
        return fetchCoins(query: query ?? "", limit: defaultLimit, offset: offset)
    }
    
    func fetchCoins(query searchItem: String?, limit: Int, offset: Int) -> AnyPublisher<[Coin], CoinsError> {
        let urlString = WEBSITE + requestPath
        var urlComponents = URLComponents(string: urlString)
        if let searchItem = searchItem, !searchItem.isEmpty {
            urlComponents?.queryItems = [URLQueryItem(name: "limit", value: "\(limit)"),
                                         URLQueryItem(name: "search", value: "\(searchItem)"),
                                         URLQueryItem(name: "offset", value: "\(offset)")]
        } else {
            urlComponents?.queryItems = [URLQueryItem(name: "limit", value: "\(limit)"),
                                         URLQueryItem(name: "offset", value: "\(offset)")]
        }

        var dataTask: URLSessionDataTask?
        
        let onSubscription: (Subscription) -> Void = { _ in dataTask?.resume() }
        let onCancel: () -> Void = { dataTask?.cancel() }
        
        return Future<[Coin], CoinsError> { promise in
            guard let url = urlComponents?.url else {
                
                promise(.failure(CoinsError.invalidURL(urlString)))
                return
            }
            
            var request: URLRequest = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("yhjMzLPhuIDl", forHTTPHeaderField: "referenceCurrencyUuid")
            request.addValue("24h", forHTTPHeaderField: "timePeriod")
            request.addValue("marketCap", forHTTPHeaderField: "orderBy")
            request.addValue("desc", forHTTPHeaderField: "orderDirection")
            request.setValue(API_KEY, forHTTPHeaderField: "apikey")

            dataTask = URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    promise(.failure(CoinsError.networking(error)))
                    return
                }
                guard let data = data else {
                    promise(.failure(CoinsError.noData))
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(CoinsResponse.self, from: data)
                    let coins = decoded.data.coins
                    promise(.success(coins))
                } catch {
                    print("Decoding failed with error: \(error)")
                    promise(.failure(CoinsError.decoding(error)))
                    return
                }
            }
        }
        .handleEvents(receiveSubscription: onSubscription, receiveCancel: onCancel)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
