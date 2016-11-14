//
//  MessageOtherCell.swift
//  SwiftProject
//
//  Created by IOS on 2016/11/9.
//  Copyright © 2016年 IOS. All rights reserved.
//

import UIKit
import SnapKit

class MessageOtherCell: UITableViewCell {
    var model: MessageModel? {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let messageDate = dateFormatter.date(from: (model?.sendTime)!)
            if let today = dateFormatter.date(from: dateFormatter.string(from: Date())) {
                if messageDate?.compare(today) == .orderedSame {
                    if let timeIndex = model?.sendTime.index((model?.sendTime.startIndex)!, offsetBy: 11) {
                        lblTime.text = model?.sendTime.substring(from: timeIndex)
                    }
                }
            }
            
        }
    }
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgHead: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewContent: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgHead.layer.cornerRadius = imgHead.bounds.width / 2
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
