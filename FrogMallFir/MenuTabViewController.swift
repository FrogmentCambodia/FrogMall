//
//  MenuTabViewController.swift
//  FrogMallFir
//
//  Created by 阿瀬義弘 on 2018/08/26.
//  Copyright © 2018年 Frogment. All rights reserved.
//

import UIKit
import MessageUI
import Firebase
import FirebaseUI
import FirebaseStorage

class MenuTabViewController: UIViewController, MFMailComposeViewControllerDelegate  {
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuTopView: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    var uid = ""
    var email = ""
    var photoURL:URL!
    var userName = ""
    var storage = Storage.storage()
    var menuTableView:UITableView!
    var selectedMenu = ""
    let cellMenu = ["Setting", "Contact us", "Terms of Use", "Privacy policy", "My item list", "Log out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = Auth.auth().currentUser
        if let user = user {
            uid = user.uid
            email = user.email!
            photoURL = user.photoURL
            userName = user.displayName!
        }
        let topImage = UIImage(named: "background7")
        menuTopView.image = topImage
        SDImageCache.shared.clearDisk()
        SDImageCache.shared.clearMemory()
        getAccountImage()
        userImage.contentMode = .scaleAspectFill
        userImage.clipsToBounds = true
        userImage.layer.cornerRadius = userImage.frame.height / 2.0
        userLabel.text = userName
        let blurEffect = UIBlurEffect(style: .light)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = self.menuTopView.frame
        self.menuTopView.addSubview(visualEffectView)
        
        menuTableView = UITableView(frame: CGRect(x: 0, y: menuTopView.frame.maxY, width: menuView.frame.width, height: 280), style: .plain)
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.isScrollEnabled = false
        menuTableView.separatorColor = UIColor.darkGray
        self.menuView.addSubview(menuTableView)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let menuPos = self.menuView.layer.position
        self.menuView.layer.position.x = -self.menuView.frame.width
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.menuView.layer.position.x = menuPos.x
            },completion: { bool in })
    }
    
    // Get profile image
    func getAccountImage() {
        let storageRef = storage.reference(forURL: "gs://frogment-ccf72.appspot.com")
        let imageRef = storageRef.child("account/\(uid)")
        let reference = imageRef.child("AccountImage_" + (uid) + ".jpg")
        let placeholderImage = UIImage(named: "NoImage2")
        self.userImage.sd_setImage(with: reference, placeholderImage: placeholderImage) { data, error, _, _ in
            if let error = error {
                print("**** getAccountImage_ error")
                print(error)
                if self.photoURL != nil {
                    self.userImage.sd_setImage(with: self.photoURL)
                } else {
                    print("**** no photoURL")
                }
            } else {
                print("**** getAccountImage01_ success")
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch.view?.tag == 1 {
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    options: .curveEaseIn,
                    animations: {
                        self.menuView.layer.position.x = -self.menuView.frame.width
                },completion: { bool in
                    self.dismiss(animated: true, completion: nil)
                }
                )
            }
        }
    }
    
    // Prepare for E-mail to send
    func sendMail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["frogment.cambodia@gmail.com"])
            mail.setSubject("[FrogMall:Help]")
            mail.setMessageBody("--------------------------------------\n\n\n\n\n\n\n\n--------------------------------------\n\n\n\nID : \(uid)\n\nFrogMall", isHTML: false)
            present(mail, animated: true, completion: nil)
        } else {
            print("**** Mail Error")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("cancelled")
        case .saved:
            print("saved")
        case .sent:
            print("sent")
        default:
            print("failed")
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


extension MenuTabViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellMenu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let cellData = cellMenu[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = cellData
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if cellMenu[indexPath.row] == "Contact us" {
            sendMail()
        }else if cellMenu[indexPath.row] == "Setting" {
            performSegue(withIdentifier: "toProfile",sender: nil)
        }else if cellMenu[indexPath.row] == "Log out" {
            let authUI = FUIAuth.defaultAuthUI()
            do {
                try authUI?.signOut()
                performSegue(withIdentifier: "BackToHomeS6",sender: nil)
                print("**** signOut")
            } catch {
                print("**** signOut Error")
            }
        }else if (cellMenu[indexPath.row] == "Terms of Use")||(cellMenu[indexPath.row] == "Privacy policy") {
            selectedMenu = cellMenu[indexPath.row]
            performSegue(withIdentifier: "ToMenuDetail",sender: nil)
        }else if cellMenu[indexPath.row] == "My item list" {
            performSegue(withIdentifier: "toMyItemList",sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "ToMenuDetail") {
            let MDVC: MenuDetailViewController = (segue.destination as? MenuDetailViewController)!
            MDVC.getCell = selectedMenu
        } else if (segue.identifier == "toProfile") {
            let PVC: ProfileViewController = (segue.destination as? ProfileViewController)!
            PVC.uid = uid
            PVC.email = email
            PVC.photoURL = photoURL
            PVC.userName = userName
        }
    }

}
