//
//  ChatViewController.swift
//  FrogMallFir
//
//  Created by 阿瀬義弘 on 2018/05/26.
//  Copyright © 2018年 Frogment. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    
    var ref0: DatabaseReference!
    // Property for message
    var messages: [JSQMessage]?
    // Property for background image
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    // Property for account image
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvatar: JSQMessagesAvatarImage!
    var tabMSGBarStart: CGFloat!
    var disName = ""
    var myUid = ""
    var yourUid = ""
    var navigationBar = UINavigationBar()
    var msgCount = 0
    var readCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        addTopView()
        self.edgesForExtendedLayout = []
        extendedLayoutIncludesOpaqueBars = true
        collectionView.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 200/255, alpha: 0.15)

        // Set up for clean up tool bar
        inputToolbar!.contentView!.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        
        // Set up for senderId, senderDisplayName
        self.senderId = myUid
        self.senderDisplayName = yourUid
        
        // Set up for babbles
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor(red: 209/255, green: 209/255, blue: 209/255, alpha: 1))
        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor(red: 112/255, green: 192/255, blue:  75/255, alpha: 1))

        // Property for account image
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "account")!, diameter: 64)
        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "account")!, diameter: 64)

        self.messages = []
        setupFirebase()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationBar.frame.size.width = view.frame.size.width
        super.view.backgroundColor = UIColor.white
    }

    func addTopView() {
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height:70))
        let topView2 = UIView(frame: CGRect(x: 0, y: 70, width: view.frame.size.width, height:1))
        topView.backgroundColor = UIColor.white
        topView2.backgroundColor = UIColor.lightGray
        self.view.addSubview(topView)
        self.view.addSubview(topView2)
        
        let button = UIButton(type: UIButtonType.system)
        button.addTarget(self, action: #selector(btn_clicked(_:)), for: UIControlEvents.touchUpInside)
        button.setTitle("Back", for: UIControlState.normal)
        button.sizeToFit()
        button.frame = CGRect(x:10, y:40, width:70, height:30)
        topView.addSubview(button)
        
        let chatLabel = UILabel()
        chatLabel.text = "Message"
        chatLabel.textColor = UIColor.darkGray
        chatLabel.frame = CGRect(x: self.view.frame.size.width/2-40, y: 40, width: 70, height:30)
        topView.addSubview(chatLabel)
    }

    func addNavBar() {
        navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 30, width: view.frame.size.width, height:120))

        navigationBar.barTintColor = UIColor.white
        navigationBar.tintColor = UIColor.black
        navigationBar.titleTextAttributes = [.foregroundColor:UIColor.gray]
        let navigationItem = UINavigationItem()
        navigationItem.title = "Message"
        let leftButton =  UIBarButtonItem(title: "Back", style:   .plain, target: self, action: #selector(btn_clicked(_:)))
        navigationItem.leftBarButtonItem = leftButton
        navigationBar.items = [navigationItem]
        self.view.addSubview(navigationBar)
    }
    
    @objc func btn_clicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func setupFirebase() {
        ref0 = Database.database().reference()
        let ref = ref0.child("message/\(disName)")
        ref.queryLimited(toLast: 1000).observe(DataEventType.childAdded, with: { (snapshot) -> Void in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            let text = value["text"] as? String ?? ""
            let sender = value["from"] as? String ?? ""
            let name = value["name"] as? String ?? ""
            let message = JSQMessage(senderId: sender, displayName: name, text: text)
            self.messages?.append(message!)
            self.finishSendingMessage()
            
            self.readCount += 1
            let tempCount = String(self.readCount)
            let post3 = ["readCount": tempCount]
            let ref4 = self.ref0.child("chatList/\(self.myUid)/\(self.disName)")
            ref4.updateChildValues(post3)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref0.child("message/\(disName)").removeAllObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Method when send button is pushued
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        
        //Complete to send messeage
        self.finishReceivingMessage(animated: true)
        
        //Update firebase DB
        let post1 = ["from": senderId, "name": senderDisplayName, "text":text]
        let post1Ref = ref0.child("message/\(disName)").childByAutoId()
        post1Ref.setValue(post1)
        self.finishSendingMessage(animated: true)
        
        let post2 = ["LastMSG": text]
        let ref2 = ref0.child("chatList/\(myUid)/\(disName)")
        ref2.updateChildValues(post2)
        let ref3 = ref0.child("chatList/\(yourUid)/\(disName)")
        ref3.updateChildValues(post2)
        
        let tempCount2 = String(self.readCount+1)
        let post4 = ["msgCount": tempCount2]
        ref2.updateChildValues(post4)
        ref3.updateChildValues(post4)

        self.view.endEditing(true)
    }
    
    // Return message data
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        collectionView.frame = (CGRect(x: 0, y: 70, width:self.view.frame.width , height: self.view.frame.height-70))
        return messages![indexPath.item]
    }
    
    // Return message babbles
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingBubble
        }
        return self.incomingBubble
    }
    
    // Return account image
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingAvatar
        }
        return self.incomingAvatar
    }
    
    // Return number of item
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages!.count
    }
}
