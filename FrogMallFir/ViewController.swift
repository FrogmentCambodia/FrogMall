//
//  ViewController.swift
//  FrogMallFir
//
//  Created by 阿瀬義弘 on 2018/05/03.
//  Copyright © 2018年 Frogment. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import GoogleSignIn

class ViewController: UIViewController,GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var mailText: UITextField!
    @IBOutlet weak var pwText: UITextField!
    @IBOutlet weak var mailUnderBar: UIView!
    @IBOutlet weak var pwUnderBar: UIView!
    
    @IBAction func forgetButton(_ sender: Any) {

    }
    @IBAction func logInButton(_ sender: Any) {
        let email = mailText.text ?? ""
        let password = pwText.text ?? ""
        showIndicator()
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let user = result?.user {
                print("***** SignUp is completed! -> \(user)")
                self.alertApper()
            }
            self.showErrorIfNeeded(error)
            print("***** finish login process")
        }
    }
    @IBOutlet weak var logInBar: UIButton!
    @IBAction func createButton(_ sender: Any) {
    }
    @IBOutlet weak var createBar: UIButton!
    @IBAction func tapGoogleSignIn(_ sender: Any) {
        showIndicator()
        GIDSignIn.sharedInstance().signIn()
    }
    var resultTag0 = false
    var resultTag1 = false
    let indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createBar.layer.borderWidth = 0.5
        createBar.layer.borderColor = UIColor.black.cgColor
        
        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: 300, height: 30)
        toolBar.sizeToFit()
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(UploadViewController.doneButton))
        toolBar.items = [space,doneButton]
        mailText.inputAccessoryView = toolBar
        pwText.inputAccessoryView = toolBar
        logInBar.isEnabled = false
        mailText.delegate = self
        pwText.delegate = self
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }

    @objc func doneButton(){
        self.view.endEditing(true)
    }

// Validation check for E-Mail
    func isValidEmail(latestSt:String) -> Bool {
        let existSt = mailText.text! + latestSt
        let emailRegEx = "[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailRegEx2 = "[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let emailTest2 = NSPredicate(format:"SELF MATCHES %@", emailRegEx2)
        let result = emailTest.evaluate(with: existSt)
        let result2 = emailTest2.evaluate(with: existSt)
        print("***** String check! -> \(existSt)")
        print("***** result check! -> \(result),\(result2)")
        if result||result2 {
            return true
        } else {
            return false
        }
    }
    
// Validation check for Password
    func isValidPW() -> Bool {
        let existCount = pwText.text?.count ?? 0
        if existCount < 4 {
            return false
        } else {
            return true
        }
    }
    
    private func showErrorIfNeeded(_ errorOrNil: Error?) {
        guard let error = errorOrNil else { return }
        
        let message = errorMessage(of: error)
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.indicator.stopAnimating()
        present(alert, animated: true, completion: nil)
    }
    
    private func errorMessage(of error: Error) -> String {
        var message = "Error is occurred!"
        guard let errcd = AuthErrorCode(rawValue: (error as NSError).code) else {
            return message
        }
        
        switch errcd {
        case .networkError: message = "Network Error!"
        case .userNotFound: message = "User is not found!"
        case .invalidEmail: message = "E-mail invalid error!"
        case .emailAlreadyInUse: message = "This E-mail is already used!"
        case .wrongPassword: message = "Password is wrong!"
        case .userDisabled: message = "This user is disabled!"
        case .weakPassword: message = "Password is wrong!"
        default: break
        }
        return message
    }
    
    func alertApper(){
        let message = "Login Completed!"
        let alertSheet1 = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alert1 = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            action in
            self.performSegue(withIdentifier: "ToCollectoin",sender: nil)
            print("**** Go to Home screen")
        })
        alertSheet1.addAction(alert1)
        self.indicator.stopAnimating()
        self.present(alertSheet1, animated: true, completion: nil)
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("**** Error: \(error.localizedDescription)")
            return
        }
        let authentication = user.authentication
        let credential = GoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,accessToken: (authentication?.accessToken)!)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
            self.indicator.stopAnimating()
            if error == nil {
                print("**** Google Login is Completed")
                self.alertApper()
            }
            self.showErrorIfNeeded(error)
            print("***** finish Google login process")
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("**** Google Logout successfully")
    }
    
    func showIndicator() {
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.center = self.view.center
        indicator.color = UIColor.black
        indicator.hidesWhenStopped = true
        self.view.addSubview(indicator)
        self.view.bringSubview(toFront: indicator)
        indicator.startAnimating()
    }
    
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            pwText.becomeFirstResponder()
            break
        case 1:
            textField.resignFirstResponder()
            break
        default:
            break
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        if (self.mailText.isFirstResponder) {
            self.mailText.resignFirstResponder()
        } else if (self.pwText.isFirstResponder) {
            self.pwText.resignFirstResponder()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("**** textField.tag : \(textField.tag)")
        if textField.tag == 0 {
            if isValidEmail(latestSt:string) {
                mailText.textColor = UIColor.black
                mailUnderBar.backgroundColor = UIColor.black
                resultTag0 = true
            } else {
                mailText.textColor = UIColor.red
                mailUnderBar.backgroundColor = UIColor.red
                resultTag0 = false
            }
        } else {
            if isValidPW() {
                pwText.textColor = UIColor.black
                pwUnderBar.backgroundColor = UIColor.black
                resultTag1 = true
            } else {
                pwText.textColor = UIColor.red
                pwUnderBar.backgroundColor = UIColor.red
                resultTag1 = false
            }
        }
        if resultTag0 && resultTag1 {
            logInBar.isEnabled = true
            logInBar.backgroundColor = UIColor.black
            print("***** Validation is success!")
            print("***** Validation resultTag0 -> \(resultTag0)")
            print("***** Validation resultTag1 -> \(resultTag1)")
        } else {
            logInBar.isEnabled = false
            logInBar.backgroundColor = UIColor.lightGray
            print("***** Validation is error!")
            print("***** Validation resultTag0 -> \(resultTag0)")
            print("***** Validation resultTag1 -> \(resultTag1)")
        }
        return true
    }
    
}




