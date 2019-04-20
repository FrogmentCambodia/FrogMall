//
//  ChatListViewController.swift
//  FrogMallFir
//
//  Created by 阿瀬義弘 on 2018/08/16.
//  Copyright © 2018年 Frogment. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
//import FirebaseAuthUI
//import FirebaseGoogleAuthUI
import FirebaseStorage
//import FirebaseStorageUI
import FirebaseDatabase


class ChatListViewController: UIViewController {
    
    var chatTableView:UITableView!
    var searchBar:UISearchBar!
    var msgList:[String] = []
    var disList:[String] = []
    var yourList:[String] = []
    var lastMList:[String] = []
    var pathList:[String] = []
    var nameList:[String] = []
    var msgCountList:[String] = []
    var readCountList:[String] = []
    var searchResults:[String] = []
    var ref1: DatabaseReference!
    var uid = ""
    var disName = ""
    var yourName = ""
    var lastMSG = ""
    
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
        }
        msgList.removeAll()
        disList.removeAll()
        yourList.removeAll()
        lastMList.removeAll()
        chatTableView = UITableView(frame: view.frame, style: .plain)
        SDImageCache.shared().clearDisk()
        setupFirebase()
        chatTableView.register (UINib(nibName: "CustomCell", bundle: nil),forCellReuseIdentifier:"cell")
        self.view.addSubview(chatTableView)
        
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:60)
        searchBar.layer.position = CGPoint(x: self.view.bounds.width/2, y: 89)
        searchBar.searchBarStyle = UISearchBarStyle.default
        searchBar.showsSearchResultsButton = false
        searchBar.placeholder = "search"
        searchBar.setValue("cancel", forKey: "_cancelButtonText")
        searchBar.tintColor = UIColor.red
        chatTableView.tableHeaderView = searchBar
//        self.view.addSubview(searchBar)
//        searchBar.frame.origin.y = 30
//        chatTableView.frame.origin.y = searchBar.frame.maxY
        checkLoggedIn()
    }
/*
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
*/
    func setupFirebase() {
        ref1 = Database.database().reference()
        let ref2 = ref1.child("chatList/\(self.uid)")
        ref2.queryLimited(toLast: 1000).observe(DataEventType.childAdded, with: { (snapshot) -> Void in
            let value = snapshot.value as? NSDictionary
            let itemTitle = value?["Title"] as? String ?? ""
            let displayName = value?["DisplayName"] as? String ?? ""
            let yourList = value?["accountNo"] as? String ?? ""
            let lastM = value?["LastMSG"] as? String ?? ""
            let pathList = value?["Path"] as? String ?? ""
            let nameList = value?["user name"] as? String ?? ""
            let msgCount = value?["msgCount"] as? String ?? ""
            let readCount = value?["readCount"] as? String ?? ""
            self.msgList.append(itemTitle)
            self.disList.append(displayName)
            self.yourList.append(yourList)
            self.lastMList.append(lastM)
            self.pathList.append(pathList)
            self.nameList.append(nameList)
            self.msgCountList.append(msgCount)
            self.readCountList.append(readCount)
//            print("**** msgList -> \(self.msgList)")
//            print("**** disList -> \(self.disList)")
//            print("**** lastMList -> \(self.lastMList)")
            print("**** msgCountList -> \(self.msgCountList)")
            print("**** readCountList -> \(self.readCountList)")

            self.chatTableView.delegate = self
            self.chatTableView.dataSource = self
            self.chatTableView.isScrollEnabled = true
            SDImageCache.shared().clearDisk()
            SDImageCache.shared().clearMemory()
            self.chatTableView.reloadData()
        })
        ref2.queryLimited(toLast: 1000).observe(DataEventType.childChanged, with: { (snapshot) in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            let displayName2 = value["DisplayName"] as? String ?? ""
            let lastM2 = value["LastMSG"] as? String ?? ""
            print("**** listen changed = \(displayName2),\(lastM2)")
            let num = self.disList.index(of: displayName2)
            if num != nil {
//                if lastM2 != self.lastMList[num!] {
                self.lastMList[num!] = lastM2
                self.chatTableView.reloadData()
//                }
            }
        })
        ref2.queryLimited(toLast: 1000).observe(DataEventType.childChanged, with: { (snapshot) in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            let displayName3 = value["DisplayName"] as? String ?? ""
            let msgCount2 = value["msgCount"] as? String ?? ""
            let readCount2 = value["readCount"] as? String ?? ""
            print("**** listen changed = \(displayName3),\(msgCount2),\(readCount2)")
            let num = self.disList.index(of: displayName3)
            if num != nil {
                self.msgCountList[num!] = msgCount2
                self.readCountList[num!] = readCount2
                self.chatTableView.reloadData()
            }
        })
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
    }
/*
    func clearInput() {
        self.msgList.removeAll()
        self.disList.removeAll()
        self.yourList.removeAll()
        self.lastMList.removeAll()
    }
*/
}

extension ChatListViewController: FUIAuthDelegate {
    
    func checkLoggedIn() {
        print("**** start_checkLoggedIn")
        self.setupLogin()
        handle = Auth.auth().addStateDidChangeListener{auth, user in
            if Auth.auth().currentUser != nil {
                print("**** Listener_success")
            } else {
                print("**** Listener_fail")
                self.actionSheet()
            }
        }
    }
    
    func checkLoggedIn2() {
        handle = Auth.auth().addStateDidChangeListener{auth, user in
            if Auth.auth().currentUser != nil {
                print("**** Listener_success2")
                self.performSegue(withIdentifier: "toChat",sender: nil)
            } else {
                print("**** Listener_fail2")
                self.actionSheet()
            }
        }
    }
    
    func actionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let action1 = UIAlertAction(title: "Login", style: UIAlertActionStyle.default, handler: {
            action in
            self.performSegue(withIdentifier: "BackToHomeS2",sender: nil)
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

extension ChatListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchBar.showsCancelButton = true
        searchResults = msgList.filter{
            $0.lowercased().contains(searchBar.text!.lowercased())
        }
        chatTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        self.view.endEditing(true)
        searchBar.text = ""
        chatTableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
}



extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text != "" {
            return searchResults.count
        } else {
            return msgList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//2        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        if searchBar.text != "" {
//2            cell.textLabel?.text = searchResults[indexPath.row]
            cell.cusItem.text = searchResults[indexPath.row]
            
        } else {
//2            cell.textLabel?.text = msgList[(indexPath as NSIndexPath).row]
            cell.cusItem.text = msgList[(indexPath as NSIndexPath).row]
        }
//2        cell.detailTextLabel?.text = lastMList[(indexPath as NSIndexPath).row]
        cell.cusMsg.text = lastMList[(indexPath as NSIndexPath).row]
        if nameList[(indexPath as NSIndexPath).row] != ""{
            cell.cusName.text = nameList[(indexPath as NSIndexPath).row]
        } else {
            cell.cusName.text = "No Name"
        }
        
        var msgCount = 0
        if msgCountList[(indexPath as NSIndexPath).row] != "" {
            msgCount = Int(msgCountList[(indexPath as NSIndexPath).row])!
        }
        var readCount = 0
        if readCountList[(indexPath as NSIndexPath).row] != "" {
            readCount = Int(readCountList[(indexPath as NSIndexPath).row])!
        }
        let newMSG = msgCount - readCount
        
        if newMSG > 0 {
            cell.cusGreen.image = UIImage(named: "newMSG3")
            cell.cusCount.text = String(newMSG)
        } else {
            cell.cusGreen.image = nil
            cell.cusCount.text = ""
        }
        
//2        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
//        cell.imageView?.image = UIImage(named: "account")

//        let fileName = "account/\(yourList[(indexPath as NSIndexPath).row])/AccountImage_\(yourList[(indexPath as NSIndexPath).row]).jpg"
        let fileName = pathList[(indexPath as NSIndexPath).row]
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://frogment-ccf72.appspot.com")
        let reference = storageRef.child(fileName)
        let placeholderImage = UIImage(named: "NoImage2")
        cell.cusImage.sd_setImage(with: reference, placeholderImage: placeholderImage) { data, error, _, _ in
            if let error = error {
                print("**** getChatData error \(fileName)")
                print(error)
                cell.cusImage.image = UIImage(named: "NoImage2")
            } else {
                print("**** getChatData success \(fileName)")
            }
        }
//2        cell.cusImage.contentMode = UIViewContentMode.left
        cell.cusImage.clipsToBounds = true
        cell.cusImage.contentMode = .scaleAspectFill
//2        cell.cusImage.frame = CGRect(x:0, y:0, width:30, height:30)
//        cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.height)! / 2.0
//        let path = UIBezierPath(roundedRect: (cell.imageView?.bounds)!, byRoundingCorners: [.bottomLeft, .bottomRight, .topLeft, .topRight], cornerRadii: CGSize(width: 7, height: 7))
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        cell.imageView?.layer.mask = mask

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        disName = disList[indexPath.row]
        yourName = yourList[indexPath.row]
        checkLoggedIn2()
//        performSegue(withIdentifier: "toChat",sender: nil)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toChat") {
            let CVC: ChatViewController = (segue.destination as? ChatViewController)!
            CVC.disName = self.disName
            CVC.yourUid = self.yourName
            CVC.myUid = self.uid
        }
    }
    
}
