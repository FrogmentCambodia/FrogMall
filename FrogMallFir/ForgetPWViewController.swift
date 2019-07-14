//
//  ForgetPWViewController.swift
//  Frog Mall
//
//  Created by 阿瀬義弘 on 2019/04/22.
//  Copyright © 2019年 Frogment. All rights reserved.
//

import UIKit
import Firebase

class ForgetPWViewController: UIViewController {

    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var emailBar: UIView!
    @IBAction func submitButton(_ sender: Any) {
        let email = emailText.text ?? ""
        showIndicator()
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }
            if error == nil {
                print("***** Send E-mail!")
                self.alertApper()
            }
            print("***** Send E-mail2!")
            self.showErrorIfNeeded(error)
        }
    }
    @IBOutlet weak var submitBar: UIButton!
    var resultTag0 = false
    let indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: 300, height: 30)
        toolBar.sizeToFit()
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(UploadViewController.doneButton))
        toolBar.items = [space,doneButton]
        emailText.inputAccessoryView = toolBar
        emailText.delegate = self
        submitBar.isEnabled = false
    }
    
    @objc func doneButton(){
        self.view.endEditing(true)
    }
    
    private func showErrorIfNeeded(_ errorOrNil: Error?) {
        
        guard let error = errorOrNil else { return }
        print("***** Error is occurred! -> \(error)")

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
        let message = "Send E-mail!"
        let alertSheet1 = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alert1 = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            action in
            self.performSegue(withIdentifier: "ToCollectoin3",sender: nil)
        })
        alertSheet1.addAction(alert1)
        self.indicator.stopAnimating()
        self.present(alertSheet1, animated: true, completion: nil)
        
    }
    
    func isValidEmail(latestSt:String) -> Bool {
        let existSt = emailText.text! + latestSt
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

extension ForgetPWViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        if (self.emailText.isFirstResponder) {
            self.emailText.resignFirstResponder()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("**** textField.tag : \(textField.tag)")
        if isValidEmail(latestSt:string) {
            emailText.textColor = UIColor.black
            emailBar.backgroundColor = UIColor.black
            resultTag0 = true
        } else {
            emailText.textColor = UIColor.red
            emailBar.backgroundColor = UIColor.red
            resultTag0 = false
        }
        if resultTag0 {
            submitBar.isEnabled = true
            submitBar.backgroundColor = UIColor.black
            print("***** Validation is success!")
            print("***** Validation resultTag0 -> \(resultTag0)")
        } else {
            submitBar.isEnabled = false
            submitBar.backgroundColor = UIColor.lightGray
            print("***** Validation is error!")
            print("***** Validation resultTag0 -> \(resultTag0)")
        }
        return true
    }
    
}

