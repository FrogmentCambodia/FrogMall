//
//  CustomCell.swift
//  Frog Mall
//
//  Created by 阿瀬義弘 on 2018/09/16.
//  Copyright © 2018年 Frogment. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var cusImage: UIImageView!
    @IBOutlet weak var cusItem: UILabel!
    @IBOutlet weak var cusName: UILabel!
    @IBOutlet weak var cusMsg: UILabel!
    @IBOutlet weak var cusGreen: UIImageView!
    @IBOutlet weak var cusCount: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
