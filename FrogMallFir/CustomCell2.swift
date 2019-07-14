//
//  CustomCell2.swift
//  Frog Mall
//
//  Created by 阿瀬義弘 on 2018/11/10.
//  Copyright © 2018年 Frogment. All rights reserved.
//

import UIKit

protocol CellDelegate {
    func sellButton2(_: Int)
}

class CustomCell2: UITableViewCell {
    
    var delegate: CellDelegate!
    var indexPath = IndexPath()
    
    @IBOutlet weak var sellImage: UIImageView!
    @IBOutlet weak var sellTitle: UILabel!
    @IBOutlet weak var sellCate: UILabel!
    @IBAction func sellButton(_ sender: Any) {
        delegate.sellButton2(indexPath.row)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
