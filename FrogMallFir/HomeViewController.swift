//
//  HomeViewController.swift
//  FrogMallFir
//
//  Created by 阿瀬義弘 on 2018/05/06.
//  Copyright © 2018年 Frogment. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseStorage
import FirebaseDatabase

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionVIew: UICollectionView!
    @IBOutlet weak var upView: UIView!
    @IBAction func menuButton(_ sender: Any) {}
    var selectedref = ""
    var selectedCount = ""
    let reuseIdentifier = "reuseIdentifier"
    var ref1: DatabaseReference!
    var countDB: Int = 0
    var countDBs: String = ""
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
    var cellX = 0
    var cellY = 0
    var cellW:CGFloat = 0
    var cellH:CGFloat = 0
    private let refreshControl = UIRefreshControl()
    var areaList:[String] = []
    var cateList:[String] = []
    var priceList:[String] = []
    var accountList:[String] = []
    var disList:[String] = []
    var dateList:[String] = []
    var cDBList:[String] = []
    var blockUserList:[String] = []
    var blockItemList:[String] = []
    var blockedUserList:[String] = []
    var blockedItemList:[String] = []
    var favList:[String] = []
    var orderList:[Int] = []
    let indicator = UIActivityIndicatorView()
    var cellArea = ""
    var cellCate = ""
    var cellPrice = ""
    let gradientLayer = CAGradientLayer()
    var myUid = ""
    var myEmail = ""
    var blockFlag = 0
    var blockedFlag = 0
    
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
    let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
    var handle: AuthStateDidChangeListenerHandle?
    var loginSt = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        if let user = user {
            myUid = user.uid
            myName = user.displayName!
            myEmail = user.email!
        }
        showIndicator()
        ref1 = Database.database().reference()
        cellW = ((view.frame.width) / 2) - 15
        cellH = 250
        getInput()
        getInputBlock()
        getInputBlocked()
        getSellDate()
        getFavo()
        SDImageCache.shared.clearDisk()
        setupFirebase()
        collectionVIew.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(HomeViewController.refresh(sender:)), for: .valueChanged)
        registProfile()
        
        checkLoggedIn()
        
        print("**** Home_screen")
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
    }
    
    // Get count from Firebase DB
    func setupFirebase() {
        let ref2 = ref1.child("count")
        ref2.queryLimited(toLast: 1).observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            self.countDBs = value["countDB"] as? String ?? ""
            print("**** listen countDBs = \(self.countDBs)")
            self.collectionVIew.dataSource = self
            self.collectionVIew.delegate = self
            self.collectionVIew.allowsSelection = true
            self.indicator.stopAnimating()
        })
    }
    
    // Get product information
    func getInput() {
        let ref3 = ref1.child("upload")
        ref3.observe(DataEventType.childAdded, with: { (snapshot) -> Void in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            let area2 = value["Area"] as? String ?? ""
            let category2 = value["item category"] as? String ?? ""
            let price2 = value["item price"] as? String ?? ""
            let title2 = value["item title"] as? String ?? ""
            let account2 = value["account number"] as? String ?? ""
            let selldate2 = value["sell date"] as? String ?? ""
            let cDB2 = value["count DB"] as? String ?? ""
            let orderNum = Int(cDB2)!
            let fav = value["favorite"] as? String ?? ""
            let disList = "\(title2) + \(account2) + \(self.myUid)"
            self.areaList.append(area2)
            self.cateList.append(category2)
            self.priceList.append(price2)
            self.accountList.append(account2)
            self.dateList.append(selldate2)
            self.cDBList.append(cDB2)
            self.orderList.shuffle()
            self.orderList.append(orderNum)
            self.favList.append(fav)
            self.disList.append(disList)
        })
    }
    
    // Get block user list
    func getInputBlock() {
        let ref4 = ref1.child("Account/\(myUid)/Block")
        ref4.observe(DataEventType.childAdded, with: { (snapshot) -> Void in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            let blockUser = value["accountNo"] as? String ?? ""
            let blockKey = value["DisplayName"] as? String ?? ""
            self.blockUserList.append(blockUser)
            self.blockItemList.append(blockKey)
            print("**** blockUserList1 = \(self.blockUserList)")
        })
        ref4.observe(DataEventType.childRemoved, with: { (snapshot) -> Void in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            let blockUser = value["accountNo"] as? String ?? ""
            let blockKey = value["DisplayName"] as? String ?? ""
            self.blockUserList.remove(at: self.blockUserList.index(of: blockUser)!)
            self.blockItemList.remove(at: self.blockItemList.index(of: blockKey)!)
            print("**** blockUserList2 = \(self.blockUserList)")
        })
    }
    
    // Get be blocked user list
    func getInputBlocked() {
        let ref5 = ref1.child("Account/\(myUid)/Be Blocked")
        ref5.observe(DataEventType.childAdded, with: { (snapshot) -> Void in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            let blockedUser = value["accountNo"] as? String ?? ""
            let blockedKey = value["DisplayName"] as? String ?? ""
            self.blockedUserList.append(blockedUser)
            self.blockedItemList.append(blockedKey)
            print("**** blockedUserList1 = \(self.blockedUserList)")
        })
        ref5.observe(DataEventType.childRemoved, with: { (snapshot) -> Void in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            let blockedUser = value["accountNo"] as? String ?? ""
            let blockedKey = value["DisplayName"] as? String ?? ""
            self.blockedUserList.remove(at: self.blockedUserList.index(of: blockedUser)!)
            self.blockedItemList.remove(at: self.blockedItemList.index(of: blockedKey)!)
            print("**** blockedUserList2 = \(self.blockedUserList)")
        })
    }
    
    // Get block sell date
    func getSellDate() {
        let ref6 = ref1.child("upload")
        ref6.queryLimited(toLast: 1000).observe(DataEventType.childChanged, with: { (snapshot) in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            let sellDate = value["sell date"] as? String ?? ""
            let cDB = value["count DB"] as? String ?? ""
            print("**** listen changed selldate = \(sellDate)")
            let num = self.cDBList.index(of: cDB)
            if num != nil {
                self.dateList[num!] = sellDate
                self.collectionVIew.reloadData()
            }
        })
    }
    
    // Get favorite user list
    func getFavo() {
        let ref8 = ref1.child("upload")
        ref8.queryLimited(toLast: 1000).observe(DataEventType.childChanged, with: { (snapshot) in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            let newFav = value["favorite"] as? String ?? ""
            let cDB = value["count DB"] as? String ?? ""
            print("**** listen changed favo = \(newFav)")
            let num = self.cDBList.index(of: cDB)
            if num != nil {
                self.favList[num!] = newFav
                self.collectionVIew.reloadData()
            }
        })
    }
    
    // Register profile
    func registProfile() {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .none
        f.locale = Locale(identifier: "ja_JP")
        let now = Date()
        let date = f.string(from: now)
        
        let singleton :Singleton =  Singleton.sharedInstance
        let gender = singleton.shareGender
        let birth = singleton.shareBirth
        
        if Auth.auth().currentUser != nil {
            let post1 = ["User ID" : myUid, "User name" : myName, "E-mail" : myEmail, "Last Login" : date, "Gender" : gender, "Birthday" : birth]
            let ref7 = self.ref1.child("Account/\(myUid)/info")
            ref7.updateChildValues(post1)
            print("**** Regist profile!")
        } else {
            print("**** No user login!")
        }
    }

    @objc func refresh(sender: UIRefreshControl) {
        SDImageCache.shared.clearDisk()
        SDImageCache.shared.clearMemory()
        orderList.shuffle()
        collectionVIew.reloadData()
        sender.endRefreshing()
    }
    
    // Get product count
    func checkTimes(times :Int) {
        if times == 0 {
            self.countDB = (Int(countDBs))!
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int {
        return Int(countDBs)!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //space -> (top , left , bottom , right)
        return UIEdgeInsetsMake(0,10,0,10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellW, height: cellH)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let testCell:UICollectionViewCell =
            collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                               for: indexPath)
        // Create UIImageView instance
        let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x:0, y:0, width:cellW, height:cellH)
        imageView.clipsToBounds = true
        
        // Shape ImageView
        let path = UIBezierPath(roundedRect: imageView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight, .topLeft, .topRight], cornerRadii: CGSize(width: 7, height: 7))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        imageView.layer.mask = mask
        
        checkTimes(times : indexPath.row)
        
        let sortNum = orderList[indexPath.row]
        let fileName = "images/sample\(sortNum).jpg"
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://frogment-ccf72.appspot.com")
        let reference = storageRef.child(fileName)
        let placeholderImage = UIImage(named: "loading05")
        let blockTemp = accountList[sortNum-1]
        
        // Confirm whether or not product is uploaded by block user
        if blockUserList.contains(blockTemp) {
            imageView.image = UIImage(named: "Blocked03")
        } else {
            imageView.sd_setImage(with: reference, placeholderImage: placeholderImage) { data, error, _, _ in
            if let error = error {
                print("**** getData error \(sortNum)")
                print(error)
            } else {
                print("**** getData success \(sortNum)")
                }
            }
        }
        
        let label = testCell.contentView.viewWithTag(2) as! UILabel
        let soldDate = testCell.contentView.viewWithTag(3) as! UIImageView
        soldDate.contentMode = .scaleAspectFill
        soldDate.clipsToBounds = true

        // Get sell date
        if dateList[sortNum-1] != "" {
            soldDate.image = UIImage(named: "SoldOut3")
        } else {
            soldDate.image = UIImage(named: "")
        }
        
        let heart = testCell.contentView.viewWithTag(4) as! UIImageView
        let favLabel = testCell.contentView.viewWithTag(5) as! UILabel
        heart.contentMode = .scaleAspectFit
        heart.clipsToBounds = true

        // Get favorite information
        if favList[sortNum-1] != "" {
            heart.image = UIImage(named: "heart2")
            if Int(favList[sortNum-1])! > 99 {
                favLabel.text = "+99"
            } else {
                favLabel.text = favList[sortNum-1]
            }
        } else {
            heart.image = UIImage(named: "")
            favLabel.text = ""
        }
        
        // Get price information
        if priceList.count >= (sortNum) {
            label.text = "$ \(priceList[sortNum-1])"
        } else {
            label.text = "$ ???"
        }
        return testCell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedCount = String(orderList[indexPath.row])
        if blockUserList.contains(accountList[orderList[indexPath.row]-1]) {
            blockFlag = 1
        } else {
            blockFlag = 0
        }
        if blockedUserList.contains(accountList[orderList[indexPath.row]-1]) {
            blockedFlag = 1
        } else {
            blockedFlag = 0
        }
        selectedref = "images/sample\(selectedCount).jpg"
        print("**** selected index = \(indexPath.row)")
        getInfo(count:selectedCount)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toDetailViewController") {
            let dtVC: DetailViewController = (segue.destination as? DetailViewController)!
            
            dtVC.getRef = selectedref
            dtVC.countDBs = selectedCount
            dtVC.pic1 = pic1
            dtVC.pic2 = pic2
            dtVC.pic3 = pic3
            dtVC.itemTitle = itemTitle
            dtVC.itemDescription = itemDescription
            dtVC.price = price
            dtVC.category = category
            dtVC.area = area
            dtVC.upDate = upDate
            dtVC.accountNo = accountNo
            dtVC.emailAdd = emailAdd
            dtVC.userName = userName
            dtVC.myName = myName
            dtVC.myUid = myUid
            dtVC.blockFlag = blockFlag
            dtVC.blockedFlag = blockedFlag
            print("**** segue > \(selectedref),\(selectedCount),\(itemTitle)")
        }
    }
    
    func getInfo(count:String) {
        let ref2 = ref1.child("upload/\(count)")
        ref2.queryLimited(toLast: 1000).observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            self.pic1 = value["pic1"] as? String ?? ""
            self.pic2 = value["pic2"] as? String ?? ""
            self.pic3 = value["pic3"] as? String ?? ""
            self.itemTitle = value["item title"] as? String ?? ""
            self.itemDescription = value["item description"] as? String ?? ""
            self.price = value["item price"] as? String ?? ""
            self.category = value["item category"] as? String ?? ""
            self.area = value["Area"] as? String ?? ""
            self.upDate = value["upload date"] as? String ?? ""
            self.accountNo = value["account number"] as? String ?? ""
            self.emailAdd = value["E-mail"] as? String ?? ""
            self.userName = value["user name"] as? String ?? ""

            self.performSegue(withIdentifier: "toDetailViewController",sender: nil)
        })
    }
    
}

extension HomeViewController: FUIAuthDelegate {
    
    func checkLoggedIn() {
        print("**** start_checkLoggedIn")
        self.setupLogin()
        handle = Auth.auth().addStateDidChangeListener{auth, user in
            if Auth.auth().currentUser != nil {
                self.loginSt = 1
                print("**** Listener_success")
            } else {
                self.performSegue(withIdentifier: "BackToHomeS5",sender: nil)
                print("**** Listener_fail")
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
}
