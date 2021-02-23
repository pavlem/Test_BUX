//
//  ProductDetailsVM.swift
//  TBux
//
//  Created by Pavle Mijatovic on 19/02/2021.
//

import UIKit

struct ProductDetailsVM {
    let id: String

    var isFetching: Bool = true
    var name = ""
    var currency = ""
    var category = ""
    var currentPrice = ""
    var closingPrice = ""
    var timeZone = ""
    var isWebSocketConnected = false
    var isChannelMonitored = false
    var description = ""
}

extension ProductDetailsVM {

    var isClosingPriceLarger: Bool {
        return ProductVM.isClosingPriceLarger(current: currentPrice, closing: closingPrice)
    }

    static func getDelta(currentPrice: String, closingPrice: String) -> String {
        let currentPriceDouble = Double(currentPrice)!
        let closingPriceDouble = Double(closingPrice)!
        var percent = ((100*currentPriceDouble) / closingPriceDouble) - 100
        percent = Double(round(1000*percent)/1000)
        return String(percent) + " %"
    }

    var deltaOfPriceInPercentage: String {
        ProductDetailsVM.getDelta(currentPrice: self.currentPrice, closingPrice: self.closingPrice)
    }

    var currentPriceDescription: String {
        return "Current:"
    }

    var currentPriceVal: String {
        let growthSymbol = ProductVM.growthSymbolForPrice(current: currentPrice, closing: closingPrice)
        return growthSymbol + " " + currentPrice.formatedNumber + " " + currencySymbol
    }

    var previousDayPrice: String {
        return "Previous:"
    }

    var previousDayPriceVal: String {
        return closingPrice.formatedNumber + " " + currencySymbol
    }

    var deltaInPrice: String {
        return "Difference:"
    }

    var priceColor: UIColor {
        return ProductVM.priceColor(current: currentPrice, closing: closingPrice)
    }

    var deltaInPriceVal: String {
        let growthSymbol = ProductVM.growthSymbolForPrice(current: currentPrice, closing: closingPrice)
        return growthSymbol + " " + deltaOfPriceInPercentage
    }

    var nameDescription: String {
        return name.uppercased()
    }

    var currencySymbol: String {
        return currency.getSymbolForCurrencyCode()
    }

    private var attributedTitle: [NSAttributedString.Key : NSObject] {
        let txtTitleFont = UIFont.buxBold17
        let txtColor = UIColor.buxPrimary

        let attTitle = [
            NSAttributedString.Key.font: txtTitleFont,
            NSAttributedString.Key.strokeColor: txtColor,
        ]
        return attTitle
    }


    private var attributedTxt: [NSAttributedString.Key : NSObject] {
        let txtColor = UIColor.buxPrimary
        let txtFont = UIFont.buxRegular

        let attTxt = [
            NSAttributedString.Key.font: txtFont,
            NSAttributedString.Key.strokeColor: txtColor,
        ]
        return attTxt
    }

    var attributedDetails: NSMutableAttributedString {

        let finalTxt = NSMutableAttributedString(string: "")

        let categoryDescription = NSMutableAttributedString(string: "Category: ")

        categoryDescription.addAttributes(attributedTitle, range: NSRange(location: 0, length: categoryDescription.length))

        let categoryMsg = NSMutableAttributedString(string: category + "\n\n")
        categoryMsg.addAttributes(attributedTxt, range: NSRange(location: 0, length: categoryMsg.length))

        let timezoneDescription = NSMutableAttributedString(string: "Timezone: ")
        timezoneDescription.addAttributes(attributedTitle, range: NSRange(location: 0, length: timezoneDescription.length))

        let timezoneMsg = NSMutableAttributedString(string: timeZone + "\n\n")
        timezoneMsg.addAttributes(attributedTxt, range: NSRange(location: 0, length: timezoneMsg.length))

        let txtDescription = NSMutableAttributedString(string: "Description: ")
        txtDescription.addAttributes(attributedTitle, range: NSRange(location: 0, length: txtDescription.length))

        let txtMsg = NSMutableAttributedString(string: description)
        txtMsg.addAttributes(attributedTxt, range: NSRange(location: 0, length: txtMsg.length))

        finalTxt.append(categoryDescription)
        finalTxt.append(categoryMsg)
        finalTxt.append(timezoneDescription)
        finalTxt.append(timezoneMsg)
        finalTxt.append(txtDescription)
        finalTxt.append(txtMsg)

        finalTxt.addAttribute(NSAttributedString.Key.foregroundColor, value: labelColor, range: NSRange(location: 0, length: finalTxt.length))

        return finalTxt
    }

    var nameFetching: String {
        return "Fetching for: " + name
    }

    var connectBtnTxt: String {
        return "Connect"
    }

    var disconnectBtnTxt: String {
        return "Disconnect"
    }

    var startLiveBtnTxt: String {
        return "Start live monitoring"
    }

    var stopLiveBtnTxt: String {
        return "Stop live monitoring"
    }

    var labelColor: UIColor {
        return UIColor.buxPrimary
    }

    var labelFont: UIFont {
        return UIFont.buxBold17
    }

    var priceFont: UIFont {
        return UIFont.buxBlack22
    }
}

extension ProductDetailsVM {

    init(productVM: ProductVM) {
        self.id = productVM.id
        self.name = productVM.name
    }

    init(productResponse: ProductResponse) {
        self.id = productResponse.securityId
        self.name = productResponse.displayName
        self.currency = productResponse.quoteCurrency
        self.category = productResponse.category
        self.currentPrice = productResponse.currentPrice?.amount ?? ""
        self.closingPrice = productResponse.closingPrice?.amount ?? ""
        self.timeZone = productResponse.openingHours?.timezone ?? ""
        self.isFetching = false
        self.description = productResponse.description ?? ""
    }
}
