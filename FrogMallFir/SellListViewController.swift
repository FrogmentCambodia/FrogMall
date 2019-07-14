//
//  SellListViewController.swift
//  Frog Mall
//
//  Created by 阿瀬義弘 on 2018/11/10.
//  Copyright © 2018年 Frogment. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseStorage
import FirebaseDatabase

class SellListViewController: UIViewController {

    @IBAction func back2Top(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var sellListTable: UITableView!
    var pathList:[String] = []
    var titleList:[String] = []
    var priceList:[String] = []
    var cateList:[String] = []
    var uploadDateList:[String] = []
    var sellDateList:[String] = []
    var countList:[String] = []
    var descList:[String] = []
    var areaList:[String] = []
    var ref1: DatabaseReference!
    var uid = ""
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
    var path = ""
    var counts = ""

    
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
    let providers: [FUIAuthProvider] = [
        FUIGoogleAuth(),
        FUIFacebookAuth()
    ]
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        if let user = user {
            uid = user.uid
            myName = user.displayName!
        }
        pathList.removeAll()
        titleList.removeAll()
        priceList.removeAll()
        cateList.removeAll()
        uploadDateList.removeAll()
        sellDateList.removeAll()
        countList.removeAll()
        descList.removeAll()
        areaList.removeAll()
        SDImageCache.shared.clearDisk()
        setupFirebase()
        sellListTable.register (UINib(nibName: "CustomCell2", bundle: nil),forCellReuseIdentifier:"cell2")
        checkLoggedIn()
    }
    
    func setupFirebase() {
        ref1 = Database.database().reference()
        let ref2 = ref1.child("Account/\(self.uid)/Upload")
        ref2.queryLimited(toLast: 1000).observe(DataEventType.childAdded, with: { (snapshot) -> Void in
            let value = snapshot.value as? NSDictionary
            let path = value?["image name"] as? String ?? ""
            let title = value?["item title"] as? String ?? ""
            let price = value?["item price"] as? String ?? ""
            let category = value?["item category"] as? String ?? ""
            let upDate = value?["upload date"] as? String ?? ""
            let seDate = value?["sell date"] as? String ?? ""
            let countDB = value?["count DB"] as? String ?? ""
            let desc = value?["item description"] as? String ?? ""
            let area = value?["Area"] as? String ?? ""

            self.pathList.append(path)
            self.titleList.append(title)
            self.priceList.append(price)
            self.cateList.append(category)
            self.uploadDateList.append(upDate)
            self.sellDateList.append(seDate)
            self.countList.append(countDB)
            self.descList.append(desc)
            self.areaList.append(area)
            self.sellListTable.delegate = self
            self.sellListTable.dataSource = self
            self.sellListTable.isScrollEnabled = true
            SDImageCache.shared.clearDisk()
            SDImageCache.shared.clearMemory()
            self.sellListTable.reloadData()
        })
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
    }
}


extension SellListViewController: FUIAuthDelegate {
    
    func checkLoggedIn() {
        print("**** start_checkLoggedIn")
        self.setupLogin()
        handle = Auth.auth().addStateDidChangeListener{auth, user in
            if Auth.auth().currentUser != nil {
                print("**** Listener_success_sellList")
            } else {
                print("**** Listener_fail_sellList")
                self.actionSheet()
            }
        }
    }
    
    func actionSheet() {
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
        let kFirebaseTermsOfService = URL(string: "https://frogment-ccf72.firebaseapp.com")!
        authUI.tosurl = kFirebaseTermsOfService
        
    }
    
}



extension SellListViewController: UITableViewDelegate, UITableViewDataSource, CellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pathList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! CustomCell2
        cell2.indexPath = indexPath
        cell2.delegate = self
        cell2.sellTitle.text = titleList[indexPath.row]
        cell2.sellCate.text = cateList[indexPath.row]

        let fileName = pathList[indexPath.row]
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://frogment-ccf72.appspot.com")
        let reference = storageRef.child("images/\(fileName)")
        let placeholderImage = UIImage(named: "NoImage2")
        cell2.sellImage.sd_setImage(with: reference, placeholderImage: placeholderImage) { data, error, _, _ in
            if let error = error {
                print("**** getSellData error \(fileName),\(error)")
                cell2.sellImage.image = UIImage(named: "NoImage2")
            } else {
            }
        }
        cell2.sellImage.clipsToBounds = true
        cell2.sellImage.contentMode = .scaleAspectFill
        
        return cell2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        getInfo(count: indexPath.row)
    }
    
    func getInfo(count:Int) {
        self.itemTitle = self.titleList[count]
        self.itemDescription = self.descList[count]
        self.price = self.priceList[count]
        self.category = self.cateList[count]
        self.area = self.areaList[count]
        self.path = self.pathList[count]
        self.upDate = self.uploadDateList[count]
        self.counts = self.countList[count]

        self.performSegue(withIdentifier: "toDetailViewController3",sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toDetailViewController3") {
            let dtVC: DetailViewController = (segue.destination as? DetailViewController)!
            
            dtVC.getRef = "images/\(path)"
            dtVC.countDBs = counts
            dtVC.itemTitle = itemTitle
            dtVC.itemDescription = itemDescription
            dtVC.price = price
            dtVC.category = category
            dtVC.area = area
            dtVC.upDate = upDate
            dtVC.accountNo = uid
            dtVC.userName = myName
            dtVC.myName = myName
            dtVC.myUid = uid
            print("**** segue > images/\(path),\(counts),\(itemTitle),\(myName)")
        }
    }
    
    
    func sellButton2(_ selectedIndex : Int) {
        print("**** selected Index => \(countList[selectedIndex])")
        if sellDateList[selectedIndex] != "" {
            alertSheets2(alertCODE : "Error", alertMSG : "Sold out item!")
        } else {
            alertSheets(alertCODE : "Change?", alertMSG : "On sale -> Sold out", countDB : countList[selectedIndex])
        }
    }
    
    func alertSheets(alertCODE : String, alertMSG : String, countDB : String) {
        let alertSheet1 = UIAlertController(title: alertCODE, message: alertMSG, preferredStyle: UIAlertControllerStyle.alert)
        let alert1 = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            action in
            self.updateDB(cDB: countDB)
        })
        let alert2 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            action in
            print("**** alertSheets alert2 -> \(alertMSG)")
        })
        alertSheet1.addAction(alert2)
        alertSheet1.addAction(alert1)
        self.present(alertSheet1, animated: true, completion: nil)
    }
    
    func alertSheets2(alertCODE : String, alertMSG : String) {
        let alertSheet2 = UIAlertController(title: alertCODE, message: alertMSG, preferredStyle: UIAlertControllerStyle.alert)
        let alert3 = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            action in
            print("**** alertSheets2 -> \(alertMSG)")
        })
        alertSheet2.addAction(alert3)
        self.present(alertSheet2, animated: true, completion: nil)
    }
    
    func updateDB(cDB : String) {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .none
        f.locale = Locale(identifier: "ja_JP")
        let now = Date()
        let date = f.string(from: now)
        
        let post1 = ["sell date": date]
        let post1Ref = self.ref1.child("Account/\(self.uid)/Upload/\(cDB)")
        post1Ref.updateChildValues(post1)
        
        let post2 = ["sell date": date]
        let post2Ref = self.ref1.child("upload/\(cDB)")
        post2Ref.updateChildValues(post2)
        
        alertSheets2(alertCODE : "Success", alertMSG : "Finish Changing!")
    }
    
}



