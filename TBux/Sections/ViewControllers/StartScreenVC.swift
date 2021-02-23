//
//  StartScreenVC.swift
//  TBux
//
//  Created by Pavle Mijatovic on 16/02/2021.
//

import UIKit

class StartScreenVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
    }

    @IBAction func openProductList(_ sender: Any) {
        navigationController?.pushViewController(UIStoryboard.productListTVC, animated: true)
    }
}
