//
//  AlertVC.swift
//  OnTheMap
//
//  Created by Agnidhra Gangopadhyay on 3/4/20.
//  Copyright © 2020 Agnidhra Gangopadhyay. All rights reserved.
//

import Foundation
import UIKit
class AlertVC {
    class func getAlert(alertMessage: String) -> UIAlertController{
        let alert = UIAlertController(title: "Error", message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }
}
