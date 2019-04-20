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
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {
    
    @IBAction func imageButton(_ sender: Any) {
        self.performSegue(withIdentifier: "ToCollectoin",sender: nil)
//        checkLoggedIn2()
    }
    @IBAction func signOut(_ sender: Any) {
        signOut()
    }
        
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
//    let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
    let providers: [FUIAuthProvider] = [
        FUIGoogleAuth(),
        FUIFacebookAuth()
        ]
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLoggedIn()
//        let loginButton:FBSDKLoginButton = FBSDKLoginButton()
//        loginButton.center = self.view.center
//        self.view.addSubview(loginButton)
    }
    
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
}

extension ViewController: FUIAuthDelegate {
    
    func checkLoggedIn() {
        print("**** start_checkLoggedIn")
        self.setupLogin()
        handle = Auth.auth().addStateDidChangeListener{auth, user in
            if Auth.auth().currentUser != nil {
                print("**** Listener_success")
//                let vc = self.storyboard?.instantiateViewController(withIdentifier:"Menu")
//                self.present(vc!, animated: true, completion: nil)
//                print("**** present_New_VC")
            } else {
                print("**** Listener_fail")
                self.login()
            }
        }
    }
    
    func checkLoggedIn2() {
        handle = Auth.auth().addStateDidChangeListener{auth, user in
            if Auth.auth().currentUser != nil {
                print("**** Listener_success2")
                self.performSegue(withIdentifier: "ToCollectoin",sender: nil)
            } else {
                print("**** Listener_fail2")
                self.login()
            }
        }
    }
    
    func setupLogin() {
        authUI.delegate = self
        authUI.providers = providers
//        authUI.isSignInWithEmailHidden = true
        let kFirebaseTermsOfService = URL(string: "https://frogment-ccf72.firebaseapp.com")!
        authUI.tosurl = kFirebaseTermsOfService
        print("**** after_setupLogin")

    }
    
    func login() {
        let authViewController = authUI.authViewController()
        self.present(authViewController, animated: true, completion: nil)
        print("**** go_to_login")

    }
    
    func signOut() {
        let authUI = FUIAuth.defaultAuthUI()
        do {
            try authUI?.signOut()
            print("**** signOut")
        } catch {
            print("**** サインアウト失敗")
        }
        
    }

    
    
}






