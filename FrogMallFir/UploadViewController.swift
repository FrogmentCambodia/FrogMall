//
//  UploadViewController.swift
//  FrogMallFir
//
//  Created by 阿瀬義弘 on 2018/05/06.
//  Copyright © 2018年 Frogment. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
//import FirebaseAuthUI
//import FirebaseGoogleAuthUI
import FirebaseDatabase

class UploadViewController: UIViewController {
    
    var ref1: DatabaseReference!
    var countDB: Int = 0
    var countDBs: String = ""
    var countPhoto:String = ""
    var setCell = ""
    let sectionUp = ["item category", "area"]
    var section00 = ["(Select category)"]
    var section01 = ["(Select area)"]
    var inputTableView:UITableView!
    var uploadTemp:UIImage!
    var actionNo = 0
    var action1Status = 0
    var action2Status = 0
    var action3Status = 0
    var upData1 = Data()
    var upData2 = Data()
    var upData3 = Data()
    let indicator = UIActivityIndicatorView()
    var uid = ""
    var email = ""
    var photoURL:URL!
    var userName = ""
    
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
    let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
    var handle: AuthStateDidChangeListenerHandle?
    var loginSt = 0

    @IBOutlet weak var upButton01: UIButton!
    @IBOutlet weak var upButton02: UIButton!
    @IBOutlet weak var upButton03: UIButton!
    @IBAction func upButton1(_ sender: Any) {actionSheet(acNo: 1)}
    @IBAction func upButton2(_ sender: Any) {actionSheet(acNo: 2)}
    @IBAction func upButton3(_ sender: Any) {actionSheet(acNo: 3)}
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var descTF: UITextView!
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet weak var tabBarCame: UITabBarItem!
    @IBAction func upload(_ sender: Any) {
        checkLoggedIn2()
        if loginSt == 1 {
            checkInput()
        }
    }
    @IBAction func returnToMe(segue: UIStoryboardSegue) { }
    @IBAction func returnToMe2(segue: UIStoryboardSegue) { }

    override func viewDidLoad() {
        super.viewDidLoad()
//        let ud = UserDefaults.standard
//        ud.set(0, forKey: "count")
        setupFirebase()
        inputTableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 140), style: .grouped)
        inputTableView.frame.origin.y = priceTF.frame.maxY + 1
        inputTableView.delegate = self
        inputTableView.dataSource = self
        inputTableView.isScrollEnabled = false
        self.view.addSubview(inputTableView)
        
        titleTF.layer.borderWidth = 0.5
        descTF.layer.borderWidth = 0.5
        priceTF.layer.borderWidth = 0.5
        titleTF.layer.borderColor = UIColor(red: 199.68 / 255.0, green: 199.68 / 255.0, blue: 204.8 / 255.0, alpha: 1.0).cgColor
        descTF.layer.borderColor = UIColor(red: 199.68 / 255.0, green: 199.68 / 255.0, blue: 204.8 / 255.0, alpha: 1.0).cgColor
        priceTF.layer.borderColor = UIColor(red: 199.68 / 255.0, green: 199.68 / 255.0, blue: 204.8 / 255.0, alpha: 1.0).cgColor
        
        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: 300, height: 30)
        toolBar.sizeToFit()
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(UploadViewController.doneButton))
        toolBar.items = [space,doneButton]
        titleTF.inputAccessoryView = toolBar
        descTF.inputAccessoryView = toolBar
        priceTF.inputAccessoryView = toolBar

        titleTF.delegate = self
        descTF.delegate = self
        priceTF.delegate = self
        let user = Auth.auth().currentUser
        if let user = user {
            uid = user.uid
            email = user.email!
            photoURL = user.photoURL
            userName = user.displayName!
            print("**** user is \(uid)")
            print("**** email is \(email)")
        }
        
        checkLoggedIn()
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        inputTableView.frame.origin.y = priceTF.frame.maxY + 1
    }
    
    @objc func doneButton(){
        self.view.endEditing(true)
    }

    func updateCount() {
        self.countDB = Int(self.countDBs)! + 1
        print("**** new countDB -> \(self.countDB)")
    }

    func setupFirebase() {
        ref1 = Database.database().reference()
        let ref2 = ref1.child("count")
        ref2.queryLimited(toLast: 1).observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            self.countDBs = value["countDB"] as? String ?? ""
            print("**** listen countDBs = \(self.countDBs)")
        })
    }
    
    func checkInput() {
        if (action1Status == 0) {
            alertSheets(alertCODE : "Error", alertMSG : "Please select ★ picture.")
            return;
        }
        if (titleTF.text == "")||(descTF.text == "")||(priceTF.text == "") {
            alertSheets(alertCODE : "Error", alertMSG : "Please input the text.")
            return;
        }
        if (section00 == ["(Select category)"])||(section01 == ["(Select area)"]) {
            alertSheets(alertCODE : "Error", alertMSG : "Please select items.")
            return;
        }
        showIndicator()
        uploadToMall()
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
    
    func uploadToMall() {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://frogment-ccf72.appspot.com")
        let imageRef = storageRef.child("images")
        let metadata = StorageMetadata()
//        metadata.contentType = "image/png"
        metadata.contentType = "image/jpeg"
        print("**** start uploading file")
        updateCount()
        self.updatePicStatus(picNo: "pic1", status: "before")
        self.updatePicStatus(picNo: "pic2", status: "before")
        self.updatePicStatus(picNo: "pic3", status: "before")

//          let reference = imageRef.child(NSUUID().uuidString + "/" + countPhoto() + ".jpg")
        if action1Status == 9 {
            self.updatePicStatus(picNo: "pic1", status: "uploading")
            let reference = imageRef.child("sample" + String(self.countDB) + ".jpg")
            let uploadTask = reference.putData(upData1, metadata: metadata) { metaData, error in
                if let error = error {
                    print("**** Upload01 error occurred!")
                    self.updatePicStatus(picNo: "pic1", status: "error")
                    self.killUpload()
                    print(error)
                }
            }
            uploadTask.observe(.success) { snapshot in
                print("**** Success Upload01 -> \(reference)")
                self.action1Status = 10
                self.updatePicStatus(picNo: "pic1", status: "success")
            }
        }
        if action2Status == 9 {
            self.updatePicStatus(picNo: "pic2", status: "uploading")
            let reference = imageRef.child("sample" + String(self.countDB) + "-02.jpg")
            let uploadTask = reference.putData(upData2, metadata: metadata) { metaData, error in
                if let error = error {
                    print("**** Upload02 error occurred!")
                    self.updatePicStatus(picNo: "pic2", status: "error")
                    self.killUpload()
                    print(error)
                }
            }
            uploadTask.observe(.success) { snapshot in
                print("**** Success Upload02 -> \(reference)")
                self.action2Status = 10
                self.updatePicStatus(picNo: "pic2", status: "success")
            }
        }
        if action3Status == 9 {
            self.updatePicStatus(picNo: "pic3", status: "uploading")
            let reference = imageRef.child("sample" + String(self.countDB) + "-03.jpg")
            let uploadTask = reference.putData(upData3, metadata: metadata) { metaData, error in
                if let error = error {
                    print("**** Upload03 error occurred!")
                    self.updatePicStatus(picNo: "pic3", status: "error")
                    self.killUpload()
                    print(error)
                }
            }
            uploadTask.observe(.success) { snapshot in
                print("**** Success Upload03 -> \(reference)")
                self.action3Status = 10
                self.updatePicStatus(picNo: "pic3", status: "success")
            }
        }
        self.checkUploadStatus()
    }
    
    func updatePicStatus(picNo : String, status : String) {
        let picStatus = [picNo : status]
        let picRef = self.ref1.child("uploadStatus/\(self.countDB)")
        picRef.updateChildValues(picStatus)
    }
    
    func checkUploadStatus() {
        let picRef = self.ref1.child("uploadStatus/\(self.countDB)")
        picRef.queryLimited(toLast: 3).observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            let p1St = value["pic1"] as? String ?? ""
            let p2St = value["pic2"] as? String ?? ""
            let p3St = value["pic3"] as? String ?? ""
            print("**** listen pic1-3 -> pic1:\(p1St),pic2:\(p2St),pic3:\(p3St)")
            if ((p1St == "before")||(p1St == "success"))&&((p2St == "before")||(p2St == "success"))&&((p3St == "before")||(p3St == "success")) {
                picRef.removeAllObservers()
                self.updateDB()
            }
        })
    }
    
    func updateDB() {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .none
        f.locale = Locale(identifier: "ja_JP")
        let now = Date()
        print("**** date -> \(f.string(from: now))")
        
        let title = titleTF.text
        let desc = descTF.text
        let price = priceTF.text
        let category = section00[0]
        let area = section01[0]
        let date = f.string(from: now)
        let imageName = "sample\(String(self.countDB)).jpg"
        
        let post1 = ["item title": title, "item description": desc, "item price": price, "item category": category, "Area": area, "upload date": date, "sell date": "", "account number": self.uid, "E-mail": self.email, "user name": self.userName, "count DB": String(self.countDB)]
        let post1Ref = self.ref1.child("upload/\(self.countDB)")
        post1Ref.updateChildValues(post1)
        
        let post2 = ["countDB": String(self.countDB)]
        let post2Ref = self.ref1.child("count")
        post2Ref.setValue(post2)
        
        let post3 = ["item title": title, "item description": desc, "item price": price, "item category": category, "Area": area, "upload date": date, "sell date": "", "image name": imageName, "count DB": String(self.countDB)]
        let post3Ref = self.ref1.child("Account/\(self.uid)/Upload/\(String(self.countDB))")
        post3Ref.setValue(post3)

        self.indicator.stopAnimating()
        alertSheets(alertCODE : "Success", alertMSG : "Finish uploading!")
        clearInput()
        print("**** Success setValue with Uploading")
    }
    
    func killUpload() {
        self.indicator.stopAnimating()
        alertSheets(alertCODE : "Error", alertMSG : "Please retry!")
        clearInput()
        let picRef = self.ref1.child("upload/\(self.countDB)")
        picRef.removeAllObservers()
    }
    
    func clearInput() {
        titleTF.text?.removeAll()
        descTF.text.removeAll()
        priceTF.text = ""
        section00 = ["(Select category)"]
        section01 = ["(Select area)"]
        upData1.removeAll()
        upData2.removeAll()
        upData3.removeAll()
        inputTableView.reloadData()
        self.upButton01.setImage(#imageLiteral(resourceName: "camera008"), for : UIControlState())
//20170925        self.upButton02.setImage(#imageLiteral(resourceName: "camera007"), for : UIControlState())
//20170925        self.upButton03.setImage(#imageLiteral(resourceName: "camera007"), for : UIControlState())

    }

    func actionSheet(acNo : Int) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let action1 = UIAlertAction(title: "Current picture!", style: UIAlertActionStyle.default, handler: {
            action in
            self.pickImageFromLibrary()
        })
        let action2 = UIAlertAction(title: "New picture!", style: UIAlertActionStyle.default, handler: {
            action in
            print("**** new pic")
            self.pickImageFromCamera()
        })
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            action in
            print("**** cancel")
        })
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(cancel)
        actionSheet.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        self.actionNo = acNo
        print("**** select Button No.\(self.actionNo)")
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

extension UploadViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let beforeStr: String = descTF.text
        if descTF.text.count > 120 {
            let zero = beforeStr.startIndex
            let start = beforeStr.index(zero, offsetBy: 0)
            let end = beforeStr.index(zero, offsetBy: 120)
            descTF.text = String(beforeStr[start...end])
        }
    }
}

extension UploadViewController: FUIAuthDelegate {
    
    func checkLoggedIn() {
        print("**** start_checkLoggedIn")
        self.setupLogin()
        handle = Auth.auth().addStateDidChangeListener{auth, user in
            if Auth.auth().currentUser != nil {
                self.loginSt = 1
                print("**** Listener_success")
            } else {
                self.actionSheet()
                print("**** Listener_fail")
            }
        }
    }
    
    func checkLoggedIn2() {
        handle = Auth.auth().addStateDidChangeListener{auth, user in
            if Auth.auth().currentUser != nil {
                self.loginSt = 1
                print("**** Listener_success2")
            } else {
                self.actionSheet()
                print("**** Listener_fail2")
            }
        }
    }
    
    func actionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let action1 = UIAlertAction(title: "Login", style: UIAlertActionStyle.default, handler: {
            action in
            self.performSegue(withIdentifier: "BackToHomeS4",sender: nil)
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
    
    func setupLogin() {
        authUI.delegate = self
        authUI.providers = providers
        //        authUI.isSignInWithEmailHidden = true
        let kFirebaseTermsOfService = URL(string: "https://frogment-ccf72.firebaseapp.com")!
        authUI.tosurl = kFirebaseTermsOfService
        print("**** after_setupLogin")
    }
}

extension UploadViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            descTF.becomeFirstResponder()
            break
        case 1:
            priceTF.becomeFirstResponder()
            break
        case 2:
            textField.resignFirstResponder()
            break
        default:
            break
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        if (self.titleTF.isFirstResponder) {
            self.titleTF.resignFirstResponder()
        } else if (self.descTF.isFirstResponder) {
            self.descTF.resignFirstResponder()
        } else if (self.priceTF.isFirstResponder) {
            self.priceTF.resignFirstResponder()
        }
    }
}


extension UploadViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionUp.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionUp[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let tableDatas = [section00, section01]
        let sectionData = tableDatas[(indexPath as NSIndexPath).section]
        let cellData = sectionData[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = cellData
        cell.textLabel?.textColor = UIColor.gray
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 30;
        } else {
            return 10;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func reloadCell(){
        inputTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        setCell = sectionUp[indexPath.section]
        if setCell == "area" {
            performSegue(withIdentifier: "ToSAreaFromUP",sender: nil)
        } else if setCell == "item category" {
            performSegue(withIdentifier: "ToSCateFromUP", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "ToSAreaFromUP") {
            let SAVC2: SearchAreaViewController = (segue.destination as? SearchAreaViewController)!
            SAVC2.fromVC = "FromUpload"
        } else if (segue.identifier == "ToSCateFromUP") {
            let SCVC2: SearchCategoryViewController = (segue.destination as? SearchCategoryViewController)!
            SCVC2.fromVC = "FromUpload"
        }
    }

}


extension UploadViewController: UINavigationControllerDelegate {
    
    func pickImageFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
            
            present(controller, animated: true, completion: nil)
        }
    }
    
    func pickImageFromCamera() {
        let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        } else {
            print ("**** camera Error")
            alertSheets(alertCODE : "Error", alertMSG : "You can't use camera.")
        }
        
    }
}

extension UploadViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo
        info: [String : Any]) {
        self.uploadTemp = info[UIImagePickerControllerOriginalImage] as? UIImage
        if self.actionNo == 1 {
            self.upButton01.setImage(uploadTemp, for : UIControlState())
            if let data = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage] as! UIImage,0.2) {
                self.upData1 = data
                action1Status = 9
                print("**** success to set data1. action1status is 9")
            }
        } else if self.actionNo == 2 {
            self.upButton02.setImage(uploadTemp, for : UIControlState())
            if let data = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage] as! UIImage,0.2) {
                self.upData2 = data
                action2Status = 9
                print("**** success to set data2. action2status is 9")
            }
        } else {
            self.upButton03.setImage(uploadTemp, for : UIControlState())
            if let data = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage] as! UIImage,0.2) {
                self.upData3 = data
                action3Status = 9
                print("**** success to set data3. action3status is 9")
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
}


/*
 func countPhoto() -> String {
 let ud = UserDefaults.standard
 let count = ud.object(forKey: "count") as! Int
 ud.set(count + 1, forKey: "count")
 return String(count)
 }
 */

/*
 override func viewDidLoad() {
 super.viewDidLoad()
 print("**** Start_UploadVC")
 
 // [1]ストレージ サービスへの参照を取得
 let storage = Storage.storage()
 // [2]ストレージへの参照を取得
 let storageRef = storage.reference(forURL: "gs://frogment-ccf72.appspot.com")
 // [3]ツリーの下位への参照を作成
 let imageRef = storageRef.child("images")    //rootからDir
 var spaceRef = imageRef.child("sample_test.png")   //Dirからfile
 let path = spaceRef.fullPath;                //fileのフルパス取得
 
 // [4]Dataを作成
 let imageData = UIImagePNGRepresentation(UIImage(named: "sample_test")!)!
 
 // [5]アップロードを実行
 spaceRef.putData(imageData, metadata: nil) { metadata, error in
 if (error != nil) {
 print("**** Uh-oh, an error occurred!")
 } else {
 let downloadURL = metadata!.downloadURL()!
 print("**** Uploading is Success!")
 print("**** downloadURL:", downloadURL)
 }
 }
 }
 
 }
 */


