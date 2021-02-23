//
//  ChannelStatusView.swift
//  TBux
//
//  Created by Pavle Mijatovic on 19/02/2021.
//

import UIKit

class StatusIndicator: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
        self.backgroundColor = .red
    }

    var isConnected: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.5) {
                self.backgroundColor = self.isConnected ? UIColor.buxGreen : UIColor.buxRed
            }
        }
    }
}
