//
//  ProfileViewController.swift
//  FrogMallFir
//
//  Created by 阿瀬義弘 on 2018/09/02.
//  Copyright © 2018年 Frogment. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
//import FirebaseAuthUI
import FirebaseStorage
//import FirebaseStorageUI
import FirebaseDatabase

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var topProfile: UIImageView!
    @IBOutlet weak var imageProfile: UIImageView!
    //    @IBOutlet weak var imageProfile: UIButton!
    @IBAction func imageBTProfile(_ sender: Any) {actionSheet()}
    @IBOutlet weak var nameProfile: UILabel!
    @IBOutlet weak var textIntro: UITextView!
    @IBAction func BackToHam(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func registButton(_ sender: Any) {registProfile()}
    var uid = ""
    var email = ""
    var photoURL:URL!
    var userName = ""
    var menuTableView:UITableView!
    var placeHolderIn = ""
    var ref1: DatabaseReference!
    var storage = Storage.storage()
    var accountData = Data()
    let indicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
/*
        let user = Auth.auth().currentUser
        if let user = user {
            uid = user.uid
            email = user.email!
            photoURL = user.photoURL
            userName = user.displayName!
        }
 */
        let topImage = UIImage(named: "background7")
        topProfile.image = topImage
        topProfile.contentMode = .scaleAspectFill
        topProfile.clipsToBounds = true
        getAccountImage()
        imageProfile.contentMode = .scaleAspectFill
        imageProfile.clipsToBounds = true
        imageProfile.layer.cornerRadius = imageProfile.frame.height / 2.0
        nameProfile.text = userName
        SDImageCache.shared().clearDisk()
        setupFirebase()

    }
    
    func setupFirebase() {
        ref1 = Database.database().reference()
        let ref2 = ref1.child("Account/\(uid)/info")
        ref2.queryLimited(toLast: 3).observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            self.placeHolderIn = value["Introduction"] as? String ?? ""
            self.textIntro.text = self.placeHolderIn
        })
    }
    
    func registProfile() {
        let intro = textIntro.text!
        let post1 = ["Introduction": intro]
        let ref2 = self.ref1.child("Account/\(uid)/info")
        ref2.updateChildValues(post1)
        alertSheets(alertCODE : "Success", alertMSG : "Update Completed!")
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
    
    func uploadAccountImage() {
        let storageRef = storage.reference(forURL: "gs://frogment-ccf72.appspot.com")
        let imageRef = storageRef.child("account/\(uid)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let reference = imageRef.child("AccountImage_" + (uid) + ".jpg")
        let uploadTask = reference.putData(accountData, metadata: metadata) { metaData, error in
            if let error = error {
                print("**** Upload error occurred!")
                print("**** \(error)")
                self.killUpload()
            }
        }
        uploadTask.observe(.success) { snapshot in
            self.getAccountImage()
            self.indicator.stopAnimating()
            self.accountData.removeAll()
            print("**** getAccountImage02_ success")
            self.alertSheets(alertCODE : "Success", alertMSG : "Upload Completed!")
        }
    }
    
    func getAccountImage() {
        SDImageCache.shared().clearDisk()
        SDImageCache.shared().clearMemory()
        let storageRef = storage.reference(forURL: "gs://frogment-ccf72.appspot.com")
        let imageRef = storageRef.child("account/\(uid)")
        let reference = imageRef.child("AccountImage_" + (uid) + ".jpg")
        let placeholderImage = UIImage(named: "NoImage2")
        self.imageProfile.sd_setImage(with: reference, placeholderImage: placeholderImage) { data, error, _, _ in
            if let error = error {
                print("**** getAccountImage_ error")
                print(error)
                if self.photoURL != nil {
                    self.imageProfile.sd_setImage(with: self.photoURL)
                } else {
                    print("**** no photoURL")
                }
            } else {
                print("**** getAccountImage01_ success")
            }
        }
    }
    
    func killUpload() {
        self.indicator.stopAnimating()
        alertSheets(alertCODE : "Error", alertMSG : "Please retry!")
        accountData.removeAll()
    }
    
    func actionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let action1 = UIAlertAction(title: "Select a picture", style: UIAlertActionStyle.default, handler: {
            action in
            self.pickImageFromLibrary()
        })
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            action in
        })
        actionSheet.addAction(action1)
        actionSheet.addAction(cancel)
        actionSheet.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func alertSheets(alertCODE : String, alertMSG : String) {
        let alertSheet1 = UIAlertController(title: alertCODE, message: alertMSG, preferredStyle: UIAlertControllerStyle.alert)
        let alert1 = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            action in
            print("**** alertMSG -> \(alertMSG)")
        })
        alertSheet1.addAction(alert1)
        self.present(alertSheet1, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textIntro.becomeFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        if (self.textIntro.isFirstResponder) {
            self.textIntro.resignFirstResponder()
        }
    }
}


extension ProfileViewController: UINavigationControllerDelegate {
    
    func pickImageFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
            present(controller, animated: true, completion: nil)
        }
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo
        info: [String : Any]) {
        showIndicator()
        if let data = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage] as! UIImage,0.1) {
            self.accountData = data
            uploadAccountImage()
            print("**** success to set Account data.")
        }
        dismiss(animated: true, completion: nil)
    }
    
}

