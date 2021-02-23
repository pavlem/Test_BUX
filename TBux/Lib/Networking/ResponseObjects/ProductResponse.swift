//
//  ProductResponse.swift
//  TBux
//
//  Created by Pavle Mijatovic on 17/02/2021.
//

import Foundation

struct ProductResponse: Decodable {
    let symbol, displayName, securityId, quoteCurrency: String
    let displayDecimals, maxLeverage, multiplier: Int?
    let currentPrice, closingPrice: ProductResponsePrice?
    let dayRange, yearRange: ProductResponseRange?
    let openingHours: ProductResponseOpeningHours?
    let category: String
    let favorite: Bool?
    let productMarketStatus: String?
    let tags: [String]?
    let localizedMainTag: ProductResponseLocalizedMainTag?
    let description: String?
    let legalDocumentLink: String?
}

struct ProductResponsePrice: Decodable {
    let currency: String?
    let decimals: Int?
    let amount: String?
}

struct ProductResponseRange: Decodable {
    let currency: String?
    let decimals: Int?
    let high, low: String?
}

struct ProductResponseLocalizedMainTag: Decodable {
    let id, name: String?
}

struct ProductResponseOpeningHours: Decodable {
    let timezone: String?
    let weekDays: [[ProductResponseWeekDay]]?
}

struct ProductResponseWeekDay: Decodable {
    let start: String?
    let end: String?
}
