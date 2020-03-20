//
//  AddStudentLocationViewController.swift
//  OnTheMap
//
//  Created by Agnidhra Gangopadhyay on 3/11/20.
//  Copyright © 2020 Agnidhra Gangopadhyay. All rights reserved.
//

import UIKit
import CoreLocation

class AddStudentLocationViewController: UIViewController {

    
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        subscribeToKeyBoardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyBoardNotifications()
    }
    
    @IBAction func tappedCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedFindButton(_ sender: Any) {
        guard let place = placeTextField.text, placeTextField.text?.count ?? 0 > 0 else {
            self.present(getAlert(alertMessage: "Please enter the Place details."), animated: true)
            return
        }
        guard linkTextField.text != "" else {
            self.present(getAlert(alertMessage: "Please enter the Link details."), animated: true)
            return
        }
        findGeoLocation(address: place)
    }
   
    func findGeoLocation(address: String){
        self.loadingIndicator.startAnimating()
        CLGeocoder().geocodeAddressString(address, completionHandler: {
            placemarks, error in
            
            if error != nil {
                self.loadingIndicator.stopAnimating()
                self.present(self.getAlert(alertMessage: "Invalid Location. Try again."), animated: true)
            } else {
                let placemark = placemarks?.first
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "NewLocationOnMapViewController") as! NewLocationOnMapViewController
                vc.pecker = placemark
                vc.placeName = self.placeTextField.text
                vc.mediaURL = self.linkTextField.text
                self.loadingIndicator.stopAnimating()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
    
    //MARK: Notification Functions
    @objc func keyboardWillShow(_ notification: Notification) {
        if(placeTextField.isEditing || linkTextField.isEditing) {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height/2
    }
    
    
    func subscribeToKeyBoardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyBoardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        linkTextField.endEditing(true)
        placeTextField.endEditing(true)
    }
}
