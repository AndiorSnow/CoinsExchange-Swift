//
//  InviteFriendCell.swift
//  CoinsExchange
//
//  Created by LMC60018 on 2024/1/30.
//

import UIKit

class InviteFriendCell: UITableViewCell {
    
    @IBOutlet weak var inviteFriendView: UIView!
    @IBOutlet weak var inviteView: UIView!
    @IBOutlet weak var inviteIcon: UIImageView!
    @IBOutlet weak var inviteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUpCell() {
        backgroundColor = .clear
        inviteFriendView.backgroundColor = UIColor(rgb: 0xC5E6FF)
        inviteFriendView.clipsToBounds = false
        inviteFriendView.layer.cornerRadius = 8
        inviteFriendView.layer.masksToBounds = false
        
        inviteView.backgroundColor = UIColor(rgb: 0xF9F9F9)
        inviteView.layer.cornerRadius = inviteView.bounds.size.width / 2
        
        inviteIcon.image = UIImage(named: "share")
        inviteIcon.layer.masksToBounds = true
        
        let attrStr = NSMutableAttributedString(string: "You can earn $10  when you invite a friend to buy crypto. Invite your friend")
        attrStr.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: 58))
        attrStr.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: NSRange(location: 58, length: 18))
        attrStr.addAttribute(.foregroundColor, value: UIColor(rgb: 0x38A0FF), range: NSRange(location: 58, length: 18))
        inviteLabel.numberOfLines = 0
        inviteLabel.attributedText = attrStr
    }
}
