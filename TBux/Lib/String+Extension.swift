//
//  String+Extension.swift
//  TBux
//
//  Created by Pavle Mijatovic on 19/02/2021.
//

import Foundation

extension String {

    func getSymbolForCurrencyCode() -> String {
        let locale = NSLocale(localeIdentifier: self)
        if locale.displayName(forKey: .currencySymbol, value: self) == self {
            let newlocale = NSLocale(localeIdentifier: self.dropLast() + "_en")
            return newlocale.displayName(forKey: .currencySymbol, value: self) ?? ""
        }
        let symbol = locale.displayName(forKey: .currencySymbol, value: self)
        return symbol ?? ""
    }

    var formatedNumber: String {
        guard let doubleNumber = Double(self) else { return "" }
        let nsNUmber = NSNumber(value:doubleNumber)
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        guard let formattedAmount = formatter.string(from: nsNUmber) else { return ""}
        return formattedAmount
    }
}
