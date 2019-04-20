//
//  MyTextField.swift
//  FrogMallFir
//
//  Created by 阿瀬義弘 on 2018/08/23.
//  Copyright © 2018年 Frogment. All rights reserved.
//

import UIKit

@IBDesignable class PaddingTextField: UITextField {
    // MARK: Properties
    
    /// テキストの内側の余白
    @IBInspectable var padding: CGPoint = CGPoint(x: 6.0, y: 0.0)
    
    // MARK: Internal Methods
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        // テキストの内側に余白を設ける
        return bounds.insetBy(dx: self.padding.x, dy: self.padding.y)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        // 入力中のテキストの内側に余白を設ける
        return bounds.insetBy(dx: self.padding.x, dy: self.padding.y)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        // プレースホルダーの内側に余白を設ける
        return bounds.insetBy(dx: self.padding.x, dy: self.padding.y)
    }
}
