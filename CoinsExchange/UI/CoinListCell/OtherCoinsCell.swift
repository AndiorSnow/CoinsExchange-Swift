//
//  OtherCoinsCell.swift
//  CoinsExchange
//
//  Created by LMC60018 on 2024/1/23.
//

import Foundation
import UIKit

class OtherCoinsCell: UITableViewCell {
    
    @IBOutlet weak var otherCoinsView: UIView!
    @IBOutlet weak var coinIcon: UIImageView!
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var coinSymbolLabel: UILabel!
    @IBOutlet weak var coinPriceLabel: UILabel!
    @IBOutlet weak var coinChangeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUpCell(with coin: Coin) {
        backgroundColor = .clear
        otherCoinsView.backgroundColor = UIColor(rgb: 0xF9F9F9)
        otherCoinsView.clipsToBounds = false
        otherCoinsView.layer.cornerRadius = 8
        otherCoinsView.layer.shadowOffset = CGSize(width: 0, height: 2)
        otherCoinsView.layer.shadowColor = UIColor(white: 000000, alpha: 0.1).cgColor
        otherCoinsView.layer.shadowRadius = 8
        otherCoinsView.layer.masksToBounds = false
        
        if let rawUrl = coin.iconUrl,
           let url = URL(string: rawUrl.replacingOccurrences(of: ".svg", with: ".png")) {
            coinIcon.setImage(url)
        }
        coinIcon.layer.masksToBounds = true
        
        coinNameLabel.text = coin.name ?? ""
        coinNameLabel.textColor = UIColor(rgb: 0x333333)
        coinNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        coinNameLabel.textAlignment = .left
        coinNameLabel.numberOfLines = 1
        coinNameLabel.lineBreakMode = .byTruncatingTail
//        coinNameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//        coinNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        coinSymbolLabel.text = coin.symbol ?? ""
        coinSymbolLabel.textColor = UIColor(rgb: 0x999999)
        coinSymbolLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        coinSymbolLabel.textAlignment = .left
        
        coinPriceLabel.text = coin.price?.to5Decimal ?? ""
        coinPriceLabel.textColor = UIColor(rgb: 0x333333)
        coinPriceLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        coinPriceLabel.textAlignment = .right
        
        let attachment = NSTextAttachment()
        let attrMub = NSMutableAttributedString()
        let font = UIFont.systemFont(ofSize: 12, weight: .bold)
        if let changeString = coin.change, let changeDouble = Double(changeString) {
            if changeDouble > 0 {
                let img = UIImage(systemName: "arrow.up")?.withTintColor(UIColor(rgb: 0x13BC24))
                attachment.image = img
                attachment.bounds = CGRect(x: 0, y: 0, width: 12, height: 12)
                let attrImage = NSAttributedString(attachment: attachment)
                let attrStr = NSAttributedString(string: " " + (coin.change?.to2Decimal ?? ""), attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: UIColor(rgb: 0x13BC24)])
                attrMub.append(attrImage)
                attrMub.append(attrStr)
            } else {
                let img = UIImage(systemName: "arrow.down")?.withTintColor(UIColor(rgb: 0xF82D2D))
                attachment.image = img
                attachment.bounds = CGRect(x: 0, y: 0, width: 12, height: 12)
                let attrImage = NSAttributedString(attachment: attachment)
                let attrStr = NSAttributedString(string: " " + (coin.change?.to2Decimal ?? ""), attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: UIColor(rgb: 0xF82D2D)])
                attrMub.append(attrImage)
                attrMub.append(attrStr)
            }
        }
        coinChangeLabel.attributedText = attrMub
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
