//
//  SearchCollectViewController.swift
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

class SearchCollectViewController: UIViewController {
    
    @IBAction func BackToSMore(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var SearchCollect: UICollectionView!
    @IBOutlet weak var searchLabel: UILabel!
    
    var getCate = ""
    var getArea = ""
    
    var selectedref = ""
    var selectedCount = ""
    let reuseIdentifier = "reuseIdentifier"
    var ref1: DatabaseReference!
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
    var cellX = 0
    var cellY = 0
    var cellW:CGFloat = 0
    var cellH:CGFloat = 0
    private let refreshControl = UIRefreshControl()
    var areaList:[String] = []
    var priceList:[String] = []
    var cateList:[String] = []
    var accountList:[String] = []
    var selectedCateList:[String] = []
    var selectedAreaList:[String] = []
    var blockUserList:[String] = []
    var blockItemList:[String] = []
    var favorList:[String] = []
    let indicator = UIActivityIndicatorView()
    var cellArea = ""
    var cellCate = ""
    var cellPrice = ""
    let gradientLayer = CAGradientLayer()
    var myUid = ""
    var blockFlag = 0
    var countIndex = 0
    var sortNum = 0
    var countDBs: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        if let user = user {
            myUid = user.uid
        }
        showIndicator()
        ref1 = Database.database().reference()
        cellW = ((view.frame.width) / 2) - 15
        cellH = 250
        getInput()
        getInputBlock()
        SDImageCache.shared().clearDisk()
        SearchCollect.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(HomeViewController.refresh(sender:)), for: .valueChanged)
        setupFirebase()
        if getCate == "" {
            searchLabel.text = getArea
        } else {
            searchLabel.text = getCate
        }
        print("**** Search_screen")
    }
    
    func setupFirebase() {
        let ref2 = ref1.child("count")
        ref2.queryLimited(toLast: 1).observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            self.countDBs = value["countDB"] as? String ?? ""
            print("**** listen countDBs = \(self.countDBs)")
            self.SearchCollect.dataSource = self
            self.SearchCollect.delegate = self
            self.SearchCollect.allowsSelection = true
            self.indicator.stopAnimating()
        })
    }
    
    func getInput() {
        let ref3 = ref1.child("upload")
        ref3.observe(DataEventType.childAdded, with: { (snapshot) -> Void in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            let area2 = value["Area"] as? String ?? ""
            let category2 = value["item category"] as? String ?? ""
            let price2 = value["item price"] as? String ?? ""
            let account2 = value["account number"] as? String ?? ""
            self.areaList.append(area2)
            self.cateList.append(category2)
            self.priceList.append(price2)
            self.accountList.append(account2)
            self.countIndex += 1
            if self.getCate != "" {
                if self.getCate == category2 {
                    self.selectedCateList.append(String(self.countIndex))
                }
            } else {
                if self.getArea == area2 {
                    self.selectedAreaList.append(String(self.countIndex))
                }
            }
        })
    }
    
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
    
    
    @objc func refresh(sender: UIRefreshControl) {
        SDImageCache.shared().clearDisk()
        SDImageCache.shared().clearMemory()
        SearchCollect.reloadData()
        sender.endRefreshing()
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

extension SearchCollectViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int {
        if getCate != "" {
            return selectedCateList.count
        } else {
            return selectedAreaList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
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
        let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x:0, y:0, width:cellW, height:cellH)
        imageView.clipsToBounds = true
        
        let path = UIBezierPath(roundedRect: imageView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight, .topLeft, .topRight], cornerRadii: CGSize(width: 7, height: 7))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        imageView.layer.mask = mask
        
        if getCate != "" {
            let tempNum = (selectedCateList.count - indexPath.row) - 1
            sortNum = Int(selectedCateList[tempNum])!
        } else {
            let tempNum = (selectedAreaList.count - indexPath.row) - 1
            sortNum = Int(selectedAreaList[tempNum])!
        }
        print("**** sortNum \(sortNum)")
        let fileName = "images/sample\(sortNum).jpg"
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://frogment-ccf72.appspot.com")
        let reference = storageRef.child(fileName)
        let placeholderImage = UIImage(named: "loading05")
        let blockTemp = accountList[sortNum-1]
        
        if blockUserList.contains(blockTemp) {
            imageView.image = UIImage(named: "Blocked03")
        } else {
            imageView.sd_setImage(with: reference, placeholderImage: placeholderImage) { data, error, _, _ in
                if let error = error {
                    print("**** error \(error)")
                } else {
                }
            }
        }
        
        let label = testCell.contentView.viewWithTag(2) as! UILabel
        
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
        
        var tempNum2 = 0
        if getCate != "" {
            let tempNum3 = (selectedCateList.count - indexPath.row) - 1
            tempNum2 = Int(selectedCateList[tempNum3])!
        } else {
            let tempNum3 = (selectedAreaList.count - indexPath.row) - 1
            tempNum2 = Int(selectedAreaList[tempNum3])!
        }
        selectedCount = String(tempNum2)
        if blockUserList.contains(accountList[tempNum2-1]) {
            blockFlag = 1
        } else {
            blockFlag = 0
        }
        selectedref = "images/sample\(selectedCount).jpg"
        print("**** selected index = \(selectedref)")
        getInfo(count:selectedCount)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toDetailViewController2") {
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
            dtVC.myUid = myUid
            dtVC.blockFlag = blockFlag
            print("**** segue > \(selectedref),\(selectedCount),\(itemTitle)")
        }
    }
    
    func getInfo(count:String) {
        let ref2 = ref1.child("upload/\(count)")
        ref2.queryLimited(toLast: 12).observe(DataEventType.value, with: { (snapshot) in
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
            
            self.performSegue(withIdentifier: "toDetailViewController2",sender: nil)
        })
    }
    
}
