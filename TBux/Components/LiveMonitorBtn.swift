//
//  LiveMonitorBtn.swift
//  TBux
//
//  Created by Pavle Mijatovic on 18/02/2021.
//

import UIKit

class BuxBtn: UIButton {

    private let selectedStateTxt = "STOP LIVE"
    private let notSelectedStateTxt = "LIVE"

    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.orange.withAlphaComponent(0.7) : .orange
        }
    }

    override open var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.setTitle(selectedStateTxt, for: .normal)
            } else {
                self.setTitle(notSelectedStateTxt, for: .normal)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.contentMode = .scaleToFill
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true

        self.setTitleColor(.black, for: .normal)
        self.setTitleColor(.black, for: .selected)
        self.backgroundColor = .orange

        self.setTitle(notSelectedStateTxt, for: .normal)
        self.setTitle(selectedStateTxt, for: .selected)
    }
}
