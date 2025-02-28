//
//  CoinDetailViewModel.swift
//  CoinsExchange
//
//  Created by LMC60018 on 2024/1/31.
//

import Foundation
import Combine

final class CoinDetailViewModel {
    
    @Published private(set) var detailCoin: Coin?

    private let coinDetailActions: CoinDetailActions
    private var bindings = Set<AnyCancellable>()
    
    init(coinDetailActions: CoinDetailActions = CoinDetailService()) {
        self.coinDetailActions = coinDetailActions
    }

    func setUpDetail(coinId: String) {
        fetchCoinDetail(coinId: coinId)
    }
}

extension CoinDetailViewModel {
    private func fetchCoinDetail(coinId: String) {
        
        let coinDetailValueHandler: (Coin) -> Void = { [weak self] detailCoin in
            self?.detailCoin = detailCoin
        }
        
        coinDetailActions
            .fetchCoinDetail(coinId: coinId)
            .sink(receiveCompletion: {_ in }, receiveValue: coinDetailValueHandler)
            .store(in: &bindings)
    }
}
