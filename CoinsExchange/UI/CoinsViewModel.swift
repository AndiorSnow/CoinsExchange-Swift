//
//  CoinsExchangeViewModel.swift
//  CoinsExchange
//
//  Created by LMC60018 on 2024/1/23.
//

import Foundation
import Combine

enum CoinsViewModelError: Error, Equatable {
    case searchError
}

enum CoinsViewModelState: Equatable {
    case loading
    case finishedLoading
    case loadError
    case searchError
}

final class CoinsViewModel {
    
    @Published var coins: [Coin] = []
    @Published var searchCoins: [Coin] = []
    @Published var coinsOffset = 0
    @Published var searchCoinsOffset = 0
    @Published private(set) var state: CoinsViewModelState = .loading
    var currentSearchQuery: String = ""
    
    private let coinActions: CoinsActions
    private var bindings = Set<AnyCancellable>()
    
    init(coinActions: CoinsActions = CoinsService()) {
        self.coinActions = coinActions
    }
    
    func setUpCoins() {
        coinsOffset = 0
        fetchCoins(offset: coinsOffset)
        coinsOffset += LOAD_NUMBER
    }
    
    func continueSetUpCoins() {
        fetchCoins(offset: coinsOffset)
        coinsOffset += LOAD_NUMBER
    }
    
    func retrySetUpCoins() {
        fetchCoins(offset: coinsOffset)
    }
    
    func searchCoins(query: String) {
        searchCoinsOffset = 0
        searchCoins.removeAll()
        currentSearchQuery = query
        fetchCoins(query: query, offset: searchCoinsOffset)
        searchCoinsOffset += LOAD_NUMBER
    }
    
    func continueSearchCoins() {
        fetchCoins(query: currentSearchQuery, offset: searchCoinsOffset)
        searchCoinsOffset += LOAD_NUMBER
    }
    
    func retrySearchCoins() {
        fetchCoins(query: currentSearchQuery, offset: searchCoinsOffset)
    }
}

extension CoinsViewModel {
    private func fetchCoins(offset: Int) {
        state = .loading
        
        let coinsCompletionHandler: (Subscribers.Completion<CoinsError>) -> Void = { [weak self] completion in
            switch completion {
            case .failure:
                self?.state = .loadError
            case .finished:
                self?.state = .finishedLoading
            }
        }
        
        let coinsValueHandler: ([Coin]) -> Void = { [weak self] coins in
            self?.coins += coins
        }
        
        coinActions
            .fetchCoins(query: nil, offset: offset)
            .sink(receiveCompletion: coinsCompletionHandler, receiveValue: coinsValueHandler)
            .store(in: &bindings)
    }
    
    private func fetchCoins(query: String, offset: Int) {
        state = .loading
        
        let coinsCompletionHandler: (Subscribers.Completion<CoinsError>) -> Void = { [weak self] completion in
            switch completion {
            case .failure:
                self?.state = .searchError
            case .finished:
                self?.state = .finishedLoading
            }
        }
        
        let coinsValueHandler: ([Coin]) -> Void = { [weak self] coins in
            self?.searchCoins += coins
        }
        
        coinActions
            .fetchCoins(query: query, offset: offset)
            .sink(receiveCompletion: coinsCompletionHandler, receiveValue: coinsValueHandler)
            .store(in: &bindings)
    }
}
