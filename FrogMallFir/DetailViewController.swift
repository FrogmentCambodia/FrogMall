//
//  DetailViewController.swift
//  FrogMallFir
//
//  Created by 阿瀬義弘 on 2018/06/20.
//  Copyright © 2018年 Frogment. All rights reserved.

import UIKit
import Firebase
import FirebaseUI
//import FirebaseAuthUI
//import FirebaseGoogleAuthUI
import FirebaseStorage
//import FirebaseStorageUI
import FirebaseDatabase

let sectionTitle = [" ", "Item Description", "PRICE", "CATEGORY", "AREA", "Upload DATE", "Seller"]

class DetailViewController: UIViewController, UIScrollViewDelegate {

    var getRef: String!
    var countDBs = ""
    var ref1: DatabaseReference!
    var myTableView:UITableView!
    var pic1 = ""
    var pic2 = ""
    var pic3 = ""
    var itemTitle = ""
    var itemDescription = ""
    var price = ""
    var category = ""
    var area = ""
    var upDate = ""
    var accountNo = ""
    var emailAdd = ""
    var userName = ""
    var myName = ""
    var myUid = ""
    var displayName = ""
    var blockFlag = 0
    var blockedFlag = 0
    var loginSt = 0
    var currentFav = 0
    var favStatus = 0
    
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
    let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
    var handle: AuthStateDidChangeListenerHandle?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var detailView: UIImageView!
    @IBAction func backFromDVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func actionDetail(_ sender: Any) {checkLoggedIn2()}
    @IBOutlet weak var letButton01: UIButton!
    @IBAction func letButton02(_ sender: Any) {
        checkLoggedIn3()
        if loginSt == 1 {
            if self.myUid == self.accountNo {
                self.alertSheets(alertCODE : "Error", alertMSG : "It's my item!")
            } else if blockFlag == 1{
                self.alertSheets(alertCODE : "Error", alertMSG : "Block user!")
            } else if blockedFlag == 1{
                self.alertSheets(alertCODE : "Error", alertMSG : "You cannot send MSG to this user!")
            } else {
                self.updateChatDB()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        excludeTitle()
        scrollView.delegate = self
        myTableView = UITableView(frame: CGRect(x: 0, y: detailView.frame.maxY, width: self.view.frame.width, height: 500), style: .grouped)
        myTableView.isScrollEnabled = false
        scrollView.addSubview(myTableView)
        getImage()
        setupFirebase()
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        displayName = "\(itemTitle) + \(accountNo) + \(myUid)"
        
        titleLabel.text = itemTitle

        print("**** after getImage")
    }
    
/*
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        myTableView2.frame.origin.y = myTableView.frame.maxY + 200
        myTableView2.frame.origin.x = 0
    }
*/
    func excludeTitle() {
        let excludes = CharacterSet(charactersIn: ".$#[]")
        itemTitle = itemTitle.components(separatedBy: excludes).joined()
    }
    
    func getImage() {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://frogment-ccf72.appspot.com")
        let reference = storageRef.child(getRef)
        let placeholderImage = UIImage(named: "loading05")
        
        if blockFlag == 1 {
            detailView.image = UIImage(named: "Blocked03")
        } else {
            detailView.sd_setImage(with: reference, placeholderImage: placeholderImage) { data, error, _, _ in
                if let error = error {
                    print("**** getDetailData error")
                    print(error)
                } else {
                    print("**** getDetailData success")
                }
            }
        }
        detailView.clipsToBounds = true
        detailView.contentMode = UIViewContentMode.scaleAspectFill
    }
    
    func setupFirebase() {
        ref1 = Database.database().reference()
        let ref2 = ref1.child("upload/\(countDBs)")
        ref2.observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            let favoriteST = value["favorite"] as? String ?? ""
            if favoriteST != "" {
                self.currentFav = Int(favoriteST)!
            }
            print("**** listen favorite1 = \(self.currentFav)")
        })
        ref2.observe(DataEventType.childChanged, with: { (snapshot) -> Void in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            let favoriteST = value["favorite"] as? String ?? ""
            if favoriteST != "" {
                self.currentFav = Int(favoriteST)!
            }
            print("**** listen favorite2 = \(self.currentFav)")
        })
        
        let ref10 = ref1.child("Account/\(myUid)/Favorite/\(countDBs)")
        ref10.observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            let sender = value["sender"] as? String ?? ""
            if sender == self.myUid {
                self.favStatus = 1
            }
            print("**** listen favorite3 = \(self.currentFav)")
        })
        ref10.observe(DataEventType.childChanged, with: { (snapshot) -> Void in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            let sender = value["sender"] as? String ?? ""
            if sender == self.myUid {
                self.favStatus = 1
            }
            print("**** listen favorite4 = \(self.currentFav)")
        })
    }

    
    func updateChatDB() {
        let post1 = ["accountNo": accountNo, "DisplayName": displayName, "Title": itemTitle, "Path": getRef, "user name": userName]
        let ref2 = self.ref1.child("chatList/\(myUid)/\(displayName)")
        ref2.setValue(post1)
        
        let post2 = ["accountNo": myUid, "DisplayName": displayName, "Title": itemTitle, "Path": getRef, "user name": myName]
        let ref3 = self.ref1.child("chatList/\(accountNo)/\(displayName)")
        ref3.setValue(post2)

        self.performSegue(withIdentifier: "toChat2",sender: nil)
        print("**** updated ChatDB")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toChat2") {
            let CVC: ChatViewController = (segue.destination as? ChatViewController)!
            CVC.disName = displayName
            CVC.yourUid = accountNo
            CVC.myUid = myUid
        }
    }
    
    func actionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let action1 = UIAlertAction(title: "Favorite", style: UIAlertActionStyle.default, handler: {
            action in
            if self.accountNo != self.myUid {
                if self.favStatus == 1 {
                    self.alertSheets(alertCODE : "Error", alertMSG : "Favorite item!")
                } else {
                    self.updateAccountDB(Action: "Favorite")
                    self.updateUploadDB()
                }
            } else {
                self.alertSheets(alertCODE : "Error", alertMSG : "It's my item!")
            }
        })
        let action2 = UIAlertAction(title: "Block", style: UIAlertActionStyle.destructive, handler: {
            action in
            if self.accountNo != self.myUid {
                self.updateBlockDB()
            } else {
                self.alertSheets(alertCODE : "Error", alertMSG : "It's my item!")
            }
        })
        let action3 = UIAlertAction(title: "Unblock", style: UIAlertActionStyle.destructive, handler: {
            action in
            if self.accountNo != self.myUid {
                self.removeAccountDB()
            } else {
                self.alertSheets(alertCODE : "Error", alertMSG : "It's my item!")
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            action in
        })
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(action3)
        actionSheet.addAction(cancel)
        actionSheet.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func updateAccountDB(Action: String) {
        let post1 = ["Receiver": accountNo, "sender": myUid, "Title": itemTitle, "count DB": countDBs]
        let ref4 = self.ref1.child("Account/\(myUid)/\(Action)/\(countDBs)")
        ref4.setValue(post1)
        print("**** updated AccountDB")
    }
    
    func updateUploadDB() {
        let ref9 = self.ref1.child("upload/\(countDBs)")
        let newFav = currentFav + 1
        let post4 = ["favorite": String(newFav)]
        ref9.updateChildValues(post4)
        print("**** updated uploadDB")
    }
    
    func updateBlockDB() {
        let post2 = ["accountNo": accountNo, "DisplayName": displayName, "Title": itemTitle]
        let post3 = ["accountNo": myUid, "DisplayName": displayName, "Title": itemTitle]
        let ref5 = self.ref1.child("Account/\(myUid)/Block/\(accountNo)")
        let ref6 = self.ref1.child("Account/\(accountNo)/Be Blocked/\(myUid)")
        ref5.setValue(post2)
        ref6.setValue(post3)
        print("**** Blocked AccountDB")
    }
    
    func removeAccountDB() {
        let ref7 = self.ref1.child("Account/\(myUid)/Block/\(accountNo)")
        let ref8 = self.ref1.child("Account/\(accountNo)/Be Blocked/\(myUid)")
        ref7.removeValue()
        ref8.removeValue()
        print("**** remove Blocked AccountDB")
    }

}

extension DetailViewController: FUIAuthDelegate {
    
    func checkLoggedIn2() {
        handle = Auth.auth().addStateDidChangeListener{auth, user in
            if Auth.auth().currentUser != nil {
                print("**** Listener_success2")
                self.loginSt = 1
                self.actionSheet()
            } else {
                print("**** Listener_fail2")
                self.actionSheet2()
            }
        }
    }
    
    func checkLoggedIn3() {
        handle = Auth.auth().addStateDidChangeListener{auth, user in
            if Auth.auth().currentUser != nil {
                print("**** Listener_success3")
                self.loginSt = 1
            } else {
                print("**** Listener_fail3")
                self.actionSheet2()
            }
        }
    }
    
    func actionSheet2() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let action1 = UIAlertAction(title: "Login", style: UIAlertActionStyle.default, handler: {
            action in
            self.performSegue(withIdentifier: "BackToHomeS3",sender: nil)
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

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableData = [itemTitle, itemDescription, price, category, area, upDate, userName]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let sectionData = tableData[(indexPath as NSIndexPath).section]
//        let cellData = sectionData[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = sectionData
        if indexPath.section == 0 {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 25)
        } else {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        }
        if indexPath.section == 6 {
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }
        cell.textLabel?.numberOfLines = 0
        cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        /*
        if indexPath.section == 6 {
            
        }
 */
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0
        } else {
            return 12
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 50
        } else if indexPath.section == 1 {
            tableView.estimatedRowHeight = 20
            return UITableViewAutomaticDimension
        } else {
            return 37
        }
    }
    
}

