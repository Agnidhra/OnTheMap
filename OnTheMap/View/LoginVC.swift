//
//  ViewController.swift
//  OnTheMap
//
//  Created by Agnidhra Gangopadhyay on 3/3/20.
//  Copyright © 2020 Agnidhra Gangopadhyay. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin


class LoginVC: UIViewController, LoginButtonDelegate {
    
    //MARK: IBOutlets
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var appLoginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loginButton = FBLoginButton(permissions: [.publicProfile, .email])
    
        loginButton.delegate = self
        self.stackView.addArrangedSubview(loginButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        subscribeToKeyBoardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyBoardNotifications()
    }

    //MARK: IBActions
    @IBAction func tappedLoginButton(_ sender: Any) {
        setLoggingIn(true)
        var metCriteria: Bool = true
        
        guard let userName = userNameTextField.text, let password = passwordTextField.text else {
            metCriteria = false
            self.present(AlertVC.getAlert(alertMessage: "Invalid User Name or Password"), animated: true)
            setLoggingIn(false)
            return
        }
        
        if(!Utility.isValidEmail(email: userName)) {
            metCriteria = false
            self.present(AlertVC.getAlert(alertMessage: "Invalid User Name or Password"), animated: true)
            setLoggingIn(false)
        }
        
        if(metCriteria) {
            Client.authenticateUser(username: userName, password: password, completion: handleAuthResponse(callSuccess:errorMessage:error:))
        }
        
    }
    
    @IBAction func tappedSignUpButton(_ sender: Any) {
        setLoggingIn(true)
        let app = UIApplication.shared
        app.open(URL(string: "https://auth.udacity.com/sign-up")!, options: [:], completionHandler: nil)
        setLoggingIn(false)
    }
    
    func handleAuthResponse(callSuccess: Bool, errorMessage: String?, error: Error?) {
        if(callSuccess) {
            if let errorMessage = errorMessage {
                self.present(AlertVC.getAlert(alertMessage: errorMessage), animated: true)
                setLoggingIn(false)
            } else {
                Client.getStudentLocationDetails(limit: "100", orderBy: "-updatedAt", completion: handlestudentLocationDetailsRespone(responseData:error:))
            }
        } else {
            self.present(AlertVC.getAlert(alertMessage: "Something Went Wrong, Try Again."), animated: true)
            setLoggingIn(false)
        }
    }
    
    func handlestudentLocationDetailsRespone(responseData: StudentLocationDetails?, error: Error?){
        setLoggingIn(false)
        if let responseData = responseData {
            Client.studentLocationDetails.removeAll()
            Client.studentLocationDetails = responseData.results
            userNameTextField.text = ""
            passwordTextField.text = ""
            performSegue(withIdentifier: "loginComplete", sender: nil)
        } else {
            self.present(AlertVC.getAlert(alertMessage: "Something Went Wrong, Try Again."), animated: true)
            LoginManager().logOut()
            Client.studentLocationDetails.removeAll()
            Client.logOut()
        }
    }
    
    func loginButtonWillLogin(_ loginButton: FBLoginButton) -> Bool {
        setLoggingIn(true)
        return true
    }
    
    //MARK: Delegate Functions
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        setLoggingIn(false)
        if let result = result {
            if !result.isCancelled {
                if(result.token != nil){
                    Client.getStudentLocationDetails(limit: "100", orderBy: "-updatedAt", completion: handlestudentLocationDetailsRespone(responseData:error:))
                }
            }
        }
        if error != nil {
            self.present(AlertVC.getAlert(alertMessage: "Something Went Wrong, Try Again."), animated: true)
        }
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //No Action required for post Logout button
    }
    
    //MARK: Notification Functions
    @objc func keyboardWillShow(_ notification: Notification) {
        if(userNameTextField.isEditing || passwordTextField.isEditing) {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
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
        userNameTextField.endEditing(true)
        passwordTextField.endEditing(true)
    }
    
    func setLoggingIn(_ loggingIn: Bool){
        if(loggingIn) {
            activityIndicator.startAnimating();
        } else {
            activityIndicator.stopAnimating();
            
        }
        userNameTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        appLoginButton.isEnabled = !loggingIn
        appLoginButton.isEnabled = !loggingIn
        signUpButton.isEnabled = !loggingIn
    }
}
