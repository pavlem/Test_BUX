//
//  UIStoryboard+Extension.swift
//  TBux
//
//  Created by Pavle Mijatovic on 16/02/2021.
//

import UIKit

extension UIStoryboard {

    static var main: UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }

    static var startScreenVC: StartScreenVC { return UIStoryboard.main.instantiateViewController(withIdentifier: "StartScreenVC_ID") as! StartScreenVC }

    static var productListTVC: ProductListTVC { return UIStoryboard.main.instantiateViewController(withIdentifier: "ProductListTVC_ID") as! ProductListTVC }

    static var productDetailsVC: ProductDetailsVC { return UIStoryboard.main.instantiateViewController(withIdentifier: "ProductDetailsVC_ID") as! ProductDetailsVC }
}
