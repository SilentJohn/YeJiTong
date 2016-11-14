//
//  MessageTableViewCell.swift
//  SwiftProject
//
//  Created by IOS on 2016/10/27.
//  Copyright © 2016年 IOS. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var imgHeadIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblBrief: UILabel!
    
    var messageModel: MessageModel? {
        didSet {
            lblTitle.text = messageModel?.senderTitle
            lblTime.text = messageModel?.sendTime
            lblBrief.text = messageModel?.messageContent
//            NetRequestManager.shared.sen
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgHeadIcon.layer.cornerRadius = imgHeadIcon.bounds.width / 2.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
