//
//  CreateAccountViewController.swift
//  Frog Mall
//
//  Created by 阿瀬義弘 on 2019/04/21.
//  Copyright © 2019年 Frogment. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class CreateAccountViewController: UIViewController {

    var toolBar:UIToolbar!
    var gender = "male"
    var resultTag0 = false
    var resultTag1 = false
    var resultTag2 = false
    var resultTag3 = false
    var resultTag4 = false
    var resultTag6 = false
    var passwd = ""
    var passwdCon = ""
    let indicator = UIActivityIndicatorView()
    var datePicker: UIDatePicker = UIDatePicker()
    
    @IBOutlet weak var naviBar: UIView!
    @IBOutlet weak var baseView: UIView!
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var firstNameBar: UIView!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var lastNameBar: UIView!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var emailBar: UIView!
    @IBOutlet weak var pwText: UITextField!
    @IBOutlet weak var pwBar: UIView!
    @IBOutlet weak var pwConText: UITextField!
    @IBOutlet weak var pwConBar: UIView!
    @IBOutlet weak var genderText: UISegmentedControl!
    @IBAction func genderText2(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            gender = "male"
            print("***** gender -> male")
        case 1:
            gender = "female"
            print("***** gender -> female")
        default:
            break
        }
    }
    @IBOutlet weak var birthText: UITextField!
    @IBOutlet weak var birthBar: UIView!
    @IBAction func agreeButton(_ sender: Any) {
    }
    @IBOutlet weak var registerButton: UIButton!
    @IBAction func registerButton2(_ sender: Any) {
        let email = emailText.text ?? ""
        let password = pwText.text ?? ""
        let name = firstNameText.text! + " " + lastNameText.text!
        showIndicator()
        
        // To create new user
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let user = result?.user {
                let req = user.createProfileChangeRequest()
                req.displayName = name
                req.commitChanges() { [weak self] error in
                    guard let self = self else { return }
                    if error == nil {
                        user.sendEmailVerification() { [weak self] error in
                            guard let self = self else { return }
                            if error == nil {
                                let singleton :Singleton =  Singleton.sharedInstance
                                singleton.shareGender = self.gender
                                singleton.shareBirth = self.birthText.text ?? ""
                                print("***** SignUp is completed!")
                                print("***** Singleton -> \(singleton.shareGender),\(singleton.shareBirth)")
                                self.alertApper()
                            }
                            self.showErrorIfNeeded(error)
                        }
                    }
                    self.showErrorIfNeeded(error)
                }
            }
            self.showErrorIfNeeded(error)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35)
        toolBar.sizeToFit()
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBT))
        toolBar.items = [space,doneButton]

        firstNameText.inputAccessoryView = toolBar
        lastNameText.inputAccessoryView = toolBar
        emailText.inputAccessoryView = toolBar
        pwText.inputAccessoryView = toolBar
        pwConText.inputAccessoryView = toolBar
        
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale.current
        birthText.inputView = datePicker
        
        let toolBarForBirth = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spaceForBirth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButtonForBirth = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBTFotBirth))
        toolBarForBirth.setItems([spaceForBirth, doneButtonForBirth], animated: true)
        
        birthText.inputView = datePicker
        birthText.inputAccessoryView = toolBarForBirth
  
        registerButton.isEnabled = false
        
        firstNameText.delegate = self
        lastNameText.delegate = self
        emailText.delegate = self
        pwText.delegate = self
        pwConText.delegate = self
        birthText.delegate = self
    }
    
    func showErrorIfNeeded(_ errorOrNil: Error?) {
        guard let error = errorOrNil else { return }
        
        let message = errorMessage(of: error)
        print("***** error is \(error)")
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
            self.performSegue(withIdentifier: "ToCollectoin2",sender: nil)
            print("**** Go to Home screen")
        })
        alertSheet1.addAction(alert1)
        self.indicator.stopAnimating()
        self.present(alertSheet1, animated: true, completion: nil)
    }
    
    @objc func doneBTFotBirth() {
        birthText.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        birthText.text = "\(formatter.string(from: datePicker.date))"
        isValidBirth()
        isValidTotal()
    }
    
    @objc func doneBT(){
        self.view.endEditing(true)
        isValidTotal()
    }
    
    // Validation check for Firstname
    func isValidFN() {
        let existCount = firstNameText.text?.count ?? 0
        if existCount < 2 {
            firstNameText.textColor = UIColor.red
            firstNameBar.backgroundColor = UIColor.red
            resultTag0 = false
        } else {
            firstNameText.textColor = UIColor.black
            firstNameBar.backgroundColor = UIColor.black
            resultTag0 = true
        }
    }
    
    // Validation check for Lastname
    func isValidLN() {
        let existCount = lastNameText.text?.count ?? 0
        if existCount < 2 {
            lastNameText.textColor = UIColor.red
            lastNameBar.backgroundColor = UIColor.red
            resultTag1 = false
        } else {
            lastNameText.textColor = UIColor.black
            lastNameBar.backgroundColor = UIColor.black
            resultTag1 = true
        }
    }

    // Validation check for E-mail
    func isValidEmail(latestSt:String) {
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
            emailText.textColor = UIColor.black
            emailBar.backgroundColor = UIColor.black
            resultTag2 = true
        } else {
            emailText.textColor = UIColor.red
            emailBar.backgroundColor = UIColor.red
            resultTag2 = false
        }
    }
    
    // Validation check for Password
    func isValidPW(latestSt:String) {
        passwd = pwText.text! + latestSt
        let existCount = pwText.text?.count ?? 0
        if existCount < 6 {
            pwText.textColor = UIColor.red
            pwBar.backgroundColor = UIColor.red
            resultTag3 = false
        } else {
            pwText.textColor = UIColor.black
            pwBar.backgroundColor = UIColor.black
            resultTag3 = true
        }
    }
    
    // Validation check for Password confimation
    func isValidPWCon(latestSt:String) {
        passwdCon = pwConText.text! + latestSt
        print("***** pwText -> \(passwd)")
        print("***** passwdCon -> \(passwdCon)")
        if passwd == passwdCon {
            pwConText.textColor = UIColor.black
            pwConBar.backgroundColor = UIColor.black
            resultTag4 = true
        } else {
            pwConText.textColor = UIColor.red
            pwConBar.backgroundColor = UIColor.red
            resultTag4 = false
        }
    }
    
    // Validation check for Birthday
    func isValidBirth() {
        let birth = birthText.text ?? ""
        print("***** birth -> \(birth)")
        if birth == "" {
            birthText.textColor = UIColor.red
            birthBar.backgroundColor = UIColor.red
            resultTag6 = false
            print("***** birthtest 3!")
        } else {
            birthText.textColor = UIColor.black
            birthBar.backgroundColor = UIColor.black
            resultTag6 = true
            print("***** birthtest 4!")
        }
    }
    
    // Validation check for status
    func isValidTotal() {
        if resultTag0 && resultTag1 && resultTag2 && resultTag3 && resultTag4 && resultTag6 {
            registerButton.isEnabled = true
            registerButton.backgroundColor = UIColor.black
            print("***** Validation is success!")
        } else {
            registerButton.isEnabled = false
            registerButton.backgroundColor = UIColor.lightGray
            print("***** Validation is error!")
        }
        print("***** Validation resultTag0 -> \(resultTag0)")
        print("***** Validation resultTag1 -> \(resultTag1)")
        print("***** Validation resultTag2 -> \(resultTag2)")
        print("***** Validation resultTag3 -> \(resultTag3)")
        print("***** Validation resultTag4 -> \(resultTag4)")
        print("***** Validation resultTag6 -> \(resultTag6)")
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

extension CreateAccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            lastNameText.becomeFirstResponder()
            break
        case 1:
            emailText.becomeFirstResponder()
            break
        case 2:
            pwText.becomeFirstResponder()
            break
        case 3:
            pwConText.becomeFirstResponder()
            break
        case 4:
            textField.resignFirstResponder()
            break
        default:
            break
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        if (self.firstNameText.isFirstResponder) {
            self.firstNameText.resignFirstResponder()
        } else if (self.lastNameText.isFirstResponder) {
            self.lastNameText.resignFirstResponder()
        } else if (self.emailText.isFirstResponder) {
            self.emailText.resignFirstResponder()
        } else if (self.pwText.isFirstResponder) {
            self.pwText.resignFirstResponder()
        } else if (self.pwConText.isFirstResponder) {
            self.pwConText.resignFirstResponder()
        } else if (self.birthText.isFirstResponder) {
            self.birthText.resignFirstResponder()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("**** Change textField.tag : \(textField.tag)") 
        if textField.tag == 0 {
            isValidFN()
        } else if textField.tag == 1 {
            isValidLN()
        } else if textField.tag == 2 {
            isValidEmail(latestSt:string)
        } else if textField.tag == 3 {
            isValidPW(latestSt:string)
        } else if textField.tag == 4 {
            isValidPWCon(latestSt:string)
        } else if textField.tag == 6 {
            isValidBirth()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField:UITextField){
        print("**** end textField.tag : \(textField.tag)")
        if textField.tag == 0 {
            isValidFN()
        } else if textField.tag == 1 {
            isValidLN()
        } else if textField.tag == 2 {
            isValidEmail(latestSt:"")
        } else if textField.tag == 3 {
            isValidPW(latestSt:"")
        } else if textField.tag == 4 {
            isValidPWCon(latestSt:"")
        } else if textField.tag == 6 {
            isValidBirth()
        }
        isValidTotal()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("**** clear textField.tag : \(textField.tag)")
        if textField.tag == 0 {
            isValidFN()
        } else if textField.tag == 1 {
            isValidLN()
        } else if textField.tag == 2 {
            isValidEmail(latestSt:"")
        } else if textField.tag == 3 {
            isValidPW(latestSt:"")
        } else if textField.tag == 4 {
            isValidPWCon(latestSt:"")
        } else if textField.tag == 6 {
            isValidBirth()
        }
        isValidTotal()
        return true
    }

    
}
