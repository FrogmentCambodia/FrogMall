//
//  SearchCategoryViewController.swift
//  Frog Mall
//
//  Created by 阿瀬義弘 on 2018/11/16.
//  Copyright © 2018年 Frogment. All rights reserved.
//

import UIKit
import Firebase

class SearchCategoryViewController: UIViewController {

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBAction func backBT(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var categoryLabel: UILabel!
    var cellX = 0
    var cellY = 0
    var cellW:CGFloat = 0
    var cellH:CGFloat = 0
    var setCell3 = ""
    var fromVC = ""
    let reuseIdentifier = "reuseIdentifier"
    let imageNameList = ["search_hat", "search_t-shirt", "search_long shirts", "search_onepiece", "search_pants", "search_shorts-pants", "search_skirt", "search_sneakers", "search_tote-bag", "search_phone", "search_lip", "search_watch", "search_neck", "search_belt", "search_other"]
    let categoryList = ["Hat/Cap", "T-shirt/shirt", "Long shirt", "Dress", "Pants", "Shorts-pants", "Skirt", "Shoes/Heel", "Bag", "Phone", "Cosmetics", "Watch", "Accessories", "Ring", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cellW = (view.frame.width - 81) / 3
        cellH = 250
        
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.allowsSelection = true
    }
}


extension SearchCategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //space -> (top , left , bottom , right)
        return UIEdgeInsetsMake(15,15,15,15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellW, height: cellW)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let testCell2:UICollectionViewCell =
            collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                               for: indexPath)
        let imageView = testCell2.contentView.viewWithTag(1) as! UIImageView
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x:0, y:0, width:cellW, height:cellW)
        imageView.clipsToBounds = true
        
        let path = UIBezierPath(roundedRect: imageView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight, .topLeft, .topRight], cornerRadii: CGSize(width: 50, height: 50))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        imageView.layer.mask = mask
 
        
        let imageName = imageNameList[indexPath.row]
        imageView.image = UIImage(named: imageName)
        return testCell2

    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setCell3 = categoryList[indexPath.row]
        print("**** selected index = \(setCell3), \(indexPath.row)")
        if fromVC != "FromUpload" {
            self.performSegue(withIdentifier: "ToSearchFromCate", sender: nil)
        } else if fromVC == "FromUpload" {
            self.performSegue(withIdentifier: "myRewindSegue2", sender: nil)
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "ToSearchFromCate") {
            let TSFC: SearchCollectViewController = (segue.destination as? SearchCollectViewController)!
            TSFC.getCate = setCell3
            TSFC.getArea = ""
        } else if (segue.identifier == "myRewindSegue2") {
            let UPVC: UploadViewController = (segue.destination as? UploadViewController)!
            
            UPVC.section00 = [setCell3]
            UPVC.reloadCell()
        }
    }

    
}
