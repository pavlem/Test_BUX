//
//  LiveMonitorBtn.swift
//  TBux
//
//  Created by Pavle Mijatovic on 18/02/2021.
//

import UIKit

class BuxBtn: UIButton {

    // MARK: - API
    var selectedStateTxt = ""
    var notSelectedStateTxt = ""

    // MARK: - Properties
    override open var isSelected: Bool {
        didSet {
            if self.isSelected {
                setTitle(selectedStateTxt, for: .normal)
            } else {
                setTitle(notSelectedStateTxt, for: .normal)
            }
        }
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        contentMode = .scaleToFill
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true

        setTitleColor(.white, for: .normal)
        setTitleColor(.white, for: .selected)
        backgroundColor = .darkGray
    }
}
