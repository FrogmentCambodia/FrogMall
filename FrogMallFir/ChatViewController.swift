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
    // メッセージ内容に関するプロパティ
    var messages: [JSQMessage]?
    // 背景画像に関するプロパティ
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    // アバター画像に関するプロパティ
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
        addNavBar()
        self.edgesForExtendedLayout = []
        extendedLayoutIncludesOpaqueBars = true
/*
        let imageView = UIImageView()
        let image = UIImage(named: "background3")
        imageView.image = image
        self.collectionView.backgroundView = imageView
*/
        // クリーンアップツールバーの設定
        inputToolbar!.contentView!.leftBarButtonItem = nil
        // 新しいメッセージを受信するたびに下にスクロールする
        automaticallyScrollsToMostRecentMessage = true
        
        // 自分のsenderId, senderDisplayNameを設定
        self.senderId = myUid
        self.senderDisplayName = yourUid
        
        // 吹き出しの設定
        let bubbleFactory = JSQMessagesBubbleImageFactory()
/*
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
*/
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor(red: 209/255, green: 209/255, blue: 209/255, alpha: 1))
        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor(red: 112/255, green: 192/255, blue:  75/255, alpha: 1))

        // アバターの設定
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "account")!, diameter: 64)
        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "account")!, diameter: 64)
//        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: senderId, backgroundColor: UIColor.lightGray, textColor: UIColor.white, font: UIFont.systemFont(ofSize: 10), diameter: 30)

        self.messages = []
        setupFirebase()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationBar.frame.size.width = view.frame.size.width
    }
    
    func addTopView() {
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height:30))
        topView.backgroundColor = UIColor.white
        self.view.addSubview(topView)
    }
    
    func addNavBar() {
        navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 35, width: view.frame.size.width, height:90))

        navigationBar.barTintColor = UIColor.black
        navigationBar.tintColor = UIColor.white
        navigationBar.titleTextAttributes = [.foregroundColor:UIColor.white]
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
/*
            let snapshotValue = snapshot.value as! NSDictionary
            let text = snapshotValue["text"] as! String
            let sender = snapshotValue["from"] as! String
            let name = snapshotValue["name"] as! String
            print(snapshot.value!)
*/
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
    
    // Sendボタンが押された時に呼ばれるメソッド
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        
        //メッセージの送信処理を完了する(画面上にメッセージが表示される)
        self.finishReceivingMessage(animated: true)
        
        //firebaseにデータを送信、保存する
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

        //キーボードを閉じる
        self.view.endEditing(true)
    }
    
    // アイテムごとに参照するメッセージデータを返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
//        collectionView.frame.origin.y = 60
        collectionView.frame = (CGRect(x: 0, y: 70, width:self.view.frame.width , height: self.view.frame.height-70))
        return messages![indexPath.item]
    }
    
    // アイテムごとのMessageBubble(背景)を返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingBubble
        }
        return self.incomingBubble
    }
    
    // アイテムごとにアバター画像を返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingAvatar
        }
        return self.incomingAvatar
    }
    
    // アイテムの総数を返す
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages!.count
    }
    

/*    var messages: [JSQMessage] = [
        JSQMessage(senderId: "Tsuru", displayName: "tsuru", text: "こんにちは！"),
        JSQMessage(senderId: "Gami", displayName: "gami", text: "こんにちは！！")
    ]
 
    override func viewDidLoad() {
        super.viewDidLoad()
        senderDisplayName = "tsuru"
        senderId = "Tsuru"
        self.edgesForExtendedLayout = []
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        inputToolbar.contentView.textView.text = ""
        let ref = Database.database().reference()
        ref.child("messages").childByAutoId().setValue(["senderId": senderId, "text": text, "displayName": senderDisplayName])
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    // コメントの背景色の指定
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        if messages[indexPath.row].senderId == senderId {
            return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor(red: 112/255, green: 192/255, blue:  75/255, alpha: 1))
        } else {
            return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1))
        }
    }
    
    // コメントの文字色の指定
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        if messages[indexPath.row].senderId == senderId {
            cell.textView.textColor = UIColor.white
        } else {
            cell.textView.textColor = UIColor.darkGray
        }
        return cell
    }
    
    // メッセージの数
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    // ユーザのアバターの設定
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return JSQMessagesAvatarImageFactory.avatarImage(
            withUserInitials: messages[indexPath.row].senderDisplayName,
            backgroundColor: UIColor.lightGray,
            textColor: UIColor.white,
            font: UIFont.systemFont(ofSize: 10),
            diameter: 30)
    }
 */

}
