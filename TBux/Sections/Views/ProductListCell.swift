//
//  ProductListCell.swift
//  TBux
//
//  Created by Pavle Mijatovic on 17/02/2021.
//

import UIKit

class ProductListCell: UITableViewCell {
    // MARK: - API
    var productVM: ProductVM? {
        willSet {
            setUI(productVM: newValue)
        }
    }

    // MARK: - Properties
    @IBOutlet weak var productNameLbl: UILabel!
    @IBOutlet weak var currencyLbl: UILabel!

    // MARK: Constants
    static let cellIdentifier = "ProductListCell_ID"

    // MARK: Helper
    private func setUI(productVM: ProductVM?) {
        guard let vm = productVM else { return }
        productNameLbl.text = vm.formatedName
        currencyLbl.text = vm.formatedPrice
        currencyLbl.textColor = vm.priceColor
        productNameLbl.textColor = vm.labelColor
        productNameLbl.font = vm.nameFont
        currencyLbl.font = vm.symbolFont
    }
}
