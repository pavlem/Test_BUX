//
//  ProductVM.swift
//  TBux
//
//  Created by Pavle Mijatovic on 17/02/2021.
//

import UIKit

struct ProductVM {
    
    let name: String
    let currency: String
    let id: String
    let category: String
    let currentPrice: String
    let closingPrice: String

    static let productsTitle = "Products"
    static let productsFetching = "Fetching..."
    static let searchForProducts = "Search Product..."

    var currencySymbol: String {
        return currency.getSymbolForCurrencyCode()
    }

    var formatedCurrency: String {
        return currentPrice.formatedNumber
    }

    var formatedPrice: String {
        return ProductVM.growthSymbolForPrice(current: self.currentPrice, closing: self.closingPrice) + " " + formatedCurrency + " " + currencySymbol
    }

    var formatedName: String {
        return self.name + " (\(self.currency))"
    }

    var priceColor: UIColor {
        return ProductVM.priceColor(current: currentPrice, closing: closingPrice)
    }

    var labelColor: UIColor {
        return UIColor.buxPrimary
    }

    var nameFont: UIFont {
        return UIFont.buxBold16
    }

    var symbolFont: UIFont {
        return UIFont.buxBlack22
    }

    private var isClosingPriceLarger: Bool {
        return ProductVM.isClosingPriceLarger(current: currentPrice, closing: closingPrice)
    }
}

extension ProductVM {

    init(productResponse: ProductResponse) {
        self.name = productResponse.displayName
        self.currency = productResponse.quoteCurrency
        self.id = productResponse.securityId
        self.category = productResponse.category
        self.currentPrice = productResponse.currentPrice?.amount ?? ""
        self.closingPrice = productResponse.closingPrice?.amount ?? ""
    }
}

extension ProductVM {

    static func isClosingPriceLarger(current: String, closing: String) -> Bool {
        guard let currentPriceDouble = Double(current), let closingPriceDouble = Double(closing) else { return false }
        return (closingPriceDouble - currentPriceDouble) > 0
    }

    static func growthSymbolForPrice(current: String, closing: String) -> String {
        guard current != closing else { return "◼︎" }
        return isClosingPriceLarger(current: current, closing: closing) ? "▼" : "▲"
    }

    static func priceColor(current: String, closing: String) -> UIColor {
        guard current != closing else { return UIColor.buxPrimary }
        return ProductVM.isClosingPriceLarger(current: current, closing: closing) ? UIColor.buxRed : UIColor.buxGreen
    }
}




