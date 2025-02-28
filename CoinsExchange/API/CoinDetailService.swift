//
//  CoinDetailService.swift
//  CoinsExchange
//
//  Created by LMC60018 on 2024/1/23.
//

import Foundation
import Combine

protocol CoinDetailActions {
    func fetchCoinDetail(coinId: String) -> AnyPublisher<Coin, CoinsError>
}

class CoinDetailService: CoinDetailActions {

    private let requestPath = "/coin/"
//    func fetchCoinDetail(coinId: String, completion: @escaping (Result<CoinDetailInfo, CoinsError>) -> Void) {
//        return fetchCoinDetail(coinId: coinId, completion: completion)
//    }
    
    func fetchCoinDetail(coinId: String) -> AnyPublisher<Coin, CoinsError> {
        
        let urlString = WEBSITE + requestPath + coinId
        var urlComponents = URLComponents(string: urlString)
        
        var dataTask: URLSessionDataTask?
        
        let onSubscription: (Subscription) -> Void = { _ in dataTask?.resume() }
        let onCancel: () -> Void = { dataTask?.cancel() }
        
        return Future<Coin, CoinsError> { promise in
            guard let url = urlComponents?.url else {
                promise(.failure(CoinsError.invalidURL(urlString)))
                return
            }
            
            var request: URLRequest = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("yhjMzLPhuIDl", forHTTPHeaderField: "referenceCurrencyUuid")
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
                    let decoded = try JSONDecoder().decode(CoinDetailResponse.self, from: data)
                    let coin = decoded.data.coin
                    promise(.success(coin))
                } catch {
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
