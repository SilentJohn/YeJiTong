//
//  LoginTextField.swift
//  SwiftProject
//
//  Created by IOS on 2016/10/20.
//  Copyright © 2016年 IOS. All rights reserved.
//

import UIKit

@IBDesignable
class LoginTextField: UITextField {
    @IBInspectable var leftImageName: String? {
        didSet {
            self.leftViewMode = .always
            if leftImageName != nil {
                let leftView = UIImageView(image: UIImage(named: leftImageName!))
                leftView.bounds = CGRect(x: 0, y: 0, width: 32, height: 32)
                self.leftView = leftView
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    init(frame: CGRect, leftImageName: String) {
        super.init(frame: frame)
        self.borderStyle = .none
        self.leftImageName = leftImageName
        self.setNeedsDisplay()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    convenience init(leftImageName: String) {
        self.init(frame: CGRect.zero, leftImageName: leftImageName)
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let path = UIBezierPath()
        path.lineWidth = 1
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        UIColor.gray.setStroke()
        path.stroke()
        super.draw(rect)
    }
    

}
