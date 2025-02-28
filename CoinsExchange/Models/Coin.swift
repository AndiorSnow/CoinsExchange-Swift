//
//  CoinsModel.swift
//  CoinsExchange
//
//  Created by LMC60018 on 2024/1/23.
//

import Foundation

struct CoinsResponse: Decodable {
    let data: CoinsData
}

struct CoinsData: Decodable {
    let coins: [Coin]
}

struct CoinDetailResponse: Decodable {
    let data: CoinDetailData
}

struct CoinDetailData: Decodable {
    let coin: Coin
}

struct Coin: Equatable, Hashable, Decodable {
    var uuid: String
    var symbol: String?
    var name: String?
    var iconUrl: String?
    var price: String?
    var change: String?
    var color: String?
    var marketCap: String?
    var description: String?
    var websiteUrl: String?
}

extension Coin {
    init(coinsInfo: Coin) {
        self.uuid = coinsInfo.uuid
        self.symbol = coinsInfo.symbol
        self.name = coinsInfo.name
        self.iconUrl = coinsInfo.iconUrl
        self.price = coinsInfo.price
        self.change = coinsInfo.change
    }
    mutating func updataDetail(coinDetailInfo: Coin) {
        self.uuid = coinDetailInfo.uuid
        self.symbol = coinDetailInfo.symbol
        self.name = coinDetailInfo.name
        self.iconUrl = coinDetailInfo.iconUrl
        self.price = coinDetailInfo.price
        self.color = coinDetailInfo.color
        self.marketCap = coinDetailInfo.marketCap
        self.description = coinDetailInfo.description
        self.websiteUrl = coinDetailInfo.websiteUrl
    }
}
