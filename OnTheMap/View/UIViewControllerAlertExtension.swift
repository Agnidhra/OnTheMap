//
//  UIViewControllerAlertExtension.swift
//  OnTheMap
//
//  Created by Agnidhra Gangopadhyay on 3/20/20.
//  Copyright © 2020 Agnidhra Gangopadhyay. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func getAlert(alertMessage: String) -> UIAlertController{
        let alert = UIAlertController(title: "Error", message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }
}
